-- CON30.EXE parent; BUILD.BAT/RUN.BAT echo markers, MAKE.EXE prints TARGET_PASS
-- and exits with code 7. See BUILD_RUN_TESTING.md for the isolated test disk.
if _G.kode_console_exec then return end
_G.kode_console_exec = true
local m = manager.machine
local p = m.devices[':maincpu'].spaces['program']
local screen = m.screens[':screen']
local keys, sy = {}, {}
for tag, port in pairs(m.ioport.ports) do
 if tag:find('^:kbd:') then for name, field in pairs(port.fields) do keys[name] = field end end
end
for line in io.lines('build/mame-console/fixture.sym') do
 local n, h = line:match('^(%w+): EQU 0x(%x+)')
 if n then sy[n] = tonumber(h, 16) end
end
local function frames(n) for i = 1, n do coroutine.yield() end end
local function key(n)
 assert(keys[n], n):set_value(1); frames(8)
 keys[n]:set_value(0); frames(8)
end
local function modifier(n, k)
 keys[n]:set_value(1); frames(8); key(k)
 keys[n]:set_value(0); frames(8)
end
local co = coroutine.create(function()
 frames(700)
 for _, keyboard in pairs(m.natkeyboard.keyboards) do keyboard.enabled = true end
 key('F9'); frames(150); screen:snapshot('exec-build1.png')
 key('F9'); frames(150); screen:snapshot('exec-build2.png')
 modifier('Left Ctrl', 'F9'); frames(150); screen:snapshot('exec-run.png')
 modifier('Left Alt', 'B'); key('T'); frames(80); key('Enter'); frames(150)
 screen:snapshot('exec-error.png')
 key('Space'); frames(150); screen:snapshot('exec-return.png')
 modifier('Left Alt', 'B'); key('L'); frames(100)
 screen:snapshot('exec-show.png'); key('Space'); frames(100)
 modifier('Left Alt', 'X'); frames(200); screen:snapshot('exec-exit.png')
 local function read(a) return p:read_u8(0x10000 + a) end
 assert(read(sy.Done) == 1, 'parent did not finish')
  local chars = {}
 for i = 0, 2559 do chars[#chars + 1] = string.char(read(0xc000 + 2 * i)) end
 local text = table.concat(chars)
 local count = 0
 for _ in text:gmatch('BUILD_PASS') do count = count + 1 end
 assert(count == 2, 'expected two continued Build outputs, got ' .. count)
 assert(text:find('RUN_PASS', 1, true), 'Run output missing')
 assert(text:find('TARGET_PASS', 1, true), 'Target output missing')
 assert(text:find('Exit code 7 - press any key', 1, true), 'error message missing')
 assert(read(sy.Mode) == 3 and read(sy.Page) == 0, 'console mode/page differs')
 print('PASS: two Builds, Run, Target error, Show log and exit with real DSS.Exec')
 m:exit()
end)
emu.register_frame_done(function()
 if coroutine.status(co) == 'suspended' then
  local ok, err = coroutine.resume(co)
  if not ok then print('FAIL', err); m:exit() end
 end
end)
