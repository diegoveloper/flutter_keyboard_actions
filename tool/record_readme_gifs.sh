#!/usr/bin/env bash
# Record the booted iOS Simulator and save an optimized GIF under doc/gifs/.
#
# Usage:
#   ./tool/record_readme_gifs.sh done-only 5
#
# Open the matching example demo first, then run this script and interact
# during the countdown.

set -euo pipefail

name="${1:-demo}"
seconds="${2:-5}"
root="$(cd "$(dirname "$0")/.." && pwd)"
out_dir="$root/doc/gifs"
tmp_mp4="$(mktemp -t keyboard_actions_gif).mp4"
out_gif="$out_dir/${name}.gif"

mkdir -p "$out_dir"

if ! xcrun simctl list devices booted | grep -q Booted; then
  echo "No booted iOS Simulator. Start one and run: cd example && flutter run"
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required (brew install ffmpeg)"
  exit 1
fi

echo "Recording ${seconds}s to ${out_gif}"
echo "Starting in 3 seconds. Open the demo and get ready..."
sleep 3
echo "Recording NOW. Interact with the simulator."

xcrun simctl io booted recordVideo "$tmp_mp4" &
rec_pid=$!
sleep "$seconds"
kill -INT "$rec_pid" 2>/dev/null || true
wait "$rec_pid" 2>/dev/null || true

ffmpeg -y -i "$tmp_mp4" \
  -vf "fps=10,scale=390:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" \
  -loop 0 "$out_gif"

rm -f "$tmp_mp4"
ls -lh "$out_gif"
echo "Done: doc/gifs/${name}.gif"
