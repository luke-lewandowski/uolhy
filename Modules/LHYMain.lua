dofile("..\\Lib\\uoext\\uoext.lua")

LHYMain = LHYMain or {}

-- Basic settings for this applications
LHYMain.Settings = {
	-- Each character will create its own config
	["configFile"] = BaseDir .. "\\Configs\\config_" .. string.gsub(UO.CharName, " ", "_") .. "-" .. string.gsub(UO.Shard, " ", "_") .. ".json",
	["timeInterval"] = 2000,
	["version"] = "0.2"
}

-- JSON config file should mimic following structure
local configStructure = {
	["charName"] = UO.CharName,
	["shardName"] = UO.Shard
}

-- Main method containing main logic for working with modules
function LHYMain:Create()
	local f = {
		["IsRunning"] = false
	}

	-- Property that contains all modules
	f.ModulesDefinitions = {}

	-- Local table to store all main UI controls.
	-- NOTE: All modules will get their own table so that there is no posibilty of overriding another module.
	local ems = {}

	-- Destroys all local components
	local destroy = function()
		for k,v in pairs(ems) do
			-- Check if its module objects to be cleaned
			if(string.find(tostring(k), "_controls_")) then
				for subk,subv in pairs(v) do
					Obj.Free(subv)
				end
			else
				Obj.Free(v)
			end
		end
	end

	-- ############################# --
	-- PUBLIC METHODS
	-- ############################# --

	function f:GetControls()
		return ems
	end

	function f:CreateConfigVar(key, value)
		if(string.len(key) > 0) then
			if(f.Config[key] == nil) then
					f.Config[key] = value
			end
		end
	end

	function f:DeleteConfigVar(key)
		if(string.len(key) > 0 and f.Config[key] ~= nil) then
			table.remove(f.Config, key)
		end
	end

	function f:LoadConfiguration()
		local settings = UOExt.Config.GetConfig(LHYMain.Settings.configFile)

		if(settings == nil) then
			UOExt.Config.SaveConfig(LHYMain.Settings.configFile, configStructure)
			settings = configStructure
		end

		-- Saving to atom variable as string to be decoded elsehwere
		setatom(LHYVars.Shared.Config, json.encode(settings))
		return settings
	end

	function f:SaveConfiguration()
		UOExt.Config.SaveConfig(LHYMain.Settings.configFile, f.Config)

		-- Saving to atom variable as string to be doecoded elsewhere
		setatom(LHYVars.Shared.Config, json.encode(f.Config))
	end

	function f:Run()
		f.Config = f:LoadConfiguration()

		ems.Main = Obj.Create("TForm")
		ems.Main.Caption = "UO:LemiHelpYou " .. LHYMain.Settings.version
		ems.Main.OnClose = function(sender)
			Obj.Exit()
		end
		ems.Main.Width = 500
		ems.Main.Height = 150
		ems.Main.FormStyle = 3 -- Always on top
		ems.Main.BorderStyle = 3 -- Do not allow resize

		-- Application is driven by a timer
		ems.Timer = Obj.Create("TTimer")
		ems.Timer.Enabled = f.IsRunning
		ems.Timer.Interval = LHYMain.Settings.timeInterval
		ems.Timer.OnTimer = function(sender)
			if(f.ModulesDefinitions ~= nil) then
				for k,v in pairs(f.ModulesDefinitions) do
					pcall(v.Run, f.Config)
				end
			end
		end

		ems.TTab = f:AddControl(Obj.Create("TTabControl"), 5, 5)
		ems.TTab.Width = ems.Main.Width - 20
		ems.TTab.Height = ems.Main.Height - 40

		-- Setup all tabs based on what has been provided in config below
		if(f.ModulesDefinitions ~= nil) then
			for k,v in pairs(f.ModulesDefinitions) do
				local index = k - 1
				-- Setup configuration
				if(v.ExtraSettings ~= nil) then
					local extsuc = pcall(v.ExtraSettings, f.Config)

					if(extsuc ~= true) then
						print("Issues in " .. v.TabName .. " extra settings.")
					end
				end
				
				ems.TTab.Tabs.Add(v.TabName)
				-- Create panel for that tab
				local tab = f:AddControl(Obj.Create("TPanel"), 5, 25, ems.TTab)
				tab.Width = ems.TTab.Width - 10
				tab.Height = ems.TTab.Height - 25 - 5

				if(ems.TTab.Tabs.Count > 1)then
					tab.Visible = false
				end

				ems["_tab" .. index] = tab
				-- Used to isolate module controsl from everything else
				ems["_tab_controls_" .. index] = {}

				-- Call Creator of module and pass in tab and pannel to be used as a parent
				local suc = pcall(v.Creator, ems["_tab_controls_" .. index], tab)

				if(suc ~= true) then
					print("Issues in " .. tostring(index))
				end
			end
		end

		ems.TTab.OnChange = function(sender)
			-- Show/Hide correct tabs
			if(f.ModulesDefinitions ~= nil) then
				for k,v in pairs(f.ModulesDefinitions) do
					local index = k - 1
					if(v ~= nil and index == sender.TabIndex) then
						-- Show correct one
						ems["_tab" .. index].Visible = true
					else
						-- Hide all others
						ems["_tab" .. index].Visible = false
					end
				end
			end
		end
		
		ems.Main.Show()

		Obj.Loop()
		destroy()
	end

	function f:AddControl(control, left, top, parent)
		control.Top = top
		control.Left = left

		if(parent == nil) then parent = ems.Main end
		control.Parent = parent

		return control
	end

	function f:ShowMessage(message)
			print(msg)
			UO.SysMessage(message)
	end

	return f
end
