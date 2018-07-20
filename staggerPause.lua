--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details


local staggerPause = CreateFrame("frame")

staggerPause.scripts = {
  OnEvent = function(self, event, unit, _, _, _, spellID)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      if unit == "player" and spellID == 115308 and self.haveBuff then
        self.pauseExpiry = self.pauseExpiry and (self.pauseExpiry + 3) or GetTime() + 3
        self:Enable()
      end
    else
      self.haveBuff = BrewmasterTools.util.UnitAura("player",228563)
    end
  end,
  OnUpdate = function(self)
    if not self.pauseExpiry or self.pauseExpiry < GetTime() then
      self:Disable()
    end
  end
}

staggerPause.events = {
  "UNIT_SPELLCAST_SUCCEEDED",
  "UNIT_AURA"
}

staggerPause.api = {
  GetStaggerPause = function()
    return  staggerPause.pauseExpiry
  end,
}

function staggerPause:Init()
  for _, event in pairs(self.events) do
    self:RegisterUnitEvent(event, "player")
  end
  for handler, script in pairs(self.scripts) do
    self:SetScript(handler, script)
  end
end

function staggerPause:Enable()
  self:SetScript("OnUpdate", self.scripts.OnUpdate)
end
function staggerPause:Disable()
  self.pauseExpiry = nil
  self:SetScript("OnUpdate", nil)
end
BrewmasterTools.AddModule("staggerPause", staggerPause)
