#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/dist"
ZIP_PATH="$OUT_DIR/code-idea-jdk11-template.zip"

mkdir -p "$OUT_DIR"

TMP_DIR="$(mktemp -d)"
trap "rm -rf \"$TMP_DIR\"" EXIT

# Copy template contents into a clean temp dir so the zip has .tf at the root.
rsync -a \
  --exclude ".git" \
  --exclude "dist" \
  --exclude ".DS_Store" \
  "$ROOT_DIR/" "$TMP_DIR/"

( cd "$TMP_DIR" && zip -r "$ZIP_PATH" . >/dev/null )

echo "Template package created: $ZIP_PATH"
