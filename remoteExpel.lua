--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--this holds functionality for reporting (via addonmessage) how many orbs you have available

local api = {}

local prev = 0
local nextCheck = 0
local me = UnitGUID("player")

local controlScripts = {
  OnUpdate = function(self)
    if nextCheck <= GetTime() and self.reporting then
      nextCheck = GetTime() + 1
      local now = GetSpellCount(115072)
      if now ~= prev then
        prev = now
        local toSend = ("%s,%i"):format(me,now)
        SendAddonMessage("brmtRE",toSend,"RAID")
      end
    end
  end,
  OnEvent = function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
      self.reporting = true
    elseif event == "PLAYER_REGEN_ENABLED" then
      self.reporting = false
    end
  end,
  events = {
    "PLAYER_REGEN_ENABLED",
    "PLAYER_REGEN_DISABLED"
  }
}

local controlFrame = CreateFrame("frame")



local init = function(self)
  for handler,script in pairs(self.controlScripts) do
    if handler == "events" then
      for _, event in ipairs(script) do
        self.controlFrame:RegisterEvent(event)
      end
    else
      self.controlFrame:SetScript(handler,script)
    end
  end
end

BrewmasterTools.AddModule("RemoteExpel",api,init,controlFrame,controlScripts)
