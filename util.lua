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

function util.HexToRGBA(hex) --expects a 6-8 digit hex string.
	if type(hex) ~= 'string' then return 0,0,0 end
	return 	tonumber((hex:sub(1,2)) or 0, 16)/255,
				tonumber((hex:sub(3,4)) or 0, 16)/255,
				tonumber((hex:sub(5,6)) or 0, 16)/255,
				tonumber((hex:sub(7,8)) or 0, 16)/255
end

function util.UnitAura(unit, spellID, filter)
	local i, id = 0, 0
	if type(spellID) == "number" then
		while id do
			i = i + 1
			id = select(10, UnitAura(unit, i, filter))
			if spellID == id then
				return UnitAura(unit, i, filter)
			end
		end
	else
		while id do
			i = i + 1
			id = select(10, UnitAura(unit, i, filter))
			if spellID[id] then
				return UnitAura(unit, i, filter)
			end
		end
	end
end

BrewmasterTools.util = util
