dofile("..\\LHYVars.lua")
dofile("..\\LHYConnect.lua")

Looter = Looter or {}

-- Amount of bodies to rememebr
Looter.History = UOExt.Structs.LimitedStack:Create(20)

-- Looter settings for use with atoms
Looter.Shared = {
	["IsRunning"] = "looter_isrunning",
	["IsLoaded"] = "looter_isloaded",

    --- Ping used (in form of ticks) so that LHY can see when was the last run.
    ["LastPing"] = "looter_ping"
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
		    ["looter_ignoreTypes"] = false
		}
	end

	-- Do not run when dead
	if(UO.Hits <= 0) then
		return
	end

	local corpses = UOExt.Managers.ItemManager.GetCorpsesWithinRange(options.looter_distance)

    --- Check if journal states something being too far or out of sight
    local reCheckAvailbility = function(journalObject)
        if(journalObject:Find("far away", "seen")) then
            LHYConnect.PostMessage("Unable to loot. Get closer to corps and try again.")
            return false
        end

        return true
    end

	if(#corpses > 0) then
        for kcorps,corps in pairs(corpses) do 
            if(Looter.History:valueExists(corps.ID) ~= true) then
            	
                local items = {}
                
                -- Open corps
                while(UO.ContType ~= 8198) do
                    corps.Use()
                    wait(300)
                end

                local journal = NewJournal()

                print(options.looter_useSkinning)
            	if(options.looter_useSkinning)then
                    LHYConnect.PostMessage("Running skinner")
                    local knife = UOExt.Managers.SkinningManager.FindKnife()
                    if(knife ~= nil) then
                        -- Add hides to be looted
                        table.insert(items, 4217)
                        -- Cut corps
                        UOExt.Managers.SkinningManager.CutCorps(corps.ID, knife)

                        -- Add something here for checking this actually happened.
                        wait(600)
                    else
                        LHYConnect.PostMessage("Unable to find dagger in your backpack.")
                    end
            	end

                
                if(reCheckAvailbility(journal) ~= true) then
                    return
                end

            	-- Check journal here for "Too far away" or "Out of sight"
                -- return

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

                            if(reCheckAvailbility(journal) ~= true) then
                                return
                            end
    					else
    						LHYConnect.PostMessage("Skipping item with no name.")
			            end
			        end
			        LHYConnect.PostMessage("Done looting.")
        		end

                -- Cut hides
                if(options.looter_useSkinning)then
                    LHYConnect.PostMessage("Cutting hides")
                    local scissors = UOExt.Managers.SkinningManager.FindScissors()
                    if(scissors ~= nil) then
                        -- Cut hides
                        UOExt.Managers.SkinningManager.CutHides(options.looter_containerID, scissors)
                    else
                        LHYConnect.PostMessage("Unable to find scissors in your backpack.")
                    end
                end

        		Looter.History:push(corps.ID)
            else
                LHYConnect.PostMessage("No unlooted corps found.")
            end
        end
    end
end