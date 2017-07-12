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


--[[
Written by Rivers. Contains the necessary code to manage cooldowns
]]
--this is totally unnecessary since i won't ever actually run this file, but oh well
local aura_env = aura_env or {}
--on Init action
WeakAuras.WatchGCD()
--register addon messages
do
  --these addon messages will be used to comunicate CD information
  if not IsAddonMessagePrefixRegistered("cdTrackReset") then
    RegisterAddonMessagePrefix("cdTrackReset")
  end
  --Greet announces which spells the sender wishes to report - 'specID,name,spellID,fileID,cdDuration,cdExpires,priority'
  if not IsAddonMessagePrefixRegistered("cdTrackGreet") then
    RegisterAddonMessagePrefix("cdTrackGreet")
  end
  --Report announces when current cd info should be updated - spellid,current cd info
  if not IsAddonMessagePrefixRegistered("cdTrackReport") then
    RegisterAddonMessagePrefix("cdTrackReport")
  end
end

aura_env.toReport = {}
aura_env.reports = {}
function aura_env.sendGreetingMessage()
  --at most one or 2 messages for each raid member; no need to use AceComms
  --presumably we won't have >1 ENCOUNTER_START events in one second.
  --That'd be crazy and I'm going to consider that an acceptable risk
  local specID = GetSpecializationInfo(GetSpecialization())
  local defaultStrength = aura_env.spellsOfNote[specID].strength or -1
  local toSend = strjoin(',',GetTime(), defaultStrength)
  SendAddonMessage("cdTrackReset",toSend,"RAID")
  wipe(aura_env.toReport)
  --get specID; at this point we're probably
    for priority,ID in ipairs(aura_env.spellsOfNote[specID]) do
      local funcs = aura_env.spellDetails[ID]
      if funcs.test(ID) then
        --compose a cdTrackGreet message and send
        local currentDuration, currentExpire = funcs.report(ID)
        local name, fileID = funcs.info(ID)
        local toSend = strjoin(','GetTime() + .5,name,spellID,fileID,currentDuration,currentExpire,priority)
        SendAddonMessage("cdTrackGreet",toSend,"RAID")
        --will just iterate through toReport and check if it's any different
        aura_env.toReport[ID] = {
          id = ID
          check = funcs.report,
          duration = currentDuration,
          expires = currentExpire,
          priority = priority,
          strength = funcs.strength
        }
      end
    end
end
--convert Name-Realm to raidN and back again
function aura_env.makeConverter()
    local IDtoName = {}
    for unit in aura_env.GroupMembers() do
        IDtoName[unit] = UnitName(unit)
    end
    local NametoID = tInvert(IDtoName)
    return function(id)
        return IDtoName[id] or NametoID[id]
    end
end

local function GetAuraCooldown(auraID)
  return select(6,UnitDebuff('player',GetSpellInfo(auraID)))
end
--override because we want duration and endTime, not startTime
local function aura_GetSpellCooldown(spellID)
  local s, d = GetSpellCooldown(spellID)
  local e = s + d
  if d == 0 then
    d = GetSpellBaseCooldown(spellID)
  end
  return d, e
end

local function aura_GetSpellInfo(spellID)
  local name, _, fileID = GetSpellInfo(spellID)
  reutrn name, fileID
end

local standardTest = {
  test = IsPlayerSpell,
  report = aura_GetSpellCooldown,
  info = aura_GetSpellInfo,
  strength = 0,
}
--these are keyed by spellID; they are added to tracking when v.test(ID) is true, and v.info(ID) and v.report are used to send messages
aura_env.spellDetails = {

}
setmetatable(aura_env.spellDetails, {
  __index = standardTest,
  __newindex = function(t,k,v)
    --validate that it's correct
    if type(v) == 'table' then
      --what a handy function this is!
      WeakAuras.validate(v,standardTest)
    elseif v ~= nil then
      --deleting is allowed
      v = standardTest
    end
    rawset(t,k,v)
  end
})
aura_env.spellsOfNote = {
  --keyed by specID, table is keyed by priority, value is spellID; ice block has higher priority than cauterize, for example

}
setmetatable(aura_env.spellsOfNote,{
  __index = {} --by default nothing here
})
aura_env.raidList = setmetatable({}, {
    __index = function(t,k) --lazy table!
      t[k] = {}
      return t[k]
    end,
})

