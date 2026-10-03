#!/usr/bin/env bash
# Unit tests for the host-testable pure layers, run under a host Z80 emulator
# (test/harness.js + test/Z80core.js, forked from sprinter-lha's test harness)
# instead of a Sprinter emulator. Requires: sjasmplus, node.
#
# Covered: CmdLineOpen (Dialog_Windows/Cmdline.asm) command-line file open,
# and BuildScan (Dialog_Windows/BuildScan.asm) Build/Run decision layer.
#
#   ./test/run_tests.sh
set -uo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

if ! command -v sjasmplus >/dev/null 2>&1; then
  echo "Error: sjasmplus is not installed or not in PATH" >&2
  exit 1
fi
if ! command -v node >/dev/null 2>&1; then
  echo "Error: node is not installed or not in PATH" >&2
  exit 1
fi

mkdir -p build/test
sjasmplus --nologo --syntax=f --fullpath --raw=build/test/CMDTEST.EXE \
  --lst=build/test/cmdtest.LST test/cmdtest.asm >/dev/null
sjasmplus --nologo --syntax=f --fullpath --raw=build/test/BUILDTEST.EXE \
  --lst=build/test/buildtest.LST test/buildtest.asm >/dev/null

pass=0 fail=0

# check <label> <cmdline> <expected regex anchored to the whole report line>
# Set CWD=<path> in the environment to run the case from another current dir
# (CWD= is the drive root); default is C:\WORK, where the fixtures live.
check() {
  local label="$1" cmdline="$2" expect_re="$3"
  local out
  out="$(node "$script_dir/harness.js" build/test/CMDTEST.EXE "$script_dir/data/work" "$cmdline" 2>&1)"
  if [[ "$out" =~ ^${expect_re}$ ]]; then
    echo "ok      - $label"
    pass=$((pass+1))
  else
    echo "FAIL    - $label"
    echo "          cmdline:  [$cmdline]"
    echo "          expected: $expect_re"
    echo "          got:      $out"
    fail=$((fail+1))
  fi
}

check "empty command line -> no argument"          ""                        'A=0 NAME='
check "whitespace-only command line -> no argument" "   "                    'A=0 NAME='
check "existing file in launch dir"                 "TEST.TXT"                'A=1 NAME=C:\\WORK\\TEST.TXT'
check "existing file, lower case, uppercased"       "test.txt"                'A=1 NAME=C:\\WORK\\TEST.TXT'
check "existing file in subdirectory (relative)"    "SUB\\T2.TXT"             'A=1 NAME=C:\\WORK\\SUB\\T2.TXT'
check "explicit drive+dir path"                     "C:\\WORK\\SUB\\T2.TXT"   'A=1 NAME=C:\\WORK\\SUB\\T2.TXT'
check "drive letter, no backslash, copied verbatim" "C:TEST.TXT"              'A=1 NAME=C:TEST.TXT'
check "missing file -> absent, absolute name built" "NOFILE.TXT"              'A=2 NAME=C:\\WORK\\NOFILE.TXT'
check "second argument after space is ignored"      "TEST.TXT SECOND.TXT"     'A=1 NAME=C:\\WORK\\TEST.TXT'
CWD= check "launched from drive root, no doubled \\" "NOFILE.TXT"             'A=2 NAME=C:\\NOFILE.TXT'
CWD= check "launched from root, existing subdir file" "WORK\\TEST.TXT"        'A=1 NAME=C:\\WORK\\TEST.TXT'
# Regression: DSS trashes HL across RST #10, which used to truncate the built
# path to just the directory ("C:\TEST1"), losing the name and with it the
# extension the syntax highlighter keys off.
CWD=WORK\\TEST1 check "relative name keeps dir + name + ext" "BENCH.C"        'A=1 NAME=C:\\WORK\\TEST1\\BENCH.C'
check "explicit full path keeps name + ext"         "C:\\WORK\\TEST1\\BENCH.C" 'A=1 NAME=C:\\WORK\\TEST1\\BENCH.C'

# checkb <label> <fixture-subdir> <action> <expected regex>
# Runs BuildScan's decide/scan layer against a fixture dir mounted as C:\WORK.
checkb() {
  local label="$1" dir="$2" action="$3" expect_re="$4"
  local out
  out="$(node "$script_dir/harness.js" build/test/BUILDTEST.EXE "$script_dir/data/$dir" "$action" 2>&1)"
  if [[ "$out" =~ ^${expect_re}$ ]]; then
    echo "ok      - $label"
    pass=$((pass+1))
  else
    echo "FAIL    - $label"
    echo "          action:   [$action] in [$dir]"
    echo "          expected: $expect_re"
    echo "          got:      $out"
    fail=$((fail+1))
  fi
}

echo
checkb "Build: BUILD.BAT wins over MAKEFILE"      bld_bat  "BUILD"    'A=0 CMD=SYSTEM.EXE /C BUILD.BAT'
checkb "Build: MAKEFILE fallback"                 bld_mk   "BUILD"    'A=0 CMD=MAKE.EXE'
checkb "Build: nothing found"                     bld_none "BUILD"    'A=1 CMD='
checkb "Run: RUN.BAT with params"                 bld_run  "RUN a b"  'A=0 CMD=SYSTEM.EXE /C RUN.BAT a b'
checkb "Run: RUN.BAT no params, no trailing sp"   bld_run  "RUN"      'A=0 CMD=SYSTEM.EXE /C RUN.BAT'
checkb "Run: MAKEFILE run target"                 bld_mk   "RUN"      'A=0 CMD=MAKE.EXE run'
checkb "Run: BUILD.BAT does not satisfy Run"      bld_bat  "RUN"      'A=1 CMD='
checkb "Run: nothing found"                       bld_none "RUN"      'A=1 CMD='
checkb "Target scan: comments/.PHONY/vars/recipes filtered, chunked" \
                                                  bld_scan "TARGETS"  'A=3 LIST=all\|run\|clean'
checkb "Target scan: no makefile -> marker"       bld_none "TARGETS"  'A=9'

echo
echo "PASS: $pass  FAIL: $fail"
[ "$fail" -eq 0 ]
