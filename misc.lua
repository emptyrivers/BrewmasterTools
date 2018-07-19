--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--miscellaneous functions that don't require a whole module

function BrewmasterTools.GetNextTick(unit)
  unit = UnitExists(unit) and unit or 'player'
	return select(16,BrewmasterTools.util.UnitDebuff(unit,(GetSpellInfo(124275))))
	or select(16,BrewmasterTools.util.UnitDebuff(unit,(GetSpellInfo(124274))))
	or select(16,BrewmasterTools.util.UnitDebuff(unit,(GetSpellInfo(124273))))
	or 0
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
