--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--this code will detect when stagger is paused, and record the relevant information




--[[
local controlFrame = CreateFrame'Frame'
controlFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
controlFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
controlFrame:SetScript("OnEvent",function(self,event)
	if event == "PLAYER_REGEN_DISABLED" then --
		normalStaggerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		timeLimit = IsEquippedItem(137044) and 13 or 10
	else
		normalStaggerFrame:UnregisterAllEvents()
	end
end)
normalStaggerFrame:SetScript("OnEvent",Update)
--]]
