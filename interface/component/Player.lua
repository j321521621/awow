local addonName, NS = ...


local Player = {}
Player.__index = Player

function Player:New(parent, left, top, spellids)
    local self = setmetatable({}, Player)

    self.frame = NS.create_frame(parent, left, top, 120, 40, {0, 0, 0, 1})

    self.gcd =      NS.create_bar(self.frame, 0, -0, 36, 5)
    self.cast =     NS.create_bar(self.frame, 0, -8, 36, 5)
    self.channel =  NS.create_bar(self.frame, 0, -16, 36, 5)
    self.mana =     NS.create_bar(self.frame, 0, -24, 36, 5)
    self.essence =  NS.create_bar(self.frame, 0, -32, 36, 5)

    self.cd = {
        {spellid = 373861, bar = NS.create_bar(self.frame, 40, -0, 36, 5)},
        {spellid = 360995, bar = NS.create_bar(self.frame, 40, -8, 36, 5)},
        {spellid = 357208, bar = NS.create_bar(self.frame, 40, -16, 36, 5)},
        {spellid = 366155, bar = NS.create_bar(self.frame, 40, -24, 36, 5)},
    }

    self.hot = {
        NS.create_hot(self.frame, 80, 0, 13, 13, "player", 369299),
        NS.create_hot(self.frame, 80, -16, 13, 13, "player", 1242759),
        NS.create_hot(self.frame, 100, 0, 13, 13, "player", 1256579),
    }



    return self
end 

function Player:Update()
    self.gcd:SetTimerDuration(C_Spell.GetSpellCooldownDuration(61304, false))

    local castName, _, _, startTime, endTime = UnitCastingInfo("player")
    if castName then
        self.cast:Show()
        self.cast:SetMinMaxValues(0, endTime / 1000 - startTime / 1000)
        self.cast:SetValue(GetTime() - startTime / 1000)
    else
        self.cast:Hide()
    end

    local _, _, _, startTime, endTime, _, _, spellID = UnitChannelInfo("player")
    if spellID then
        self.channel:Show()
        self.channel:SetMinMaxValues(0, endTime / 1000 - startTime / 1000)
        self.channel:SetValue(GetTime() - startTime / 1000)
    else
        self.channel:Hide()
    end

    self.mana:SetMinMaxValues(0,  UnitPowerMax("player", Enum.PowerType.Mana))
    self.mana:SetValue(UnitPower("player", Enum.PowerType.Mana))

    self.essence:SetMinMaxValues(0, UnitPowerMax("player", Enum.PowerType.Essence))
    self.essence:SetValue(UnitPower("player", Enum.PowerType.Essence))

    for _, cd in ipairs(self.cd) do
        cd.bar:SetTimerDuration(C_Spell.GetSpellCooldownDuration(cd.spellid, true))
    end
end

NS.Player = Player