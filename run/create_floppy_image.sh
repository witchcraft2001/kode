#!/usr/bin/env bash
set -euo pipefail

if ! command -v mformat >/dev/null 2>&1 || ! command -v mcopy >/dev/null 2>&1; then
  echo "Error: mtools is required (mformat and mcopy were not found)." >&2
  exit 1
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

exe_path="${1:-$repo_root/build/KODE.EXE}"
image_path="${2:-$repo_root/build/kode.img}"

if [ ! -f "$exe_path" ]; then
  echo "Error: EXE file not found: $exe_path" >&2
  exit 1
fi

mkdir -p "$(dirname "$image_path")"
rm -f "$image_path"

# 1.44MB floppy image with FAT12 filesystem
mformat -C -i "$image_path" -f 1440 ::

# Copy executable into image root as KODE.EXE
mcopy -i "$image_path" -o "$exe_path" ::KODE.EXE

echo "Created FAT12 floppy image: $image_path"
echo "Copied file: $exe_path -> ::KODE.EXE"
