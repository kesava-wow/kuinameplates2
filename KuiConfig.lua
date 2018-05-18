--[[
-- Simple configuration library with profiles.
-- By Kesava @ curse.com.
-- All rights reserved.
--]]
local MAJOR, MINOR = 'KuiConfig-1.0', 6
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
        for i,listener_tbl in ipairs(tbl.listeners) do
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
-- set config key [k] to value [v]
--]]
function config_meta:SetKey(k,v)
    if not self.profile then return end
    self.profile[k] = v

    -- post complete profile to saved variable
    -- TODO set to other profiles maybe?
    _G[self.gsv_name].profiles[self.csv.profile] = self.profile

    -- dispatch to configChanged listeners
    CallListeners(self,k,v)
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
-- set active profile to given name
-- will create a profile if given doesn't exist
--]]
function config_meta:SetProfile(profile_name)
    _G[self.csv_name].profile = profile_name
    self.csv = _G[self.csv_name]
    self.profile = self:GetProfile(profile_name)

    CallListeners(self)
end

function config_meta:GetProfile(profile_name)
    if not profile_name then
        profile_name = 'default'
    end

    if not self.gsv.profiles[profile_name] then
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
-- copy named profile to given name
--]]
function config_meta:CopyProfile(profile_name,new_name)
    if not profile_name or not new_name or new_name == '' then return end

    _G[self.gsv_name].profiles[new_name] = self:GetProfile(profile_name)
    self.gsv.profiles[new_name] = _G[self.gsv_name].profiles[new_name]

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
-- reset named profile to defaults (by deleting and recreating it)
--]]
function config_meta:ResetProfile(profile_name)
    if not profile_name then return end

    _G[self.gsv_name].profiles[profile_name] = nil
    self.gsv.profiles[profile_name] = nil

    self:SetProfile(profile_name)
end

--[[
-- alias for GetProfile(active_profile_name)
-- sets config_meta.profile to active profile
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
