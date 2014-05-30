--- Used for sending messages between modules.
-- @module LHYConnect

dofile("LHYVars.lua")

LHYConnect = LHYConnect or {}

LHYConnect.PostMessage = function(message)
	setatom(LHYVars.Shared.Message, message)
end

LHYConnect.ClearMessage = function()
	setatom(LHYVars.Shared.Message, nil)
end

LHYConnect.GetMessage = function()
	return getatom(LHYVars.Shared.Message)
end