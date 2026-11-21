--!strict
-- PoloskaLib v2 entrypoint (modular local UI library bundled via darklua).

local Tokens = require("./Tokens")
local Window = require("./Window")

local PoloskaLib = {
	Version = Tokens.Version,
}

function PoloskaLib:Create(config: any)
	return Window.Create(config)
end

return PoloskaLib
