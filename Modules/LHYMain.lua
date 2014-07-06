--- LHYMain
-- @module LHYMain

dofile("..\\Lib\\uoext\\uoext.lua")

--- LHYMain is the main class that drives UI, configuration collection and wiring up all modules together.
-- Each module should follow correct structure to setup configuration object & UI to to edit those settings.
-- @see LHYConnect
-- @see LHYVars
LHYMain = LHYMain or {}

--- Basic settings for this application
-- @table LHYMain.Settings
-- @field configFile Path where config for each character is saved. Default Configs folder with shard & char name.
-- @field timeInterval Interval of when Run method gets called in each module. Default 2 seconds
-- @field propagateConfigEachRun Set it to true if you want module to reflect latest changes in config even if not saved.
-- @field version Current version of LHY - this should reflect Git tag.
LHYMain.Settings = {
	-- Each character will create its own config
	["configFile"] = BaseDir .. "\\Configs\\config_" .. string.gsub(UO.CharName, " ", "_") .. "-" .. string.gsub(UO.Shard, " ", "_") .. ".json",
	["timeInterval"] = 2000,
	["pingInterval"] = 300000,
	["ServerPing"] = 600,
	-- Make sure that each time module is called that config is propagated across.
	-- If set to false, modules will be using "Saved" version of the config.
	["propagateConfigEachRun"] = true,
	["version"] = "1.0.0"
}

--- Very basic configuration for LHY - this should be extended by modules.
-- @table configStructure
-- @field charName Name of the currently logged in character
-- @field shardName Name of shard you are logged into.
local configStructure = {
	["charName"] = UO.CharName,
	["shardName"] = UO.Shard,
	[LHYVars.Shared.StayOnTop] = false
}

--- Main method containing main logic for working with modules
-- @return LHYMain
function LHYMain:Create()

	--- 
	-- @table LHYMain
	-- @field IsRunning This is set to true when LHY starts. Use this property in module to find out if LHY is running.
	local f = {
		["IsRunning"] = false
	}

	--- Property that contains all modules
	-- @see OverviewModule
	f.ModulesDefinitions = {}

	--- Local table to store all main UI controls.
	-- NOTE: All modules will get their own table so that there is no posibilty of overriding another module.
	local ems = {}

	--- Destroys all local components
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

	--- Find all atoms and wipe them (in case LHY was restarted)
	local _curAtoms = listatoms("")
	if(_curAtoms ~= nil and #_curAtoms > 0) then
		for k,v in pairs(_curAtoms) do
			setatom(v, nil)
		end
	end
	

	-- ############################# --
	-- PUBLIC METHODS
	-- ############################# --

	--- Get UI controls
	-- @return table All controls that are used on LHY (including modules)
	function f:GetControls()
		return ems
	end

	--- CreateConfigVar
	-- @param key Key in the config. Use your module name as prefix so that you dont override other modules.
	-- @param value Value for specified key
	function f:CreateConfigVar(key, value)
		if(string.len(key) > 0) then
			if(f.Config[key] == nil) then
					f.Config[key] = value
			end
		end
	end

	--- Deletes specified configuration with given key. Only if exsits.
	-- @param key A key to look for in config.
	function f:DeleteConfigVar(key)
		if(string.len(key) > 0 and f.Config[key] ~= nil) then
			table.remove(f.Config, key)
		end
	end

	--- Loads configuration from JSON and deserializes it to a key value pair table
	-- @return configStructure
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

	--- Saves current config
	function f:SaveConfiguration()
		UOExt.Config.SaveConfig(LHYMain.Settings.configFile, f.Config)

		-- Saving to atom variable as string to be doecoded elsewhere
		setatom(LHYVars.Shared.Config, json.encode(f.Config))
	end

	--- This method propagates current status of LHY (whether its running or not) to modules.
	function f:UpdateTimerStatus()
		ems.Timer.Enabled = getatom(LHYVars.Shared.IsRunning)
	end

	--- Use this method to execute LHY. All modules should have been included before this gets executed.
	function f:Run()
		f.Config = f:LoadConfiguration()

		ems.Main = Obj.Create("TForm")
		ems.Main.Caption = "UO:LemiHelpYou " .. LHYMain.Settings.version
		ems.Main.OnClose = function(sender)
			Obj.Exit()
		end
		ems.Main.Width = 500
		ems.Main.Height = 300

		if(f.Config[LHYVars.Shared.StayOnTop] ~= nil and f.Config[LHYVars.Shared.StayOnTop] == true) then
			ems.Main.FormStyle = 3 --3 -- Always on top
		else
			f.Config[LHYVars.Shared.StayOnTop] = false
		end
		
		local updatePing = function()
			setatom(LHYVars.Shared.ServerPing, UOExt.Math.Round(UOExt.Server.GetPing(),0))
		end
		
		ems.Main.BorderStyle = 3 --3 -- Do not allow resize
		-- Initial ping
		updatePing()
		-- Application is driven by a timer
		ems.Timer = Obj.Create("TTimer")
		ems.Timer.Enabled = f.IsRunning
		ems.Timer.Interval = LHYMain.Settings.timeInterval
		ems.Timer.OnTimer = function(sender)
			-- Make sure that config is propagated across all modules
			if(LHYMain.Settings.propagateConfigEachRun) then
				setatom(LHYVars.Shared.Config, json.encode(f.Config))
			end
			
			if(f.ModulesDefinitions ~= nil) then
				for k,v in pairs(f.ModulesDefinitions) do
					pcall(v.Run, f.Config)
				end
			end
		end

		-- Ping Timer
		ems.PingTimer = Obj.Create("TTimer")
		ems.PingTimer.Enabled = true
		ems.PingTimer.Interval = LHYMain.Settings.pingInterval
		ems.PingTimer.OnTimer = function(sender)
			updatePing()
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

	--- Adds control to specified parent
	-- @param control Control object. Use Obj.Create("<object>") to create object.
	-- @param left placement from left edge of parent
	-- @param top placement from top edge of parent
	-- @param parent parent object. defaults to main window.
	function f:AddControl(control, left, top, parent)
		control.Top = top
		control.Left = left

		if(parent == nil) then parent = ems.Main end
		control.Parent = parent

		return control
	end

	--- Generic method for showing message/update
	-- @param message - message to be shown 
	function f:ShowMessage(message)
			print(msg)
			UO.SysMessage(message)
	end

	return f
end
