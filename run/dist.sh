#!/usr/bin/env bash
# Build a release zip for KODE: the program, SYNTAX profiles, both manuals
# (doc/kode_ru.txt recoded to CP866, doc/kode_en.txt), FILE_ID.DIZ and
# version.txt. All entry names are 8.3 so the archive unpacks cleanly on
# the Sprinter FAT filesystem.
#
# Usage: run/dist.sh [output.zip]
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

exe="build/KODE.EXE"
[ -f "$exe" ] || { echo "Building KODE.EXE..." >&2; run/make.sh; }

# Version (major.minor.build) straight from version.inc:
#   DEFINE _progVERSION '0.1.2'
version="$(awk -F"'" '/DEFINE[ \t]+_progVERSION/ { print $2; exit }' version.inc)"
case "$version" in
  [0-9]*.[0-9]*.[0-9]*)
    ;;
  *)
    echo "Could not determine KODE version from version.inc" >&2
    exit 1
    ;;
esac

name="kode-$version"
if [ "$#" -eq 0 ]; then
  out="build/$name.zip"
  # Do not leave stale versioned release archives beside the current one.
  find build -maxdepth 1 -type f -name 'kode-*.zip' -not -name "$name.zip" -delete
else
  out="$1"
fi
stage="build/dist"

rm -rf "$stage"
mkdir -p "$stage/SYNTAX"

# Sources are UTF-8 (editable in the repo). For the Sprinter, recode the
# Russian manual to CP866; the English one is ASCII. Both get DOS line ends.
to_dos() { perl -pe 's/\r?\n/\r\n/'; }                       # LF -> CRLF
with_version() {
  sed -E "s/(KODE v\.)[0-9]+\.[0-9]+\.[0-9]+/\\1$version/g"
}
if command -v iconv >/dev/null 2>&1; then
  with_version < doc/kode_ru.txt | iconv -f UTF-8 -t CP866 | to_dos > "$stage/kode_ru.txt"
else
  echo "warning: iconv not found, shipping kode_ru.txt as UTF-8" >&2
  with_version < doc/kode_ru.txt | to_dos > "$stage/kode_ru.txt"
fi
with_version < doc/kode_en.txt | to_dos > "$stage/kode_en.txt"

# FILE_ID.DIZ: the classic BBS-style archive description. Generated here
# so the version and release date can never go stale.
release_date="$(date +%Y-%m-%d)"
to_dos > "$stage/FILE_ID.DIZ" <<EOF
KODE v$version - text editor for
the Sprinter computer (Peters
Plus, Estex/DSS). Multi-window
editing, syntax highlighting and
Build/Run integration (BAT and
MAKEFILE). By Anton Enin (1999),
Anatoliy Belyanskiy (Sprinter
Team) and Dmitry Mikhalchenkov.
FidoNet: 2:5030/1997.10
Released: $release_date
EOF

# Program + runtime files (copied verbatim - parsed by KODE as-is).
cp "$exe" "$stage/KODE.EXE"
printf '%s\n' "$version" > "$stage/version.txt"
cp syntax/index.lst "$stage/SYNTAX/INDEX.LST"
for syn_file in "$repo_root/syntax/"*.syn; do
  [ -e "$syn_file" ] || continue
  base=$(basename "$syn_file")
  upper=$(printf '%s' "$base" | tr 'a-z' 'A-Z')
  cp "$syn_file" "$stage/SYNTAX/$upper"
done

# Zip the staged files at the archive ROOT (no top-level folder): the Sprinter
# unpacks straight into the target dir, so KODE.EXE lands in the root and
# SYNTAX/ stays a subdir. Every entry is an 8.3 name.
rm -f "$out"
( cd "$stage" && zip -rq "$repo_root/$out" \
    KODE.EXE version.txt FILE_ID.DIZ kode_ru.txt kode_en.txt SYNTAX )

echo "Built $out"
unzip -l "$out"
