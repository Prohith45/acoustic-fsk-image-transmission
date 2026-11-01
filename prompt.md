Act as a digital communications engineer. Build a complete MATLAB project 
for my Analog & Digital Communication lab:

PROJECT: Image transmission between two smartphones using acoustic 
binary FSK, with BER analysis.

SYSTEM CHAIN:
Image -> grayscale -> resize (64x64) -> bits (8 bits/pixel) -> packetize 
(256 bits/packet, each packet preceded by a linear chirp sync preamble) 
-> binary FSK modulation (f0=2000 Hz, f1=3200 Hz, 400 bps, Fs=48000 Hz) 
-> WAV file -> played on Phone 1 -> air channel -> recorded on Phone 2 
-> matched-filter sync per packet (to handle clock drift) 
-> non-coherent FSK demodulation (energy compare at f0 and f1) 
-> bits -> image reconstruction.

DELIVERABLES:
1. fsk_tx.m: transmitter, saves fsk_image.wav and txdata.mat
2. fsk_rx.m: receiver, shows original/received/error image, prints BER
3. Well-commented code with a parameter section at the top
4. Plots: waveform, spectrogram, sync correlation, received image
5. Extension A: BER vs distance / noise-level table and plot
6. Extension B: add repetition(3) or Hamming(7,4) coding and compare BER
7. Extension C: add DBPSK and compare against FSK (BER, image quality, speed)
8. Extension D: a simulation mode with AWGN to plot BER vs SNR for FSK and 
   DBPSK against theory (Pe = 0.5*exp(-Eb/2N0) for non-coherent FSK)
9. Short report outline: aim, block diagram, theory, procedure, results, 
   conclusion

CONSTRAINTS: Use only base MATLAB where possible, keep code beginner 
friendly, and explain each block briefly.