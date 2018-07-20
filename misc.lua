--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--miscellaneous functions that don't require a whole module

local staggerDebuffs = {
  [124273] = true,
  [124274] = true,
  [124275] = true,
}

function BrewmasterTools.GetNextTick()
  return select(16,BrewmasterTools.util.UnitAura("player", staggerDebuffs, "HARMFUL")) or 0
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
