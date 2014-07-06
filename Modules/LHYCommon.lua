--- Used for holding common methods shared across all modules and runners
-- @module LHYCommon

dofile("LHYVars.lua")
dofile("LHYConnect.lua")

LHYCommon = LHYCommon or {}

LHYCommon.GetPingAdjustedDelay = function(delay)
	local ping = getatom(LHYVars.Shared.ServerPing) or 600 -- default
	return UOExt.Server.GetPingAdjustedDelay(ping,delay)
end

-- Aliases
gpad = function(delay)
	return LHYCommon.GetPingAdjustedDelay(delay)
end