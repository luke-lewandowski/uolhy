-- ########################################
-- MODULE DEFINITION
-- ########################################

local utilityDefinition = 
{
	["TabName"] = "Utility",
	["Creator"] = function(controls, panel)
		local buttonSize = 100
		local rowHeight = 30
		local groupSpace = 17
		local margin = 5
		
		controls.TPouchGroup = Form:AddControl(Obj.Create("TGroupBox"), margin, margin + 2,panel)
		controls.TPouchGroup.Caption = " Reagent Pouch Creator "
		controls.TPouchGroup.Width = panel.Width - (margin * 3) - buttonSize - rowHeight
		controls.TPouchGroup.Height = 50
		
		controls.TMakeOne = Form:AddControl(Obj.Create("TButton"), margin * 2, groupSpace, controls.TPouchGroup)
		controls.TMakeOne.Caption = "Make Pouches"
		controls.TMakeOne.Width = 80
		controls.TMakeOne.Height = 20
		controls.TMakeOne.OnClick = function(sender)
			local pouch = PouchFrenzy
			pouch.Options.amountToMove = Form.Config["utility_regAmount"]
			pouch.Run()
			pouch = nil
		end
		
		controls.TAmountLabel = Form:AddControl(Obj.Create("TLabel"), (buttonSize), groupSpace + 3, controls.TPouchGroup)
		controls.TAmountLabel.Caption = "Reagent Amount: "
		
		controls.TReagentAmount = Form:AddControl(Obj.Create("TEdit"), (buttonSize * 2) - (margin * 3), groupSpace, controls.TPouchGroup)
		controls.TReagentAmount.Width = 40
		controls.TReagentAmount.Height = 20
		controls.TReagentAmount.Text = Form.Config["utility_regAmount"]
	
		controls.TSetReagent = Form:AddControl(Obj.Create("TButton"), (buttonSize * 2) - (margin * 4) + 50, groupSpace, controls.TPouchGroup)
		controls.TSetReagent.Caption = "Set Amount"
		controls.TSetReagent.Width = 80
		controls.TSetReagent.Height = 20
		controls.TSetReagent.OnClick = function(sender)
			Form.Config["utility_regAmount"] = tonumber(controls.TReagentAmount.Text)
			Form:ShowMessage("Updated the reagent amount per pouch.")
		end
		

		
		
	end,
	["ExtraSettings"] = function(config)
		Form:CreateConfigVar("utility_regAmount", "20")
	end,
	["Run"] = function(config)
	end
}
-- Add to ModulesDefinition to make it run
table.insert(Form.ModulesDefinitions, utilityDefinition)