#!/usr/bin/env bash
# Create an isolated test disk from a DSS system CHD (4096x16x32, FAT16 at LBA63).
# Usage: bash test/prepare_mame_console.sh <system.chd> [modes|exec]
set -euo pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
base_chd="${1:?Supply the original DSS system CHD (read only)}"
variant="${2:-modes}"
case "$variant" in modes|exec) ;; *) echo 'Expected modes or exec' >&2; exit 1;; esac
cd "$repo_root"
out=build/mame-console
mkdir -p "$out"
chdman extracthd -i "$base_chd" -o "$out/$variant.img" -f
disk="$out/$variant.img@@32256"
mcopy -o -i "$disk" build/KODE.EXE ::/KODE.EXE
mcopy -o -i "$disk" test/buildtest.asm ::/MAIN.ASM
for mode in 2 3; do
 for page in 0 1; do
  sjasmplus --nologo --syntax=f "-DCON_MODE=$mode" "-DCON_PAGE=$page" \
   "--raw=$out/CON$mode$page.EXE" "--sym=$out/fixture.sym" test/mame_console_fixture.asm
  mcopy -o -i "$disk" "$out/CON$mode$page.EXE" "::/CON$mode$page.EXE"
 done
done
if [ "$variant" = modes ]; then
 printf '@echo off\r\nC:\\CON20.EXE\r\nC:\\CON21.EXE\r\nC:\\CON30.EXE\r\nC:\\CON31.EXE\r\nPAUSE\r\n' > "$out/SYSTEM.BAT"
else
 printf '@echo off\r\nSET PATH=C:\\;C:\\BIN\\;\r\nC:\\CON30.EXE\r\nPAUSE\r\n' > "$out/SYSTEM.BAT"
 printf '@echo off\r\nECHO BUILD_PASS\r\n' > "$out/BUILD.BAT"
 printf '@echo off\r\nECHO RUN_PASS\r\n' > "$out/RUN.BAT"
 printf 'all:\r\n' > "$out/MAKEFILE"
 sjasmplus --nologo --syntax=f "--raw=$out/MAKE.EXE" test/mame_console_child.asm
 for name in BUILD.BAT RUN.BAT MAKEFILE MAKE.EXE; do
  mcopy -o -i "$disk" "$out/$name" "::/$name"
 done
fi
mcopy -o -i "$disk" "$out/SYSTEM.BAT" ::/SYSTEM.BAT
chdman createhd -i "$out/$variant.img" -o "$out/$variant-system.chd" \
 -chs 4096,16,32 -c none -f
