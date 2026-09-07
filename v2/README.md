# VoxFlow v2

Native macOS dictation and file transcription, entirely on-device. Swift 6, SwiftUI,
whisper.cpp, macOS 15+, Apple Silicon.

This directory is the v2 rewrite growing on the `develop` branch until promotion (see
issue #105 and `docs/superpowers/specs/2026-09-07-voxflow-v2-design.md`). The .NET v1
code at the repository root is frozen and will be removed at promotion.

## Layout

| Path | What |
|---|---|
| `project.yml` | XcodeGen definition of the app target and the `VoxFlow` scheme |
| `VoxFlow/` | SwiftUI app shell: App, MainWindow, MenuBar, FlowBar, Onboarding, Settings, Design |
| `VoxFlowTests/` | App-layer tests |
| `VoxFlowKit/` | SwiftPM package with all logic: Core, Audio, Speech, Models, Files, Dictation, Storage, Styling, MCP |
| `design/` | The Claude Design canvas that is the product spec |
| `docs/adr/` | Architecture decision records for v2 |
| `docs/superpowers/` | Design specs and implementation plans |

## Build and test

Requires Xcode 26.x and XcodeGen (`brew install xcodegen`).

```bash
cd v2
xcodegen generate                       # creates VoxFlow.xcodeproj (gitignored)
xcodebuild -scheme VoxFlow -destination 'platform=macOS' build test
```

Package-only tests, no Xcode project needed:

```bash
cd v2/VoxFlowKit && swift test
```

Open `VoxFlow.xcodeproj` in Xcode to run the app (scheme `VoxFlow`).

## CI

`.github/workflows/ci-v2.yml` runs the same two commands on `macos-15`;
`.github/workflows/codeql-v2.yml` runs CodeQL for Swift. Both trigger only for `v2/**`.
