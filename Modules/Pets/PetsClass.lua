dofile("..\\LHYVars.lua")
dofile("..\\LHYConnect.lua")

PetsClass = PetsClass or {}

-- Amount of bodies to rememebr
PetsClass.History = UOExt.Structs.LimitedStack:Create(20)

-- PetsClass settings for use with atoms
PetsClass.Shared = {
	["IsRunning"] = "pets_isrunning",
	["IsLoaded"] = "pets_isloaded",

    --- Ping used (in form of ticks) so that LHY can see when was the last run.
    ["LastPing"] = "pets_ping"
}

--- Keys used to get configuration for pets module
PetsClass.ConfKeys = {
    ["PetsList"] = "pets_petsList",
    ["Threshold"] = "pets_threshold",
    ["UseMagery"] = "pets_useMagery",
    ["ShowDistance"] = "pets_showDistance"
}


PetsClass.Run = function(options)
	if(options == nil) then
		options = {
			-- Pets to look after
			[PetsClass.ConfKeys.PetsList] = {
				["123"] = "amazing pet" -- Non existant pet
			},

            -- Threshold to when to use veterinary
            [PetsClass.ConfKeys.Threshold] = 80,

		    -- Distance from your character to be able to use veterinary
		    ["pets_vetDistance"] = 2,

		    -- Use skinning looter for corpses around
		    [PetsClass.ConfKeys.ShowDistance] = true,

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

    local CastSpellOnTarget = function(targetID, spellID)
        local temp = UO.LTargetID
        UO.LTargetID = targetID
        UO.Macro(15, spellID) -- Poison
        UOExt.Core.WaitForTarget()
        UO.Macro(22, 0) -- Last target
        UO.LTargetID = temp
    end

	for key,pet in pairs(options[PetsClass.ConfKeys.PetsList]) do
        local tryPet = Ground().WithID(tonumber(key)).Items

        if(#tryPet == 1) then
            local pet = tryPet[1]

            if(pet ~= nil) then
                UO.StatBar(pet.ID)

                -- Replace this with wait for gump
                wait(300)

                local health, col = GetHitBarLife(pet.ID)
                local dist = pet.Active.Dist()

                -- Make sure its always a number
                health = UOExt.Core.ConvertToInt(health)

                -- Cure is most important
                if(col ~= nil and col == "green") then
                    -- Cast cure & check fore regs for that
                    -- TODO
                    CastSpellOnTarget(pet.ID, 10)
                    UO.ExMsg(pet.ID, "Casting cure on this fela")
                end

                if(health ~= nil and tonumber(health) < options[PetsClass.ConfKeys.Threshold]) then
                    local bandages = UOExt.Managers.ItemManager.GetItemFromContainer(3617, UO.BackpackID)

                    if(pet.Active.Dist() < 2 and bandages["ID"] ~= nil) then
                        -- Use bandages
                        UO.ExMsg(pet.ID, "Using bandages on pet")
                        UOExt.Managers.ItemManager.UseItemOnItem(bandages, pet)
                        wait(5000)
                    elseif(options[PetsClass.ConfKeys.UseMagery] and health > 0) then
                        -- Use GH here
                        CastSpellOnTarget(pet.ID, 28)
                        UO.ExMsg(pet.ID, "Casting GH on pet")
                        wait(5000)
                    end
                end

                -- Only do it when its enabled and health is below 100%
                if(options[PetsClass.ConfKeys.ShowDistance] and health < 100) then
                    UO.ExMsg(pet.ID, (tostring(pet.Active.Dist()) .. "/" .. tostring(health) .. "%"))
                end
            end
        end
    end
end