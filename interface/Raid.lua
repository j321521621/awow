-- ============================================================
-- UNIT_AURA 事件处理 - 简单Demo
-- ============================================================
-- 演示如何：
-- 1. 监听UNIT_AURA事件
-- 2. 使用C_UnitAuras API获取光环数据
-- 3. 处理Duration对象（秘密值安全）
-- 4. 更新UI显示
-- ============================================================

local addonName, DF = ...

-- ============================================================
-- 第一部分：初始化
-- ============================================================

local AuraDemo = {
    isActive = false,
    auraCache = {},           -- 缓存光环数据
    frame = nil,              -- UI主框架
    eventFrame = nil,         -- 事件框架
    auraElements = {},        -- UI光环元素
}

-- ============================================================
-- 第二部分：完整的UNIT_AURA事件处理循环
-- ============================================================

-- 步骤1：监听事件（WoW事件注册）
local function RegisterAuraEvents()
    local frame = CreateFrame("Frame", "AuraDemoFrame", UIParent)
    
    -- 监听UNIT_AURA事件
    -- event参数：事件名 "UNIT_AURA"
    -- unit参数：受影响的单位 "player", "party1", "raid1" 等
    -- updateInfo参数：包含增量更新信息（可选）
    frame:RegisterUnitEvent("UNIT_AURA", "player")
    
    frame:SetScript("OnEvent", function(self, event, unit, updateInfo)
        if event == "UNIT_AURA" then
            -- 步骤2：处理事件 → 扫描光环
            AuraDemo:ScanUnitAuras(unit, updateInfo)
        end
    end)
    
    return frame
end

-- ============================================================
-- 步骤2：扫描单位光环
-- ============================================================

function AuraDemo:ScanUnitAuras(unit, updateInfo)
    -- 输入参数说明：
    -- unit: 要扫描的单位ID
    -- updateInfo: 增量更新信息（有则使用增量，无则全量扫描）
    
    if not unit then return end
    
    -- 方式1：快速路径 - 使用增量更新（性能优化）
    if updateInfo then
        local addedCount = type(updateInfo.addedAuras) == "table" and #updateInfo.addedAuras or 0
        local updatedCount = type(updateInfo.updatedAuraInstanceIDs) == "table" and #updateInfo.updatedAuraInstanceIDs or 0
        local removedCount = type(updateInfo.removedAuraInstanceIDs) == "table" and #updateInfo.removedAuraInstanceIDs or 0

        print(string.format(
            "增量更新: added=%d, updated=%d, removed=%d",
            addedCount,
            updatedCount,
            removedCount
        ))
        self:ApplyAuraDelta(unit, updateInfo)
    else
        -- 方式2：全量扫描（初始化时或增量失败时）
        print("全量扫描")
        self:ScanUnitFull(unit)
    end
end

-- ============================================================
-- 步骤3a：全量扫描 - 获取单位所有光环
-- ============================================================

