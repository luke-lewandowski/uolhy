dofile(".\\LooterClass.lua")

local LootItems = function(config)
	local arr = {}
	local items = {}

	arr = config.looter_lootItems

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

Form.runtime["Looter"] = 
{
	["Index"] = 1,
	["Creator"] = function(controls, panel)
		local buttonSize = 100
		local rowHeight = 30
		local margin = 5

		controls.TLootEnabled = Form:AddControl(Obj.Create("TCheckBox"), margin, margin, panel)
		controls.TLootEnabled.Caption = "Enable Looter"
		controls.TLootEnabled.OnClick = function(sender)
			Form.Config["looter_IsEnabled"] = sender.Checked
		end
		controls.TLootEnabled.Checked = Form.Config["looter_IsEnabled"]

		local updateLootBagButton = function()
			if(tonumber(UO.BackpackID) == tonumber(Form.Config["looter_containerID"])) then
				controls.TSetLootBag.Caption = "Cont: Backpack"
			else
				controls.TSetLootBag.Caption = "Cont: " .. Form.Config["looter_containerID"]
			end
		end
		controls.TSetLootBag = Form:AddControl(Obj.Create("TButton"), panel.Width - (buttonSize * 2) - (margin * 6), margin, panel)
		updateLootBagButton()
		controls.TSetLootBag.Width = buttonSize
		controls.TSetLootBag.Height = 20
		controls.TSetLootBag.OnClick = function(sender)
			Form:ShowMessage("Select new looting bag... or wait 6 seconds to set it to your backpack")
			Form.Config["looter_containerID"] = UOExt.Managers.ItemManager.GetTargetID(UO.BackpackID)
			updateLootBagButton()
		end

		controls.TLootSettingsPanel = Form:AddControl(Obj.Create("TPanel"), margin, 25, panel)
		controls.TLootSettingsPanel.Width = panel.Width - buttonSize - (margin) - 30
		controls.TLootSettingsPanel.Height = panel.Height - 30

		-- #########################################
		-- SETTINGS
		-- #########################################
		controls.TLootAllowCrimLooting = Form:AddControl(Obj.Create("TCheckBox"), margin, margin, controls.TLootSettingsPanel)
		controls.TLootAllowCrimLooting.Caption = "Allow 'Crim' looting"
		controls.TLootAllowCrimLooting.Width = 150
		controls.TLootAllowCrimLooting.Checked = Form.Config["looter_allowCrim"]
		controls.TLootAllowCrimLooting.OnClick = function(sender)
			Form.Config["looter_allowCrim"] = sender.Checked
		end
		-- TODO Crim looting needs to be implemented
		controls.TLootAllowCrimLooting.Enabled = false
		
		controls.TLootAllowSkinning = Form:AddControl(Obj.Create("TCheckBox"), (margin * 2) + 150, margin, controls.TLootSettingsPanel)
		controls.TLootAllowSkinning.Caption = "Skin corpses"
		controls.TLootAllowSkinning.Width = 150
		controls.TLootAllowSkinning.Checked = Form.Config["looter_useSkinning"]
		controls.TLootAllowSkinning.OnClick = function(sender)
			Form.Config["looter_useSkinning"] = sender.Checked
		end
		
		controls.TLootIgnoreTypes = Form:AddControl(Obj.Create("TCheckBox"), margin, 30, controls.TLootSettingsPanel)
		controls.TLootIgnoreTypes.Caption = "Ignore loot type list (loot all)"
		controls.TLootIgnoreTypes.Width = 250
		controls.TLootIgnoreTypes.Checked = Form.Config["looter_ignoreTypes"]
		controls.TLootIgnoreTypes.OnClick = function(sender)
			Form.Config["looter_ignoreTypes"] = sender.Checked
		end
		
		controls.TLootTypes = Form:AddControl(Obj.Create("TListBox"), panel.Width - buttonSize - margin, margin, panel)
		controls.TLootTypes.Height = panel.Height - (2 * margin)
		controls.TLootTypes.Width = buttonSize
		for k,v in pairs(UOExt.TableUtils.CombineKeyWithValue(Form.Config["looter_lootItems"], ",")) do
			controls.TLootTypes.Items.Add(tostring(v))
		end

		-- Add Type to list
		controls.TLooterAddType = Form:AddControl(Obj.Create("TButton"), panel.Width - buttonSize - (margin) - 20 , margin, panel)
		controls.TLooterAddType.Caption = "+"
		controls.TLooterAddType.Width = 20
		controls.TLooterAddType.Height = 20
		controls.TLooterAddType.OnClick = function(sender)
			-- Get target cursor
			-- Add it to the list if such items doesnt exist yet
			Form:ShowMessage("Select new item to add to looting list... or wait 6 seconds to cancel")
			local newItem = UOExt.Managers.ItemManager.GetTargetID()
			if(newItem > 0) then
				
					local item = World().WithID(newItem).Items[1]
					if(item ~= nil and item.Type ~= nil) then
						local exists = Form.Config["looter_lootItems"][item.Type] ~= nil
						if(Form.Config["looter_lootItems"][tostring(item.Type)] == nil) then
							local nameArr = {}

							-- Sometimes names contain other characters - filter it
							local names = {}

							string.gsub(item.Name, "(%w+)", function(s)
									if(string.match(s, "%d") == nil) then
										table.insert(names, s) 
									end
								end
							)

							local name = table.concat(names, " ")

							Form:ShowMessage(tostring(name) .. " added to loot list")
							Form.Config["looter_lootItems"][item.Type] = name
							controls.TLootTypes.Items.Add(tostring(item.Type) .. "," .. tostring(name))
						else
							Form:ShowMessage("Item already on the list!")
						end
					end
				
			end
		end

		-- Remove Type from list
		controls.TLooterRemoveType = Form:AddControl(Obj.Create("TButton"), panel.Width - buttonSize - (margin) - 20 , margin + 20, panel)
		controls.TLooterRemoveType.Caption = "-"
		controls.TLooterRemoveType.Width = 20
		controls.TLooterRemoveType.Height = 20
		controls.TLooterRemoveType.OnClick = function(sender)
			local index = controls.TLootTypes.ItemIndex
			if(index > -1) then
				local toRemove = controls.TLootTypes.Items.GetString(index)
				local id, name = toRemove:match("([^,]+),([^,]+)")

				controls.TLootTypes.Items.Delete(tonumber(index))
				Form:ShowMessage("Removed " .. name .. " from loot list")

				Form.Config["looter_lootItems"][id] = nil
			end
		end


	end,
	["ExtraSettings"] = function(config)
		Form:CreateConfigVar("looter_IsEnabled", false)
		Form:CreateConfigVar("looter_lootItems",
			-- Items to loot
			-- Note: If its detected that corps belongs to you 
			-- then it will loot all items
			{
				["3821"] = "gold", -- Gold

				-- Rocks
				["3859"] = "ruby", -- Ruby
				["3877"] = "amber" -- Amber
				--3862, -- Amethyst
				--3861 -- Citrine
			}
		)
		Form:CreateConfigVar("looter_containerID", UO.BackpackID)
		Form:CreateConfigVar("looter_distance",2)
		Form:CreateConfigVar("looter_useSkinning", true)
		Form:CreateConfigVar("looter_allowCrim", true)
		Form:CreateConfigVar("looter_ignoreTypes", true)
	end,
	["Run"] = function(config)
		Looter.Run(Form.Config)
	end
}