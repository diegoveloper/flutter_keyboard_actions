#!/usr/bin/env bash
# Capture README GIFs by running integration tests on a booted iOS Simulator.
# Recording starts when the test prints README_GIF_READY (demo open + keyboard up).
#
# Usage:
#   ./tool/capture_readme_gifs.sh [device_id]
#
# Requires: booted iOS Simulator, ffmpeg, flutter

set -euo pipefail

device="${1:-}"
root="$(cd "$(dirname "$0")/.." && pwd)"
example="$root/example"
out_dir="$root/doc/gifs"

if [[ -z "$device" ]]; then
  device="$(xcrun simctl list devices booted | sed -n 's/.*(\([A-F0-9-]*\)) (Booted).*/\1/p' | head -1)"
fi

if [[ -z "$device" ]]; then
  echo "No booted iOS Simulator. Boot one first."
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required (brew install ffmpeg)"
  exit 1
fi

mkdir -p "$out_dir"

wait_for_gif_ready() {
  local log="$1"
  local timeout_secs="${2:-180}"
  local deadline=$((SECONDS + timeout_secs))

  while (( SECONDS < deadline )); do
    if grep -q 'README_GIF_READY' "$log" 2>/dev/null; then
      return 0
    fi
    sleep 0.15
  done
  echo "Timed out waiting for README_GIF_READY" >&2
  return 1
}

to_gif() {
  local in_mp4="$1"
  local out_gif="$2"
  ffmpeg -y -i "$in_mp4" \
    -vf "fps=10,scale=390:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" \
    -loop 0 "$out_gif"
}

capture() {
  local name="$1"
  local test_name="$2"
  local raw_mp4
  raw_mp4="$(mktemp -t keyboard_actions_gif).mp4"
  local out_gif="$out_dir/${name}.gif"
  local log
  log="$(mktemp -t keyboard_actions_test_log).txt"

  echo "Capturing ${name} (${test_name})..."

  (
    cd "$example"
    stdbuf -oL flutter test integration_test/readme_gifs_test.dart \
      --name "$test_name" \
      -d "$device" 2>&1 | stdbuf -oL tee "$log"
  ) &
  local test_pid=$!

  if ! wait_for_gif_ready "$log"; then
    kill "$test_pid" 2>/dev/null || true
    wait "$test_pid" 2>/dev/null || true
    rm -f "$log" "$raw_mp4"
    exit 1
  fi

  xcrun simctl io "$device" recordVideo "$raw_mp4" &
  local rec_pid=$!

  local deadline=$((SECONDS + 120))
  while (( SECONDS < deadline )); do
    if grep -q 'README_GIF_DONE' "$log" 2>/dev/null; then
      sleep 0.35
      break
    fi
    if ! kill -0 "$test_pid" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done

  kill -INT "$rec_pid" 2>/dev/null || true
  wait "$rec_pid" 2>/dev/null || true
  wait "$test_pid" 2>/dev/null || true

  to_gif "$raw_mp4" "$out_gif"

  rm -f "$log" "$raw_mp4"
  ls -lh "$out_gif"
}

cd "$example"
flutter pub get

echo "Prebuilding iOS app (once)..."
flutter build ios --simulator -d "$device"

capture done-only 'readme: done only'
capture navigation 'readme: navigation'
capture integrated-bar 'readme: integrated bar'
capture custom-keyboard 'readme: custom keyboard'
capture large-list 'readme: large list'
capture dialog 'readme: dialog'

echo "All GIFs saved under doc/gifs/"
