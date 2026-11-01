%% EXTENSION C: DBPSK MODULATION & COMPARISON AGAINST FSK
% Project: Acoustic Binary FSK Image Transmission
% Description: Implements Differential Binary Phase Shift Keying (DBPSK)
% and compares it with Binary FSK in terms of Bit Error Rate (BER),
% transmission speed, spectral occupancy, and reconstructed image quality.

function extension_c_dbpsk()
clc; close all;

fprintf('=================================================================\n');
fprintf('   EXTENSION C: DBPSK VS BINARY FSK COMPARISON                   \n');
fprintf('   Acoustic Transmission Performance, Speed, & Image Quality     \n');
fprintf('=================================================================\n\n');

%% ---------------- 1. Parameters ----------------
Fs          = 48000;      % sampling rate (Hz)
Rb_fsk      = 400;        % FSK bit rate (bps)
f0          = 2000;       % FSK mark frequency (Hz)
f1          = 3200;       % FSK space frequency (Hz)
sps_fsk     = Fs / Rb_fsk;% 120 samples/bit

fc_dbpsk    = 2500;       % DBPSK single carrier frequency (Hz)
Rb_dbpsk    = 400;        % DBPSK standard bit rate (bps)
sps_dbpsk   = Fs / Rb_dbpsk;

% Optional high-speed DBPSK rate (occupies same bandwidth as FSK)
Rb_dbpsk_fast = 800;      % 2x faster DBPSK bit rate (bps)

imgSize     = [48 48];    % 48x48 = 2304 pixels = 18432 bits
evalEbN0    = 6;          % Eb/N0 for visual image comparison (dB)

%% ---------------- 2. Image Loading & Bit Conversion ----------------
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
    rIdx = round(linspace(1, size(imgRaw, 1), imgSize(1)));
    cIdx = round(linspace(1, size(imgRaw, 2), imgSize(2)));
    img = uint8(imgRaw(rIdx, cIdx));
else
    [X, Y] = meshgrid(1:imgSize(2), 1:imgSize(1));
    img = uint8(128 + 100*sin(X/5) .* cos(Y/5));
end

