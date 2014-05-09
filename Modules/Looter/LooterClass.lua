Looter = Looter or {}

-- Amount of bodies to rememebr
Looter.History = UOExt.Structs.LimitedStack:Create(20)

-- #### Nothing past this line needs changing #### --

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

	if(UO.Hits <= 0) then
		return
	end

	local corpses = UOExt.Managers.ItemManager.GetCorpsesWithinRange(options.looter_distance)

	if(#corpses > 0) then
        for kcorps,corps in pairs(corpses) do 
            if(Looter.History:valueExists(corps.ID) ~= true) then
            	-- Open corps
                corps.Use()

                wait(2000)

            	if(options.looter_useSkinning)then
            		Form:ShowMessage("Running skinner")
            		UOExt.Managers.SkinningManager.CutAndLoot(corps)
            	end

            	local items = {}

            	if(options.looter_ignoreTypes)then
            		-- Loot all
            		items = World().InContainer(corps.ID).Items
            	else
            		-- Any other body. Use selected types.
        			items = World().WithType(UOExt.TableUtils.GetKeys(options.looter_lootItems)).InContainer(corps.ID).Items
            	end

        		Form:ShowMessage("Found items to loot: " .. #items)

        		if(#items > 0)then
    				for kitem,item in pairs(items) do
    					if(string.len(item.Name) > 0) then
							Form:ShowMessage("Moving " .. item.Name)
			            	UOExt.Managers.ItemManager.MoveItemToContainer(item, options.looter_containerID)
    					else
			            	Form:ShowMessage("Skipping item with no name.")
			            end
			        end

			        Form:ShowMessage("Done looting.")
        		end

        		Looter.History:push(corps.ID)
            end
        end
    end
end