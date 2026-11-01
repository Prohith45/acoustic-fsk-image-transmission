# Hyperframes Composition Brief: Acoustic Binary FSK Image Transmission

## Objective
Create a short, sleek, high-impact brag video for the Acoustic Binary FSK Smartphone Image Transmission project.

## Output
- Composition directory: `brag-output/composition/`
- Rendered video: `brag-output/brag.mp4`
- Format: landscape — 1920x1080
- Duration: 20 seconds (600 frames at 30 fps)

## Source Material
- Project root: `C:\Users\papan\downloads\FSK_image`
- Primary files read: `fsk_tx.m`, `fsk_rx.m`, `extension_a_distance_noise.m`, `extension_b_channel_coding.m`, `extension_c_dbpsk.m`, `extension_d_sim_ber.m`, `README.md`, `report_outline.md`
- Product name: Acoustic Binary FSK Image Transmission
- Tagline: "Beam images across smartphones using pure sound"
- Key visuals to incorporate:
  - `lion.jpg` (Original transmitted image)
  - `received_image.png` (Reconstructed image)
  - `extension_d_results.png` (Monte Carlo BER vs Theory plot)
  - Audio waveform and chirp spectrum graphics
  - Real MATLAB parameters: $f_0 = 2000\text{ Hz}$, $f_1 = 3200\text{ Hz}$, $R_b = 400\text{ bps}$, $F_s = 48\text{ kHz}$

## Creative Direction
- Tone preset: `polished`
- Creative direction: Modern DSP & hardware engineering launch
- Tone interpretation: Sleek dark glassmorphism, glowing cyan & violet accents, precise typography, smooth GSAP motion, no cluttered generic filler.
- Hook: "Can you transmit images using ONLY SOUND?"
- Outro: "Zero RF. Zero Wi-Fi. Pure Acoustic Math." -> GitHub repository callout.
- Avoid: Generic SaaS tropes, low contrast text, sluggish pacing.

## Visual Identity
- Background: `#0B0F19` (Deep obsidian navy)
- Card Surface: `rgba(20, 27, 45, 0.88)`
- Primary Accent: `#00F0FF` (Electric acoustic cyan)
- Secondary Accent: `#8B5CF6` (Vibrant purple)
- Accent Gradient: `linear-gradient(135deg, #00F0FF, #8B5CF6)`
- Highlight Green: `#10B981` (BER Success green)
- Text Primary: `#FFFFFF`
- Text Secondary: `#94A3B8`
- Display Font: `Inter, system-ui, -apple-system, sans-serif`
- Border Glow: `1px solid rgba(0, 240, 255, 0.25)`

## Storyboard Timings (30 fps, 600 frames total)
1. **Scene 1: The Acoustic Hook** (0.0s - 4.5s / frames 0 - 135)
   - Headline: "TRANSMIT IMAGES ACROSS SMARTPHONES"
   - Tagline: "Using ONLY Acoustic Sound Waves 🔊📡"
   - Badges: `BFSK Modulation`, `f0 = 2000 Hz (Mark 0)`, `f1 = 3200 Hz (Space 1)`
2. **Scene 2: The Physical Channel & Sync Chirp** (4.5s - 9.5s / frames 135 - 285)
   - Architecture pipeline: `Pixels` -> `Packets` -> `100ms LFM Chirp` -> `Air Channel`
   - Matched-filter sync visual: Sharp correlation peak tracking clock drift ($W = \pm 300$ samples)
   - Audio parameters: `48 kHz PCM`, `400 bps`, `120 sps`
3. **Scene 3: Real Over-The-Air Demodulation & BER Results** (9.5s - 15.0s / frames 285 - 450)
   - Visual side-by-side: `lion.jpg` (Transmitted) vs `received_image.png` (Received)
   - Highlight: `0.00% BER` at close distance, `+9.8 dB PSNR` with DBPSK
   - Extension badges: `Hamming(7,4) FEC`, `Monte Carlo 60k Bits vs Theory`
4. **Scene 4: The Outro & Open Source Code** (15.0s - 20.0s / frames 450 - 600)
   - Headline: "ZERO RF. ZERO WI-FI. JUST ACOUSTIC MATH."
   - Repo: `github.com/Prohith45/acoustic-fsk-image-transmission`
   - Badges: `MATLAB Code`, `Lab Report PDF`, `Audio WAV & MP3 Included`, `MIT License`

## Audio Assets
- Music: `brag-output/composition/assets/music/happy-beats-business-moves-vol-10-by-ende-dot-app.mp3`
- SFX: Subtle UI switch / click sounds for card transitions
