-- Constants
BaseDir = getbasedir ()

-- Libraries & runtime
dofile(".\\Lib\\uoext\\uoext.lua")

dofile(".\\Modules\\LHYVars.lua")
dofile(".\\Modules\\LHYConnect.lua")

dofile(".\\Modules\\Looter\\LooterClass.lua")

setatom(Looter.Shared.IsLoaded, true)

while true do
	-- Check if LHY is running
	local lhyrunning = getatom(LHYVars.Shared.IsRunning)
        local sleepTime = 2000

	if(lhyrunning ~= nil and lhyrunning == true) then
		-- Mark Looter as "running"
		setatom(Looter.Shared.IsRunning, true)
		setatom(Looter.Shared.LastPing, getticks())

		-- Get config from LHY
		local config = json.decode(getatom(LHYVars.Shared.Config))
		if(config ~= nil) then
			print("...")

			local key1, key2 = config["looter_manualHotkey"]:match("([^\+]+)\+([^\+]+)")

			if(config["looter_autoloot"] ~= true) then
				sleepTime = 0
				print("Hotkeys: " .. tostring(key1) .. "+" .. tostring(key2))
				-- Manual looting
				for i=1,50,1 do
					if(UOExt.KeyManager.IfKeyPressed(key1, key2) == true) then
						print("Starting manual looting.")
						Looter.Run(config)
					end
					wait(100)
				end
			else
				-- Automatically find bodies and loot
				sleepTime = 2000
				Looter.Run(config)
			end

		else
			print("Something wrong with config. Check if LHY.lua is running.")
		end

	else
		print("Start LHY.lua first and press Run")
	end

	wait(sleepTime)
end