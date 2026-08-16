# Posture Pal

A playful, private macOS menu-bar companion that nudges you to reset your
posture throughout the day.

## Features

- Animated blob companion and custom floating reminder popup
- Warm, playful, or delightfully dramatic prompts
- Hourly reminders by default, with configurable interval and active hours
- Five-minute snooze and longer pause controls
- Optional gentle sound
- Local daily check-ins and streak
- Optional launch at login
- No account, camera, analytics, or network access

## Requirements

- macOS 13 or newer
- Xcode Command Line Tools (`xcode-select --install`)

## Install from source

```bash
git clone https://github.com/YOUR-USERNAME/posture-pal.git
cd posture-pal
./install.sh
```

The installer builds an ad-hoc signed app, copies it to
`~/Applications/Posture Pal.app`, and opens it. Posture Pal appears in the menu
bar as a standing-person icon. Open its menu to trigger a test reminder or
adjust settings.

Because this source build is not notarized through Apple, macOS may ask you to
confirm opening it the first time.

## Build without installing

```bash
./build.sh
```

The app bundle will be created at `build/Posture Pal.app`.

## Uninstall

```bash
./uninstall.sh
```

To also remove saved preferences:

```bash
defaults delete com.local.PosturePal
```

## Development

Posture Pal is a dependency-free Swift Package using SwiftUI and AppKit.

```bash
swift build
swift run
```

## Privacy

Posture Pal has no account, camera access, analytics, or network requests.
Preferences and streak data stay in macOS `UserDefaults`.

## Contributing

Issues and pull requests are welcome. Please keep the experience encouraging,
accessible, and free of guilt-based reminders.

## License

[MIT](LICENSE)
