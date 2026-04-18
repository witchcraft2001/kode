#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
mhmt_bin="${MHMT:-$repo_root/Tools/mhmt}"

if ! command -v sjasmplus >/dev/null 2>&1; then
  echo "Error: sjasmplus is not installed or not in PATH" >&2
  exit 1
fi

if [ ! -x "$mhmt_bin" ]; then
  echo "Error: mhmt tool not found or not executable: $mhmt_bin" >&2
  exit 1
fi

mkdir -p "$repo_root/Build" "$repo_root/build/bin/HRUST"
cd "$repo_root"

sjasmplus -DSAVE_BIN=1 -DCOLLECT_INFO=0 --color=on -Wno-rdlow --msg=war --nologo --syntax=f --fullpath --lst="$repo_root/Build/Prebuilds.LST" "$repo_root/TASM_BIN.ASM"
"$mhmt_bin" -hst -zxh "$repo_root/build/bin/Prepare.bin" "$repo_root/build/bin/HRUST/Prepare.hst"
"$mhmt_bin" -hst -zxh "$repo_root/build/bin/TasmMain.bin" "$repo_root/build/bin/HRUST/TasmMain.hst"
"$mhmt_bin" -hst -zxh "$repo_root/build/bin/DialogWN.bin" "$repo_root/build/bin/HRUST/DialogWN.hst"
"$mhmt_bin" -hst -zxh "$repo_root/build/bin/MenuBar.bin" "$repo_root/build/bin/HRUST/MenuBar.hst"
"$mhmt_bin" -hst -zxh "$repo_root/build/bin/Command.bin" "$repo_root/build/bin/HRUST/Command.hst"
sjasmplus --longptr --nologo --syntax=f --fullpath --lst="$repo_root/Build/KodeEXE.LST" "$repo_root/TasmEXE.asm"
