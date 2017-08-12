--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--defines utilities that we can use elsewhere in the addon
local util = {}


function util.makeTempAdder()
  local val = 0
  return function(toAdd, decayTime) --modify upvalue
    val = val + toAdd
    C_Timer.After(decayTime,function()
      val = val - toAdd
    end)
  end,
  function()  return val  end --access upvalue
end

function util.AllGroupMembers (reverse, forceParty)
  local unit  = (not forceParty and IsInRaid()) and 'raid' or 'party'
   local numGroupMembers = forceParty and GetNumSubgroupMembers()  or GetNumGroupMembers()
   local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
   return function()
      local ret
      if i == 0 and unit == 'party' then
         ret = 'player'
      elseif i <= numGroupMembers and i > 0 then
         ret = unit .. i
      end
      i = i + (reversed and -1 or 1)
      return ret
   end
end


BrewmasterTools.util = util
