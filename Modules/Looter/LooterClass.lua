dofile("..\\LHYCommon.lua")

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
	local journal = journal:new()
	if(options == nil) then
		options = {
			-- Items to loot
			["looter_lootItems"] = {
				-- Important Stuff
				["3821"] = "Gold", -- Gold
				-- Reagents
				["3981"] = "Spiders Silk", -- Spiders Silk
				["3962"] = "Black Pearl", -- Black Pearl
				["3974"] = "Mandrake Root", -- Mandrake Root
				["3976"] = "Nightshade", -- Nightshade
				["3972"] = "Garlic", -- Garlic
				["3980"] = "Sulfurous Ash", -- Sulfurous Ashe
				["3973"] = "Ginseng", -- Ginseng
				["3963"] = "Blood Moss", -- Blood Moss		
				-- Rocks
				["3859"] = "Ruby", -- Ruby
				["3877"] = "Amber", -- Amber
				["3862"] = "Amethyst", -- Amethyst
				["3873"] = "Star Sapphire", -- Star Sapphire
				["3856"] = "Emerald", -- Emerald
				["3878"] = "Diamond", -- Diamond
				["3865"] = "Sapphire", -- Sapphire
				["3861"] = "Citrine", -- Citrine
				["3885"] = "Tourmaline" -- Tourmaline
			},

			-- Container of where to place all the loot
		    ["looter_containerID"] = UO.BackpackID,

		    -- Distance from your character to seek corpses
		    ["looter_distance"] = 5,

		    -- Use skinning looter for corpses around
		    ["looter_useSkinning"] = true,

		    -- Loot only specific types
		    ["looter_ignoreTypes"] = false,
			
			-- Broadcast what you've looted in party chat
			["looter_broadcastParty"] = false,
			 
			-- Broadcast what you've looted in guild chat
			["looter_broadcastGuild"] = false,
			
			-- Broadcast what you've looted in UOAM chat
			["looter_broadcastUOAM"] = false
		}
	end

	-- Do not run when dead
	if(UO.Hits <= 0) then
		return
	end
	
	local corpses = UOExt.Managers.ItemManager.GetCorpsesWithinRange(options.looter_distance)

    --- Check if journal states something being too far or out of sight
    local reCheckAvailbility = function(journalObject)
        if(journal:find("far away", "seen", "sight") == 1) then
            LHYConnect.PostMessage("Unable to loot. Get closer to the corpse and try again.")
            return false
        end
        return true
    end

    local itemsToLoot = UOExt.TableUtils.GetKeys(options.looter_lootItems)

	if(#corpses > 0) then
        for kcorps,corps in pairs(corpses) do 
            if(Looter.History:valueExists(corps.ID) ~= true) then
            	
                local items = {}
                
                -- Open corps
                while(UO.ContType ~= 8198) do
                    corps.Use()
                    wait(300)
                end

                --local journal = NewJournal()

            	if(options.looter_useSkinning)then
                    LHYConnect.PostMessage("Running skinner")
                    local knife = UOExt.Managers.SkinningManager.FindKnife()
                    if(knife ~= nil) then
                        -- Add hides to be looted
                        table.insert(itemsToLoot, 4217)
                        -- Cut corps
                        UOExt.Managers.SkinningManager.CutCorps(corps.ID, knife)

                        -- Add something here for checking this actually happened.
                        wait(gpad(600))
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
                        for k,v in pairs(itemsToLoot) do
                            if((av.Type ~= nil and v ~= nil) and tonumber(av.Type) == tonumber(v)) then
                                table.insert(items, av)
                            end
                        end
                    end
                else
                    for ak,av in pairs(allItems) do
                        if(av ~= nil and av.Name ~= "" and av.Name ~= nil and av.ContID == corps.ID and av.Visible == true) then
                            table.insert(items, av)
                        end
                    end
                end

            	LHYConnect.PostMessage(("Found items to loot: " .. #items))

        		if(#items > 0)then
    				for kitem,item in pairs(items) do
						LHYConnect.PostMessage(("Moving " .. item.Name))
						if(options.looter_broadcastParty) then
							UO.Msg('/ Looted: '..item.Name..string.char(13))
						end
						if(options.looter_broadcastGuild) then
							UO.Msg('\ Looted: '..item.Name..string.char(13))	
						end
						if(options.looter_broadcastUOAM) then
							lootMsg = ('--Looted: '..item.Name)
							UO.Msg(string.sub(lootMsg, 1, 27)..string.char(13))	
						end
		            	UOExt.Managers.ItemManager.MoveItemToContainer(item, options.looter_containerID)
		
                        if(reCheckAvailbility(journal) ~= true) then
                            return
                        end

                        wait(gpad(600))
			        end
			        LHYConnect.PostMessage("Done looting.")
        		end

                -- Cut hides
                if(options.looter_useSkinning)then
                    wait(500)
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
                LHYConnect.PostMessage("No unlooted corpses found.")
            end
        end
    else
        LHYConnect.PostMessage("No dead bodies around you!")
    end
end

Looter.LootAll = function(container)
	if(container == nil) then
		LHYConnect.PostMessage("Container could not be passed.")
		
	end
	
	-- Make sure container is open.
	while(UO.ContID ~= container.ID) do
		container.Use()
		wait(300)
	end
						
	-- Get all the items.
	local allItems = World().InContainer(container.ID).Items
	
	local items = {}

	for ak,av in pairs(allItems) do
		if(av ~= nil and av.Name ~= "" and av.Name ~= nil and av.ContID == container.ID and av.Visible == true) then
			table.insert(items, av)
		end
	end
	
	-- Loot
	LHYConnect.PostMessage(("Found items to loot: " .. #items))

	if(#items > 0)then
		for kitem,item in pairs(items) do
			LHYConnect.PostMessage(("Moving " .. item.Name))
			UOExt.Managers.ItemManager.MoveItemToContainer(item, UO.BackpackID)
			wait(gpad(600))
		end
		LHYConnect.PostMessage("Done looting.")
		return
	end
end