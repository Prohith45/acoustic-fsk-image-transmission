%% EXTENSION B: ERROR-CONTROL CHANNEL CODING COMPARISON
% Project: Acoustic Binary FSK Image Transmission
% Description: Evaluates and compares Uncoded FSK against Repetition(3) and
% Hamming(7,4) forward error correction (FEC) codes using pure base MATLAB.

function extension_b_channel_coding()
clc; close all;

fprintf('=================================================================\n');
fprintf('   EXTENSION B: FORWARD ERROR CORRECTION (FEC) CODING           \n');
fprintf('   Comparing: Uncoded vs Repetition(3) vs Hamming(7,4)          \n');
fprintf('=================================================================\n\n');

%% ---------------- 1. Parameters ----------------
Fs      = 48000;          % sampling rate (Hz)
Rb      = 400;            % bit rate (bps)
f0      = 2000;           % tone for bit 0 (Hz)
f1      = 3200;           % tone for bit 1 (Hz)
sps     = Fs / Rb;        % samples per bit (120)
imgSize = [32 32];        % image size (32x32 = 8192 info bits)

% SNR sweep for BER curves (dB)
snrValues = 0:2:12;

%% ---------------- 2. Load and Prepare Image ----------------
if exist('image.jpg', 'file')
    imgName = 'image.jpg';
elseif exist('image.png', 'file')
    imgName = 'image.png';
elseif exist('lion.jpg', 'file')
    imgName = 'image.jpg';
    if ~exist(imgName, 'file'), imgName = 'lion.jpg'; end
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
    [X, Y] = meshgrid(1:imgSize(2), 1:imgSize(1));
    img = uint8(128 + 100*sin(X/4) .* cos(Y/4));
end

