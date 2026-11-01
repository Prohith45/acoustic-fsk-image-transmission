# Share Copy Variants

## Twitter / X
Beam images across the room with pure sound 🔊📡

Built an end-to-end acoustic FSK modem in MATLAB with linear chirp sync, Hamming(7,4) FEC, and real phone-to-phone air transmission: https://github.com/Prohith45/acoustic-fsk-image-transmission

#DSP #MATLAB #Engineering #SignalProcessing #AudioTech

---

## LinkedIn
Who needs Wi-Fi or Bluetooth when you can transmit images over acoustic sound waves? 🔊📱

I built and validated an end-to-end digital communications acoustic modem in MATLAB:
• BFSK modulation (2000 Hz Mark, 3200 Hz Space, 400 bps)
• 100ms LFM Hann-windowed sync chirp preamble with matched filtering
• Dynamic tracking window (±300 samples) mitigating phone crystal clock drift
• Non-coherent quadrature demodulation (|E0| vs |E1| envelope comparison)
• Channel coding: Repetition(3) & Systematic Hamming(7,4)
• DBPSK modulation comparison (+9.8 dB PSNR advantage)
• 60,000-bit Monte Carlo simulation matching analytical theory: Pe = 0.5·exp(-Eb/2N0)

Open-source code, audio recordings, and complete PDF report:
https://github.com/Prohith45/acoustic-fsk-image-transmission

---

## Discord / Communities
Just released an acoustic FSK image transmission project in MATLAB! It transmits pixel data between two smartphones over the air with chirp matched filtering, Hamming coding, and 0% bit errors at close range: https://github.com/Prohith45/acoustic-fsk-image-transmission
