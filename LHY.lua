-- Constants
BaseDir = getbasedir ()

-- Libraries & runtime
dofile(".\\Lib\\uoext\\uoext.lua")

dofile(".\\Modules\\LHYVars.lua")
dofile(".\\Modules\\LHYConnect.lua")
dofile(".\\Modules\\LHYMain.lua")

-- Global property used for accessing form
Form = LHYMain:Create()

-- Modules
dofile(".\\Modules\\Overview\\OverviewModule.lua")
dofile(".\\Modules\\Looter\\LooterModule.lua")

Form:Run()