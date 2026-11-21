--!strict
-- Safe, cached TweenService wrapper for PoloskaLib v2.

local TweenService = game:GetService("TweenService")

local Animator = {}

local infoCache: { [string]: TweenInfo } = {}
local infoCacheCount = 0

function Animator.Alive(obj: any): boolean
	return typeof(obj) == "Instance" and (obj.Parent ~= nil or obj:IsDescendantOf(game))
end

function Animator.Info(duration: number, style: Enum.EasingStyle?, dir: Enum.EasingDirection?): TweenInfo
	local s = style or Enum.EasingStyle.Quart
	local d = dir or Enum.EasingDirection.Out
	local key = string.format("%.3f|%s|%s", duration, tostring(s), tostring(d))
	local cached = infoCache[key]
	if not cached then
		cached = TweenInfo.new(duration, s, d)
		if infoCacheCount < 64 then
			infoCache[key] = cached
			infoCacheCount += 1
		end
	end
	return cached
end

function Animator.Tween(
	obj: any,
	duration: number,
	props: { [string]: any },
	style: Enum.EasingStyle?,
	dir: Enum.EasingDirection?
): Tween?
	if not Animator.Alive(obj) then
		return nil
	end
	local ok, t = pcall(TweenService.Create, TweenService, obj, Animator.Info(duration, style, dir), props)
	if ok and t then
		t:Play()
		return t
	end
	return nil
end

return Animator
