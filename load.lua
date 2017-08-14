--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--this part contains all of the code that handles ADDON_LOADED and PLAYER_LOGIN

local loadFrame = CreateFrame("FRAME")

loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent",
  function(event,arg)
    if event == "ADDON_LOADED" and arg == "BrewmasterTools" then
      --call init functions for each module, replace dummy functions
      for _, module in pairs(BrewmasterTools.modules) do
        module:init()
        for name, func in pairs(module.api) do
          BrewmasterTools[name] = func
        end
      end
    end
    print('Welcome to Brwemastertools! If you encounter any issues, please visit https://github.com/emptyrivers/BrewmasterTools and open an issue, or contact Rivers#8800.')
  end
)
