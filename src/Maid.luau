--!strict
-- Lightweight Maid scoped to a PoloskaLib window so all UserInputService,
-- Workspace, and timer hooks are cleanly torn down on Gui.Destroying.

local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({
		_tasks = {} :: { any },
		_cleaned = false,
	}, Maid)
end

function Maid:Add(taskItem: any): any
	if self._cleaned then
		pcall(function()
			if typeof(taskItem) == "RBXScriptConnection" then
				taskItem:Disconnect()
			elseif typeof(taskItem) == "function" then
				taskItem()
			elseif typeof(taskItem) == "Instance" then
				taskItem:Destroy()
			elseif typeof(taskItem) == "table" and typeof(taskItem.Disconnect) == "function" then
				taskItem:Disconnect()
			end
		end)
		return taskItem
	end
	table.insert(self._tasks, taskItem)
	return taskItem
end

function Maid:Connect(signal: any, fn: (...any) -> ()): RBXScriptConnection
	local conn = signal:Connect(fn)
	return self:Add(conn)
end

function Maid:Clean()
	if self._cleaned then
		return
	end
	self._cleaned = true
	local tasks = self._tasks
	self._tasks = {}
	for i = #tasks, 1, -1 do
		local item = tasks[i]
		pcall(function()
			if typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			elseif typeof(item) == "function" then
				item()
			elseif typeof(item) == "Instance" then
				item:Destroy()
			elseif typeof(item) == "table" then
				if typeof(item.Disconnect) == "function" then
					item:Disconnect()
				elseif typeof(item.Destroy) == "function" then
					item:Destroy()
				end
			end
		end)
	end
end

return Maid
