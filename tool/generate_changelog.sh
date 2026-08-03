#!/usr/bin/env bash
#
# Prepends a CHANGELOG section for NEW_VERSION with merged PRs and direct
# commits since the latest git tag, and bumps pubspec.yaml.
#
#   ./tool/generate_changelog.sh 5.0.1
#
# Requires: git, optional gh (GH_TOKEN / GITHUB_TOKEN) for PR titles.
# Retry: if pubspec and CHANGELOG already match NEW_VERSION and the tag does
# not exist yet, skips file edits (useful after a failed tag push).
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PUBSPEC="pubspec.yaml"
CHANGELOG="CHANGELOG.md"
NEW_VERSION="${1:-}"

if [[ -z "$NEW_VERSION" ]]; then
  echo "Usage: ./tool/generate_changelog.sh MAJOR.MINOR.PATCH"
  exit 1
fi

if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: invalid version '${NEW_VERSION}' (expected MAJOR.MINOR.PATCH)"
  exit 1
fi

if [[ ! -f "$PUBSPEC" ]] || [[ ! -f "$CHANGELOG" ]]; then
  echo "ERROR: run from the package root (missing $PUBSPEC or $CHANGELOG)"
  exit 1
fi

CURRENT=$(grep -E '^version:' "$PUBSPEC" | head -n1 | sed -E 's/^version:[[:space:]]*//; s/[[:space:]]+$//')

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "ERROR: not a git repository"
  exit 1
fi

if git rev-parse "refs/tags/${NEW_VERSION}" >/dev/null 2>&1; then
  echo "ERROR: tag '${NEW_VERSION}' already exists locally"
  exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/${NEW_VERSION}" >/dev/null 2>&1; then
  echo "ERROR: tag '${NEW_VERSION}' already exists on origin"
  exit 1
fi

PREV_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
if [[ -z "$PREV_TAG" ]]; then
  echo "ERROR: no previous tag found (create an initial tag first, e.g. 5.0.0)"
  exit 1
fi

HIGHER=$(printf '%s\n%s\n' "$PREV_TAG" "$NEW_VERSION" | sort -V | tail -1)
if [[ "$HIGHER" != "$NEW_VERSION" ]] || [[ "$PREV_TAG" == "$NEW_VERSION" ]]; then
  echo "ERROR: ${NEW_VERSION} must be greater than the latest tag (${PREV_TAG})"
  exit 1
fi

if grep -qE "^## \\[${NEW_VERSION}\\]" "$CHANGELOG"; then
  if [[ "$CURRENT" == "$NEW_VERSION" ]]; then
    echo "Retry mode: pubspec and CHANGELOG already at ${NEW_VERSION}; skipping file edits."
    echo "PREV_TAG=${PREV_TAG}"
    exit 0
  fi
  echo "ERROR: CHANGELOG.md already contains '## [${NEW_VERSION}]'"
  exit 1
fi

if [[ "$CURRENT" != "$PREV_TAG" ]] && [[ "$CURRENT" != "$NEW_VERSION" ]]; then
  echo "ERROR: pubspec version is '${CURRENT}', expected '${PREV_TAG}' or a retry at '${NEW_VERSION}'"
  exit 1
fi

if [[ "$CURRENT" != "$NEW_VERSION" ]]; then
  if [[ "$CURRENT" != "$PREV_TAG" ]]; then
    echo "ERROR: pubspec version '${CURRENT}' is not the latest tag '${PREV_TAG}'"
    exit 1
  fi
fi

SEEN="$(mktemp)"
trap 'rm -f "$SEEN"' EXIT

extract_pr_number() {
  local subject="$1"
  local num
  num=$(sed -n 's/Merge pull request #\([0-9]*\) from.*/\1/p' <<<"$subject")
  if [[ -n "$num" ]]; then
    echo "$num"
    return 0
  fi
  num=$(sed -n 's/.*(#\([0-9]*\)).*/\1/p' <<<"$subject")
  if [[ -n "$num" ]]; then
    echo "$num"
    return 0
  fi
  return 1
}

pr_line() {
  local num="$1"
  if grep -qx "$num" "$SEEN" 2>/dev/null; then
    return 1
  fi
  echo "$num" >>"$SEEN"

  local title author
  if command -v gh >/dev/null 2>&1; then
    title=$(gh pr view "$num" --json title -q .title 2>/dev/null || true)
    author=$(gh pr view "$num" --json author -q .author.login 2>/dev/null || true)
  fi
  if [[ -z "${title:-}" ]]; then
    title="Pull request #${num}"
  fi
  if [[ -n "${author:-}" ]]; then
    printf '* #%s %s (@%s)\n' "$num" "$title" "$author"
  else
    printf '* #%s %s\n' "$num" "$title"
  fi
}

should_skip_commit_subject() {
  local subject="$1"
  [[ "$subject" =~ ^chore:\ bump\ version\ to\  ]] && return 0
  [[ "$subject" =~ ^chore:\ release\  ]] && return 0
  [[ "$subject" =~ ^Merge\ pull\ request\ # ]] && return 0
  [[ "$subject" =~ ^Merge\ branch\  ]] && return 0
  [[ "$subject" =~ ^Release\  ]] && return 0
  return 1
}

BULLETS="$(mktemp)"
trap 'rm -f "$SEEN" "$BULLETS"' EXIT

# Commits since the previous tag (newest first). Git omits a trailing newline
# on the last record, so keep reading while sha is non-empty.
while IFS='|' read -r sha subject || [[ -n "${sha:-}" ]]; do
  [[ -z "$sha" ]] && continue
  if should_skip_commit_subject "$subject"; then
    continue
  fi
  num="$(extract_pr_number "$subject" || true)"
  if [[ -n "$num" ]]; then
    pr_line "$num" >>"$BULLETS" || true
    continue
  fi
  printf '* %s (`%s`)\n' "$subject" "$sha" >>"$BULLETS"
done < <(git log "${PREV_TAG}..HEAD" --pretty=format:'%h|%s')

if [[ ! -s "$BULLETS" ]]; then
  echo '* Maintenance release.' >>"$BULLETS"
fi

# Deduplicate while preserving order.
UNIQ="$(mktemp)"
trap 'rm -f "$SEEN" "$BULLETS" "$UNIQ"' EXIT
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  grep -Fxq "$line" "$UNIQ" 2>/dev/null && continue
  echo "$line" >>"$UNIQ"
done <"$BULLETS"

{
  echo "## [${NEW_VERSION}]"
  echo
  cat "$UNIQ"
  echo
  cat "$CHANGELOG"
} >"${CHANGELOG}.new"
mv "${CHANGELOG}.new" "$CHANGELOG"

sed -i.bak -E "s/^version:[[:space:]]*.+$/version: ${NEW_VERSION}/" "$PUBSPEC"
rm -f "${PUBSPEC}.bak"

echo "Prepared release ${NEW_VERSION} (since tag ${PREV_TAG})"
echo "PREV_TAG=${PREV_TAG}"
echo "--- CHANGELOG preview ---"
sed -n "/^## \\[${NEW_VERSION}\\]/,/^## \\[/p" "$CHANGELOG" | sed '$d'
echo "---------------------------"
