local MAJOR, MINOR = 'KuiSpellList-1.0', 19
local KuiSpellList = LibStub:NewLibrary(MAJOR, MINOR)
local _

if not KuiSpellList then
    -- already registered
    return
end

--[[
-- HELPFUL = targets friendly characters
-- HARMFUL = targets hostile characters
-- CONTROL = slows, stuns, roots, morphs, etc
--]]

local listeners = {}
local auras = {
    DRUID = {
        HELPFUL = {
            [774] = true, -- rejuvenation
            [8936] = true, -- regrowth
            [33763] = true, -- lifebloom
            [188550] = true, -- lifebloom (HFC 4-set bonus)
            [48438] = true, -- wild growth
            [102342] = true, -- ironbark
            [155777] = true, -- rejuvenation (germination)
            [102351] = true, -- cenarion ward
            [102352] = true, -- cenarion ward proc
        },
        HARMFUL = {
            [1079] = true, -- rip
            [1822] = true, -- rake
            [155722] = true, -- rake 6.0
            [8921] = true, -- moonfire
            [164812] = true,
            [77758] = true, -- bear thrash; td ma
            [106830] = true, -- cat thrash
            [93402] = true, -- sunfire
            [164815] = true,
        },
        CONTROL = {
            [339] = true, -- entangling roots
            [6795] = true, -- growl
            [16914] = true, -- hurricane
            [22570] = true, -- maim
            [33786] = true, -- cyclone
            [78675] = true, -- solar beam silence
            [102359] = true, -- mass entanglement
            [99] = true, -- disorienting roar
            [5211] = true, -- mighty bash
            [61391] = true, -- typhoon daze
        }
    },
    HUNTER = {
        HELPFUL = {
            [34477] = true, -- misdirection
        },
        HARMFUL = {
            [1130] = true, -- hunter's arrow
            [118253] = true, -- serpent sting
            [131894] = true, -- murder by way of crow
            [13812] = true, -- explosive trap
            [117405] = true, -- binding shot
        },
        CONTROL = {
            [5116] = true, -- concussive shot
            [20736] = true, -- distracting shot
            [24394] = true, -- intimidation
            [64803] = true, -- entrapment
            [3355] = true, -- freezing trap
            [135299] = true, -- ice trap TODO isn't classed as caused by player
            [136634] = true, -- narrow escape
            [19386] = true, -- wyvern sting
            [117526] = true, -- binding shot stun
            [120761] = true, -- glaive toss slow
            [121414] = true, -- glaive toss slow 2
        }
    },
    MAGE = {
        HELPFUL = {
            [130] = true, -- slow fall
        },
        HARMFUL = {
            [2120] = true, -- flamestrike
            [11366] = true, -- pyroblast
            [12654] = true, -- ignite
            [44457] = true, -- living bomb
            [112948] = true, -- frost bomb
            [157981] = true, -- blast wave
            [114923] = true, -- nether tempest
        },
        CONTROL = {
            [31589] = true, -- slow
            [116] = true, -- frostbolt debuff
            [157997] = true, -- ice nova
            [120] = true, -- cone of cold
            [31661] = true, -- dragon's breath
            [82691] = true, -- ring of frost

            [118] = true, -- polymorph
            [28271] = true, -- polymorph: turtle
            [28272] = true, -- polymorph: pig
            [61305] = true, -- polymorph: cat
            [61721] = true, -- polymorph: rabbit
            [61780] = true, -- polymorph: turkey
            [126819] = true, -- polymorph: pig
            [161353] = true, -- polymorph: bear cub
            [161354] = true, -- polymorph: monkey
            [161355] = true, -- polymorph: penguin
            [161372] = true, -- polymorph: turtle
        }
    },
    DEATHKNIGHT = {
        HELPFUL = {
            [3714] = true, -- path of frost
            [57330] = true, -- horn of winter
        },
        HARMFUL = {
            [43265] = true, -- death and decay
            [55095] = true, -- frost fever
            [55078] = true, -- blood plague
            [194310] = true, -- festering wound
            [196782] = true, -- outbreak
            [130736] = true, -- soul reaper
            [191587] = true, -- virulent plague
        },
        CONTROL = {
            [56222] = true, -- dark command
            [45524] = true, -- chains of ice
            [108194] = true, -- asphyxiate stun
        }
    },
    WARRIOR = {
        HELPFUL = {
            [3411] = true,   -- intervene
            [114030] = true, -- vigilance
        },
        HARMFUL = {
            [167105] = true, -- colossus smash again
            [1160] = true,   -- demoralizing shout
            [772] = true,    -- rend
            [115767] = true, -- deep wounds
            [113344] = true, -- bloodbath debuff
        },
        CONTROL = {
            [355] = true,    -- taunt
            [1715] = true,   -- hamstring
            [5246] = true,   -- intimidating shout
            [7922] = true,   -- charge stun
            [12323] = true,  -- piercing howl
            [107566] = true, -- staggering shout
            [132168] = true, -- shockwave stun
            [132169] = true, -- storm bolt stun
        }
    },
    PALADIN = {
        HELPFUL = {
            [114163] = true, -- eternal flame
            [53563] = true, -- beacon of light
            [156910] = true, -- beacon of faith

            -- hand of...
            [6940] = true,   -- sacrifice
            [1044] = true,   -- freedom
            [1022] = true,   -- protection
        },
        HARMFUL = {
            [26573] = true,  -- consecration
        },
        CONTROL = {
            [853] = true,    -- hammer of justice
            [20066] = true,  -- repentance
            [31935] = true,  -- avenger's shield silence
            [62124] = true,  -- reckoning taunt
            [105421] = true, -- blinding light
        },
    },
    WARLOCK = {
        HELPFUL = {
            [5697]  = true,  -- unending breath
            [20707]  = true, -- soulstone
        },
        HARMFUL = {
            [980] = true,    -- agony
            [603] = true,    -- doom
            [172] = true,    -- corruption (demo version)
            [146739] = true, -- corruption
            [348] = true,    -- immolate
            [157736] = true, -- immolate (green?)
            [27243] = true,  -- immolate (green?)
            [27243] = true,  -- seed of corruption
            [30108] = true,  -- unstable affliction
            [48181] = true,  -- haunt
            [80240] = true,  -- havoc
        },
        CONTROL = {
            [710] = true,    -- banish
            [1098] = true,   -- enslave demon
            [5484] = true,   -- howl of terror
            [5782] = true,   -- fear
            [30283] = true,  -- shadowfury
            [118699] = true, -- fear (again)
            [171018] = true, -- meteor strike (abyssal stun)
        },
    },
    SHAMAN = {
        HELPFUL = {
            [546] = true,    -- water walking
            [61295] = true,  -- riptide
        },
        HARMFUL = {
            [17364] = true,  -- stormstrike
            [61882] = true,  -- earthquake
        },
        CONTROL = {
            [3600] = true,   -- earthbind totem slow
            [116947] = true, -- earthbind totem slow again
            [64695] = true,  -- earthgrab totem root
            [51514] = true,  -- hex
            [77505] = true,  -- earthquake stun
            [51490] = true,  -- thunderstorm slow
        },
    },
    PRIEST = {
        HELPFUL = {
            [17] = true,     -- power word: shield
            [81782] = true,  -- power word: barrier
            [139] = true,    -- renew
            [33206] = true,  -- pain suppression
            [41635] = true,  -- prayer of mending buff
            [47788] = true,  -- guardian spirit
            [114908] = true, -- spirit shell shield
            [152118] = true, -- clarity of will
            [111759] = true, -- levitate
        },
        HARMFUL = {
            [2096] = true,   -- mind vision
            [589] = true,    -- shadow word: pain
            [14914] = true,  -- holy fire
            [34914] = true,  -- vampiric touch
            [129250] = true, -- power word: solace
            [155361] = true, -- void entropy
        },
        CONTROL = {
            [605] = true,    -- dominate mind
            [8122] = true,   -- psychic scream
            [64044] = true,  -- psychic horror
            [88625] = true,  -- holy word chastise
            [9484] = true,   -- shackle undead
            [114404] = true, -- void tendril root
        },
    },
    ROGUE = {
        HELPFUL = {
            [57934] = true,  -- tricks of the trade
        },
        HARMFUL = {
            [703] = true,    -- garrote
            [1943] = true,   -- rupture
            [16511] = true,  -- hemorrhage
            [79140] = true,  -- vendetta
            [2818] = true,   -- deadly poison
            [8680] = true,   -- wound poison
            [137619] = true, -- marked for death
            [195452] = true, -- nightblade
            [206760] = true, -- night terrors
        },
        CONTROL = {
            [408] = true,    -- kidney shot
            [1330] = true,   -- garrote silence
            [1776] = true,   -- gouge
            [1833] = true,   -- cheap shot
            [2094] = true,   -- blind
            [6770] = true,   -- sap
            [26679] = true,  -- deadly throw
            [88611] = true,  -- smoke bomb
            [3409] = true,   -- crippling poison
            [115196] = true, -- debilitating poison
            [197395] = true, -- finality: nightblade (snare)
        },
    },
    MONK = {
        HELPFUL = {
            [116841] = true, -- tiger's lust
            [116844] = true, -- ring of peace
            [116849] = true, -- life cocoon
            [119611] = true, -- renewing mist
            [124081] = true, -- zen sphere
        },
        HARMFUL = {
            [123725] = true, -- breath of fire dot
            [138130] = true, -- storm, earth and fire 1
        },
        CONTROL = {
            [116095] = true, -- disable
            [115078] = true, -- paralysis
            [116189] = true, -- provoke taunt
            [119381] = true, -- leg sweep
            [120086] = true, -- fists of fury stun
            [121253] = true, -- keg smash slow
            [122470] = true, -- touch of karma
        },
    },
    DEMONHUNTER = {
        SELF = {
            [218256] = true, -- empower wards
            [203819] = true, -- demon spikes
            [187827] = true, -- metamorphosis
            [212800] = true, -- blur
            [196555] = true, -- netherwalk
        },
        HELPFUL = {
            [209426] = true, -- darkness
        },
        HARMFUL = {
            [207744] = true, -- fiery brand
            [207771] = true, -- fiery brand 2
            [204598] = true, -- sigil of flame
            [204490] = true, -- sigil of silence
            [207407] = true, -- soul carver
            [224509] = true, -- frail
            [206491] = true, -- nemesis

            -- TODO
            -- bloodlet
            -- nemesis
            -- master of the glaive snare
            -- chaos blades
        },
        CONTROL = {
            [185245] = true, -- torment taunt
            [204843] = true, -- sigil of chains
            [179057] = true, -- chaos nova
            [211881] = true, -- fel eruption
            [200166] = true, -- metamorphosis stun
            [198813] = true, -- vengeful retreat
            [217932] = true, -- imprison
        },
    },
    GLOBAL = {
        HELPFUL = {
        },
        HARMFUL = {
        },
        CONTROL = {
            [28730] = true, -- arcane torrent/s
            [25046] = true,
            [50613] = true,
            [69179] = true,
            [80483] = true,
            [129597] = true,
            [155145] = true,
            [20549] = true, -- war stomp
            [107079] = true, -- quaking palm
        }
    }
}

