local addonName, NS = ...


local AuraDemo = {
    isActive = false,
    auraCache = {},           -- 缓存光环数据
    frame = nil,              -- UI主框架
    eventFrame = nil,         -- 事件框架
    auraElements = {},        -- UI光环元素
}


-- 步骤1：监听事件（WoW事件注册）
local function RegisterAuraEvents()
    local frame = CreateFrame("Frame", "AuraDemoFrame", UIParent)
    
    frame:RegisterUnitEvent("UNIT_AURA", "player")
    
    frame:SetScript("OnEvent", function(self, event, unit, updateInfo)
        if event == "UNIT_AURA" then
            -- 步骤2：处理事件 → 扫描光环
            AuraDemo:ScanUnitAuras(unit, updateInfo)
        end
    end)
    
    return frame
end


function AuraDemo:ScanUnitAuras(unit, updateInfo)
    self:ScanUnitFull(unit)
end


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
            if not issecretvalue(auraData.name) and (auraData.spellId == 119611 or auraData.spellId == 124682) then
                cache.buffs[#cache.buffs + 1] = auraData
            end
        end
    end
    
    
    -- 缓存结果
    self.auraCache[unit] = cache
end




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
    
    for i, auraData in ipairs(allAuras) do
        if true then break end
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

NS.AuraDemo = AuraDemo

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

frame:SetScript("OnUpdate",function(self, elapsed)
    raid:Update()
end)
