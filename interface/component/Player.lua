local addonName, NS = ...


local Player = {}
Player.__index = Player

function Player:New(parent, left, top, spellids)
    local self = setmetatable({}, Player)

    self.frame = NS.create_frame(parent, left, top, 80, 40)

    self.channel = NS.create_bar(self.frame, 0, 0, 40, 5)
    self.gcd = NS.create_bar(self.frame, 0, -8, 40, 5)

    return self
end

function Player:Update()
    self.gcd:SetTimerDuration(C_Spell.GetSpellCooldownDuration(61304, false))

    local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo("player")
    if spellID then
        self.channel:Show()
        self.channel:SetMinMaxValues(0, endTime / 1000 - startTime / 1000)
        self.channel:SetValue(GetTime() - startTime / 1000)
    else
        self.channel:Hide()
    end


end

NS.Player = Player