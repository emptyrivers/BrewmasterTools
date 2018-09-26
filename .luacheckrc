std = "lua51"
max_line_length = false
exclude_files = {
	"babelfish.lua",
	".luacheckrc"
}
ignore = {
	"11./SLASH_.*", -- Setting an undefined (Slash handler) global variable
	"11./BINDING_.*", -- Setting an undefined (Keybinding header) global variable
	"113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	"113/NUM_LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	"211", -- Unused local variable
	"211/L", -- Unused local variable "CL"
	"211/CL", -- Unused local variable "CL"
	"212", -- Unused argument
	"213", -- Unused loop variable
	-- "231", -- Set but never accessed
	"311", -- Value assigned to a local variable is unused
	"314", -- Value of a field in a table literal is unused
	"42.", -- Shadowing a local variable, an argument, a loop variable.
	"43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
	"542", -- An empty if branch
}
globals = {
	-- luacheck
	"std",
	"max_line_length",
	"exclude_files",
	"ignore",
	"globals",
	-- brmt globals
	"BrewmasterTools",
	"BRMTOOL",
	-- WoW API
	"CreateFrame",
	"C_Timer",
	"UnitAura",
	"UnitHealthMax",
	"UnitGUID",
	"GetSpellInfo",
	"CombatLogGetCurrentEventInfo",
	"InCombatLockdown",
	"IsEquippedItem",
	"UnitLevel",
	"IsPlayerSpell",
	"GetTime",
	"GetSpellCount",
	"C_ChatInfo",
	"IsInGroup",
}
