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

-- list checking ###############################################################
function l:SpellIncludedAll(spellid)
    return include_all[spellid]
end
function l:SpellIncludedOwn(spellid)
    return include_own[spellid]
end
function l:SpellExcluded(spellid)
    return exclude[spellid]
end

-- list management #############################################################
function l:AddSpell(spellid,include,all)
    if include and all then
        include_all[spellid] = true
    elseif include then
        include_own[spellid] = true
    else
        exclude[spellid] = true
    end
end
function l:RemoveSpell(spellid,include,all)
    if include and all then
        include_all[spellid] = nil
    elseif include then
        include_own[spellid] = nil
    else
        exclude[spellid] = nil
    end
end
function l:Import(list,include,all)
    if not list or type(list) ~= 'table' then return end
    if include and all then
        include_all = list
    elseif include then
        include_own = list
    else
        exclude = list
    end
end
function l:Export(include,all)
    if include and all then
        return include_all
    elseif include then
        return include_own
    else
        return exclude
    end
end
function l:Clear()
    wipe(include_all)
    wipe(include_own)
    wipe(exclude)
end
