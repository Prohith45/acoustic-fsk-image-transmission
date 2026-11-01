%% EXTENSION D: MONTE-CARLO BER VS SNR SIMULATION AGAINST THEORY
% Project: Acoustic Binary FSK Image Transmission
% Description: High-precision Monte-Carlo AWGN simulation of non-coherent 
% Binary FSK and DBPSK compared against theoretical analytical error curves:
%   Pe(FSK non-coherent) = 0.5 * exp(-Eb / (2*N0))
%   Pe(DBPSK)            = 0.5 * exp(-Eb / N0)
%   Pe(BPSK coherent)    = 0.5 * erfc(sqrt(Eb / N0))

function extension_d_sim_ber()
clc; close all;

fprintf('=================================================================\n');
fprintf('   EXTENSION D: BER VS SNR SIMULATION AGAINST THEORY             \n');
fprintf('   Validating Pe = 0.5*exp(-Eb/(2*N0)) for Non-Coherent FSK     \n');
fprintf('=================================================================\n\n');

%% ---------------- 1. Simulation Parameters ----------------
Fs          = 48000;          % sampling rate (Hz)
Rb          = 400;            % bit rate (bps)
f0          = 2000;           % FSK mark frequency (Hz)
f1          = 3200;           % FSK space frequency (Hz)
fc          = 2500;           % DBPSK carrier frequency (Hz)
sps         = Fs / Rb;        % 120 samples per bit

% Sweep range for Eb/N0 in dB
EbN0_dB_sweep = 0:1:13;
nPoints       = numel(EbN0_dB_sweep);

% Target bit count per point for reliable statistics down to BER ~ 10^-4
N_bits_target = 60000; 

fprintf('Simulation Configuration:\n');
fprintf('  Sampling Rate (Fs):       %d Hz\n', Fs);
fprintf('  Bit Rate (Rb):            %d bps (sps = %d)\n', Rb, sps);
fprintf('  FSK Frequencies:          %d Hz (bit 0), %d Hz (bit 1)\n', f0, f1);
fprintf('  DBPSK Carrier Frequency:  %d Hz\n', fc);
fprintf('  Eb/N0 Range:              %d to %d dB (step: 1 dB)\n', EbN0_dB_sweep(1), EbN0_dB_sweep(end));
fprintf('  Bits tested per point:    %d\n\n', N_bits_target);

%% ---------------- 2. Precompute Tone Vectors ----------------
tb = (0:sps-1)' / Fs;

% FSK reference vectors
s0 = sin(2*pi*f0*tb);
s1 = sin(2*pi*f1*tb);
E0 = exp(-1j*2*pi*f0*tb);
E1 = exp(-1j*2*pi*f1*tb);

% DBPSK reference vectors
carrier = cos(2*pi*fc*tb);
Ec      = exp(-1j*2*pi*fc*tb);

%% ---------------- 3. Theoretical Bit Error Probabilities ----------------
EbN0_lin = 10.^(EbN0_dB_sweep / 10);

% Theoretical curves
Pe_theory_fsk   = 0.5 * exp(-EbN0_lin / 2);
Pe_theory_dbpsk = 0.5 * exp(-EbN0_lin);
Pe_theory_bpsk  = 0.5 * erfc(sqrt(EbN0_lin));

%% ---------------- 4. Monte-Carlo Simulation Loop ----------------
ber_sim_fsk   = zeros(1, nPoints);
ber_sim_dbpsk = zeros(1, nPoints);
ber_sim_bpsk  = zeros(1, nPoints);

fprintf('%-10s | %-12s | %-12s | %-12s | %-12s\n', ...
    'Eb/N0 (dB)', 'FSK Theory', 'FSK Sim', 'DBPSK Theory', 'DBPSK Sim');
fprintf('------------------------------------------------------------------------\n');

