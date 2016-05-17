local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('auras')
--[[
TODO
layout aura frame configuration:
layout:SetAuras({
    filter, point, max, size, x_spacing, y_spacing, x_offset, y_offset,
    rows, sort
})
--]]
-- local functions #############################################################
-- prototype additions #########################################################
-- messages ####################################################################
function ele.Initialised()
    if not addon.layout.Auras then return end
end
-- events ######################################################################
-- register ####################################################################
ele:RegisterMessage('Initialised')
