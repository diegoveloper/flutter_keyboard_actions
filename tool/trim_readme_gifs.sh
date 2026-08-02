#!/usr/bin/env bash
# Re-trim existing README GIFs to remove leading idle frames.
#
# Usage:
#   ./tool/trim_readme_gifs.sh

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
out_dir="$root/doc/gifs"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required (brew install ffmpeg)"
  exit 1
fi

for gif in "$out_dir"/*.gif; do
  [[ -f "$gif" ]] || continue
  base="$(basename "$gif" .gif)"
  tmp="$(mktemp -t keyboard_actions_trim).gif"
  echo "Trimming ${base}.gif..."
  ffmpeg -y -i "$gif" \
    -vf "select='gt(scene,0.02)',setpts=N/FRAME_RATE/TB" \
    -loop 0 "$tmp"
  mv "$tmp" "$gif"
  ls -lh "$gif"
done

echo "Done."
