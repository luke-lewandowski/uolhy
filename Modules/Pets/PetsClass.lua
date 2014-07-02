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
    ["LastPing"] = "pets_ping",

    ["HotKey"] = "pets_manualHotkey"
}

--- Keys used to get configuration for pets module
PetsClass.ConfKeys = {
    ["PetsList"] = "pets_petsList",
    ["Threshold"] = "pets_threshold",
    ["UseMagery"] = "pets_useMagery",
    ["ShowDistance"] = "pets_showDistance",
    ["Distance"] = "pets_distance"
}

PetsClass.GetDefaultOptions = function()
    local options = {
        -- Pets to look after
        [PetsClass.ConfKeys.PetsList] = {
            ["123"] = "amazing pet" -- Non existant pet
        },

        -- Threshold to when to use veterinary
        [PetsClass.ConfKeys.Threshold] = 98,

        -- Distance from your character to be able to use veterinary
        [PetsClass.ConfKeys.Distance] = 2,

        -- Use skinning looter for corpses around
        [PetsClass.ConfKeys.ShowDistance] = true,
        -- Loot only specific types
        [PetsClass.ConfKeys.UseMagery] = true
    }

    return options
end

PetsClass.ShowDistance = function(options)
    if(options == nil) then
        options = PetsClass.GetDefaultOptions()
    end

    -- Do not run when dead
    if(UO.Hits <= 0) then
        return
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

                -- Only do it when its enabled and health is below 100%
                if(options[PetsClass.ConfKeys.ShowDistance] and health < 100) then
                    UO.ExMsg(pet.ID, (tostring(pet.Active.Dist()) .. "/" .. tostring(health) .. "%"))
                end
            end
        end
    end

end

PetsClass.Run = function(options)
	if(options == nil) then
		options = PetsClass.GetDefaultOptions()
	end

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

    local petPool = {}

    --- Collect info about specific pets so that we can process them in order
    for key,pet in pairs(options[PetsClass.ConfKeys.PetsList]) do
        local tryPet = Ground().WithID(tonumber(key)).Items

        if(#tryPet == 1) then
            local pet = tryPet[1]

            if(pet ~= nil) then
                UO.StatBar(pet.ID)
                local health, col = GetHitBarLife(pet.ID)
                local dist = pet.Active.Dist()

                -- Make sure its always a number
                health = UOExt.Core.ConvertToInt(health)

                pet["health"] = health
                pet["healthcol"] = col

                table.insert(petPool, pet)
            end
        end
    end

    -- TODO sort it by health here so that we can attend to sicker pets first

    local journal = journal:new()
    local message = ""
    local actionTimeOut = 5000

	for key,pet in pairs(petPool) do
        -- Cure is most important
        if(pet.healthcol ~= nil and pet.healthcol == "green" and options[PetsClass.ConfKeys.UseMagery]) then
            -- Cast cure & check fore regs for that
            -- TODO Check for regs.
            CastSpellOnTarget(pet.ID, 10)

            message = "Casting cure on this fela"
            LHYConnect.PostMessage(message)
            UO.ExMsg(pet.ID, message)
        end

        if(pet.health ~= nil and tonumber(pet.health) < options[PetsClass.ConfKeys.Threshold]) then
            local bandages = UOExt.Managers.ItemManager.GetItemFromContainer(3617, UO.BackpackID)

            if(pet.Active.Dist() < options[PetsClass.ConfKeys.Distance] and bandages["ID"] ~= nil) then
                -- Use bandages
                message = "Using bandages on pet"
                LHYConnect.PostMessage(message)
                UO.ExMsg(pet.ID, message)

                journal:clear()
                local time = actionTimeOut
                UOExt.Managers.ItemManager.UseItemOnItem(bandages, pet)
				repeat
                    time = time - 100

                    -- TODO: Find out here if target is poisoned if so then cure it before bandages tick in.

					wait(100)
                until journal:find("finish", "too far away", "close") ~= nil or time < 0
				
                -- Possible messages
                -- "You finish applying the bandages"
                -- "That is too far away."
                -- "You did not stay close enough to heal your patient!"
                -- "That being is not damaged!"
                -- "You have cured the target of all poisons!"
                
            elseif(options[PetsClass.ConfKeys.UseMagery] and pet.health > 0 and UO.Mana > 10) then
                -- Use GH here
				-- Make sure that you have over 10 mana otherwise it will keep trying to cast with not enough mana.
                CastSpellOnTarget(pet.ID, 28)
                message = "Casting GH on pet"
                LHYConnect.PostMessage(message)
                UO.ExMsg(pet.ID, message)
                wait(5000)
            end
        end
    end
end