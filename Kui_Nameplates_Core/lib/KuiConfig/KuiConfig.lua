--[[
-- Simple configuration library with profiles.
-- By Kesava @ curse.com.
-- All rights reserved.
--]]
local MAJOR, MINOR = 'KuiConfig-1.0', 9
local kc = LibStub:NewLibrary(MAJOR, MINOR)

if not kc then
    -- already registered
    return
end

function kc:print(m)
    print(MAJOR..'-'..MINOR..': '..(m or 'nil'))
end

--[[
-- call callback of listeners to given config table
--]]
local function CallListeners(tbl,k,v)
    if type(tbl.listeners) == 'table' then
        for _,listener_tbl in ipairs(tbl.listeners) do
            local listener,func = unpack(listener_tbl)

            if  listener and
                type(func) == 'string' and
                type(listener[func]) == 'function'
            then
                listener[func](listener,tbl,k,v)
            elseif type(func) == 'function' then
                func(tbl,k,v)
            end
        end
    end
end

-- config table prototype ######################################################
local config_meta = {}
config_meta.__index = config_meta

function config_meta:ProfileExists(name)
    return type(self.gsv.profiles[name]) == 'table'
end

--[[
-- post the named profile to the saved variable
-- falls back to currently active profile
-- if p_table is a table, overwrite profile with p_table
--]]
function config_meta:PostProfile(p_name,p_table)
    if not p_name then p_name = self.csv.profile end
    if not p_table then p_table = self.profile end
    assert(p_name and p_table)
    _G[self.gsv_name].profiles[p_name] = p_table
end

--[[
-- post the local copy of the character's saved variable to the global
]]
function config_meta:PostCharacter()
    _G[self.csv_name] = self.csv
end

--[[
-- merges current active profile (self.profile) with given defaults and returns
-- the resulting config table
--]]
function config_meta:GetConfig()
    if not self.profile then return end

    local local_config = {}

    for k,v in pairs(self.defaults) do
        -- apply default config
        local_config[k] = v
    end

    for k,v in pairs(self.profile) do
        if self.defaults[k] == nil or self.defaults[k] == v then
            -- unset variables which don't exist or which equal the defaults
            self.profile[k] = nil
        else
            -- apply saved variables from profile
            local_config[k] = v
        end
    end

    return local_config
end

--[[
-- set config key [k] to value [v] and update
--]]
function config_meta:SetKey(k,v)
    if not self.profile then return end
    self.profile[k] = v
    self:PostProfile()
    CallListeners(self,k,v)
end

--[[
-- return config key [k]
--]]
function config_meta:GetKey(k)
    if not self.profile then return end
    return self.profile[k]
end

--[[
-- reset config key [k]
-- alias of config_tbl:SetKey(k,nil)
--]]
function config_meta:ResetKey(k)
    self:SetKey(k,nil)
end

--[[
-- legacy alias for config_tbl:SetKey
--]]
function config_meta:SetConfig(...)
    self:SetKey(...)
end

--[[
-- switch to given profile, creating it if it doesn't already exist
--]]
function config_meta:SetProfile(profile_name)
    -- get or create named profile
    self.profile = self:GetProfile(profile_name)

    -- remember profile for this character
    self.csv.profile = profile_name
    self:PostCharacter()

    -- inform listeners of profile change / run callbacks
    CallListeners(self)
end

--[[
-- return profile table for given profile
-- falls back to "default"
-- creates profile if it doesn't exist
--]]
function config_meta:GetProfile(profile_name)
    if not profile_name then
        profile_name = 'default'
    end

    if not self:ProfileExists(profile_name) then
        self.gsv.profiles[profile_name] = {}
    end

    return self.gsv.profiles[profile_name]
end

--[[
-- delete named profile
-- no_set: if true, don't swtich to default profile
--]]
function config_meta:DeleteProfile(profile_name,no_set)
    if not profile_name then return end

    _G[self.gsv_name].profiles[profile_name] = nil
    self.gsv.profiles[profile_name] = nil

    if not no_set then
        self:SetProfile('default')
    end
end

--[[
-- copy named profile to given name and switch to it
--]]
function config_meta:CopyProfile(profile_name,new_name)
    if not profile_name or not new_name or new_name == '' then return end
    self:PostProfile(new_name,self:GetProfile(profile_name))
    self:SetProfile(new_name)
end

--[[
-- copy named profile to given name and delete the old one
--]]
function config_meta:RenameProfile(profile_name,new_name)
    if not profile_name or not new_name or new_name == '' then return end

    -- copy the profile to the new name
    self:CopyProfile(profile_name,new_name)

    -- delete the old name
    self:DeleteProfile(profile_name,true)
end

--[[
-- reset named profile to defaults (by setting it to an empty table)
--]]
function config_meta:ResetProfile(profile_name)
    if not profile_name then return end
    self:PostProfile(profile_name,{})
    self:SetProfile(profile_name)
end

--[[
-- alias for GetProfile(active_profile_name)
-- sets config_meta.profile to active profile and returns it
--]]
function config_meta:GetActiveProfile()
    self.profile = self:GetProfile(self.csv.profile)
    return self.profile
end

--[[
-- add config changed listener:
-- arg1 = table / function
-- arg2 = key of function in table arg1
--]]
function config_meta:RegisterConfigChanged(arg1,arg2)
    if not self.listeners then
        self.listeners = {}
    end

    if type(arg1) == 'table' and type(arg2) == 'string' and arg1[arg2] then
        tinsert(self.listeners,{arg1,arg2})
    elseif type(arg1) == 'function' then
        tinsert(self.listeners,{nil,arg1})
    else
       kc:print('invalid arguments to RegisterConfigChanged: no function')
    end
end

--[[
-- initialise saved variables, return KuiConfig table
--]]
function kc:Initialise(var_prefix,defaults)
    local config_tbl = {}
    setmetatable(config_tbl, config_meta)
    config_tbl.defaults = defaults

    local g_name, c_name = var_prefix..'Saved', var_prefix..'CharacterSaved'

    if not _G[g_name] then _G[g_name] = {} end
    if not _G[c_name] then _G[c_name] = {} end

    local gsv, csv = _G[g_name], _G[c_name]

    if not gsv.profiles then
        gsv.profiles = {}
    end

    if not csv.profile then
        csv.profile = 'default'
    end

    config_tbl.gsv_name = g_name
    config_tbl.csv_name = c_name

    config_tbl.gsv = gsv
    config_tbl.csv = csv

    config_tbl:GetActiveProfile()
    return config_tbl
end
