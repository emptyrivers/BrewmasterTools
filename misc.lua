--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--miscellaneous functions that don't require a whole module

function BrewmasterTools.GetNextTick(unit)
  unit = UnitExists(unit) and unit or 'player'
  for i = 1, 40 do
    local _, _, _, _, _, _, _, _, _, spellId, _, _, _, _, _, value, _ = UnitBuff(unit, i)
    if spellId == 124273 or spellId == 124274 or spellId == 124275 then
      return value
    end
  end
  return 0
end

function BrewmasterTools.GetStaggerColor()
  local perc = BrewmasterTools.GetNextTick()/UnitHealthMax('player')
  if     perc <= .015 then
    return BrewmasterTools.util.HexToRGBA('a9a9a9')
  elseif perc <= .03 then
    return BrewmasterTools.util.HexToRGBA('e3df24')
  elseif perc <= .05 then
    return BrewmasterTools.util.HexToRGBA('e39723')
  elseif perc <= .1 then
    return BrewmasterTools.util.HexToRGBA('fd1300')
  else
    return BrewmasterTools.util.HexToRGBA('fd00b2')
  end
end
