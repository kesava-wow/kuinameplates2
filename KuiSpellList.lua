--[[
-- Curate a list of spells to include/exclude on aura frames.
-- By Kesava @ curse.com.
-- All rights reserved.
--]]
local MAJOR, MINOR = 'KuiSpellList-2.0', 1
local l = LibStub:NewLibrary(MAJOR, MINOR)
if not l then
    -- already registered
    return
end

local include_all = {}
local include_own = {}
local exclude = {}

function l:SpellIncludedAll(spellid)
    return include_all[spellid]
end
function l:SpellIncludedOwn(spellid)
    return include_own[spellid]
end
function l:SpellExcluded(spellid)
    return exclude[spellid]
end

function l:AddSpell(spellid,include,all)
    if include and all then
        include_all[spellid] = true
    elseif include then
        include_own[spellid] = true
    else
        exclude[spellid] = true
    end
end
