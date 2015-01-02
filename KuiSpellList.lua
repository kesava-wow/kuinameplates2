local MAJOR, MINOR = 'KuiSpellList-1.0', 8
local KuiSpellList = LibStub:NewLibrary(MAJOR, MINOR)
local _

if not KuiSpellList then
	-- already registered
	return
end

local listeners = {}
local whitelist = {
--[[ Important spells ----------------------------------------------------------
	Target auras which the player needs to keep track of.

	-- LEGEND --
	gp = guaranteed passive
	nd = no damage
	td = tanking dot
	ma = modifies another ability when active
]]
	DRUID = { -- 5.2 COMPLETE
		[770] = true, -- faerie fire
		[1079] = true, -- rip
		[1822] = true, -- rake
		[155722] = true, -- rake 6.0
		[8921] = true, -- moonfire
		[164812] = true,
		[77758] = true, -- bear thrash; td ma
		[106830] = true, -- cat thrash
		[93402] = true, -- sunfire
		[164815] = true,
		[33745] = true, -- lacerate
		
		[339] = true, -- entangling roots
		[6795] = true, -- growl
		[16914] = true, -- hurricane
		[22570] = true, -- maim
		[33786] = true, -- cyclone
		[78675] = true, -- solar beam silence

		[1126] = true, -- mark of the wild

		[774] = true, -- rejuvenation
		[8936] = true, -- regrowth
		[33763] = true, -- lifebloom
		[48438] = true, -- wild growth
		[102342] = true, -- ironbark

		-- talents
		[102351] = true, -- cenarion ward
		[102355] = true, -- faerie swarm
		[102359] = true, -- mass entanglement
		[61391] = true, -- typhoon daze
		[99] = true, -- disorienting roar
		[5211] = true, -- mighty bash
	},
	HUNTER = { -- 5.2 COMPLETE
		[1130] = true, -- hunter's mark
		[3674] = true, -- black arrow
		[53301] = true, -- explosive shot
		[118253] = true, -- serpent sting

		[5116] = true, -- concussive shot
		[20736] = true, -- distracting shot
		[24394] = true, -- intimidation
		[64803] = true, -- entrapment
		[131894] = true, -- murder by way of crow

		[3355] = true, -- freezing trap
		[13812] = true, -- explosive trap
		[135299] = true, -- ice trap TODO isn't classed as caused by player

		[34477] = true, -- misdirection

		-- talents
		[136634] = true, -- narrow escape
		[19386] = true, -- wyvern sting
		[117405] = true, -- binding shot
		[117526] = true, -- binding shot stun
		[120761] = true, -- glaive toss slow
		[121414] = true, -- glaive toss slow 2
	},
	MAGE = { -- 5.2 COMPLETE
		[116] = true, -- frostbolt debuff
		[11366] = true, -- pyroblast
		[12654] = true, -- ignite
		[31589] = true, -- slow
		[83853] = true, -- combustion
		
		[118] = true, -- polymorph
		[28271] = true, -- polymorph: turtle
		[28272] = true, -- polymorph: pig
		[61305] = true, -- polymorph: cat
		[61721] = true, -- polymorph: rabbit
		[61780] = true, -- polymorph: turkey
		[44572] = true, -- deep freeze
	
		[1459] = true, -- arcane brilliance
		
		-- talents
		[111264] = true, -- ice ward
		[114923] = true, -- nether tempest
		[44457] = true, -- living bomb
		[112948] = true, -- frost bomb
	},
	DEATHKNIGHT = { -- 5.2 COMPLETE
		[55095] = true, -- frost fever
		[55078] = true, -- blood plague
		[114866] = true, -- soul reaper

		[43265] = true, -- death and decay
		[45524] = true, -- chains of ice
		[49560] = true, -- death grip taunt
		[50435] = true, -- chillblains
		[56222] = true, -- dark command		
		[108194] = true, -- asphyxiate stun
		
		[3714] = true, -- path of frost
		[57330] = true, -- horn of winter

		-- talents
		[115000] = true, -- remorseless winter slow
		[115001] = true, -- remorseless winter stun
	},
	WARRIOR = { -- 5.2 COMPLETE
		[86346] = true,  -- colossus smash

		[355] = true,    -- taunt
		[772] = true,    -- rend
		[1160] = true,   -- demoralizing shout
		[1715] = true,   -- hamstring
		[5246] = true,   -- intimidating shout
		[7922] = true,   -- charge stun
		[18498] = true,  -- gag order
		[64382] = true,  -- shattering throw
		[115767] = true, -- deep wounds; td
		
		[469] = true,    -- commanding shout
		[3411] = true,   -- intervene
		[6673] = true,   -- battle shout
		
		                 -- talents
		[12323] = true,  -- piercing howl
		[107566] = true, -- staggering shout
		[132168] = true, -- shockwave debuff
		[114029] = true, -- safeguard
		[114030] = true, -- vigilance
		[113344] = true, -- bloodbath debuff
		[132169] = true, -- storm bolt debuff
	},
	PALADIN = { -- 5.2 COMPLETE
		[114163] = true, -- eternal flame
		[53563] = { colour = {1,.5,0} },  -- beacon of light
		[20925] = { colour = {1,1,.3} },  -- sacred shield
		
		[19740] = { colour = {.2,.2,1} }, -- blessing of might
		[20217] = { colour = {1,.3,.3} }, -- blessing of kings
		
		[26573] = true,  -- consecration; td
		[31803] = true,  -- censure; td
		
		                 -- hand of...
		[114039] = true, -- purity
		[6940] = true,   -- sacrifice
		[1044] = true,   -- freedom
		[1038] = true,   -- salvation
		[1022] = true,   -- protection
		
		[853] = true,    -- hammer of justice
		[2812] = true,   -- denounce
		[10326] = true,  -- turn evil
		[20066] = true,  -- repentance
		[31935] = true,  -- avenger's shield silence
		[62124] = true,  -- reckoning
		[105593] = true, -- fist of justice
		[119072] = true, -- holy wrath stun

		[114165] = true, -- holy prism
		[114916] = true, -- execution sentence dot
		[114917] = true, -- stay of execution hot
	},
	WARLOCK = {
		[5697]  = true,  -- unending breath
		[20707]  = true, -- soulstone
		[109773] = true, -- dark intent
	
		[172] = true,    -- corruption (demo version)
		[146739] = true, -- corruption
		[114790] = true, -- Soulburn: Seed of Corruption
		[348] = true,    -- immolate
		[108686] = true, -- immolate (aoe)
		[157736] = true, -- immolate (green?)

		[980] = true,    -- agony
		[27243] = true,  -- seed of corruption
		[30108] = true,  -- unstable affliction
		[47960] = true,  -- shadowflame
		[48181] = true,  -- haunt
		[80240] = true,  -- havoc
		
		[710] = true,    -- banish
		[1098] = true,   -- enslave demon
		[5782] = true,   -- fear
		[118619] = true, -- fear (again)
		[171018] = true, -- meteor strike (abyssal stun)

		                 -- metamorphosis:
		[603] = true,    -- doom
		[124915] = true, -- chaos wave
		
		                 -- talents:
		[5484] = true,   -- howl of terror
		[111397] = true, -- blood fear
	},
	SHAMAN = { -- 5.2 COMPLETE
		[8050] = true,   -- flame shock
		[8056] = true,   -- frost shock slow
		[63685] = true,  -- frost shock root
		[51490] = true,  -- thunderstorm slow
		[17364] = true,  -- stormstrike
		[61882] = true,  -- earthquake
		
		[3600] = true,   -- earthbind totem passive
		[64695] = true,   -- earthgrap totem root
		[116947] = true,   -- earthgrap totem slow

		[546] = true,    -- water walking
		[974] = true,    -- earth shield
		[61295] = true,  -- riptide
		
		[51514] = true,  -- hex
	},
	PRIEST = { -- 5.2 COMPLETE
		[139] = true,    -- renew
		[6346] = true,   -- fear ward
		[33206] = true,  -- pain suppression
		[41635] = true,  -- prayer of mending buff
		[47753] = true,  -- divine aegis
		[47788] = true,  -- guardian spirit
		[114908] = true, -- spirit shell shield
		
		[17] = true,     -- power word: shield
		[21562] = true,  -- power word: fortitude
	
		[2096] = true,   -- mind vision
		[8122] = true,   -- psychic scream
		[9484] = true,   -- shackle undead
		[64044] = true,  -- psychic horror
		[111759] = true, -- levitate
		
		[589] = true,    -- shadow word: pain
		[2944] = true,   -- devouring plague
		[158831] = true, -- devouring plague
		[14914] = true,  -- holy fire
		[34914] = true,  -- vampiric touch
		
		                 -- talents:
		[605] = true,    -- dominate mind
		[114404] = true, -- void tendril root
		[129250] = true, -- power word: solace
		[155361] = true, -- void entropy
	},
	ROGUE = { -- 5.2 COMPLETE
		[703] = true,    -- garrote
		[1943] = true,   -- rupture
		[79140] = true,  -- vendetta
		[84617] = true,  -- revealing strike
		[89775] = true,  -- hemorrhage
		[122233] = true, -- crimson tempest

		[2818] = true,   -- deadly poison
		[3409] = true,   -- crippling poison
		[115196] = true, -- debilitating poison
		[8680] = true,   -- wound poison

		[408] = true,    -- kidney shot
		[1776] = true,   -- gouge
		[1833] = true,   -- cheap shot
		[2094] = true,   -- blind
		[6770] = true,   -- sap
		[26679] = true,  -- deadly throw
		[88611] = true,  -- smoke bomb

        [57934] = true,  -- tricks of the trade

                         -- talents:
        [112961] = true, -- leeching poison
        [137619] = true, -- marked for death
	},
	MONK = { -- 5.2 COMPLETE
		[116189] = true, -- provoke taunt
		[116330] = true, -- dizzying haze debuff
		[123725] = true, -- breath of fire
		[120086] = true, -- fists of fury stun
		[122470] = true, -- touch of karma
		[128531] = true, -- blackout kick debuff
		[130320] = true, -- rising sun kick debuff

		[138130] = true, -- storm, earth and fire 1
		[138131] = true, -- storm, earth and fire 2

		[116781] = true, -- legacy of the white tiger
		[116844] = true, -- ring of peace
		
		[116849] = true, -- life cocoon
		[132120] = true, -- enveloping mist
		[119611] = true, -- renewing mist
		
		[116095] = true, -- disable
		[115078] = true, -- paralysis
	
		                 -- talents:
		[116841] = true, -- tiger's lust
		[124081] = true, -- zen sphere
		[119392] = true, -- charging ox wave
		[119381] = true, -- leg sweep
	},

	GlobalSelf = {
		[28730] = true, -- arcane torrent
		[25046] = true,
		[50613] = true,
		[69179] = true,
		[80483] = true,
		[129597] = true,
		--[155145] = true, -- seems to not be implemented 
		[20549] = true, -- war stomp
		[107079] = true, -- quaking palm
	},

-- Important auras regardless of caster (cc, flags...) -------------------------
--[[
	Global = {
		-- PVP --
		[34976] = true, -- Netherstorm Flag
		[23335] = true, -- Alliance Flag
		[23333] = true, -- Horde Flag
	},
]]
}