bits = reshape((dec2bin(img(:), 8) - '0').', [], 1);
nBits = numel(bits);

fprintf('Source Image: %d x %d (%d information bits)\n\n', imgSize(1), imgSize(2), nBits);

%% ---------------- 3. Spectral & Speed Metrics ----------------
% FSK requires band [f0 - Rb/2, f1 + Rb/2] -> approx 1600 Hz bandwidth
bw_fsk = (f1 - f0) + Rb_fsk; 
% DBPSK main lobe bandwidth is approx 2 * Rb -> 800 Hz bandwidth
bw_dbpsk = 2 * Rb_dbpsk;

duration_fsk = nBits / Rb_fsk;
duration_dbpsk = nBits / Rb_dbpsk;
duration_dbpsk_fast = nBits / Rb_dbpsk_fast;

fprintf('--- System Spectral and Speed Comparison ---\n');
fprintf('  Metric                       | Binary FSK       | DBPSK (1x)       | DBPSK (2x Speed)\n');
fprintf('  -----------------------------+------------------+------------------+------------------\n');
fprintf('  Carrier / Tone Frequencies   | 2000 & 3200 Hz   | 2500 Hz (Single) | 2500 Hz (Single) \n');
fprintf('  Bit Rate (bps)               | %-16d | %-16d | %-16d \n', Rb_fsk, Rb_dbpsk, Rb_dbpsk_fast);
fprintf('  Bandwidth Occupied (Hz)      | ~%-15d | ~%-15d | ~%-15d \n', bw_fsk, bw_dbpsk, 2*Rb_dbpsk_fast);
fprintf('  Spectral Efficiency (bps/Hz) | %-16.3f | %-16.3f | %-16.3f \n', Rb_fsk/bw_fsk, Rb_dbpsk/bw_dbpsk, Rb_dbpsk_fast/(2*Rb_dbpsk_fast));
fprintf('  Image TX Duration (sec)      | %-16.2f | %-16.2f | %-16.2f \n\n', duration_fsk, duration_dbpsk, duration_dbpsk_fast);

%% ---------------- 4. Image Transmission at Eb/N0 = 6 dB ----------------
fprintf('Transmitting image through AWGN channel at Eb/N0 = %d dB...\n', evalEbN0);

% --- FSK Simulation ---
tb_fsk = (0:sps_fsk-1)' / Fs;
s0 = sin(2*pi*f0*tb_fsk);
s1 = sin(2*pi*f1*tb_fsk);
E0 = exp(-1j*2*pi*f0*tb_fsk);
E1 = exp(-1j*2*pi*f1*tb_fsk);

bRow = bits.';
tx_fsk = s0*(1 - bRow) + s1*bRow;
sigP_fsk = 0.5;
noiseVar_fsk = (sigP_fsk * sps_fsk) / (2 * 10^(evalEbN0/10));
rx_fsk = tx_fsk + sqrt(noiseVar_fsk)*randn(size(tx_fsk));

e0 = abs(E0.' * rx_fsk);
e1 = abs(E1.' * rx_fsk);
rxBits_fsk = (e1 > e0).';

nErr_fsk = sum(bits ~= rxBits_fsk);
ber_fsk = nErr_fsk / nBits;

% --- DBPSK Simulation ---
tb_dbpsk = (0:sps_dbpsk-1)' / Fs;
carrier_dbpsk = cos(2*pi*fc_dbpsk*tb_dbpsk);
Ec_dbpsk = exp(-1j*2*pi*fc_dbpsk*tb_dbpsk);

% Differential encoding: d_k = d_{k-1} * (-1)^b_k
d = cumprod([1, (-1).^bits.']);
tx_dbpsk = zeros(sps_dbpsk, nBits + 1);
for k = 1:nBits+1
    tx_dbpsk(:, k) = d(k) * carrier_dbpsk;
end

sigP_dbpsk = 0.5;
noiseVar_dbpsk = (sigP_dbpsk * sps_dbpsk) / (2 * 10^(evalEbN0/10));
rx_dbpsk = tx_dbpsk + sqrt(noiseVar_dbpsk)*randn(size(tx_dbpsk));

% Differentially coherent demodulation
r_proj = Ec_dbpsk.' * rx_dbpsk;
z_diff = r_proj(2:end) .* conj(r_proj(1:end-1));
rxBits_dbpsk = (real(z_diff) < 0).';

nErr_dbpsk = sum(bits ~= rxBits_dbpsk);
ber_dbpsk = nErr_dbpsk / nBits;

% Reconstruct images
img_fsk   = bitsToImg(rxBits_fsk, imgSize);
img_dbpsk = bitsToImg(rxBits_dbpsk, imgSize);

% PSNR Calculation (base MATLAB)
psnr_fsk   = calculatePSNR(img, img_fsk);
psnr_dbpsk = calculatePSNR(img, img_dbpsk);

fprintf('Results at Eb/N0 = %d dB:\n', evalEbN0);
fprintf('  FSK:   Errors = %5d / %d | BER = %.4f (%.2f%%) | PSNR = %.2f dB\n', nErr_fsk, nBits, ber_fsk, ber_fsk*100, psnr_fsk);
fprintf('  DBPSK: Errors = %5d / %d | BER = %.4f (%.2f%%) | PSNR = %.2f dB\n\n', nErr_dbpsk, nBits, ber_dbpsk, ber_dbpsk*100, psnr_dbpsk);

%% ---------------- 5. BER vs SNR Sweep Comparison ----------------
ebnoSweep = 0:2:12;
ber_fsk_curve   = zeros(size(ebnoSweep));
ber_dbpsk_curve = zeros(size(ebnoSweep));
N_sweep = 20000;

fprintf('Sweeping BER vs Eb/N0 curve (0 to 12 dB)...\n');
for i = 1:numel(ebnoSweep)
    ebno_val = 10^(ebnoSweep(i)/10);
    testBits = randi([0 1], 1, N_sweep);
    
    % FSK
    tx_f = s0*(1 - testBits) + s1*testBits;
    nVar_f = (0.5 * sps_fsk) / (2 * ebno_val);
    rx_f = tx_f + sqrt(nVar_f)*randn(size(tx_f));
    dec_f = (abs(E1.'*rx_f) > abs(E0.'*rx_f));
    ber_fsk_curve(i) = sum(testBits ~= dec_f) / N_sweep;
    
    % DBPSK
    d_test = cumprod([1, (-1).^testBits]);
    tx_d = zeros(sps_dbpsk, N_sweep + 1);
    for k = 1:N_sweep+1
        tx_d(:, k) = d_test(k) * carrier_dbpsk;
    end
    nVar_d = (0.5 * sps_dbpsk) / (2 * ebno_val);
    rx_d = tx_d + sqrt(nVar_d)*randn(size(tx_d));
    proj_d = Ec_dbpsk.' * rx_d;
    z = proj_d(2:end) .* conj(proj_d(1:end-1));
    dec_d = (real(z) < 0);
    ber_dbpsk_curve(i) = sum(testBits ~= dec_d) / N_sweep;
end

%% ---------------- 6. Visualization ----------------
hFig = figure('Name', 'Extension C: DBPSK vs FSK Comparison', 'Color', 'w', 'Position', [100 80 1100 720]);

% Image 1: Original
subplot(2, 3, 1);
imshow(img); title('Original Source Image');

% Image 2: FSK Received
subplot(2, 3, 2);
imshow(img_fsk); 
title(sprintf('FSK @ %d dB\nBER = %.2f%%, PSNR = %.1f dB', evalEbN0, ber_fsk*100, psnr_fsk));

% Image 3: DBPSK Received
subplot(2, 3, 3);
imshow(img_dbpsk); 
title(sprintf('DBPSK @ %d dB\nBER = %.2f%%, PSNR = %.1f dB', evalEbN0, ber_dbpsk*100, psnr_dbpsk));

% Plot 4: Absolute Error Map Comparison
subplot(2, 3, 4);
errDiff = [abs(double(img) - double(img_fsk)), 255*ones(imgSize(1), 2), abs(double(img) - double(img_dbpsk))];
imshow(uint8(errDiff), []);
title('Error Maps: FSK (Left) vs DBPSK (Right)');

% Plot 5: BER vs Eb/N0 Curves
subplot(2, 3, 5);
semilogy(ebnoSweep, max(ber_fsk_curve, 1e-4), 'ro-', 'LineWidth', 1.8, 'MarkerFaceColor', 'r'); hold on;
semilogy(ebnoSweep, max(ber_dbpsk_curve, 1e-4), 'bs-', 'LineWidth', 1.8, 'MarkerFaceColor', 'b');
theory_fsk   = 0.5 * exp(-10.^(ebnoSweep/10) / 2);
theory_dbpsk = 0.5 * exp(-10.^(ebnoSweep/10));
semilogy(ebnoSweep, theory_fsk, 'r--', 'LineWidth', 1.2);
semilogy(ebnoSweep, theory_dbpsk, 'b--', 'LineWidth', 1.2);
grid on; xlabel('E_b / N_0 (dB)'); ylabel('Bit Error Rate');
title('BER Performance Comparison');
legend({'FSK Sim', 'DBPSK Sim', 'FSK Theory', 'DBPSK Theory'}, 'Location', 'southwest');
ylim([1e-4 1]);

% Plot 6: DBPSK Differential Phase Constellation
subplot(2, 3, 6);
z_norm = z_diff / max(abs(z_diff));
idx0 = find(bits == 0);
idx1 = find(bits == 1);
plot(real(z_norm(idx0(1:min(300, end)))), imag(z_norm(idx0(1:min(300, end)))), 'b.', 'MarkerSize', 8); hold on;
plot(real(z_norm(idx1(1:min(300, end)))), imag(z_norm(idx1(1:min(300, end)))), 'r.', 'MarkerSize', 8);
grid on; axis equal; xlim([-1.5 1.5]); ylim([-1.5 1.5]);
plot([0 0], [-1.5 1.5], 'k--', 'LineWidth', 1);
xlabel('In-Phase (I)'); ylabel('Quadrature (Q)');
title(sprintf('DBPSK Decision Scatter (Eb/N0 = %d dB)', evalEbN0));
legend({'Bit 0 (\Delta\phi = 0)', 'Bit 1 (\Delta\phi = \pi)'}, 'Location', 'north');

saveas(hFig, 'extension_c_results.png');
fprintf('Saved figure to "extension_c_results.png".\n');
end

%% ---------------- Helper Functions ----------------
function imgOut = bitsToImg(bVec, imgSize)
    bMat = reshape(bVec, 8, []).';
    pix = bMat * (2.^(7:-1:0))';
    imgOut = reshape(uint8(pix), imgSize);
end

function psnrVal = calculatePSNR(orig, rec)
    mse = mean((double(orig(:)) - double(rec(:))).^2);
    if mse == 0
        psnrVal = Inf;
    else
        psnrVal = 10 * log10((255^2) / mse);
    end
end