function aura_env.GetNameAndIcon(unit)
  local form = "|c%s%s|r - %s:0|t %s" --classColorunitname  - ICON group required
  local color = RAID_CLASS_COLORS[select(2,UnitClassBase(unit))].colorStr
  local name = aura_env.convertID(unit)
  local requirements = {
    [-1] = {
      7, "FULL SOAK REQUIRED"
    },
    [0] = {
      1, "CAN SOLO"
    },
    {
      2, "NEED ONE"
    },
  }
  local unitDetails = aura_env.raidList[unit]
  local icon, detail = unpack(requirements[(unitDetails.defaultStrength) or -1])
  local i = 0
  for priority, tracker in pairs(unitDetails) do
    if priority ~= 'defaultStrength' then
      if not (tracker.duration > 0 and tracker.duration ~= WeakAuras.gcdDuration()) and priority > i then
        i = priority

    end
  end
end
function aura_env.isDifferent(d1, d2, e1, e2)
  if d1 == d2 and e1 == e2 then
    return false
  elseif d1 > 0 and d ~= WeakAuras.gcdDurationInfo() then
    return true
  else
    return false
  end
end
--trigger 1
--this trigger handles all non-display information
local triggerType = 'event'
local events = {
  'FRAME_UPDATE',
  'ENCOUNTER_START',
  'GROUP_JOINED',
  'GROUP_ROSTER_UPDATE',
  'CHAT_MSG_ADDON',
  'ENCOUNTER_END',
}
function (event,...)
  if event == "GROUP_JOINED" or event == "GROUP_ROSTER_UPDATE" then
    --create new closure
    aura_env.convertID = aura_env.makeConverter()
  elseif event == "ENCOUNTER_START" then
    aura_env.convertID = aura_env.convertID or aura_env.makeConverter()
    local encounterID, _, difficultyID = ...
    if encounterID == 2038 and difficultyID == 16 then
      --mythic avatar
      aura_env.active = true
      aura_env.sendGreetingMessage()
    end
  elseif event == "ENCOUNTER_END" then
    --set false so that TSU runs cleanup
    aura_env.active = false
  elseif event == "CHAT_MSG_ADDON" then
    local prefix, message, _, sender = ...
    if prefix == "cdTrackReset" then
      --clear the table (new things to track will come)
      --I added a timestamp to this, just in case there's some lag, i'll be able to quickly accomodate it so that the cooldowns are reported properly
      wipe(aura_env.raidList[aura_env.convertID(sender)])
      local _, defaultStrength = strsplit(',',message)
      aura_env.raidList[aura_env.convertID(sender)].defaultStrength = tonumber(defaultStrength)
    elseif prefix == "cdTrackReport" then
      local spellID, newDuration, newExpires = strsplit(',',message)
      local tracker = aura_env.raidList[aura_env.convertID(sender)][spellID]
      if not tracker then return end
      tracker.duration, tracker.expires = tonumber(newDuration), tonumber(newExpires)
      --data is updated now
    elseif prefix == "cdTrackGreet" then
      --create new cd tracker
      local _,specID, name,spellID,fileID,cdDuration,cdExpires = strsplit(',',message)
      local tracker = {
        spellName = name,
        fileID = tonumber(fileID),
        duration = tonumber(cdDuration),
        expires = tonumber(cdExpires),
        spellID = tonumber(spellID)
      }
      aura_env.raidList[aura_env.convertID(sender)][tonumber(priority)] = tracker
    end
  elseif event == "FRAME_UPDATE" then --technically this could be `else` but this helps readability
    --check all things we should care about to see if it should be reported
    --report only if on cd and cooldown information suddenly changes, or if off cd and suddenly go on cd
    for k,v in pairs(aura_env.toReport) do
      local d,e = v.report(v.ID)
      if aura_env.isDifferent(d,v.duration, e, v.expires) then
        local toSend = strjoin(',',v.ID,d,e)
        v.duration, v.expires = d,e
        SendAddonMessage("cdTrackReport",toSend,"RAID")
      end
    end
  end
end

--trigger 2
local triggerType = 'stateupdate'
local triggerUpdate = 'everyframe'
function(displays)
  --nil causes this function to terminate, false triggers cleanup, true causes main body to execute
  if aura_env.active == false then
    aura_env.active = nil
    for k,v in pairs(displays) do
      v.show = false
      v.changed = true
      return true
    end
  elseif aura_env.active then
    for k,v in pairs(displays) do
      --force refresh every frame
      v.show = false
      v.changed = true
    end
    local i = 1
    for unit in aura_env.GroupMembers() do
      if UnitDebuff(unit, GetSpellInfo(239739)) then
        displays[i] = displays[i] or {}
        local d = displays[i]
        local dur, exp = select(6,UnitDebuff(unit,GetSpellInfo(239739)))
        d.show = true
        d.changed = true
        d.name, d.icon = aura_env.GetNameAndIcon(unit)
        d.progressType = 'timed'
        d.duration = dur
        d.expirationTime = exp
        d.resort = true
        i = i + 1
      end
    end
    return aura_env.active
end
