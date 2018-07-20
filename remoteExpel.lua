--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--this holds functionality for reporting (via addonmessage) how many orbs you have available

local remoteExpel = CreateFrame("frame")

remoteExpel.scripts = {
  OnUpdate = function(self)
    if self.nextCheck <= GetTime() then
      self.nextCheck = GetTime() + .1
      local current = GetSpellCount(115072)
      if current ~= self.prevCount then
        self.prevCount = now
        local toSend = ("%s,%i"):format(UnitGUID('player') or 'unknown',now)
        C_ChatInfo.SendAddonMessage("brmtRE",toSend,"RAID")
      end
    end
  end,
  OnEvent = function(self, event, ...)
    if InCombatLockdown() and IsInGroup() then
      self:Enable()
    else
      self:Disable()
    end
  end,
}

remoteExpel.events = {
  "PLAYER_REGEN_ENABLED",
  "PLAYER_REGEN_DISABLED"
}

function remoteExpel:Init()
  for handler,script in pairs(self.scripts) do
    self:SetScript(handler,script)
  end
  for _, event in pairs(self.events) do
    self:RegisterEvent(event)
  end
  self.scripts.OnEvent(self)
end

function remoteExpel:Enable()
  self.nextCheck = GetTime() - 1
  self.prevCount = -1
  self.enabled = true
  self:SetScript("OnUpdate", self.OnUpdate)
end

function remoteExpel:Disable()
  self.enabled = false
  self:SetScript("OnUpdate", nil)
end

BrewmasterTools.AddModule("RemoteExpel", remoteExpel)
