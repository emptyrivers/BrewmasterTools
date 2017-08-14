--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details


local haveBuff, pauseExpiry

--on USC - ISB:
local function OnEvent(self, event, unit, _, _, _, spellID)
  if event == "UNIT_SPELLCAST_SUCCEEDED"
  and unit == "player"
  and spellID == 115308
  and haveBuff then
    pauseExpiry = pauseExpiry and (pauseExpiry + 3) or GetTime() + 3
  end
end

local function OnUpdate(self)
  if pauseExpiry then
    pauseExpiry = GetTime() < pauseExpiry and pauseExpiry or nil
  end
  haveBuff = UnitBuff("player",(GetSpellInfo(228563)))
end

local events = {
  "UNIT_SPELLCAST_SUCCEEDED"
}

local function IsStaggerPaused()
  return pauseExpiry ~= nil, pauseExpiry
end

local name, api, init, controlFrame, controlScripts

name = "StaggerPause"

api = {
  IsStaggerPaused = IsStaggerPaused
}

function init(self)
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

controlFrame = CreateFrame("frame")

controlScripts = {
  OnEvent = OnEvent,
  OnUpdate = OnUpdate,
  events = events,
}


BrewmasterTools.AddModule(name,api,init,controlFrame,controlScripts)
