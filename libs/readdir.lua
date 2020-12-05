local data = require 'data'
local np = require '9p'
local pprint = require 'pprint'
local ORDONLY = 0
local OWRITE = 1
local ORDWR = 2
local OEXEC = 3 

local READ_BUF_SIZ = 8096

function _9p_readdir(ctx, path) 
  local f = ctx:newfid()
  local offset = 0
  local dir, data = nil, nil

  ctx:walk(ctx.rootfid, f, path) 
  ctx:open(f, ORDONLY)  

  data = ctx:read(f, offset, READ_BUF_SIZ) 
  if data == nil then return end
  dir = tostring(data)
  --pprint(data)
  offset = offset + #data

  while (true) do
    data = ctx:read(f, offset, READ_BUF_SIZ)

    if (data == nil) then
      break
    end
    dir = dir .. tostring(data)
    pprint(dir)
    offset = offset + #(tostring(data))
  end
  ctx:clunk(f)
  return dir
end

function readdir(ctx, path) 
  local dir = {}
  local dirdata = _9p_readdir(ctx, path)
  pprint(dirdata)
  while 1 do
    local st = ctx:getstat(data.new(dirdata)) 
    if st == nil then return nil end  
    table.insert(dir, st)
    dirdata = string.sub(dirdata, st.size + 3) 
    if (#dirdata == 0) then
      break
    end
  end
  return dir
end

return readdir
