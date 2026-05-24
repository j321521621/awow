

local function creata_cdbar(frame, left, top, width, height)

    -- 创建进度条 (StatusBar)
    local statusBar = CreateFrame("StatusBar", nil, frame)
    statusBar:SetSize(width, height)
    statusBar:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)
    statusBar:SetMinMaxValues(0, 1) -- 内部会自动对应 DurationObject 的 0%-100%

    -- 设置进度条纹理和颜色
    local texture = statusBar:CreateTexture()
    texture:SetAllPoints()
    texture:SetColorTexture(0, 0, 1, 1) -- 漂亮的蓝色
    statusBar:SetStatusBarTexture(texture)

    -- 创建进度条背景
    local bg = statusBar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 1)

    -- 创建技能图标
    -- local icon = frame:CreateTexture(nil, "ARTWORK")
    -- icon:SetSize(20, 20)
    -- icon:SetPoint("RIGHT", statusBar, "LEFT", -5, 0)
    -- local spellInfo = C_Spell.GetSpellInfo(spellid)
    --if spellInfo then
    --    icon:SetTexture(spellInfo.iconID)
    -- end

    return statusBar

end



    -- 注册事件监听技能冷却
-- 创建主框架
local frame = CreateFrame("Frame", "MySecretCDFrame", UIParent)
frame:SetSize(200, 30)
frame:SetPoint("TOPLEFT", 300, 0)

local SPELL = {
    { id = 107428, bar = true },
    { id = 100780, bar = true },
    { id = 100784, bar = true },
}
for i, spell in ipairs(SPELL) do
    print(i, spell.id)
    spell.bar = creata_cdbar(frame, 0, -10 * (i-1), 200, 10)
end

local HEALTH = {
    {id = 'player', bar = nil},
    {id = 'party1', bar = nil},
    {id = 'party2', bar = nil},
    {id = 'party3', bar = nil},
    {id = 'party4', bar = nil},
}
for i, health in ipairs(HEALTH) do
    health.bar = creata_cdbar(frame, 0, -10 * (i+3), 100, 10)
end


local ABSORB = {
    {id = 'player', bar = nil},
    {id = 'party1', bar = nil},
    {id = 'party2', bar = nil},
    {id = 'party3', bar = nil},
    {id = 'party4', bar = nil},
}
for i, absorb in ipairs(ABSORB) do
    absorb.bar = creata_cdbar(frame, 100, -10 * (i+3), 100, 10)
end

local function UpdateCooldown()
    for i, spell in ipairs(SPELL) do
        if spell.bar then
            local durationObj = C_Spell.GetSpellCooldownDuration(spell.id, true)
            spell.bar:SetTimerDuration(durationObj)
        end
    end

    -- local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo("player")
    -- print( startTime, endTime, spellID)

end

local function UpdateHealth()
    for i, health in ipairs(HEALTH) do
        if UnitExists(health.id) then
            local currentHealth = UnitHealth(health.id)
            local maxHealth = UnitHealthMax(health.id)

            health.bar:SetMinMaxValues(0, maxHealth)
            health.bar:SetValue(currentHealth)
        else
            health.bar:SetMinMaxValues(0, 1)
            health.bar:SetValue(0)
        end
    end
end


local function UpdateAbsorb()
    for i, absorb in ipairs(ABSORB) do
        if UnitExists(absorb.id) then
            local currentAbsorb = UnitGetTotalAbsorbs(absorb.id)
            local maxHealth = UnitHealthMax(absorb.id)

            absorb.bar:SetMinMaxValues(0, maxHealth)
            absorb.bar:SetValue(currentAbsorb)
        else
            absorb.bar:SetMinMaxValues(0, 1)
            absorb.bar:SetValue(0)
        end
    end
end

frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_MAXHEALTH")
frame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")

frame:SetScript("OnEvent", function(self, event, ...)
    UpdateCooldown()
    UpdateHealth()
    UpdateAbsorb()
end)