for i = 1:nPoints
    ebno = EbN0_lin(i);
    
    % Random binary stream
    b = randi([0 1], 1, N_bits_target);
    
    % ---------------- (A) Non-Coherent Binary FSK ----------------
    tx_fsk = s0*(1 - b) + s1*b;
    sigP_fsk = 0.5;
    nVar_fsk = (sigP_fsk * sps) / (2 * ebno);
    rx_fsk = tx_fsk + sqrt(nVar_fsk) * randn(size(tx_fsk));
    
    % Quadrature energy detection
    e0 = abs(E0.' * rx_fsk);
    e1 = abs(E1.' * rx_fsk);
    b_hat_fsk = (e1 > e0);
    ber_sim_fsk(i) = sum(b ~= b_hat_fsk) / N_bits_target;
    
    % ---------------- (B) Differentially Coherent DBPSK ----------------
    % Differential encoding: d_k = d_{k-1} * (-1)^b_k
    d = cumprod([1, (-1).^b]);
    tx_dbpsk = zeros(sps, N_bits_target + 1);
    for k = 1:N_bits_target+1
        tx_dbpsk(:, k) = d(k) * carrier;
    end
    sigP_dbpsk = 0.5;
    nVar_dbpsk = (sigP_dbpsk * sps) / (2 * ebno);
    rx_dbpsk = tx_dbpsk + sqrt(nVar_dbpsk) * randn(size(tx_dbpsk));
    
    % Differentially coherent demodulation
    proj_d = Ec.' * rx_dbpsk;
    z_diff = proj_d(2:end) .* conj(proj_d(1:end-1));
    b_hat_dbpsk = (real(z_diff) < 0);
    ber_sim_dbpsk(i) = sum(b ~= b_hat_dbpsk) / N_bits_target;
    
    % ---------------- (C) Coherent BPSK (Reference) ----------------
    % Matches directly with coherent matched filter
    b_bpsk = 1 - 2*b; % 0 -> +1, 1 -> -1
    rx_bpsk_samples = b_bpsk + sqrt(1 / (2*ebno)) * randn(size(b_bpsk));
    b_hat_bpsk = (rx_bpsk_samples < 0);
    ber_sim_bpsk(i) = sum(b ~= b_hat_bpsk) / N_bits_target;
    
    fprintf('%-10.1f | %-12.4e | %-12.4e | %-12.4e | %-12.4e\n', ...
        EbN0_dB_sweep(i), Pe_theory_fsk(i), ber_sim_fsk(i), Pe_theory_dbpsk(i), ber_sim_dbpsk(i));
end
fprintf('========================================================================\n\n');

%% ---------------- 5. Plotting Results ----------------
hFig = figure('Name', 'Extension D: BER vs SNR Theory Validation', 'Color', 'w', 'Position', [120 100 950 650]);

% Continuous theoretical curves for smooth visualization
EbN0_fine_dB = linspace(0, 14, 200);
EbN0_fine_lin = 10.^(EbN0_fine_dB / 10);
Pe_fine_fsk   = 0.5 * exp(-EbN0_fine_lin / 2);
Pe_fine_dbpsk = 0.5 * exp(-EbN0_fine_lin);
Pe_fine_bpsk  = 0.5 * erfc(sqrt(EbN0_fine_lin));

% Plot Theoretical Curves (Lines)
semilogy(EbN0_fine_dB, Pe_fine_fsk,   'r--', 'LineWidth', 2.0); hold on;
semilogy(EbN0_fine_dB, Pe_fine_dbpsk, 'b--', 'LineWidth', 2.0);
semilogy(EbN0_fine_dB, Pe_fine_bpsk,  'k:',  'LineWidth', 1.8);

% Plot Simulated Data (Markers)
semilogy(EbN0_dB_sweep, max(ber_sim_fsk, 1e-6),   'ro', 'LineWidth', 1.8, 'MarkerSize', 8, 'MarkerFaceColor', [1 0.7 0.7]);
semilogy(EbN0_dB_sweep, max(ber_sim_dbpsk, 1e-6), 'bs', 'LineWidth', 1.8, 'MarkerSize', 8, 'MarkerFaceColor', [0.7 0.8 1]);
semilogy(EbN0_dB_sweep, max(ber_sim_bpsk, 1e-6),  'kd', 'LineWidth', 1.5, 'MarkerSize', 7, 'MarkerFaceColor', [0.8 0.8 0.8]);

grid on;
set(gca, 'YScale', 'log');
xlim([0 13]);
ylim([1e-5 1]);

xlabel('E_b / N_0 (dB)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontSize', 12, 'FontWeight', 'bold');
title('Bit Error Rate vs E_b/N_0: Simulation vs Analytical Theory', 'FontSize', 13, 'FontWeight', 'bold');

legend({ ...
    'Non-Coherent FSK Theory: P_e = 0.5 e^{-E_b / (2N_0)}', ...
    'DBPSK Theory: P_e = 0.5 e^{-E_b / N_0}', ...
    'Coherent BPSK Theory: P_e = Q(\surd(2E_b/N_0))', ...
    'Non-Coherent FSK Simulated', ...
    'DBPSK Simulated', ...
    'Coherent BPSK Simulated' ...
    }, 'Location', 'southwest', 'FontSize', 10);

% Annotate 3 dB non-coherent FSK penalty
text(5.5, 0.05, '\leftarrow 3 dB Power Penalty of Non-Coherent FSK', ...
    'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.7 0 0]);

saveas(hFig, 'extension_d_results.png');
fprintf('Saved figure to "extension_d_results.png".\n');
end
