-- First Person Adventure Camera
-- Toggle on or off: /fpa
-- Reset to default settings: /fpa reset
-- To debug in game set: /console scriptErrors 1
-- To reload the addon: /reload
-- Auth: Zock

local MOD_NAME = "FirstPersonAdventure"

SLASH_FIRSTPERSONADVENTURE1 = "/firstpersonadventure"
SLASH_FIRSTPERSONADVENTURE2 = "/fpa"
local messages = {
	welcomeMessage = "First Person Adventure has been loaded. Enjoy the game from a different perspective!",
	enabledMessage = "First Person Adventure Camera enabled.",
	disabledMessage = "First Person Adventure Camera disabled."
}

local defaults = {
	enabled = true,
	frequency = 0, -- seconds.. zero tends to make it impossible or hard to ever zoom out. Anything higher and you can zoom but it snaps back next iteration
	cameraZoomIncrement = 50,
	isZoomedOut = false
}

local incombat = UnitAffectingCombat("player")
local f = CreateFrame("Frame")

SlashCmdList.FIRSTPERSONADVENTURE = function(msg, editBox)
	if msg == "reset" then
		FirstPersonAdventureDB = CopyTable(defaults) -- reset to defaults
		f.db = FirstPersonAdventureDB
		print("First Person Adventure Camera has been reset to default settings.")
		f.UpdateCameraRepeatingTimer(f)
		return
	end

	if f.db.enabled then
		f.db.enabled = false
		print(messages.disabledMessage)
	else
		f.db.enabled = true
		print(messages.enabledMessage)
		f.UpdateCameraRepeatingTimer(f)
	end
end

function f:SetCamera()
	if incombat == true then
		if f.db.isZoomedOut == false then
			CameraZoomOut(f.db.cameraZoomIncrement)
			f.db.isZoomedOut = true
		end
	else
		f.db.isZoomedOut = false
		CameraZoomIn(f.db.cameraZoomIncrement)
	end
end

function f:UpdateCameraRepeatingTimer()
	if f.db.enabled then
		f.SetCamera(f)
		C_Timer.After(f.db.frequency, f.UpdateCameraRepeatingTimer)
	end
end

function f:OnEvent(event, ...)
	local handler = self[event]
	if handler then
		handler(self, event, ...)
	else
		print("No handler found for event: " .. event)
	end
end

function f:PLAYER_REGEN_ENABLED()
	incombat = false
	f.UpdateCameraRepeatingTimer(f)
end

function f:PLAYER_REGEN_DISABLED()
	incombat = false
	f.UpdateCameraRepeatingTimer(f)
end

function f:ADDON_LOADED(frame, addOnName)
	if addOnName == MOD_NAME then
		FirstPersonAdventureDB = FirstPersonAdventureDB or {}
		f.db = FirstPersonAdventureDB

		for k, v in pairs(defaults) do
			if f.db[k] == nil then
				f.db[k] = v
			end
		end
		print(messages.welcomeMessage)
		f.UpdateCameraRepeatingTimer(f)
	end
end

-- function f:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
-- 	print(event, isLogin, isReload)
-- end

f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("ADDON_LOADED")
-- f:RegisterEvent("PLAYER_LOGIN")
-- f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", f.OnEvent)
