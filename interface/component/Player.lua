local addonName, NS = ...


local Player = {}
Player.__index = Player

function Player:New(parent, left, top, spellids)
    local self = setmetatable({}, Player)

    self.frame = NS.create_frame(parent, left, top, 80, 40)

    self.mana =     NS.create_bar(self.frame, 0, 0, 40, 5)
    self.essence =  NS.create_bar(self.frame, 0, -8, 40, 5)
    self.channel =  NS.create_bar(self.frame, 0, -16, 40, 5)
    self.gcd =      NS.create_bar(self.frame, 0, -24, 40, 5)

    return self
end 

function Player:Update()

    self.mana:SetMinMaxValues(0,  UnitPowerMax("player", Enum.PowerType.Mana))
    self.mana:SetValue(UnitPower("player", Enum.PowerType.Mana))

    self.essence:SetMinMaxValues(0, UnitPowerMax("player", Enum.PowerType.Essence))
    self.essence:SetValue(UnitPower("player", Enum.PowerType.Essence))

    local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo("player")
    if spellID then
        self.channel:Show()
        self.channel:SetMinMaxValues(0, endTime / 1000 - startTime / 1000)
        self.channel:SetValue(GetTime() - startTime / 1000)
    else
        self.channel:Hide()
    end

    self.gcd:SetTimerDuration(C_Spell.GetSpellCooldownDuration(61304, false))

end

NS.Player = Player