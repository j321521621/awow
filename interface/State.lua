

local SPELL = {
    { id = 61304, gcd = true, bar = true },
    { id = 107428, gcd = false, bar = true },
    { id = 100784, gcd = false, bar = true },
}

local CHANNEL = {
    bar = nil,
}

local PLAYER = {
    {id = 'player', role_box = nil, stat_box = nil, hp_bar = nil, ab_bar = nil, hab_bar = nil},
    {id = 'party1', role_box = nil, stat_box = nil, hp_bar = nil, ab_bar = nil, hab_bar = nil},
    {id = 'party2', role_box = nil, stat_box = nil, hp_bar = nil, ab_bar = nil, hab_bar = nil},
    {id = 'party3', role_box = nil, stat_box = nil, hp_bar = nil, ab_bar = nil, hab_bar = nil},
    {id = 'party4', role_box = nil, stat_box = nil, hp_bar = nil, ab_bar = nil, hab_bar = nil},
}



local function create_box(frame, left, top, width, height) 
    local box = CreateFrame("Frame", "RangeSquareFrame", frame)
    box:SetSize(width, height)
    box:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)

    box.bgtex = box:CreateTexture(nil, "BACKGROUND")
    box.bgtex:SetAllPoints()
    box.bgtex:SetColorTexture(1, 1, 1, 1) 

    return box
end

local function create_bar(frame, left, top, width, height)

    -- 创建进度条 (StatusBar)
    local bar = CreateFrame("StatusBar", nil, frame)
    bar:SetSize(width, height)
    bar:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)
    bar:SetMinMaxValues(0, 1)

    local texture = bar:CreateTexture()
    texture:SetAllPoints()
    texture:SetColorTexture(0, 0, 0.5, 1)
    bar:SetStatusBarTexture(texture)

    -- 创建进度条背景
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.5, 0, 0, 1)

    -- 创建技能图标
    -- local icon = frame:CreateTexture(nil, "ARTWORK")
    -- icon:SetSize(20, 20)
    -- icon:SetPoint("RIGHT", bar, "LEFT", -5, 0)
    -- local spellInfo = C_Spell.GetSpellInfo(spellid)
    --if spellInfo then
    --    icon:SetTexture(spellInfo.iconID)
    -- end

    return bar

end

local function CanCastHealOnUnit(unit)
    if UnitExists(unit) 
       and UnitInPhase(unit)
       and UnitInRange(unit) 
       and not UnitIsDeadOrGhost(unit) then
        return true
    end

    return false
end



local function UpdateSpell()
    for i, spell in ipairs(SPELL) do
        if spell.bar then
            local durationObj = C_Spell.GetSpellCooldownDuration(spell.id, not spell.gcd)
            spell.bar:SetTimerDuration(durationObj)
        end
    end

    local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo("player")
    if name then
        CHANNEL.bar:Show()
        CHANNEL.bar:SetMinMaxValues(0, endTime / 1000 - startTime / 1000)
        CHANNEL.bar:SetValue(GetTime() - startTime / 1000)
    else
        CHANNEL.bar:Hide()
    end

end

local function UpdatePlayer()
    for i, player in ipairs(PLAYER) do
        if UnitExists(player.id) then
            player.role_box:Show()
            player.stat_box:Show()
            player.hp_bar:Show()
            player.ab_bar:Show()
            player.hab_bar:Show()

            local role = UnitGroupRolesAssigned(player.id)
            if role == "TANK" then
                player.role_box.bgtex:SetColorTexture(1, 0, 0, 1)
            elseif role == "HEALER" then
                player.role_box.bgtex:SetColorTexture(0, 1, 0, 1)
            else
                player.role_box.bgtex:SetColorTexture(0, 0, 1, 1)
            end

            if UnitIsDeadOrGhost(player.id) then
                player.stat_box.bgtex:SetColorTexture(1, 0, 0, 1)
            else
                player.stat_box.bgtex:SetColorTexture(1, 1, 1, 1)
            end
            player.stat_box:SetAlphaFromBoolean(UnitInRange(player.id), 1.0, 0.5)
            
            local maxhp = UnitHealthMax(player.id)
            local hp = UnitHealth(player.id)
            local ab = UnitGetTotalAbsorbs(player.id)
            local hab = UnitGetTotalHealAbsorbs(player.id)
            player.hp_bar:SetMinMaxValues(0, maxhp)
            player.hp_bar:SetValue(hp)
            player.ab_bar:SetMinMaxValues(0, maxhp)
            player.ab_bar:SetValue(ab)
            player.hab_bar:SetMinMaxValues(0, maxhp)
            player.hab_bar:SetValue(hab)
            
        else
            player.role_box:Hide()
            player.stat_box:Hide()
            player.hp_bar:Hide()
            player.ab_bar:Hide()
            player.hab_bar:Hide()
        end
    end
end




local function main()

    local frame = CreateFrame("Frame", "Awow", UIParent)
    frame:SetHeight(50)
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetFrameLevel(0)
    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(frame)
    background:SetColorTexture(0, 0, 0, 1)

    for i, player in ipairs(PLAYER) do
        player.role_box = create_box(frame, 0, -10 * (i-1), 8, 8)
        player.stat_box = create_box(frame, 10, -10 * (i-1), 8, 8)
        player.hp_bar = create_bar(frame, 20, -10 * (i-1), 98, 8)
        player.ab_bar = create_bar(frame, 120, -10 * (i-1), 48, 8)
        player.hab_bar = create_bar(frame, 170, -10 * (i-1), 48, 8)
    end

    
    CHANNEL.bar = create_bar(frame, 300, -10 * (1-1), 98, 8)

    for i, spell in ipairs(SPELL) do
        spell.bar = create_bar(frame, 400, -10 * (i-1), 98, 8)
    end

    frame:SetScript("OnUpdate",function(self, elapsed)
        UpdateSpell()
        UpdatePlayer()
    end)

end

main()