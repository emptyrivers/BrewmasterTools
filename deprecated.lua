print[[
Hi, and thanks for using BrewmasterTools! This project has been retired, however.
If you use Normalized Stagger, then please update that WeakAura to the latest verison, which can be found here: https://wago.io/NormalStagger
]]
-- cleanup SV (i didn't really use them that much anyways)
local f = CreateFrame('FRAME')
f:SetScript("PLAYER_LOGOUT", function() BRMTOOL = nil end)