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


local player = NS.Player:New(frame, 0, 0)
local raid = NS.Raid:New(frame, 80, 0, {364343})

C_Timer.NewTicker(0.1, function(self, elapsed)
    player:Update()
    raid:Update()
end)


local frame2 = NS.create_box(frame, 400, 0, 50, 50)

container = CreateFrame("AuraContainer", nil, frame2, "CustomAuraContainerTemplate")

container:SetAllPoints()
container:SetUnit('player')
container:SetMouseClickEnabled(false)
container:SetMouseMotionEnabled(false)



button = container:AddAuraSlot("default", "HELPFUL", {
    candidateFilters = { includeSpellIDs = { [369299] = true } },
    
    -- 1. 初始化界面结构：创建用于展示层数的 FontString
    initializeFrame = function(btn)
        -- 原有底色/材质
        btn.echoAuraDemoFill = btn:CreateTexture(nil, "BACKGROUND")
        btn.echoAuraDemoFill:SetAllPoints(btn)
        btn.echoAuraDemoFill:SetColorTexture(1, 0, 0, 1)


        btn.Count = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
        btn.Count:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", -2, 2)


        btn.Count.SetText("123")
        btn:SetApplicationCount(btn.Count)

    end,

})

button:SetAllPoints(container)