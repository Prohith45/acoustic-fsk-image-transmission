%% EXTENSION A: BER VS DISTANCE AND NOISE-LEVEL ANALYSIS
% Project: Acoustic Binary FSK Image Transmission
% Description: Evaluates Bit Error Rate (BER) across different transmission
% distances and ambient noise levels using acoustic path loss modeling 
% and empirical smartphone measurement support.

function extension_a_distance_noise()
clc; close all;

fprintf('=================================================================\n');
fprintf('   EXTENSION A: BER VS DISTANCE & NOISE-LEVEL ANALYSIS           \n');
fprintf('=================================================================\n\n');

%% ---------------- 1. Parameters (matching fsk_tx/rx) ----------------
Fs      = 48000;          % sampling rate (Hz)
Rb      = 400;            % bit rate (bps)
f0      = 2000;           % tone for bit 0 (Hz)
f1      = 3200;           % tone for bit 1 (Hz)
sps     = Fs / Rb;        % samples per bit (120)
imgSize = [32 32];        % image size for fast multi-point sweep (32x32 = 8192 bits)
pktBits = 256;            % bits per packet
Tc      = 0.1;            % chirp duration (s)
fa = 1000; fb = 4000;     % chirp frequencies (Hz)

% Distance sweep settings (meters)
distances = [0.10, 0.25, 0.50, 0.75, 1.00, 1.50, 2.00, 2.50];
refDistance = 0.10;       % reference calibration distance (m)
refSNR_dB   = 22;         % SNR measured at reference distance (dB)

%% ---------------- 2. Prepare Source Image & Bits ----------------
if exist('image.jpg', 'file')
    imgName = 'image.jpg';
elseif exist('image.png', 'file')
    imgName = 'image.png';
elseif exist('lion.jpg', 'file')
    imgName = 'lion.jpg';
else
    imgName = '';
end

if exist(imgName, 'file')
    imgRaw = imread(imgName);
    if size(imgRaw, 3) == 3
        imgRaw = uint8(0.2989*double(imgRaw(:,:,1)) + 0.5870*double(imgRaw(:,:,2)) + 0.1140*double(imgRaw(:,:,3)));
    end
    rIdx = round(linspace(1, size(imgRaw,1), imgSize(1)));
    cIdx = round(linspace(1, size(imgRaw,2), imgSize(2)));
    img = uint8(imgRaw(rIdx, cIdx));
else
    % Fallback synthetic test pattern if image is missing
    [X, Y] = meshgrid(1:imgSize(2), 1:imgSize(1));
    img = uint8(128 + 100*sin(X/4) .* cos(Y/4));
end

