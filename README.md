# Tempo — Metronome for Musicians

A minimal, precise, and beautifully designed metronome for iPhone and Apple Watch. Built with SwiftUI and AVAudioEngine.

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B%20%7C%20watchOS%2010%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

- **Precise BPM control** — slider, tap tempo, and manual input (20–300 BPM)
- **Time signatures** — 4/4, 3/4, 6/8, 5/4, 7/8 with accented first beat
- **Sound selection** — Click, Wood, Beep, Hi-Hat with adjustable volume
- **Haptic feedback** — CoreHaptics with stronger accent on beat one
- **Apple Watch companion** — tap tempo on your wrist, haptic-only mode

## Screenshots

*Coming soon*

## Requirements

- iOS 17.0+
- watchOS 10.0+
- Xcode 15+
- Swift 5.9+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/tempo-metronome.git
   ```
2. Open `Tempo.xcodeproj` in Xcode
3. Select your target device or simulator
4. Press `Cmd + R` to build and run

No external dependencies — pure Swift and Apple frameworks only.

## Architecture

```
Tempo/
├── App/
│   └── TempoApp.swift          # App entry point
├── Views/
│   ├── MainView.swift          # Main metronome screen
│   ├── BPMControlView.swift    # BPM slider + tap tempo
│   └── TimeSigView.swift       # Time signature picker
├── Engine/
│   ├── MetronomeEngine.swift   # AVAudioEngine core logic
│   └── HapticEngine.swift      # CoreHaptics manager
└── Models/
    └── MetronomeState.swift    # App state (Observable)

TempoWatch/
├── WatchApp.swift
└── WatchMainView.swift
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a pull request.

## License

MIT License — see [LICENSE](LICENSE) for details.
