local overviewDefinition = 
{
	["TabName"] = "Overview",
	["Creator"] = function(controls, panel)
		local buttonSize = 100
		local rowHeight = 30
		local margin = 5

		-- Save button top right hand side
		controls.TSaveButton = Form:AddControl(Obj.Create("TButton"), panel.Width - buttonSize - margin , margin, panel)
		controls.TSaveButton.Caption = "Save config"
		controls.TSaveButton.Width = buttonSize
		controls.TSaveButton.OnClick = function(sender)
			Form:SaveConfiguration()
			Form:ShowMessage("Config saved")
		end

		-- Run button
		controls.TRunButton = Form:AddControl(Obj.Create("TButton"), panel.Width - buttonSize - margin, margin + (rowHeight), panel)
		controls.TRunButton.Caption = "Run"
		controls.TRunButton.Width = buttonSize
		controls.TRunButton.OnClick = function(sender)
			local currentVar = getatom(LHYVars.Shared.IsRunning)

			if(currentVar == nil) then
				currentVar = false
			end

			currentVar = not currentVar

			setatom(LHYVars.Shared.IsRunning, currentVar)
			if(currentVar) then
				sender.Caption = "Stop"
			else
				sender.Caption = "Run"
			end
			controls.Timer.Enabled = currentVar
		end

		-- Message history
		controls.TMessageBox = Form:AddControl(Obj.Create("TListBox"), margin , margin, panel)
		controls.TMessageBox.Width = panel.Width - buttonSize - (margin * 3)
		controls.TMessageBox.Height = panel.Height - (margin * 2)

		-- Timer for message boxes
		controls.MsgTimer = Obj.Create("TTimer")
		controls.MsgTimer.Interval = 1000
		controls.MsgTimer.OnTimer = function(sender)
			print("Timer...")
			if(LHYConnect.GetMessage() ~= nil) then
				local msg = LHYConnect.GetMessage()
				Form:ShowMessage(msg)
				LHYConnect.ClearMessage()
			end
		end
		controls.MsgTimer.Enabled = true

		-- Override default messaging system
		function Form:ShowMessage(message)
			if(message ~= nil) then
				local nHour, nMinute = gettime ()
				local msg = string.format("%.2d:%.2d: %s", nHour, nMinute, message)
				controls.TMessageBox.Items.Add(msg)
				print(msg)

				UO.SysMessage(message)
				controls.TMessageBox.TopIndex = -1 + controls.TMessageBox.Items.Count
			end
		end

		Form:ShowMessage("LHY Loaded. Press Run to execute.")
	end,
	["ExtraSettings"] = function(config)
		-- Not required here
	end,
	["Run"] = function(config)
		-- Not required here
	end
}
table.insert(Form.ModulesDefinitions, overviewDefinition)