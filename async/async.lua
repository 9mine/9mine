local  cqueues = require"cqueues"
local  socket = require"cqueues.socket"
local cq = cqueues.new()
local sct = socket.connect("localhost", 9000)
sct:settimeout(1)

while true do
cq:wrap(function()
    local str = "world\n"
	local _, error_code = sct:send(str, 1, str:len())
	if not error_code then print("sent") end
	local response
	repeat
	response = sct:recv("*l")
	until response
	print(response)
end)
	cq:step()
end