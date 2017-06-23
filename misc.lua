--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details 

--miscellaneous functions that don't require a whole module

function BrewmasterTools.GetNextTick(unit)
  unit = UnitExists(unit) and unit or 'player'
	return select(17,UnitDebuff(unit,GetSpellInfo(124275)))
	or select(17,UnitDebuff(unit,GetSpellInfo(124274)))
	or select(17,UnitDebuff(unit,GetSpellInfo(124273)))
	or 0
end
