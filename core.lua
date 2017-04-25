-- This file is loaded from "BrewmasterTools.toc"

local me = select(2,UnitClass'player')
if me ~= 'MONK' then return end --only monks have stagger

local normalStaggerFrame = CreateFrame"Frame"
BrewmasterTools = {}
local b = BrewmasterTools
local staggerPool = 0
local timeLimit 

--[=[

we need to record stagger events, and add them to a pool temporarily DONE

add an api that reports normalised Stagger target value

]=]

local addToPool = function(amount, decayTime)
    staggerPool = staggerPool + amount -- add to the pool
    
    C_Timer.After(decayTime,  -- after delay of decayTime, remove from pool
        function()
            staggerPool = max(staggerPool - amount,0) --should never be negative
        end
    )
end





local filter = { 
    -- delete an entry, or set it to false to remove it from the whitelist. To add a spell, add a [spellid] = <val> line, where spellid is the spell id of the damage you want to whitelist. Make sure the entries are separated by commas, or you will get endless errors.
    
    -- testing purposes. Dummies are enemies too!
    
    [167381] = 1,  --dummy strike  
    [167385] = .5, --Uber strike
    
    --The Emerald Nightmare
    
    --Nythendra
    
    [204504] = 1, --Infested
    
    --Il'gynoth
    
    [215233] = 1, --Nightmarish Fury *your choice to set this one to false; i dont consider it burst damage considering the nature of the fight, but up to you.
    [210984] = .5, --Eye of Fate
    
    --Elerethe
    
    [210228] = 1, --Dripping Fangs. Can do a lot of damage but's like a 30 second dot
    
    [233485] = 1, --Web of pain
    
    --Ursoc
    
    [197943] = 1, --Overwhelm
    [204859] = 1, --Rend Flesh
    --Despite these being kind of bursty (rend flesh especially), I consider them 'boring' because they happen all the time
    
    --Dragons of Nightmare
    
    [203125] = 1, --Mark of Emeriss
    [203121] = 1, --Mark of Taerar
    [203102] = 1, --Mark of Ysondre
    [203124] = 1, --Mark of Lethon
    
    --Cenarius
    
    [210279] = 1, --Creeping Nightmares
    [214529] = .5, --Spear of Nightmares
    [213162] = .5, --Nightmare Blast
    
    --Xavius
    
    [206651] = 1, --Darkening Soul
    [209158] = 1, --Blackening Soul
    
    -- Trial of Valor
    
    --Odyn
    
    [228932] = .5, --Stormforged Spear
    
    --Guarm
    
    [227642] = 1, --Multiheaded
    
    --Helya
    
    --The NightHold
    
    --Skorpyron
    
    [204766] = 1, --Energy surge
    [204275] = .5,--Arcanoslash
    
    --Chronomatic Anomaly
    
    [206607] = 1, --Chronometric particles
    
    --Trilliax
    
    [206641] = .5, --Arcane Slash
    
    
    --Spellblade Alluriel
    
    [212492] = .5, --Annihilate
    [230504] = .5, --Decimate
    
    --Tichondrius
    
    [216024] = .5, --Volatile Wound
    
    --Krosus
    
    [206677] = 1, --Searing Brand
    [225362] = .5, --Slam
    
    --High Botanist Tel'arn
    
    [218503] = 1, --Recursive Srikes
    
    --Star Augur Etraeus
    
    [205486] = 1, --Starburst
    [206921] = 1, --Iceburst
    [206388] = 1, --Felburst
    [206965] = 1, --Voidburst
    
    --Grand Magistrix Elisande
    
    [209615] = 1, --Ablation
    [209973] = .5, --Ablating Explosion
    [209971] = .5, --Ablative Pulse (hopefully is interrupted)
    
    --Gul'dan
    
    [206675] = .25, --Shatter Essence. You shouldn't take damage from this, and it's pretty extreme damage. Double purifying this is warranted.
    [227554] = .5, --Fel Scythe
    
    
}

filter.mt = {_index = .75}

local known_encounters = {
    
    --We won't use the whitelist on unknown encounters; otherwise you can run into unfortunate circumstances
    
    
    --Emerald Nightmare
    
    [1853] = true, --Nythendra
    [1873] = true, --Il'gynoth
    [1876] = true, --Elerethe
    [1841] = true, --Ursoc
    [1854] = true, --Dragons
    [1877] = true, --Cenarius
    [1864] = true, --Xaviu
    
    --Trials of Valor
    
    [1958] = true, --Odyn
    [1962] = true, --Guarm
    [2008] = true, --Helya
    
    --NightHold 
    
    [1849] = true, --Skorpyron
    [1865] = true, --Chronomatic
    [1867] = true, --Trilliax
    [1871] = true, --Alluriel
    [1862] = true, --Tichondrius
    [1842] = true, --Krosus
    [1886] = true, --Botanist
    [1863] = true, --Star Augur
    [1872] = true, --Elisande
    [1866] = true  --Gul'dan 
    
}


local fillPool = function(decayTime) --fills the pool temporarily to Max HP. Decays by 10% in .1 * decayTime second intervals.
	local hpChunk = UnitHealthMax('player') * .1
	local interval = decayTime * .1
	for i= interval, decayTime, interval do
		addToPool(hpChunk,i)
	end
end

local GetNormalStagger = function()
	return staggerPool
end
local Update = function (self,event,...)
	if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end 
    
    local timeStamp = select(1,...)
    local eventType = select(2,...)
    local destGUID = select(8,...)
    
    
    if destGUID == UnitGUID'player' then --grab only things that target me
        local offset = 12
        
        
        if eventType=="SPELL_ABSORBED" then --stagger's mitigation is all in absorb
            
            
            if GetSpellInfo((select(offset, ...)))==(select(offset + 1, ...)) then 
                
                --this is a spell. Spells are filtered, so that only part of the damage is accounted for, to encourage purifying (with priority on mechanics with a lower value on the filter
                --by default, 75% of each spell is added to our average damage staggered.
                --Mechanics that you would be expected to purify on should have a filter value of .5 or lower=
                --Spell damage that is similar to swing damage (in that it occurs frequently and isnt particularly dangerous (large in volume, small in impact) should have a filter of 1.
                
                local spellid = select(offset,...)
              --  local filter = aura_env.filter[spellid] or .75
                
                offset = offset + 3
                if select(offset + 4,...) ==115069 then --we only want damage that is staggered
                    
                    addToPool(filter[spellid] *  (select(offset + 7, ...)), timeLimit)
                    -- table.insert(aura_env.table, {time, filter * (select(offset + 7, ...))}) -- record the time and damage absorbed
                    
                end
                
            else -- this is a swing. Swings are always counted.
                
                if select(offset + 4,...) ==115069 then --we only want damage that is staggered
                    
                    --     table.insert(aura_env.table, {time, (select(offset + 7, ...))}) -- record the time and damage absorbed
                    addToPool( (select(offset + 7, ...)), timeLimit)
                    
                end
            end
        end
    end
    
    if UnitStagger("Player") > 0 then return true end --if you dont have any stagger, make this thing go away. 
    return false
end
b.GetNormalStagger = GetNormalStagger


local controlFrame = CreateFrame'Frame'
controlFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
controlFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
controlFrame:SetScript("OnEvent",function(self,event)
	if event == "PLAYER_REGEN_DISABLED" then --
		normalStaggerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		timeLimit = IsEquippedItem(137044) and 13 or 10
	else
		normalStaggerFrame:SetScript("OnEvent",nil)
		normalStaggerFrame:UnregisterAllEvents()
	end
end)
normalStaggerFrame:SetScript("OnEvent",Update)
