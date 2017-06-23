--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--this holds code for normalized stagger

--if BrewmasterTools.me ~= "MONK" then return end -- only monks have stagger

local normalStagger = {}

do
  local addToPool, getVal = BrewmasterTools.util.makeTempAdder()

  local update = function (self,event,...)
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
            addToPool(filter[spellid]* (select(offset + 7, ...)), timeLimit)
          end
        else -- this is a swing. Swings are always counted.
          if select(offset + 4,...) ==115069 then --we only want damage that is staggered
            addToPool( (select(offset + 7, ...)), timeLimit)
          end
        end
      end
    end
  end
  local filter = {

    __index = function() return .75 end,

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

	  --Tomb of Sargeras
    --Goroth

	  [231363] = .5, --Burning Armor
	  [231395] = .5, --Burning Eruption

	  --Demonic Inquisition

	  [233426] = .5, --Scythe Sweep

	  --Harjatan

	  [231988] =  1, --Jagged Abrasion
	  [247403] = .5, --Unchecked Rage
	  [231854] = .5, --Unchecked Rage (the cleave one)
	  [234129] =  1, --Splashy Cleave

	  --Mistress Sassz'ine

    [230201] =  1, --Burden of Pain
	  [-32]    =  1, --Melee (the shadow swings [idk if its actually a spell, or a swing that happens to do shadow. doesn't matter tho])

	  --Sisters of the Moon

	  [236547] = .5, --Moon Glaive
	  [239264] =  1, --Lunar Fire

	  --Desolate Host

	  [241566] =  1, --Crush Mind
	  [236142] =  1, --Bone Shards

	  --Maiden of Vigilance

	  [235214] =  1, --Light Infusion
	  [235253] =  1, --Fel Infusion
	  [235569] = .75,--Hammer of Creation (cleave)
	  [241624] = .5, --Hammer of Creation (tankbuster)
	  [235573] = .75,--Hammer of Obliteration (cleave)
	  [241634] = .5, --Hammer of Obliteration (tankbuster)

	  --Fallen Avatar

	  [236494] = .5, --Desolate (terrible ability name tbh)

	  --Kil'jaeden

	  [239931] =  1, --Felclaws
  }
  setmetatable(filter,filter)
  normalStagger.GetNormalStagger = getVal
end
