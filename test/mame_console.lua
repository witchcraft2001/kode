-- Run the four CON20/CON21/CON30/CON31.EXE parents from SYSTEM.BAT.
-- Symbols: build/mame-console/fixture.sym; reports and screenshots in MAME output.
if _G.kode_console_test then return end
_G.kode_console_test = true
local m = manager.machine
local cpu = m.devices[':maincpu']
local p = cpu.spaces['program']
local screen = m.screens[':screen']
local sy, keys = {}, {}
for line in io.lines('build/mame-console/fixture.sym') do
 local n, h = line:match('^(%w+): EQU 0x(%x+)')
 if n then sy[n] = tonumber(h, 16) end
end
for tag, port in pairs(m.ioport.ports) do
 if tag:find('^:kbd:') then
  for name, field in pairs(port.fields) do keys[name] = field end
 end
end
local function frames(n) for i = 1, n do coroutine.yield() end end
local function key(n)
 assert(keys[n], n):set_value(1); frames(8)
 keys[n]:set_value(0); frames(8)
end
local function alt(n)
 keys['Left Alt']:set_value(1); frames(8); key(n)
 keys['Left Alt']:set_value(0); frames(8)
end
-- Sprinter exposes the currently banked Z80 RAM at #10000 + CPU address.
local function read(a) return p:read_u8(0x10000 + a) end
local co = coroutine.create(function()
 frames(700)
 for _, keyboard in pairs(m.natkeyboard.keyboards) do keyboard.enabled = true end
 for _, mode in ipairs({2, 3}) do
  for _, page in ipairs({0, 1}) do
   local name = 'console-' .. mode .. '-' .. page
   screen:snapshot(name .. '-editor.png')
   alt('B'); key('L'); frames(100)
   screen:snapshot(name .. '-show.png')
   key('Space'); frames(100)
   screen:snapshot(name .. '-return.png')
   alt('X'); frames(200)
   screen:snapshot(name .. '-exit.png')
   assert(read(sy.Done) == 1, name .. ': parent did not finish')
   assert(read(sy.Match) == 1, name .. ': characters/attributes differ')
   assert(read(sy.Result) == 0, name .. ': Kode exit failed')
   assert(read(sy.Mode) == mode and read(sy.Page) == page, name .. ': mode/page differ')
   assert(read(sy.Cursor) == mode * 40 - 41 and read(sy.Cursor + 1) == 31,
          name .. ': bottom-right cursor differs')
   print('PASS', name, '5120 bytes, mode, page, cursor')
   p:write_u8(0x10000 + sy.ExitFlag, 1)
   frames(700)
  end
 end
 print('PASS: 4 real BIOS/DSS console transitions')
 m:exit()
end)
emu.register_frame_done(function()
 if coroutine.status(co) == 'suspended' then
  local ok, err = coroutine.resume(co)
  if not ok then print('FAIL', err); m:exit() end
 end
end)
