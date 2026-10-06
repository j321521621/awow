local addonName, NS = ...


local Player = {}
Player.__index = Player

function Player:New(parent, left, top, spellids)
    local self = setmetatable({}, Player)

    self.frame = NS.create_frame(parent, left, top, 160, 40, {0, 0, 0, 1})

    self.hp =       NS.create_bar(self.frame, 0, -0, 36, 4)
    self.mp =       NS.create_bar(self.frame, 0, -8, 36, 4)
    self.essence =  NS.create_bar(self.frame, 0, -16, 36, 4)
    self.cast =     NS.create_bar(self.frame, 0, -24, 36, 4)
    self.channel =  NS.create_bar(self.frame, 0, -32, 36, 4)

    self.cd = {
        {spellid = 61304, ignoregcd = false ,bar = NS.create_bar(self.frame, 40, -0, 76, 4)},
        {spellid = 373861, ignoregcd = true ,bar = NS.create_bar(self.frame, 40, -8, 76, 4)},
        {spellid = 360995, ignoregcd = true ,bar = NS.create_bar(self.frame, 40, -16, 76, 4)},
        {spellid = 357208, ignoregcd = true ,bar = NS.create_bar(self.frame, 40, -24, 76, 4)},
        {spellid = 366155, ignoregcd = true ,bar = NS.create_bar(self.frame, 40, -32, 76, 4)},
    }

    self.move = NS.create_frame(self.frame, 120, -0, 8, 12, {0, 0, 1, 1})
    self.hot = {
        NS.create_hot(self.frame, 120, -16, 8, 12, "player", 369299),
        NS.create_hot(self.frame, 132, -16, 8, 12, "player", 1242759),
        NS.create_hot(self.frame, 144, -16, 8, 12, "player", 1256579),
    }



    return self
end 

function Player:Update()

    self.hp:SetMinMaxValues(0,  UnitHealthMax("player"))
    self.hp:SetValue(UnitHealth("player"))
    self.mp:SetMinMaxValues(0,  UnitPowerMax("player", Enum.PowerType.Mana))
    self.mp:SetValue(UnitPower("player", Enum.PowerType.Mana))
    self.essence:SetMinMaxValues(0, UnitPowerMax("player", Enum.PowerType.Essence))
    self.essence:SetValue(UnitPower("player", Enum.PowerType.Essence))

    local castName, _, _, startTime, endTime = UnitCastingInfo("player")
    if castName then
        self.cast:Show()
        self.cast:SetMinMaxValues(0, endTime / 1000 - startTime / 1000)
        self.cast:SetValue(GetTime() - startTime / 1000)
    else
        self.cast:Hide()
    end

    local castName, _, _, startTime, endTime = UnitChannelInfo("player")
    if castName then
        self.channel:Show()
        self.channel:SetMinMaxValues(0, endTime / 1000 - startTime / 1000)
        self.channel:SetValue(GetTime() - startTime / 1000)
    else
        self.channel:Hide()
    end

    for _, cd in ipairs(self.cd) do
        cd.bar:SetTimerDuration(C_Spell.GetSpellCooldownDuration(cd.spellid, cd.ignoregcd))
    end

    if IsPlayerMoving() or IsFalling() then
        self.move.awow.background:SetColorTexture(0, 0, 1, 1)
    else
        self.move.awow.background:SetColorTexture(1, 0, 0, 1)
    end

end

NS.Player = Player