local  cqueues = require"cqueues"
local  socket = require"cqueues.socket"
local pprint = require 'libs.pprint'
local sct1 = socket.connect("localhost", 9000)
sct1:settimeout(0)
local sct2 = socket.connect("localhost", 2701)
sct2:settimeout(0)

function socket_send(socket, message)
	socket:send(message, 1, message:len())
end

function socket_recv(socket)
	local response
	response = socket:recv("*l")
	return response
end

while true do
	
local ready = {assert (cqueues.poll(sct1, sct2, 1)) }
if type(ready[1]) ~= "number" then
for i = 1, #ready do
	if ready[i]:events() == "w" then
	socket_send(ready[i], "world\n")
	else
		local response = socket_recv(ready[i])
		if response == nil then 
			socket_send(ready[i], "world\n")
		end
		print(response)
		pprint(ready[i]:events())
	end
end
end
end