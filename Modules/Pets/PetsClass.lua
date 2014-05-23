dofile("..\\LHYVars.lua")
dofile("..\\LHYConnect.lua")

PetsClass = PetsClass or {}

-- Amount of bodies to rememebr
PetsClass.History = UOExt.Structs.LimitedStack:Create(20)

-- PetsClass settings for use with atoms
PetsClass.Shared = {
	["IsRunning"] = "pets_isrunning",
	["IsLoaded"] = "pets_isloaded"
}

PetsClass.ShowOverhead = function(options)
    if (options == nil) then 
        return
    end

    if(options["pets_petsList"] == nil) then
        return
    end

    for key,values in pairs(options.pets_petsList) do       
        local animal = World().WithID(key).InRange(8).Items[1]
        if(animal ~= nil) then
            UO.ExMsg(key, tostring(animal.Active.Dist()))
            wait(1000)
        end
    end
end


PetsClass.Run = function(options)
	if(options == nil) then
		options = {
			-- Pets to look after
			["pets_petsList"] = {
				["123"] = "amazing pet" -- Non existant pet
			},

		    -- Distance from your character to be able to use veterinary
		    ["pets_vetDistance"] = 2,

		    -- Use skinning looter for corpses around
		    ["pets_showDistance"] = true,

		    -- Loot only specific types
		    ["pets_useMagery"] = true,
		}
	end

    -- Workflow
    -- Loop through pets
    -- If IDs & distance is ok (open health bar)
    -- Check health below is above threshold
    -- If distance above limit then use magery (GH - if got regs)
    -- If distance below limit use veterinary (if bandages are there)

	-- Do not run when dead
	if(UO.Hits <= 0) then
		return
	end

	local corpses = UOExt.Managers.ItemManager.GetCorpsesWithinRange(options.looter_distance)

	if(#corpses > 0) then
        for kcorps,corps in pairs(corpses) do 
            if(PetsClass.History:valueExists(corps.ID) ~= true) then
            	-- Open corps
                corps.Use()

                wait(600)

            	if(options.looter_useSkinning)then
        			LHYConnect.PostMessage("Running skinner")
            		UOExt.Managers.SkinningManager.CutAndLoot(corps)
            	end

            	wait(2000)

            	local items = {}

            	if(options.looter_ignoreTypes)then
            		-- Loot all
            		items = World().InContainer(corps.ID).Items
            	else
            		-- Any other body. Use selected types.
            		print("Looking for following types")
            		for k,v in pairs(UOExt.TableUtils.GetKeys(options.looter_lootItems)) do
            			print(k,v)
            		end

        			items = World().WithType(UOExt.TableUtils.GetKeys(options.looter_lootItems)).InContainer(corps.ID).Items
            	end

            	LHYConnect.PostMessage(("Found items to loot: " .. #items))

        		if(#items > 0)then
    				for kitem,item in pairs(items) do
    					if(string.len(item.Name) > 0) then
    						LHYConnect.PostMessage(("Moving " .. item.Name))
			            	UOExt.Managers.ItemManager.MoveItemToContainer(item, options.looter_containerID)
    					else
    						LHYConnect.PostMessage("Skipping item with no name.")
			            end
			        end
			        LHYConnect.PostMessage("Done looting.")
        		end

        		PetsClass.History:push(corps.ID)
            end
        end
    end
end