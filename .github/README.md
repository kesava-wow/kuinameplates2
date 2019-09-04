# LibClassicDurations

Tracks all whitelisted aura applications and then returns UnitAura-friendly _duration, expirationTime_ pair.

Also can show enemy buff info. That's a completely optional feature with no impact on performance if it's not being used

Usage example 1:
-----------------

    -- Simply get the expiration time and duration

    local LibClassicDurations = LibStub("LibClassicDurations")
    LibClassicDurations:Register("YourAddon") -- tell library it's being used and should start working

    hooksecurefunc("CompactUnitFrame_UtilSetBuff", function(buffFrame, unit, index, filter)
        local name, _, _, _, duration, expirationTime, unitCaster, _, _, spellId = UnitBuff(unit, index, filter);

        local durationNew, expirationTimeNew = LibClassicDurations:GetAuraDurationByUnit(unit, spellId, unitCaster, name)
        if duration == 0 and durationNew then
            duration = durationNew
            expirationTime = expirationTimeNew
        end

        local enabled = expirationTime and expirationTime ~= 0;
        if enabled then
            local startTime = expirationTime - duration;
            CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
        else
            CooldownFrame_Clear(buffFrame.cooldown);
        end
    end)


Embedding in .pkgmeta
--------------------------

    externals:
      Libs/LibClassicDurations: https://repos.curseforge.com/wow/libclassicdurations


![Screenshot](https://i.imgur.com/ZE6IWys.jpg)