dofile(".\\PetsClass.lua")

-- ########################################
-- PRIVATE METHODS / PARAMETERS
-- ########################################

local Pets = function(config)
	local arr = {}
	local items = {}

	arr = config.pets_petsList

	items.GetItemNumbers = function()
		local numbers = {}

		for k,v in pairs(arr) do
			local name, key = items.GetItem(v)
			table.insert(numbers, key)
		end

		return numbers
	end

	items.GetItem = function(itemString)
		return itemString:match("([^,]+),([^,]+)")
	end

	items.GetItemNames = function()
		local texts = {}

		for k,v in pairs(arr) do
			local name, key = items.GetItem(v)
			table.insert(texts, name)
		end

		return texts
	end

	items.AddItem = function(id, name)
		table(arr, tostring(id) .. "," .. name)
	end

	items.RemoveItem = function(id)
		for k,v in pairs(arr) do
			local name, key = items.GetItem(v)
			if(tonumber(key) == tonumber(id)) then
				table.remove(arr, k)
			end
		end
	end

	items.GetConfig = function()
		return arr
	end
end

-- ########################################
-- MODULE DEFINITION
-- ########################################

local looterDefinition = 
{
	["TabName"] = "Pets",
	["Creator"] = function(controls, panel)
		local buttonSize = 100
		local rowHeight = 30
		local margin = 5

		controls.TPetsEnabled = Form:AddControl(Obj.Create("TCheckBox"), margin, margin, panel)
		controls.TPetsEnabled.Caption = "Enable Pets"
		controls.TPetsEnabled.OnClick = function(sender)
			Form.Config["pets_IsEnabled"] = sender.Checked
		end
		controls.TPetsEnabled.Checked = Form.Config["pets_IsEnabled"]

		controls.TPetsSettingsPanel = Form:AddControl(Obj.Create("TPanel"), margin, 25, panel)
		controls.TPetsSettingsPanel.Width = panel.Width - buttonSize - (margin) - 30
		controls.TPetsSettingsPanel.Height = panel.Height - 30

		-- #########################################
		-- SETTINGS
		-- #########################################
		controls.TUseMagery = Form:AddControl(Obj.Create("TCheckBox"), margin, margin, controls.TPetsSettingsPanel)
		controls.TUseMagery.Caption = "Use magery when out of range"
		controls.TUseMagery.Width = 200
		controls.TUseMagery.Checked = Form.Config[PetsClass.ConfKeys.UseMagery]
		controls.TUseMagery.OnClick = function(sender)
			Form.Config[PetsClass.ConfKeys.UseMagery] = sender.Checked
		end
		
		controls.TDistanceAbovePet = Form:AddControl(Obj.Create("TCheckBox"), margin, 30, controls.TPetsSettingsPanel)
		controls.TDistanceAbovePet.Caption = "Show distance to pet"
		controls.TDistanceAbovePet.Width = 200
		controls.TDistanceAbovePet.Checked = Form.Config["pets_showDistance"]
		controls.TDistanceAbovePet.OnClick = function(sender)
			Form.Config["pets_showDistance"] = sender.Checked
		end
		
		controls.TPets = Form:AddControl(Obj.Create("TListBox"), panel.Width - buttonSize - margin, margin, panel)
		controls.TPets.Height = panel.Height - (2 * margin)
		controls.TPets.Width = buttonSize
		for k,v in pairs(UOExt.TableUtils.CombineKeyWithValue(Form.Config[PetsClass.ConfKeys.PetsList], ",")) do
			controls.TPets.Items.Add(tostring(v))
		end

		-- Add pet to list
		controls.TAddPet = Form:AddControl(Obj.Create("TButton"), panel.Width - buttonSize - (margin) - 20 , margin, panel)
		controls.TAddPet.Caption = "+"
		controls.TAddPet.Width = 20
		controls.TAddPet.Height = 20
		controls.TAddPet.OnClick = function(sender)
			-- Get target cursor
			-- Add it to the list if such items doesnt exist yet
			Form:ShowMessage("Select pet to add to the list")
			local newItem = UOExt.Managers.ItemManager.GetTargetID()
			if(newItem > 0) then
				local item = World().WithID(newItem).Items[1]
				if(item ~= nil and item.Type ~= nil) then
					local exists = Form.Config[PetsClass.ConfKeys.PetsList][item.ID] ~= nil
					if(Form.Config[PetsClass.ConfKeys.PetsList][tostring(item.ID)] == nil) then
						local nameArr = {}

						-- Sometimes names contain other characters - filter it
						UO.StatBar(item.ID)
						wait(200)
						local name = item.Active.Name()

						if(name == nil or string.len(tostring(name)) == 0)then
							name = "unknown"
							Form:ShowMessage("Unable to get pet's name. This doesn't mean that pet will not be healed! You welcome to try re-add this pet again later to get his name displayed properly.")
						else
							name = UOExt.Core.Trim(name)
						end

						Form:ShowMessage(name .. " added to pet list")
						Form.Config[PetsClass.ConfKeys.PetsList][tostring(item.ID)] = name

						controls.TPets.Items.Add(tostring(item.ID) .. "," .. name)
					else
						Form:ShowMessage("Pet already on the list!")
					end
				else
					Form:ShowMessage("Unable to add selected target to the list of pets.")
				end
			end
		end

		-- Remove Type from list
		controls.TRemovePet = Form:AddControl(Obj.Create("TButton"), panel.Width - buttonSize - (margin) - 20 , margin + 20, panel)
		controls.TRemovePet.Caption = "-"
		controls.TRemovePet.Width = 20
		controls.TRemovePet.Height = 20
		controls.TRemovePet.OnClick = function(sender)
			local index = controls.TPets.ItemIndex
			if(index > -1) then
				local toRemove = controls.TPets.Items.GetString(index)
				local id, name = toRemove:match("([^,]+),([^,]+)")
				controls.TPets.Items.Delete(tonumber(index))
				Form:ShowMessage("Removed " .. name .. " from pet list")

				Form.Config[PetsClass.ConfKeys.PetsList][id] = nil

				for k,v in pairs(Form.Config[PetsClass.ConfKeys.PetsList]) do
					print(k,v)
				end
			end
		end


	end,
	["ExtraSettings"] = function(config)
		Form:CreateConfigVar("pets_IsEnabled", false)
		Form:CreateConfigVar(PetsClass.ConfKeys.PetsList,
			-- Items to loot
			{
				["123"] = "amazingpet" -- Non existant pet
			}
		)
		Form:CreateConfigVar("pets_vetDistance",2)
		Form:CreateConfigVar("pets_showDistance", true)
		Form:CreateConfigVar(PetsClass.ConfKeys.UseMagery, true)
		print(PetsClass.ConfKeys.Threshold)
		Form:CreateConfigVar(PetsClass.ConfKeys.Threshold, 80)
	end,
	["Run"] = function(config)
		-- Check here if status of looter is running
		if(config.pets_IsEnabled) then
			local loaded = getatom(PetsClass.Shared.IsLoaded)

			if(loaded == nil) then
				Form:ShowMessage("Open PetsRun.lua and press Start to run Pets.")
			end
		end

		local loaded = getatom(PetsClass.Shared.IsLoaded)
		local ticks = getatom(PetsClass.Shared.LastPing)
		local currentPing = getticks()

		if(loaded ~= nil and (currentPing - ticks) > 60000) then
			Form:ShowMessage("Lost connection to PetsRun.lua. Open it in new tab and press Start.")
			return
		end

		if(loaded == nil) then
			Form:ShowMessage("Open PetsRun.lua and press Start to run Pets.")
			return
		end
	end
}
-- Add to ModulesDefinition to make it run
table.insert(Form.ModulesDefinitions, looterDefinition)