# Brag Plan: Acoustic Binary FSK Image Transmission

## What is this app?
An end-to-end digital communications acoustic modem system implemented in MATLAB that transmits digital images over the air between two smartphones using Binary Frequency Shift Keying (BFSK) with matched-filter chirp synchronization, non-coherent quadrature energy demodulation, forward error correction, and DBPSK comparison.

## The angle
Who needs Wi-Fi or Bluetooth when you can beam photos across the room using pure sound? Turn any two smartphones into a digital acoustic communications link using mathematical modulation, chirps, and quadrature detection.

## Hook (first 2-3 seconds)
"Can you transmit images using ONLY SOUND?"
A dynamic high-tech audio waveform pulses with the frequency markers (2000 Hz Mark, 3200 Hz Space).

## Key moments (the middle)
1. **The Air Channel & Chirp Synchronization**: Showing the 100 ms LFM chirp preamble ($1000 \to 4000\text{ Hz}$) and the matched-filter cross-correlation spike eliminating clock drift between phone crystals.
2. **Phone-to-Phone Over-The-Air Transmission**: Real smartphone speaker to microphone link over $0.1\text{m}$ to $2.5\text{m}$ with zero bit errors at close range ($0.00\%\text{ BER}$).
3. **Advanced DSP Extensions**: Hamming(7,4) & Repetition(3) channel coding, DBPSK $+9.8\text{ dB}$ PSNR boost, and 60,000-bit Monte-Carlo simulation matching theory $P_e = 0.5 e^{-E_b / 2N_0}$.

## Outro / punchline
"Zero RF. Zero Wi-Fi. Just acoustic mathematics."
Shows the reconstructed image side-by-side with the GitHub repo link: `Prohith45/acoustic-fsk-image-transmission`.

## User flow worth showing
1. Phone 1 encodes image pixels into acoustic packets and plays audio chirp over speaker.
2. Acoustic wave travels across air channel with multipath and ambient noise.
3. Phone 2 records audio, matched filter locks onto sync chirps, and non-coherent demodulator renders the exact image!

## Tone
- Preset: `polished`
- Creative direction: Sleek acoustic DSP engineering showcase
- Interpretation: Confident, crisp technical typography, dark high-tech aesthetics, real waveform & spectral visuals, fast snappy transitions.

## Format: landscape — 1920x1080
## Duration: 20 seconds

## Visual identity (from the project)
- Background: `#0B0F19` (Deep DSP midnight obsidian)
- Accent: `#00F0FF` (Cyan acoustic wave) & `#7000FF` (Electric purple)
- Card BG: `rgba(20, 27, 45, 0.85)`
- Text: `#F8FAFC` (Pure bright white) & `#94A3B8` (Muted technical slate)
- Display font: `system-ui, -apple-system, 'SF Pro Display', Inter, sans-serif`
- Body font: `system-ui, -apple-system, 'SF Pro Text', Inter, sans-serif`
- Strongest visual elements: Actual acoustic spectrogram, lion source & received images, chirp cross-correlation spike, BER waterfall curve.

## Share copy (draft)
Beam images across the room with pure sound 🔊📡 Built an end-to-end acoustic FSK modem in MATLAB with chirp sync, Hamming FEC, and phone-to-phone over-the-air transmission: https://github.com/Prohith45/acoustic-fsk-image-transmission

## Audio direction
- Role: Polished energetic electronic bed with crisp DSP UI clicks
- Music: `happy-beats-business-moves-vol-10-by-ende-dot-app.mp3`
- Music treatment: Starts at 0.0s, stays confident at 0.55 volume, dips slightly during focal text, smooth 1.0s fadeout at end.
- Music cue guidance: Beat grid hits around 0.27s, 4.10s, 8.22s, 12.02s, 16.38s, 20.19s.
- Audio-reactive treatment: Subtle neon glow pulsation synced to beat energy.
- SFX posture: Crisp technical swooshes and card arrivals.
- Restraint rule: No distracting harsh buzzes or unmusical beeps.

---

## Storyboard

### Scene 1 — The Acoustic Hook — 0.0s to 4.5s (4.5s)
- **Visual**: Glowing soundwave pulsating between two smartphone icons. Bold headline: "Transmit Images... Using ONLY SOUND?" Subtitle: "Acoustic Binary FSK Smartphone Modem".
- **Product Material**: Audio frequencies 2000 Hz (Mark 0) & 3200 Hz (Space 1) badges.
- **Audio intent**: High-energy opening hook, music kicks in with beat at 0.27s.
- **Transition**: Smooth cyber-slide into Scene 2.

### Scene 2 — The Air Channel & Chirp Matched Filter — 4.5s to 9.5s (5.0s)
- **Visual**: 3-stage pipeline animation: [Image Pixels] -> [100ms LFM Chirp Preamble] -> [Acoustic Channel]. Real Matched-Filter correlation plot showing sharp sync spike ($W=\pm 300$ samples drift tracking).
- **Product Material**: Real correlation peak graph, 48 kHz sampling rate, 400 bps data rate.
- **Audio intent**: Dynamic technical intrigue with click on stage cards.
- **Transition**: Zoom reveal into Scene 3.

### Scene 3 — Live Over-The-Air Results & DSP Extensions — 9.5s to 15.0s (5.5s)
- **Visual**: Split comparison grid:
  - Left: Original vs Received Image with "0.00% BER" badge.
  - Right: 3 Metric cards: "Hamming(7,4) FEC", "DBPSK +9.8 dB PSNR", "Monte Carlo 60,000 Bits".
- **Product Material**: Actual `lion.jpg`, `received_image.png`, and `extension_d_results.png`.
- **Audio intent**: Triumph of transmission success and engineering rigor.
- **Transition**: Impact slam into Outro.

### Scene 4 — The Outro & Open Source Code — 15.0s to 20.0s (5.0s)
- **Visual**: "Zero RF. Zero Wi-Fi. Pure Acoustic Math." Large GitHub badge: `Prohith45/acoustic-fsk-image-transmission`. Complete with MATLAB code, lab report PDF, and audio recordings.
- **Product Material**: GitHub repo link, MIT license, lab report badge.
- **Audio intent**: Satisfying resolution, music fades smoothly over the last 1.2s.
