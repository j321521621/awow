local addonName, NS = ...




local frame = CreateFrame("Frame", "Awow", UIParent)
frame:SetHeight(50)
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
frame:SetFrameStrata("BACKGROUND")
frame:SetFrameLevel(0)
local background = frame:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(frame)
background:SetColorTexture(0, 0, 0, 1)


local raid = NS.Raid:New(frame, 0, 0, {119611, 124682})

C_Timer.NewTicker(0.1, function(self, elapsed)
    raid:Update()
end)