KuiSpellList.GetSingleList = function(class)
    -- return a single table of all spells caused by the given class
    if not auras[class] then return {} end
    local list = {}

    for _,spells in pairs(auras[class]) do
        for spellid,_ in pairs(spells) do
            list[spellid] = true
        end
    end

    return list
end

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

KuiSpellList.GetDefaultSpells = function(class,onlyClass)
    -- get spell list, ignoring KuiSpellListCustom
    local list = KuiSpellList.GetSingleList(class)

    -- append global spell list (i.e. racials)
    if not onlyClass then
        local global = KuiSpellList.GetSingleList('GLOBAL')

        for spellid,_ in pairs(global) do
            list[spellid] = true
        end
    end

    return list
end

KuiSpellList.GetImportantSpells = function(class)
    -- get spell list and merge with KuiSpellListCustom if it is set
    local list = KuiSpellList.GetDefaultSpells(class)

    if KuiSpellListCustom then
        for _,group in pairs({class,'GLOBAL'}) do
            if KuiSpellListCustom.Ignore and KuiSpellListCustom.Ignore[group]
            then
                -- remove ignored spells
                for spellid,_ in pairs(KuiSpellListCustom.Ignore[group]) do
                    list[spellid] = nil
                end
            end

            if KuiSpellListCustom.Classes and KuiSpellListCustom.Classes[group]
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
