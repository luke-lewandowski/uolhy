dofile(".\\LooterClass.lua")

-- ########################################
-- PRIVATE METHODS / PARAMETERS
-- ########################################

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

-- ########################################
-- MODULE DEFINITION
-- ########################################

local looterDefinition = 
{
	["TabName"] = "Looter",
	["Creator"] = function(controls, panel)
		local buttonSize = 100
		local rowHeight = 30
		local margin = 5

		-- #########################################
		-- UPPER MAIN MENU
		-- #########################################

		controls.TLootEnabled = Form:AddControl(Obj.Create("TCheckBox"), margin, margin + 2, panel)
		controls.TLootEnabled.Caption = "Enable Looter"
		controls.TLootEnabled.Width = buttonSize
		controls.TLootEnabled.OnClick = function(sender)
			Form.Config["looter_IsEnabled"] = sender.Checked
		end
		controls.TLootEnabled.Checked = Form.Config["looter_IsEnabled"]

		controls.TAutoLoot = Form:AddControl(Obj.Create("TCheckBox"), buttonSize + (margin * 2), margin + 2, panel)
		controls.TAutoLoot.Caption = "Enable Autoloot*"
		controls.TAutoLoot.OnClick = function(sender)
			Form.Config["looter_autoloot"] = sender.Checked
			if(sender.Checked) then
				Form:ShowMessage("Experimental: Looter will automatically detect corpes around you and loot them.")
			else
				Form:ShowMessage("Looter set to manual. Press " .. tostring(Form.Config["looter_manualHotkey"]) .. " to loot.")
			end
		end
		controls.TAutoLoot.Checked = Form.Config["looter_autoloot"]

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

		controls.TLootSettingsPanel = Form:AddControl(Obj.Create("TPanel"), margin, margin + 25, panel)
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

		controls.TLootAllowSkinning = Form:AddControl(Obj.Create("TCheckBox"), margin, rowHeight, controls.TLootSettingsPanel)
		controls.TLootAllowSkinning.Caption = "Skin corpses"
		controls.TLootAllowSkinning.Width = 150
		controls.TLootAllowSkinning.Checked = Form.Config["looter_useSkinning"]
		controls.TLootAllowSkinning.OnClick = function(sender)
			Form.Config["looter_useSkinning"] = sender.Checked
		end
		
		controls.TBroadcastParty = Form:AddControl(Obj.Create("TCheckBox"), margin, rowHeight * 2, controls.TLootSettingsPanel)
		controls.TBroadcastParty.Caption = "Broadcast to Party"
		controls.TBroadcastParty.Width = 150
		controls.TBroadcastParty.Checked = Form.Config["looter_broadcastParty"]
		controls.TBroadcastParty.OnClick = function(sender)
			Form.Config["looter_broadcastParty"] = sender.Checked
		end
		-- TODO broadcast to party needs to be implemented
		controls.TBroadcastParty.Enabled = false
		
		controls.TBroadcastGuild = Form:AddControl(Obj.Create("TCheckBox"), margin, rowHeight * 3, controls.TLootSettingsPanel)
		controls.TBroadcastGuild.Caption = "Broadcast to Guild"
		controls.TBroadcastGuild.Width = 150
		controls.TBroadcastGuild.Checked = Form.Config["looter_broadcastGuild"]
		controls.TBroadcastGuild.OnClick = function(sender)
			Form.Config["looter_broadcastGuild"] = sender.Checked
		end
		-- TODO broadcast to guild needs to be implemented
		controls.TBroadcastGuild.Enabled = false
		
		controls.THotKeyEdit = Form:AddControl(Obj.Create("TEdit"), (margin * 2) + 135, margin, controls.TLootSettingsPanel)
		controls.THotKeyEdit.Width = 70
		controls.THotKeyEdit.Height = 20
		controls.THotKeyEdit.Text = Form.Config["looter_manualHotkey"]

		controls.THotkeySet = Form:AddControl(Obj.Create("TButton"), (margin * 5) + (2 * buttonSize), margin, controls.TLootSettingsPanel)
		controls.THotkeySet.Width = buttonSize
		controls.THotkeySet.Height = 20
		controls.THotkeySet.Caption = "Set Hotkey"
		controls.THotkeySet.OnClick = function(sender)
			local key1, key2 = controls.THotKeyEdit.Text:match("([^\+]+)\+([^\+]+)")

			-- Very basic validation
			-- TODO: Check if each key actually exists on the key manager's list
			if(key1 == nil or key2 == nil) then
				Form:ShowMessage("Incorrect key combination given. Two keys required separated by + sign. eg. CTRL+B")
				controls.THotKeyEdit.Text = Form.Config["looter_manualHotkey"]
				return
			end

			Form:ShowMessage("Hotkey updated. Might take up to 5 seconds to start working.")
			Form.Config["looter_manualHotkey"] = string.upper(controls.THotKeyEdit.Text)
			controls.THotKeyEdit.Text = Form.Config["looter_manualHotkey"]
		end

		

		-- #########################################
		-- LOOT TYPE SETTINGS
		-- #########################################

		local toggleLootListArea = function() 
			local i = not Form.Config["looter_ignoreTypes"]

			controls.TLootTypes.Enabled = i
			controls.TLooterAddType.Enabled = i
			controls.TLooterRemoveType.Enabled = i
		end

		controls.TLootIgnoreTypes = Form:AddControl(Obj.Create("TCheckBox"), panel.Width - buttonSize - (margin) - 16, margin + 40, panel)
		controls.TLootIgnoreTypes.Checked = Form.Config["looter_ignoreTypes"]
		controls.TLootIgnoreTypes.Width = 20
		controls.TLootIgnoreTypes.OnClick = function(sender)
			Form.Config["looter_ignoreTypes"] = sender.Checked

			if(sender.Checked) then
				Form:ShowMessage("Ignoring your loot list. All items will be looted.")
			else
				Form:ShowMessage("Loot list enabled. Only items from loot list will be looted.")
			end

			toggleLootListArea()
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
		controls.TLooterRemoveType = Form:AddControl(Obj.Create("TButton"), panel.Width - buttonSize - (margin) - 20, margin + 20, panel)
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


		--- Update loot type properties (eg. disable if ignored)
		toggleLootListArea()
	end,
	["ExtraSettings"] = function(config)
		Form:CreateConfigVar("looter_IsEnabled", false)
		Form:CreateConfigVar("looter_lootItems",
			-- Items to loot
			{
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
				["3861"] = "Citrine" -- Citrine
			}
		)
		Form:CreateConfigVar("looter_containerID", UO.BackpackID)
		Form:CreateConfigVar("looter_distance",2)
		Form:CreateConfigVar("looter_useSkinning", true)
		Form:CreateConfigVar("looter_allowCrim", true)
		Form:CreateConfigVar("looter_ignoreTypes", true)
		Form:CreateConfigVar("looter_autoloot", false)

		--- Default hotkey for looting
		Form:CreateConfigVar("looter_manualHotkey", "CTRL+B")
		
		--- Broadcast features
		Form:CreateConfigVar("looter_broadcastParty", false)
		Form:CreateConfigVar("looter_broadcastGuild", false)
	end,
	["Run"] = function(config)
		-- Check here if status of looter is running
		if(config.looter_IsEnabled) then
			local loaded = getatom(Looter.Shared.IsLoaded)
			local ticks = getatom(Looter.Shared.LastPing)
			local currentPing = getticks()

			if(loaded ~= nil and (currentPing - ticks) > 60000) then
				Form:ShowMessage("Lost connection to LooterRua.lua. Open it in new tab and press Start.")
				return
			end

			if(loaded == nil) then
				Form:ShowMessage("Open LooterRun.lua and press Start to run Looter.")
				return
			end
		end
	end
}
-- Add to ModulesDefinition to make it run
table.insert(Form.ModulesDefinitions, looterDefinition)