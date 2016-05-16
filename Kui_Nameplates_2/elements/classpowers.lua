-- class powers on nameplates (combo points, shards, etc)
local addon = KuiNameplates
local ele = addon:NewElement('classpowers')
local class
-- prototype additions #########################################################
-- messages ####################################################################
-- events ######################################################################
-- register ####################################################################
function ele:Initialise()
    class = select(2,UnitClass('player'))
end