function AuraDemo:ScanUnitFull(unit)
    -- 清空旧数据
    local cache = {
        buffs = {},     -- 正面光环列表
        debuffs = {},   -- 负面光环列表
    }
    
    -- 获取光环数据：第二参数是过滤器字符串
    -- "HELPFUL" = 正面效果，"HARMFUL" = 负面效果
    -- 可以组合：如 "HELPFUL|PLAYER" 只获取玩家释放的BUFF
    
    -- 获取所有正面光环（BUFF）
    local buffs = C_UnitAuras.GetUnitAuras(unit, "HELPFUL", 100)
    if buffs then
        for i, auraData in ipairs(buffs) do
            self:ProcessAuraData(unit, auraData, "BUFF")
            cache.buffs[#cache.buffs + 1] = auraData
        end
    end
    
    -- 获取所有负面光环（DEBUFF）
    local debuffs = C_UnitAuras.GetUnitAuras(unit, "HARMFUL", 100)
    if debuffs then
        for i, auraData in ipairs(debuffs) do
            self:ProcessAuraData(unit, auraData, "DEBUFF")
            cache.debuffs[#cache.debuffs + 1] = auraData
        end
    end
    
    -- 缓存结果
    self.auraCache[unit] = cache
end

-- ============================================================
-- 步骤3b：增量更新 - 只处理变化的光环
-- ============================================================

function AuraDemo:ApplyAuraDelta(unit, updateInfo)
    -- 确保缓存存在
    if not self.auraCache[unit] then
        self:ScanUnitFull(unit)
        return
    end

    local cache = self.auraCache[unit]
    local function removeAuraByInstanceID(list, instanceID)
        for i = 1, #list do
            if list[i] and list[i].auraInstanceID == instanceID then
                table.remove(list, i)
                return true
            end
        end
        return false
    end

    local function upsertAura(list, auraData)
        if not auraData or not auraData.auraInstanceID then
            return
        end

        for i = 1, #list do
            if list[i] and list[i].auraInstanceID == auraData.auraInstanceID then
                list[i] = auraData
                return
            end
        end

        list[#list + 1] = auraData
    end

    -- 处理新增光环
    if updateInfo.addedAuras then
        for _, auraData in ipairs(updateInfo.addedAuras) do
            self:ProcessAuraData(unit, auraData, "ADDED")
            if auraData.isHarmful then
                upsertAura(cache.debuffs, auraData)
            else
                upsertAura(cache.buffs, auraData)
            end
        end
    end

    -- 处理更新的光环（持续时间变化、堆叠数变化）
    if updateInfo.updatedAuraInstanceIDs then
        for _, instanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
            local auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, instanceID)
            if auraData then
                self:ProcessAuraData(unit, auraData, "UPDATED")
                if auraData.isHarmful then
                    upsertAura(cache.debuffs, auraData)
                else
                    upsertAura(cache.buffs, auraData)
                end
            end
        end
    end

    -- 处理移除的光环
    if updateInfo.removedAuraInstanceIDs then
        for _, instanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            removeAuraByInstanceID(cache.buffs, instanceID)
            removeAuraByInstanceID(cache.debuffs, instanceID)
        end
    end

    self.auraCache[unit] = cache
    print(#self.auraCache[unit].buffs)
    if self.frame and self.frame:IsShown() then
        self:UpdateUI()
    end
end

-- ============================================================
-- 步骤4：处理单个光环数据（包含秘密值处理）
-- ============================================================

function AuraDemo:ProcessAuraData(unit, auraData, action)
    
end

-- ============================================================
-- 步骤5：处理持续时间（秘密值安全方式）
-- ============================================================

function AuraDemo:ProcessAuraDuration(unit, auraData)
    local auraInstanceID = auraData.auraInstanceID
    
    -- ❌ 不推荐：直接访问（在秘密值时会失败）
    -- if auraData.expirationTime and auraData.duration > 0 then
    --     local remaining = auraData.expirationTime - GetTime()
    -- end
    
    -- ✅ 推荐：使用Duration对象（秘密值安全）
    -- C_UnitAuras.GetAuraDuration 返回一个Duration对象
    -- 这个对象内部封装了秘密值处理逻辑
    
    if not C_UnitAuras or not C_UnitAuras.GetAuraDuration then
        -- API不可用（旧版本WoW），使用备选方案
        local remaining = (auraData.expirationTime or 0) - GetTime()
        return
    end
    
    -- 获取Duration对象（秘密安全）
    local durationObj = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)
    
    if durationObj then
        local curve = Curves and Curves.EaseOutCubic
        
        -- Duration对象提供了秘密安全的方法
        
        -- 方法1：获取剩余时间百分比（推荐 - 最安全）
        if durationObj.EvaluateRemainingPercent then
            if curve then
                local percent = durationObj:EvaluateRemainingPercent(curve)
            else
                local remaining = (auraData.expirationTime or 0) - GetTime()
                local total = auraData.duration or 0
                local percent = total > 0 and (remaining / total) or 1
            end
        end
        
        -- 方法2：获取剩余时间（秒）
        if durationObj.EvaluateRemainingDuration then
            if curve then
                local remaining = durationObj:EvaluateRemainingDuration(curve)
            else
                local remaining = (auraData.expirationTime or 0) - GetTime()
            end
        end
        
        -- 方法3：使用SetCooldownFromDurationObject更新UI冷却表
        -- if cooldownFrame then
        --     cooldownFrame:SetCooldownFromDurationObject(durationObj)
        -- end
    else
        print("    无Duration对象（秘密值或特殊光环）")
    end
end

-- ============================================================
-- 步骤6：更新UI（显示光环到屏幕）
-- ============================================================

function AuraDemo:UpdateUI()
    -- 创建UI框架显示光环
    if not self.frame then
        self.frame = CreateFrame("Frame", "AuraDemoUI", UIParent)
        self.frame:SetSize(400, 600)
        self.frame:SetPoint("CENTER")

        local bg = self.frame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.frame)
        bg:SetColorTexture(0, 0, 0, 0.8)
        bg:Show()

        local border = self.frame:CreateTexture(nil, "BORDER")
        border:SetAllPoints(self.frame)
        border:SetColorTexture(1, 1, 1, 0.25)
        border:Show()
        
        -- 标题
        local title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -10)
        title:SetText("玩家光环 (UNIT_AURA Demo)")
        
        -- 光环列表滚动框
        local scroll = CreateFrame("ScrollFrame", nil, self.frame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -40)
        scroll:SetSize(380, 550)
        scroll:Show()
        
        local content = CreateFrame("Frame", nil, scroll)
        content:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
        content:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
        content:SetWidth(380)
        content:SetHeight(1)
        content:Show()
        scroll:SetScrollChild(content)
        
        self.frame.content = content
    end
    
    -- 清空旧UI元素
    for i = 1, #self.auraElements do
        self.auraElements[i]:Hide()
    end
    wipe(self.auraElements)
    
    -- 绘制光环
    local cache = self.auraCache["player"]
    if not cache then return end
    
    local y = 0
    local allAuras = {}
    for _, auraData in ipairs(cache.buffs) do
        allAuras[#allAuras + 1] = auraData
    end
    for _, auraData in ipairs(cache.debuffs) do
        allAuras[#allAuras + 1] = auraData
    end
    
    print(#allAuras)
    for i, auraData in ipairs(allAuras) do
        if not issecretvalue(auraData.name) and auraData.name == '复苏之雾' then
            local line = CreateFrame("Frame", nil, self.frame.content)
            line:SetSize(370, 25)
            line:SetPoint("TOPLEFT", self.frame.content, "TOPLEFT", 5, y)
            
            -- 图标
            local icon = line:CreateTexture(nil, "ARTWORK")
            icon:SetSize(20, 20)
            icon:SetPoint("LEFT")
            icon:SetTexture(auraData.icon)
            
            -- 名称和堆叠
            local text = line:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
            text:SetText(auraData.name .. "  " .. tostring(auraData.spellId) .. tostring((auraData.expirationTime or 0) - GetTime()))

            
            self.auraElements[#self.auraElements + 1] = line
            y = y - 25
        end
    end
    
    self.frame.content:SetHeight(-y)
    self.frame:Show()
end

-- ============================================================
-- 部分7：启动/停止Demo
-- ============================================================

function AuraDemo:Start()
    if self.isActive then return end
    self.isActive = true
    
    print("=== AuraDemo 启动 ===")
    print("监听玩家光环变化...")
    
    -- 注册事件
    self.eventFrame = RegisterAuraEvents()
    
    -- 初始化：全量扫描一次
    self:ScanUnitFull("player")
    self:UpdateUI()
    
    -- 启用定时更新UI（检测持续时间变化）
    self.eventFrame:SetScript("OnUpdate", function(self, elapsed)
        AuraDemo:UpdateUI()
    end)
end

function AuraDemo:Stop()
    if not self.isActive then return end
    self.isActive = false
    
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnUpdate", nil)
        self.eventFrame:Hide()
    end

    if self.frame then
        self.frame:Hide()
    end
    
    print("=== AuraDemo 停止 ===")
end

-- ============================================================
-- 导出接口
-- ============================================================

DF.AuraDemo = AuraDemo

-- 便利函数
SLASH_AURADEMO1 = "/aurademo"
SlashCmdList.AURADEMO = function(msg)
    if msg == "start" or msg == "on" then
        AuraDemo:Start()
    elseif msg == "stop" or msg == "off" then
        AuraDemo:Stop()
    else
        print("/aurademo start - 启动演示")
        print("/aurademo stop  - 停止演示")
    end
end

AuraDemo:Start()
print("[AuraDemo] 已加载 - 使用 /aurademo start 启动")
