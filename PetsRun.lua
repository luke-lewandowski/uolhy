-- Constants
BaseDir = getbasedir ()

-- Libraries & runtime
dofile(".\\Lib\\uoext\\uoext.lua")

dofile(".\\Modules\\LHYVars.lua")
dofile(".\\Modules\\LHYConnect.lua")

dofile(".\\Modules\\Pets\\PetsClass.lua")

setatom(PetsClass.Shared.IsLoaded, true)

while true do
	-- Check if LHY is running
	local lhyrunning = getatom(LHYVars.Shared.IsRunning)
	local sleepTime = 2000

	if(lhyrunning ~= nil and lhyrunning == true) then
		-- Get config from LHY
		-- Expensive call. Lets not make it too often.
		local config = json.decode(getatom(LHYVars.Shared.Config))

		if(config ~= nil) then
			sleepTime = 100
			-- Mark Pets as "running"
			setatom(PetsClass.Shared.IsRunning, true)
			setatom(PetsClass.Shared.LastPing, getticks())
			
			local key1, key2 = config[PetsClass.Shared.HotKey]:match("([^\+]+)\+([^\+]+)")

			for i=1,50,1 do
				if(UOExt.KeyManager.IfKeyPressed(key1, key2) == true) then
					print("Starting manual healing.")
					PetsClass.Run(config)
				end
				if(i%10 == 0) then
					PetsClass.ShowDistance(config)
				end
				wait(100)
			end

			PetsClass.ShowDistance(config)
		else
			sleepTime = 5000
			print("Something wrong with config. Check if LHY.lua is running.")
		end
	else
		print("Start LHY.lua first and press Run")
	end

	wait(sleepTime)
end