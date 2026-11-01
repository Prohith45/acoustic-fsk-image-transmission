%% FSK IMAGE TRANSMITTER  (Image -> Bits -> FSK -> WAV)
clc; clear; close all;

%% ---------------- Parameters (must match fsk_rx.m) ----------------
Fs      = 48000;          % audio sampling rate (Hz)
Rb      = 400;            % bit rate (bits/sec)
f0      = 2000;           % tone for bit 0 (Hz)
f1      = 3200;           % tone for bit 1 (Hz)
sps     = Fs/Rb;          % samples per bit (120)

% Image resolution:
% [32 32] RGB -> ~61 seconds audio (recommended for quick phone testing)
% [64 64] RGB -> ~245 seconds audio (higher detail, longer playback)
imgSize = [32 32];        
pktBits = 256;            % bits per packet
Tc      = 0.1;            % sync chirp length (sec)
fa = 1000; fb = 4000;     % chirp start / end frequency (Hz)

%% ---------------- Image -> bits ----------------
% Check for available image file (prioritizes image.jpg, then image.png, then lion.jpg)
if exist('image.jpg', 'file')
    imgName = 'image.jpg';
elseif exist('image.png', 'file')
    imgName = 'image.png';
elseif exist('lion.jpg', 'file')
    imgName = 'lion.jpg';
else
    error('Image file not found! Place image.jpg (or image.png / lion.jpg) in the working directory.');
end
imgRaw = imread(imgName);

% Keep full RGB color channels if available
rIdx = round(linspace(1, size(imgRaw, 1), imgSize(1)));
cIdx = round(linspace(1, size(imgRaw, 2), imgSize(2)));

if size(imgRaw, 3) >= 3
    isColor = true;
    img = uint8(imgRaw(rIdx, cIdx, 1:3));
    fprintf('Loaded COLOR image: %s (%dx%d RGB)\n', imgName, imgSize(1), imgSize(2));
else
    isColor = false;
    img = uint8(imgRaw(rIdx, cIdx));
    fprintf('Loaded GRAYSCALE image: %s (%dx%d)\n', imgName, imgSize(1), imgSize(2));
end

% Serialize pixels to binary stream (8 bits per color component, MSB first)
bits = reshape((dec2bin(img(:), 8) - '0').', [], 1);
nBits = numel(bits);

% Pad so bits fit into whole packets
pad = mod(-nBits, pktBits);
bitsPadded = [bits; zeros(pad,1)];
nPkt = numel(bitsPadded)/pktBits;

%% ---------------- Sync chirp (start of every packet) ----------------
tc = (0:round(Tc*Fs)-1)'/Fs;
chirp = sin(2*pi*(fa*tc + (fb-fa)/(2*Tc)*tc.^2));
N = numel(chirp);
chirp = chirp .* (0.5*(1-cos(2*pi*(0:N-1)'/(N-1))));    % smooth window

%% ---------------- FSK modulation ----------------
tb = (0:sps-1)'/Fs;
s0 = sin(2*pi*f0*tb);
s1 = sin(2*pi*f1*tb);

x = zeros(0,1);
for p = 1:nPkt
    b = bitsPadded((p-1)*pktBits + (1:pktBits)).';      % 1 x pktBits
    w = s0*(1-b) + s1*b;                                % sps x pktBits
    x = [x; chirp; w(:)];                               %#ok<AGROW>
end
x = [zeros(Fs,1); x; zeros(Fs,1)];                      % 1 s silence at both ends
x = 0.9 * x / max(abs(x));

audiowrite('fsk_image.wav', x, Fs);
save('txdata.mat', 'bits', 'img', 'imgSize', 'isColor'); % used by receiver for BER and color display

fprintf('Bits: %d | Packets: %d | Duration: %.1f sec\n', nBits, nPkt, numel(x)/Fs);
fprintf('Saved fsk_image.wav -> play it on Phone 1.\n');

%% ---------------- Plots ----------------
figure;
subplot(2,2,1); imshow(img); title('Original image');
subplot(2,2,2); plot((0:3*sps*8-1)/Fs*1000, x(Fs+numel(chirp)+(1:3*sps*8)));
xlabel('ms'); title('FSK waveform (data part)');
subplot(2,2,[3 4]); spectrogram(x, 1024, 512, 1024, Fs, 'yaxis');
title('Spectrogram of transmitted signal'); ylim([0 6]);
