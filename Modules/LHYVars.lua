--- Definition of LHY variables to be used across.
-- @module LHYVars


--- Container for all variables that are going to be shared globaly
-- @table LHYVars
-- @field Shared Shared Variables used for broadcasting changes and messages across threads
LHYVars =
{
	---
	-- @table Shared
	-- @field Message name of the message key used in atoms
	-- @field IsRunning name of the key used for capturing whether LHY is running
	-- @field Config name of key that carries configuration
	["Shared"] = {
		["Message"] = "lhy_message",
		["IsRunning"] = "lhy_isrunning",
		["Config"] = "lhy_config",
		["StayOnTop"] = "lhy_stayontop",
		["ServerPing"] = "lhy_serverping"
	}
}
