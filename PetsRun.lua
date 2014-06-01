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
			for i=1,10 do

				-- Mark Pets as "running"
				setatom(PetsClass.Shared.IsRunning, true)
				setatom(PetsClass.Shared.LastPing, getticks())
				
				if(config ~= nil) then
					print("...")
					PetsClass.Run(config)
				else
					print("Something wrong with config. Check if LHY.lua is running.")
				end

				wait(1000)
			end
		else
			sleepTime = 5000
		end
	else
		print("Start LHY.lua first and press Run")
	end

	wait(sleepTime)
end