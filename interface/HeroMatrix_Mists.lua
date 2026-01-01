local addonName = "HeroMatrix_Mists"
local DB_DEFAULTS = {
    pos = {"TOPLEFT", "UIParent", "TOPLEFT", 20, -120},
    size = 5,
    spacing = 1,
    rows = 10,
    cols = 10,
}

HeroMatrixDB = HeroMatrixDB or {}
for k,v in pairs(DB_DEFAULTS) do if HeroMatrixDB[k]==nil then HeroMatrixDB[k]=v end end

local function CreateSquare(parent, size)
    local f = parent:CreateTexture(nil, "ARTWORK")
    f:SetSize(size, size)
    -- Use SetColorTexture when available, otherwise use a white texture + SetVertexColor
    if f.SetColorTexture then
        f:SetColorTexture(0.2, 0.2, 0.2, 0.3)
    else
        f:SetTexture("Interface\\Buttons\\WHITE8x8")
        f:SetVertexColor(0.2, 0.2, 0.2, 0.3)
    end
    return f
end

local function CreateMatrix(parent, rows, cols, size, spacing)
    local total = rows * cols
    local squares = {}
    for r=1,rows do
        for c=1,cols do
            local i = (r-1)*cols + c
            local tex = CreateSquare(parent, size)
            local x = (c-1)*(size+spacing)
            local y = -((r-1)*(size+spacing))
            tex:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
            squares[i] = tex
        end
    end
    parent:SetSize(cols*(size+spacing)-spacing, rows*(size+spacing)-spacing)
    return squares
end

local function ColorForPercentHealth(p)
    if p <= 0 then return 0.4,0.4,0.4,0.6 end
    if p < 25 then return 0.8,0.0,0.0,1 end
    if p < 50 then return 1.0,0.5,0.0,1 end
    if p < 75 then return 1.0,1.0,0.0,1 end
    return 0.0,0.8,0.0,1
end

local function ColorForPercentMana(p)
    if p <= 0 then return 0.4,0.4,0.4,0.6 end
    if p < 25 then return 0.2,0.0,0.5,1 end
    if p < 50 then return 0.0,0.2,0.6,1 end
    if p < 75 then return 0.2,0.5,1.0,1 end
    return 0.2,0.6,1.0,1
end

local function UpdateMatrix(squares, percent, colorFunc)
    local total = #squares
    local filled = math.floor((percent/100) * total + 0.5)
    local r,g,b,a = colorFunc(percent)
    for i=1,total do
        local t = squares[i]
        if i <= filled then
            if t.SetColorTexture then
                t:SetColorTexture(r,g,b,a)
            else
                t:SetTexture("Interface\\Buttons\\WHITE8x8")
                t:SetVertexColor(r,g,b,a)
            end
        else
            if t.SetColorTexture then
                t:SetColorTexture(0.15,0.15,0.15,0.25)
            else
                t:SetTexture("Interface\\Buttons\\WHITE8x8")
                t:SetVertexColor(0.15,0.15,0.15,0.25)
            end
        end
    end
end

-- Main frame
local frame = CreateFrame("Frame", "HeroMatrixMainFrame", UIParent)
-- ensure saved position is valid (must be point, relativeTo, relativePoint, x, y)
if type(HeroMatrixDB.pos) ~= "table" or #HeroMatrixDB.pos < 5 then
    HeroMatrixDB.pos = DB_DEFAULTS.pos
end
frame:SetPoint(unpack(HeroMatrixDB.pos))
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, relativeTo, relativePoint, x, y = self:GetPoint()
    HeroMatrixDB.pos = {p, relativeTo, relativePoint, x, y}
end)
 
-- Add a pure white background to the main frame
local bg = frame:CreateTexture(nil, "BACKGROUND")
if bg.SetColorTexture then
    bg:SetColorTexture(1, 1, 1, 1)
else
    bg:SetTexture("Interface\\Buttons\\WHITE8x8")
    bg:SetVertexColor(1, 1, 1, 1)
end
bg:SetAllPoints(frame)
frame.bg = bg

-- Static buttons (no actions for now)
--[[
local btn1 = CreateFrame("Button", "HeroMatrix_Button1", frame, "UIPanelButtonTemplate")
btn1:SetSize(60, 20)
btn1:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
btn1:SetText("Btn1")
btn1:SetScript("OnClick", function() end)

local btn2 = CreateFrame("Button", "HeroMatrix_Button2", frame, "UIPanelButtonTemplate")
btn2:SetSize(60, 20)
btn2:SetPoint("TOPRIGHT", btn1, "TOPLEFT", -6, 0)
btn2:SetText("Btn2")
btn2:SetScript("OnClick", function() end)
--]]

-- Create health and mana containers
local size = HeroMatrixDB.size
local spacing = HeroMatrixDB.spacing
local rows = HeroMatrixDB.rows
local cols = HeroMatrixDB.cols

local healthContainer = CreateFrame("Frame", nil, frame)
healthContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
local healthSquares = CreateMatrix(healthContainer, rows, cols, size, spacing)

local manaContainer = CreateFrame("Frame", nil, frame)
manaContainer:SetPoint("TOPLEFT", healthContainer, "BOTTOMLEFT", 0, -10)
local manaSquares = CreateMatrix(manaContainer, rows, cols, size, spacing)

-- Position the parent frame to enclose both
frame:SetSize(math.max(healthContainer:GetWidth(), manaContainer:GetWidth()), healthContainer:GetHeight() + 10 + manaContainer:GetHeight())

local function UpdateAll()
    if UnitIsDeadOrGhost("player") or not UnitIsConnected("player") then
        UpdateMatrix(healthSquares, 0, function() return 0.4,0.4,0.4,0.6 end)
        UpdateMatrix(manaSquares, 0, function() return 0.4,0.4,0.4,0.6 end)
        return
    end
    local curH = UnitHealth("player") or 0
    local maxH = UnitHealthMax("player") or 1
    local hp = (curH / maxH) * 100

    local curM = UnitPower("player") or 0
    local maxM = UnitPowerMax("player") or 1
    local mp = (curM / maxM) * 100
    print(hp, mp)

    UpdateMatrix(healthSquares, hp, ColorForPercentHealth)
    UpdateMatrix(manaSquares, mp, ColorForPercentMana)
end

-- Replace event-driven updates with a 10Hz OnUpdate timer
local updateInterval = 0.1
local acc = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    acc = acc + elapsed
    if acc >= updateInterval then
        acc = acc - updateInterval
        print(date("%H:%M:%S") .. " 11 " .. string.format("%.3f", GetTime()))
        UpdateAll()
    end
end)

frame:Show()

-- Slash command to reset position or show/hide
SLASH_HEROMATRIX1 = "/hm"
SlashCmdList["HEROMATRIX"] = function(msg)
    if msg == "reset" then
        HeroMatrixDB.pos = DB_DEFAULTS.pos
        frame:SetPoint(unpack(HeroMatrixDB.pos))
        print("HeroMatrix: position reset")
    elseif msg == "hide" then
        frame:Hide()
    else
        print("HeroMatrix show")
        frame:Show()
    end
end