KuiSpellList.RegisterChanged = function(table, method)
	-- register listener for whitelist updates
	tinsert(listeners, { table, method })
end

KuiSpellList.WhitelistChanged = function()
	-- inform listeners of whitelist update
	for _,listener in ipairs(listeners) do
		if (listener[1])[listener[2]] then
			(listener[1])[listener[2]]()
		end
	end
end

KuiSpellList.AppendGlobalSpells = function(toList)
	for spellid,_ in pairs(whitelist.GlobalSelf) do
		toList[spellid] = true
	end
	return toList
end

KuiSpellList.GetDefaultSpells = function(class,onlyClass)
	-- get spell list, ignoring KuiSpellListCustom
	local list = {}

	-- return a copy of the list rather than a reference
	for spellid,_ in pairs(whitelist[class]) do
		list[spellid] = true
	end

	if not onlyClass then
		KuiSpellList.AppendGlobalSpells(list)
	end

	return list
end

KuiSpellList.GetImportantSpells = function(class)
	-- get spell list and merge with KuiSpellListCustom if it is set
	local list = KuiSpellList.GetDefaultSpells(class)

	if KuiSpellListCustom then
		for _,group in pairs({class,'GlobalSelf'}) do
			if KuiSpellListCustom.Ignore and
			   KuiSpellListCustom.Ignore[group]
			then
				-- remove ignored spells
				for spellid,_ in pairs(KuiSpellListCustom.Ignore[group]) do
					list[spellid] = nil
				end
			end

			if KuiSpellListCustom.Classes and
			   KuiSpellListCustom.Classes[group]
			then
				-- merge custom added spells
				for spellid,_ in pairs(KuiSpellListCustom.Classes[group]) do
					list[spellid] = true
				end
			end
		end
	end

	return list
end
