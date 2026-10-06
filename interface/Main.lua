local addonName, NS = ...

local frame = CreateFrame("Frame", "Awow", UIParent)
frame:SetHeight(40)
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
frame:SetFrameStrata("BACKGROUND")
frame:SetFrameLevel(0)
local background = frame:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(frame)
background:SetColorTexture(0, 0, 0, 1)

local logo = NS.Logo:New(frame, 0, 0)
local player = NS.Player:New(frame, 40, 0)
local raid = NS.Raid:New(frame, 200, 0, {364343, 366155, 367364})

C_Timer.NewTicker(0.05, function(self, elapsed)
    logo:Update()
    player:Update()
    raid:Update()
end)

SLASH_AWOW1 = "/awow"
SlashCmdList["AWOW"] = function(msg)
    msg = msg:trim():lower()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end