infoBits = reshape((dec2bin(img(:), 8) - '0').', [], 1);
nInfo = numel(infoBits);

%% ---------------- 3. Channel Encoders ----------------
fprintf('Encoding %d information bits...\n', nInfo);

% (a) Repetition(3) Code: 1 bit -> 3 identical bits (Rate = 1/3)
repBits = repmat(infoBits.', 3, 1);
repBits = repBits(:);

% (b) Systematic Hamming(7,4) Code: 4 info bits -> 7 coded bits (Rate = 4/7)
% Generator Matrix G = [I4 | P]
G = [1 0 0 0 1 1 0;
     0 1 0 0 1 0 1;
     0 0 1 0 0 1 1;
     0 0 0 1 1 1 1];

% Parity Check Matrix H = [P' | I3]
H = [1 1 0 1 1 0 0;
     1 0 1 1 0 1 0;
     0 1 1 1 0 0 1];

% Reshape info bits into 4-bit blocks
padHam = mod(-nInfo, 4);
infoPaddedHam = [infoBits; zeros(padHam, 1)];
msgBlocks = reshape(infoPaddedHam, 4, []).';
hamCodewords = mod(msgBlocks * G, 2);
hamBits = reshape(hamCodewords.', [], 1);

fprintf('Payload summary:\n');
fprintf('  Uncoded:        %d bits (Rate = 1.00)\n', nInfo);
fprintf('  Repetition(3):  %d bits (Rate = 0.33, overhead = +200%%)\n', numel(repBits));
fprintf('  Hamming(7,4):   %d bits (Rate = 0.57, overhead = +75%%)\n\n', numel(hamBits));

%% ---------------- 4. SNR Sweep Simulation ----------------
EbN0_values = 0:2:12; % Eb/N0 range in dB
berUncoded = zeros(size(EbN0_values));
berRep     = zeros(size(EbN0_values));
berHam     = zeros(size(EbN0_values));

% Sample image at test Eb/N0 = 6 dB to visually show error correction
sampleEbN0 = 6;
imgUncodedSample = [];
imgRepSample     = [];
imgHamSample     = [];

fprintf('Running Monte-Carlo AWGN simulation across Eb/N0 = 0 to 12 dB...\n');
fprintf('%-10s | %-15s | %-15s | %-15s\n', 'Eb/N0 (dB)', 'Uncoded BER', 'Rep(3) BER', 'Hamming(7,4) BER');
fprintf('-----------------------------------------------------------------------\n');

% FSK base signals for simulation
tb_sec = (0:sps-1)' / Fs;
s0 = sin(2*pi*f0*tb_sec);
s1 = sin(2*pi*f1*tb_sec);
E0 = exp(-1j*2*pi*f0*tb_sec);
E1 = exp(-1j*2*pi*f1*tb_sec);

for s = 1:numel(EbN0_values)
    ebno_dB = EbN0_values(s);
    
    % --- 1. Uncoded FSK ---
    rawRxUncoded = simFskChannel(infoBits, s0, s1, E0, E1, sps, ebno_dB);
    decUncoded = rawRxUncoded;
    nErrUncoded = sum(infoBits ~= decUncoded);
    berUncoded(s) = nErrUncoded / nInfo;
    
    % --- 2. Repetition(3) Coded FSK ---
    rawRxRep = simFskChannel(repBits, s0, s1, E0, E1, sps, ebno_dB);
    % Majority voting decoder: 3-bit blocks
    repBlocks = reshape(rawRxRep, 3, []);
    decRep = (sum(repBlocks, 1) >= 2).';
    nErrRep = sum(infoBits ~= decRep);
    berRep(s) = nErrRep / nInfo;
    
    % --- 3. Hamming(7,4) Coded FSK ---
    rawRxHam = simFskChannel(hamBits, s0, s1, E0, E1, sps, ebno_dB);
    % Syndrome decoder
    rxBlocksHam = reshape(rawRxHam, 7, []).';
    decBlocksHam = decodeHamming74(rxBlocksHam, H);
    decHamPadded = reshape(decBlocksHam.', [], 1);
    decHam = decHamPadded(1:nInfo);
    nErrHam = sum(infoBits ~= decHam);
    berHam(s) = nErrHam / nInfo;
    
    fprintf('%-10.1f | %-15.4e | %-15.4e | %-15.4e\n', ...
        ebno_dB, berUncoded(s), berRep(s), berHam(s));
    
    % Save sample images at sampleEbN0
    if ebno_dB == sampleEbN0
        imgUncodedSample = bitsToImg(decUncoded, imgSize);
        imgRepSample     = bitsToImg(decRep, imgSize);
        imgHamSample     = bitsToImg(decHam, imgSize);
    end
end
fprintf('=======================================================================\n\n');

%% ---------------- 5. Visualization & Comparison Plots ----------------
hFig = figure('Name', 'Extension B: FEC Coding Analysis', 'Color', 'w', 'Position', [100 100 1100 700]);

% Plot 1: BER vs Eb/N0 curves (Semilog)
subplot(2, 3, [1 2]);
semilogy(EbN0_values, max(berUncoded, 1e-4), 'ro-', 'LineWidth', 1.8, 'MarkerFaceColor', 'r'); hold on;
semilogy(EbN0_values, max(berRep, 1e-4),     'bs-', 'LineWidth', 1.8, 'MarkerFaceColor', 'b');
semilogy(EbN0_values, max(berHam, 1e-4),     'g^-', 'LineWidth', 1.8, 'MarkerFaceColor', [0 0.6 0]);
grid on; xlabel('E_b / N_0 (dB)'); ylabel('Information Bit Error Rate (BER)');
title('BER vs E_b/N_0: Uncoded vs Repetition(3) vs Hamming(7,4)');
legend({'Uncoded FSK', 'Repetition(3) (Rate 1/3)', 'Hamming(7,4) (Rate 4/7)'}, 'Location', 'southwest');
ylim([1e-4 1]);

% Plot 2: Code Rate Bar Chart
subplot(2, 3, 3);
bar([1, 4/7, 1/3], 0.5, 'FaceColor', [0.3 0.5 0.8]);
set(gca, 'XTickLabel', {'Uncoded', 'Hamming(7,4)', 'Rep(3)'});
ylabel('Code Rate (Info / Coded)'); title('Code Rate & Throughput Efficiency');
ylim([0 1.1]); grid on;

% Image 1: Original
subplot(2, 3, 4);
imshow(img); title('Original Transmitted');

% Image 2: Uncoded at sampleEbN0
subplot(2, 3, 5);
idxSample = find(EbN0_values == sampleEbN0, 1);
imshow(imgUncodedSample);
title(sprintf('Uncoded @ %d dB (BER = %.3f)', sampleEbN0, berUncoded(idxSample)));

% Image 3: Hamming(7,4) Coded at sampleEbN0
subplot(2, 3, 6);
imshow(imgHamSample);
title(sprintf('Hamming(7,4) @ %d dB (BER = %.3f)', sampleEbN0, berHam(idxSample)));

saveas(hFig, 'extension_b_results.png');
fprintf('Saved comparison figure to "extension_b_results.png".\n');
end

%% ---------------- Helper: Fast FSK Channel Simulation ----------------
function rxBits = simFskChannel(txBits, s0, s1, E0, E1, sps, ebno_dB)
    b = txBits.';
    tx = s0*(1 - b) + s1*b;
    
    % AWGN Channel calibrated to Eb/N0
    ebno = 10^(ebno_dB / 10);
    sigPower = 0.5; % mean power of sin wave is 0.5
    noiseVar = (sigPower * sps) / (2 * ebno);
    rx = tx + sqrt(noiseVar) * randn(size(tx));
    
    % Non-coherent quadrature energy demodulation
    e0 = abs(E0.' * rx);
    e1 = abs(E1.' * rx);
    rxBits = (e1 > e0).';
end

%% ---------------- Helper: Hamming(7,4) Syndrome Decoder ----------------
function decMsg = decodeHamming74(rxBlocks, H)
    % rxBlocks is K x 7
    % Syndrome S = mod(rxBlocks * H', 2) -> K x 3
    S = mod(rxBlocks * H.', 2);
    
    % Map syndrome 3-bit binary vector to decimal integer
    % Column patterns of H correspond to syndVals
    syndVals = S * [4; 2; 1];
    
    % Compute syndrome value for each of the 7 column positions of H
    hVals = H.' * [4; 2; 1];
    
    % Correct single bit errors
    corrected = rxBlocks;
    for k = 1:size(rxBlocks, 1)
        sVal = syndVals(k);
        if sVal > 0
            errPos = find(hVals == sVal, 1);
            if ~isempty(errPos)
                corrected(k, errPos) = 1 - corrected(k, errPos);
            end
        end
    end
    
    % Systematic code: information bits are the first 4 columns
    decMsg = corrected(:, 1:4);
end

%% ---------------- Helper: Bits to Image ----------------
function imgOut = bitsToImg(bVec, imgSize)
    bMat = reshape(bVec, 8, []).';
    pix = bMat * (2.^(7:-1:0))';
    imgOut = reshape(uint8(pix), imgSize);
end
