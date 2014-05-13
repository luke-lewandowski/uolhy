-- Shared Variables used for broadcasting changes and messages across threads
LHYVars =
{
	["Shared"] = {
		-- Used for posting messages to LHY
		["Message"] = "lhy_message",
		
		-- Used to check whether Run button is pressed
		["IsRunning"] = "lhy_isrunning",

		-- JSON Encoded configuration
		["Config"] = "lhy_config"
	}
}