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

	if(lhyrunning ~= nil and lhyrunning == true) then
		-- Mark Pets as "running"
		setatom(PetsClass.Shared.IsRunning, true)
		
		-- Get config from LHY
		local config = json.decode(getatom(LHYVars.Shared.Config))
		if(config ~= nil) then
			-- Health print out is handled in timer in UI

			-- Drive overhead distance for pets
			if(config["pets_IsEnabled"] == false) then
				print("Enable Show Distance in Pets to get overhead distance showing.")
				wait(10000)
			end

			if(config["pets_showDistance"]) then
				PetsClass.ShowOverhead(config)
			end
			
		else
			print("Something wrong with config. Check if LHY.lua is running.")
		end

	else
		print("Start LHY.lua first and press Run")
	end

	wait(2000)
end