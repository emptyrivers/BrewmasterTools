--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--this holds code for normalized stagger

--if BrewmasterTools.me ~= "MONK" then return end -- only monks have stagger

local api = {}
local util = BrewmasterTools.util

local addToPool, getVal = util.makeTempAdder()

local normalStagger = CreateFrame('frame')
--controlFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

normalStagger.api = {GetNormalStagger = getVal}
normalStagger.filter = {
	--default value
	__index = function() return .75 end,
	-- testing purposes. Dummies are enemies too!
	[167381] = 1,  --dummy strike
	[167385] = .5, --Uber strike
}

setmetatable(normalStagger.filter,normalStagger.filter)

local function handleCLEU(self, _, eventType, _, _, _, _, _, destGUID, ...)
	if destGUID == UnitGUID'player' then --grab only things that target me
		local offset = 4
		if eventType=="SPELL_ABSORBED" then --stagger's mitigation is all in absorb
			if GetSpellInfo((select(offset, ...)))==(select(offset + 1, ...)) then
				local absorbedSpell  = select(offset, ...)
				offset = offset + 3
				if select(offset + 4, ...) ==115069 then --we only want damage that is staggered
					addToPool(self.filter[absorbedSpell] * (select(offset + 7, ...)), self.timeLimit)
				end
			else -- this is a swing. Swings are always counted.
				if select(offset + 4,...) ==115069 then --we only want damage that is staggered
					addToPool((select(offset + 7, ...)), self.timeLimit)
				end
			end
		end
	end
end

normalStagger.scripts = {
	OnEvent = function(self, event, _, eventType, _, _, _, _, _, destGUID, ...)
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			handleCLEU(self, CombatLogGetCurrentEventInfo())
		elseif event == "PLAYER_REGEN_ENABLED" then
			self:Disable()
		elseif event == "PLAYER_REGEN_DISABLED" then
			self:Enable()
		else
			if InCombatLockdown() then
				self:Enable()
			else
				self:Disable()
			end
		end
	end
}

normalStagger.events = {"COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"}

function normalStagger:Init()
	for handler, script in pairs(self.scripts) do
		self:SetScript(handler, script)
	end
	for _, event in pairs(self.events) do
		self:RegisterEvent(event)
	end
	self.scripts.OnEvent(self)
end

function normalStagger:Enable()
	self.timeLimit = 10 + ((IsEquippedItem(137044) and UnitLevel('player') <= 115) and 3 or 0) + (IsPlayerSpell(280515) and 3 or 0)
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function normalStagger:Disable()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

BrewmasterTools.AddModule('NormalStagger',normalStagger)
