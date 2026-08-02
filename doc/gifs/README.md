# README GIFs

Short screen recordings for the package README. Keep each GIF under ~2 MB (390px wide, 10 fps, 4 to 6 seconds).

## Quick capture (recommended)

1. Boot a simulator and run the example app:

```bash
cd example
flutter run
```

2. Open the demo you want to record.

3. In another terminal:

```bash
./tool/record_readme_gifs.sh done-only 5
```

Interact during the recording (focus fields, tap Prev/Next, etc.), then wait for the conversion.

## Expected files

| File | Demo | What to show |
|---|---|---|
| `done-only.gif` | Done only | Focus a field, show Done bar |
| `navigation.gif` | Form + navigation | Tap Prev / Next between fields |
| `integrated-bar.gif` | Integrated bar | Flush toolbar |
| `custom-keyboard.gif` | Custom keyboards | Counter or color picker |
| `large-list.gif` | Large ListView | Arrow to last field, auto scroll |
| `dialog.gif` | Dialog | Keyboard inside AlertDialog |

Commit the `.gif` files here so pub.dev and GitHub render them from the README.

## Automated capture

With a booted iOS Simulator:

```bash
./tool/capture_readme_gifs.sh
```

Recording starts on `README_GIF_READY` (demo open, keyboard/panel visible) and stops on `README_GIF_DONE` (before the integration-test "Test finished" overlay).

Each test focuses a field, taps Prev/Next arrows 2 to 3 times where available, holds for 2 seconds, then signals done.

## Manual capture
