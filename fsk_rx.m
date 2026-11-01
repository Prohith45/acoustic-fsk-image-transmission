%% FSK IMAGE RECEIVER  (Recording -> Sync -> FSK demod -> Image)
clc; clear; close all;

%% ---------------- Parameters (must match fsk_tx.m) ----------------
Fs      = 48000;
Rb      = 400;
f0      = 2000;
f1      = 3200;
sps     = Fs/Rb;
imgSize = [64 64];
pktBits = 256;
Tc      = 0.1;
fa = 1000; fb = 4000;

recFile = 'received.mp3';     % <-- your phone recording (.m4a, .wav, .mp3)
if ~exist(recFile, 'file')
    if exist('received.wav', 'file')
        recFile = 'received.wav';
    elseif exist('fsk_image.wav', 'file')
        fprintf('"%s" not found. Using local "fsk_image.wav" for test/loopback.\n', recFile);
        recFile = 'fsk_image.wav';
    else
        error('Recording file "%s" not found! Place your phone recording in this folder.', recFile);
    end
end

%% ---------------- Load recording ----------------
[y, Fr] = audioread(recFile);
y = mean(y, 2);                        % to mono
if Fr ~= Fs, y = resample(y, Fs, Fr); end
y = y - mean(y);
y = y / max(abs(y));

%% ---------------- Rebuild the sync chirp ----------------
tc = (0:round(Tc*Fs)-1)'/Fs;
chirp = sin(2*pi*(fa*tc + (fb-fa)/(2*Tc)*tc.^2));
N = numel(chirp);
chirp = chirp .* (0.5*(1-cos(2*pi*(0:N-1)'/(N-1))));

% matched filter: output at index n = chirp ending at sample n
c = abs(filter(flipud(chirp), 1, y));

%% ---------------- Find first packet ----------------
first = find(c > 0.5*max(c), 1);
[~, off] = max(c(first : min(first+N, numel(c))));
chirpEnd = first + off - 1;

%% ---------------- Total packets & frame sizing ----------------
if exist('txdata.mat', 'file')
    txInfo = load('txdata.mat', 'imgSize', 'isColor', 'bits');
    imgSize = txInfo.imgSize;
    if isfield(txInfo, 'isColor')
        isColor = txInfo.isColor;
    else
        isColor = false;
    end
    nBitsTotal = numel(txInfo.bits);
else
    isColor = true; % default assumption
    nBitsTotal = imgSize(1) * imgSize(2) * 3 * 8;
end
nPkt = ceil(nBitsTotal/pktBits);
pktLen = N + pktBits*sps;              % samples per packet (nominal)

%% ---------------- Demodulate packet by packet ----------------
tb = (0:sps-1)';
E0 = exp(-1j*2*pi*f0*tb/Fs);
E1 = exp(-1j*2*pi*f1*tb/Fs);

rxBits = zeros(nPkt*pktBits, 1);
W = 300;                               % sync search window (samples) for clock drift

for p = 1:nPkt
    if p > 1
        expected = chirpEnd + pktLen;
        lo = max(expected - W, 1);
        hi = min(expected + W, numel(c));
        [~, o] = max(c(lo:hi));
        chirpEnd = lo + o - 1;
    end
    startIdx = chirpEnd + 1;
    stopIdx  = startIdx + pktBits*sps - 1;
    if stopIdx > numel(y)
        warning('Recording ended early at packet %d of %d.', p, nPkt);
        break;
    end
    seg = reshape(y(startIdx:stopIdx), sps, pktBits);
    e0 = abs(E0.' * seg);              % energy at f0
    e1 = abs(E1.' * seg);              % energy at f1
    rxBits((p-1)*pktBits + (1:pktBits)) = (e1 > e0).';
end
rxBits = rxBits(1:nBitsTotal);

%% ---------------- Bits -> image ----------------
b = reshape(rxBits, 8, []).';
pix = uint8(b * (2.^(7:-1:0))');

if isColor
    imgRx = reshape(pix(1:imgSize(1)*imgSize(2)*3), [imgSize(1), imgSize(2), 3]);
else
    imgRx = reshape(pix(1:imgSize(1)*imgSize(2)), imgSize);
end

%% ---------------- BER (if tx data is available) & Plots ----------------
figure('Name', 'FSK Receiver Results', 'NumberTitle', 'off');
if exist('txdata.mat', 'file')
    load('txdata.mat', 'bits', 'img');
    nErr = sum(bits ~= rxBits);
    BER = nErr / numel(bits);
    fprintf('Bit errors: %d / %d   |   BER = %.4f (%.2f%%)\n', nErr, numel(bits), BER, BER*100);
    
    subplot(2,2,1); imshow(img);   title('Original Transmitted Image');
    subplot(2,2,2); imshow(imgRx); title(sprintf('Received Image (BER = %.4f)', BER));
    
    % Error map: mean difference across color channels
    if isColor
        errMap = uint8(mean(abs(double(img) - double(imgRx)), 3));
    else
        errMap = uint8(abs(double(img) - double(imgRx)));
    end
    subplot(2,2,3); imshow(errMap, []); title('Error Map (Differences)');
    subplot(2,2,4); plot(c); title('Sync Correlation Output'); xlabel('Sample Index'); ylabel('Magnitude'); grid on;
else
    subplot(1,2,1); imshow(imgRx); title('Received Image');
    subplot(1,2,2); plot(c); title('Sync Correlation Output'); xlabel('Sample Index'); ylabel('Magnitude'); grid on;
end
imwrite(imgRx, 'received_image.png');
