dofile("..\\LHYVars.lua")
dofile("..\\LHYConnect.lua")

Looter = Looter or {}

-- Amount of bodies to rememebr
Looter.History = UOExt.Structs.LimitedStack:Create(20)

-- Looter settings for use with atoms
Looter.Shared = {
	["IsRunning"] = "looter_isrunning",
	["IsLoaded"] = "looter_isloaded"
}

-- Main method that needs to be run in order to 
-- 1. Find corpses around you
-- 2. Loot & skin them (if selected)
Looter.Run = function(options)
	if(options == nil) then
		options = {
			-- Items to loot
			-- Note: If its detected that corps belongs to you 
			-- then it will loot all items
			["looter_lootItems"] = {
				["3821"] = "gold", -- Gold

				-- Rocks
				["3859"] = "ruby", -- Ruby
				["3877"] = "amber" -- Amber
			},

			-- Container of where to place all the loot
		    ["looter_containerID"] = UO.BackpackID,

		    -- Distance from your character to seek corpses
		    ["looter_distance"] = 5,

		    -- Use skinning looter for corpses around
		    ["looter_useSkinning"] = true,

		    -- Loot only specific types
		    ["looter_ignoreTypes"] = false,
		}
	end

	-- Do not run when dead
	if(UO.Hits <= 0) then
		return
	end

	local corpses = UOExt.Managers.ItemManager.GetCorpsesWithinRange(options.looter_distance)

	if(#corpses > 0) then
        for kcorps,corps in pairs(corpses) do 
            if(Looter.History:valueExists(corps.ID) ~= true) then
            	-- Open corps
                corps.Use()

                wait(600)

            	if(options.looter_useSkinning)then
        			LHYConnect.PostMessage("Running skinner")
            		UOExt.Managers.SkinningManager.CutAndLoot(corps)
            	end

            	wait(600)

            	local items = {}

                allItems = World().InContainer(corps.ID).Items

                if(#allItems > 0 and options.looter_ignoreTypes == false) then
                    for ak,av in pairs(allItems) do
                        print(av.Type)
                        for k,v in pairs(UOExt.TableUtils.GetKeys(options.looter_lootItems)) do
                            if((av.Type ~= nil and v ~= nil) and tonumber(av.Type) == tonumber(v)) then
                                table.insert(items, av)
                            end
                        end
                    end
                else
                    items = allItems
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

        		Looter.History:push(corps.ID)
            end
        end
    end
end