Looter = Looter or {}

-- Amount of bodies to rememebr
Looter.History = UOExt.Structs.LimitedStack:Create(20)

-- #### Nothing past this line needs changing #### --

-- Main method that needs to be run in order to 
-- 1. Find corpses around you
-- 2. Loot & skin them (if selected)
Looter.Run = function(options)
	if(optiosn == nil) then
		options = {
			-- Items to loot
			-- Note: If its detected that corps belongs to you 
			-- then it will loot all items
			["looter_lootItems"] = {
				3821, -- Gold

				-- Rocks
				3859, -- Ruby
				3877, -- Amber
				3862, -- Amethyst
				3861 -- Citrine
			},

			-- Container of where to place all the loot
		    ["looter_containerID"] = UO.BackpackID,

		    -- Distance from your character to seek corpses
		    ["looter_distance"] = 2,

		    -- Use skinning looter for corpses around
		    ["looter_useSkinning"] = true
		}
	end

	local corpses = UOExt.Managers.ItemManager.GetCorpsesWithinRange(options.looter_distance)

	if(#corpses > 0) then
        for kcorps,corps in pairs(corpses) do 
            if(Looter.History:valueExists(corps.ID) ~= true) then
            	-- Open corps
                corps.Use()

            	if(options.looter_useSkinning)then
            		form:ShowMessage("Running skinner")
            		UOExt.Managers.SkinningManager.CutAndLoot(corps)
            	end

            	local items = {}

            	if(string.find(corps.Name, UO.CharName))then
            		-- Its your own body! Loot all
            		items = World().InContainer(corps.ID).Items
            	else
            		-- Any other body. Use selected types.
        			items = World().WithType(options.looter_lootItems).InContainer(corps.ID).Items
            	end

        		form:ShowMessage("Found items to loot: " .. #items)

        		if(#items > 0)then
    				for kitem,item in pairs(items) do
			            form:ShowMessage("Moving " .. item.Name)
			            UOExt.Managers.ItemManager.MoveItemToContainer(item, options.looter_containerID)
			        end
        		end

        		Looter.History:push(corps.ID)
            end
        end
    end
end