--- Used for sending messages between modules.
-- @module LHYConnect

dofile("LHYVars.lua")

LHYConnect = LHYConnect or {}

--- Previous message container.
local l_prevMessage = ""

--- Posts message to the variable. It will block if message is already there.
-- @param message
LHYConnect.PostMessage = function(message)
	local currMsg = nil
	local attempts = 10

	repeat
		currMsg = LHYConnect.GetMessage()
		attempts = attempts - 1
		wait(100)
	until (currMsg == nil or attempts == 0)

	if(attempts == 0) then
		print("LHY didn't pick up message on time. Overriding it.")
	end

	l_prevMessage = currMsg

	setatom(LHYVars.Shared.Message, message)
	print(message)
end

--- Clears current message
LHYConnect.ClearMessage = function()
	setatom(LHYVars.Shared.Message, nil)
end

--- Gets message thats kept in the variable. Always clear message when not needed anymore.
-- @return message
LHYConnect.GetMessage = function()
	return getatom(LHYVars.Shared.Message)
end

--- Gets previous message (if any)
-- @return message
LHYConnect.GetPreviousMessage = function()
	return l_prevMessage
end