-- Minimal Luau CLI load test for standalone PoloskaLib.lua
Enum = setmetatable({}, {
	__index = function(_, k)
		return setmetatable({}, {
			__index = function(_, v)
				return k .. "." .. v
			end,
		})
	end,
})
Color3 = { fromRGB = function(r, g, b) return { r, g, b } end }
UDim = { new = function(s, o) return { s, o } end }
UDim2 = {
	new = function(...) return { ... } end,
	fromOffset = function(x, y) return { 0, x, 0, y } end,
	fromScale = function(x, y) return { x, 0, y, 0 } end,
}
Vector2 = { new = function(x, y) return { x, y } end, zero = { 0, 0 } }
NumberSequence = { new = function(t) return t end }
NumberSequenceKeypoint = { new = function(t, v) return { t, v } end }
ColorSequence = { new = function(a, b) return { a, b } end }
TweenInfo = { new = function(...) return { ... } end }
game = { GetService = function(_, name) return { Name = name } end }
workspace = {}

local lib = require("../PoloskaLib")
assert(type(lib) == "table", "PoloskaLib did not return a table")
assert(lib.Version == "2.0.0", "Unexpected version: " .. tostring(lib.Version))
assert(type(lib.Create) == "function", "Missing Create method")
print("LOAD SMOKE PASS: PoloskaLib v" .. lib.Version .. " (Create=function)")