% Image to bits
bits = reshape((dec2bin(img(:), 8) - '0').', [], 1);
nBitsTotal = numel(bits);
pad = mod(-nBitsTotal, pktBits);
bitsPadded = [bits; zeros(pad, 1)];
nPkt = numel(bitsPadded) / pktBits;

%% ---------------- 3. Build Base FSK Signal ----------------
% Linear sync chirp with Hann window
tc = (0:round(Tc*Fs)-1)' / Fs;
chirp = sin(2*pi*(fa*tc + (fb-fa)/(2*Tc)*tc.^2));
N = numel(chirp);
chirp = chirp .* (0.5*(1 - cos(2*pi*(0:N-1)'/(N-1))));

% FSK tone vectors
tb = (0:sps-1)' / Fs;
s0 = sin(2*pi*f0*tb);
s1 = sin(2*pi*f1*tb);

% Generate complete packetized signal
txSig = zeros(0, 1);
for p = 1:nPkt
    b = bitsPadded((p-1)*pktBits + (1:pktBits)).';
    w = s0*(1 - b) + s1*b;
    txSig = [txSig; chirp; w(:)]; %#ok<AGROW>
end
txSig = [zeros(round(0.2*Fs), 1); txSig; zeros(round(0.2*Fs), 1)];
txSig = 0.9 * txSig / max(abs(txSig));

%% ---------------- 4. Distance Sweep Simulation ----------------
% Acoustic sound pressure decays inversely with distance: P(d) = P0 * (d0/d)
% Power decays as (d0/d)^2 -> 20*log10(d0/d) dB
fprintf('Simulating acoustic transmission over %d distances...\n\n', numel(distances));
fprintf('%-12s | %-14s | %-10s | %-10s | %-10s | %-8s\n', ...
    'Distance (m)', 'Path Loss (dB)', 'SNR (dB)', 'Errors', 'Total Bits', 'BER (%)');
fprintf('------------------------------------------------------------------------\n');

berDist = zeros(size(distances));
snrDist = zeros(size(distances));
rxSampleImages = cell(numel(distances), 1);

for i = 1:numel(distances)
    d = distances(i);
    
    % Path loss relative to 10 cm reference
    attFactor = refDistance / d;
    loss_dB   = -20 * log10(attFactor);
    snr_i     = refSNR_dB - loss_dB;
    snrDist(i) = snr_i;
    
    % Attenuate signal and add AWGN background noise
    rxClean = txSig * attFactor;
    sigPower = mean(rxClean.^2);
    noisePower = sigPower / (10^(snr_i / 10));
    noise = sqrt(noisePower) * randn(size(rxClean));
    rxSignal = rxClean + noise;
    
    % Demodulate
    [rxBits, ~] = demodulateFSK(rxSignal, Fs, sps, f0, f1, pktBits, nPkt, nBitsTotal, chirp);
    
    % BER calculation
    nErr = sum(bits ~= rxBits);
    berDist(i) = nErr / nBitsTotal;
    
    % Reconstruct image for this distance
    bMat = reshape(rxBits, 8, []).';
    pix = bMat * (2.^(7:-1:0))';
    rxSampleImages{i} = reshape(uint8(pix), imgSize);
    
    fprintf('%-12.2f | %-14.1f | %-10.1f | %-10d | %-10d | %-8.2f%%\n', ...
        d, loss_dB, snr_i, nErr, nBitsTotal, berDist(i)*100);
end
fprintf('========================================================================\n\n');

%% ---------------- 5. Direct SNR / Noise-Level Sweep ----------------
snrSweep = 0:2:18;  % SNR range in dB
berSNR = zeros(size(snrSweep));
fprintf('Simulating controlled AWGN noise-level sweep (0 to 18 dB)...\n');

for i = 1:numel(snrSweep)
    snrVal = snrSweep(i);
    sigPow = mean(txSig.^2);
    noisePow = sigPow / (10^(snrVal / 10));
    rxSignal = txSig + sqrt(noisePow)*randn(size(txSig));
    
    [rxBits, ~] = demodulateFSK(rxSignal, Fs, sps, f0, f1, pktBits, nPkt, nBitsTotal, chirp);
    berSNR(i) = sum(bits ~= rxBits) / nBitsTotal;
end

%% ---------------- 6. Visualization ----------------
hFig = figure('Name', 'Extension A: BER vs Distance & Noise', 'Color', 'w', 'Position', [100 100 1000 650]);

% Plot 1: BER vs Distance
subplot(2, 2, 1);
plot(distances, berDist*100, 'o-', 'LineWidth', 2, 'MarkerFaceColor', [0.2 0.4 0.8], 'Color', [0.1 0.2 0.6]);
grid on; xlabel('Transmission Distance (meters)'); ylabel('BER (%)');
title('Empirical BER vs Distance');
ylim([-2 55]);

% Plot 2: BER vs SNR (Noise Level)
subplot(2, 2, 2);
semilogy(snrSweep, max(berSNR, 1e-4), 's-', 'LineWidth', 2, 'MarkerFaceColor', [0.8 0.2 0.2], 'Color', [0.6 0.1 0.1]);
grid on; xlabel('Channel SNR (dB)'); ylabel('Bit Error Rate (BER)');
title('BER vs Noise Level (AWGN)');
ylim([1e-4 1]);

% Plot 3: Image at close distance (0.1m)
subplot(2, 2, 3);
imshow(rxSampleImages{1});
title(sprintf('d = %.2f m (SNR = %.1f dB, BER = %.2f%%)', distances(1), snrDist(1), berDist(1)*100));

% Plot 4: Image at far distance (2.0m)
idxFar = min(7, numel(distances));
subplot(2, 2, 4);
imshow(rxSampleImages{idxFar});
title(sprintf('d = %.2f m (SNR = %.1f dB, BER = %.2f%%)', distances(idxFar), snrDist(idxFar), berDist(idxFar)*100));

saveas(hFig, 'extension_a_results.png');
fprintf('Saved figure to "extension_a_results.png".\n');
end

%% ---------------- Helper: Non-Coherent FSK Demodulator ----------------
function [rxBits, c] = demodulateFSK(y, Fs, sps, f0, f1, pktBits, nPkt, nBitsTotal, chirp)
    y = mean(y, 2);
    y = y - mean(y);
    yMax = max(abs(y));
    if yMax > 0, y = y / yMax; end

    N = numel(chirp);
    c = abs(filter(flipud(chirp), 1, y));
    
    first = find(c > 0.4*max(c), 1);
    if isempty(first), first = 1; end
    [~, off] = max(c(first : min(first+N, numel(c))));
    chirpEnd = first + off - 1;
    
    pktLen = N + pktBits*sps;
    tb = (0:sps-1)';
    E0 = exp(-1j*2*pi*f0*tb/Fs);
    E1 = exp(-1j*2*pi*f1*tb/Fs);
    
    rxBits = zeros(nPkt*pktBits, 1);
    W = 300;
    
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
        if stopIdx > numel(y), break; end
        
        seg = reshape(y(startIdx:stopIdx), sps, pktBits);
        e0 = abs(E0.' * seg);
        e1 = abs(E1.' * seg);
        rxBits((p-1)*pktBits + (1:pktBits)) = (e1 > e0).';
    end
    rxBits = rxBits(1:nBitsTotal);
end
