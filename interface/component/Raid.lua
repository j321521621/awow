local addonName, NS = ...


local Raid = {}
Raid.__index = Raid

function Raid:New(frame, left, top, hotids)
    local self = setmetatable({}, Raid)

    self.unit = {}
    for i = 1, 30 do
        local row = (i - 1) % 10
        local col = math.floor((i - 1) / 10)
        local baseLeft = left + col * 60
        local baseTop = top - row * 5

        self.unit[i] = {
            id = "raid" .. i,
            role_box = NS.create_box(frame, baseLeft + 0, baseTop, 3, 3),
            state_box = NS.create_box(frame, baseLeft + 5, baseTop, 3, 3),
            hp_bar = NS.create_bar(frame, baseLeft + 10, baseTop, 48, 3),
            hot_box = {},
        }

        for j, hotid in ipairs(hotids) do
            self.unit[i].hot_box[hotid] = NS.create_box(frame, baseLeft + 60 + (j - 1) * 5, baseTop, 3, 3)
        end
    end

    return self
end

function Raid:Update()
    for _, unit in ipairs(self.unit) do
        if UnitExists(unit.id) then
            unit.role_box:Show()
            unit.state_box:Show()
            unit.hp_bar:Show()
            for _, hot_box in pairs(unit.hot_box) do
                hot_box:Show()
            end

            local r = 0
            local role = UnitGroupRolesAssigned(unit.id)
            if role == "TANK" then
                r = 0.1
            elseif role == "HEALER" then
                r = 0.2
            else
                r = 0.3
            end
            local g = select(3, UnitClass(unit.id))/20
            unit.role_box.bgtex:SetColorTexture(r, g, 1, 1)

            if UnitIsDeadOrGhost(unit.id) then
                unit.state_box.bgtex:SetColorTexture(1, 0, 0, 1)
            else
                unit.state_box.bgtex:SetColorTexture(1, 1, 1, 1)
            end
            if UnitIsUnit(unit.id, "player") then
                unit.state_box:SetAlpha(1.0)
            else
                unit.state_box:SetAlphaFromBoolean(UnitInRange(unit.id), 1.0, 0.5)
            end
            
            local maxhp = UnitHealthMax(unit.id)
            local hp = UnitHealth(unit.id)
            unit.hp_bar:SetMinMaxValues(0, maxhp)
            unit.hp_bar:SetValue(hp)

            local buff = C_UnitAuras.GetUnitAuras(unit.id, "HELPFUL", 100)
            if buff then
                for _, aura in ipairs(buff) do
                    if not issecretvalue(aura.name) then
                        if unit.hot_box[aura.spellId] then
                            local t = aura.expirationTime - GetTime()
                            print(unit.id, UnitName(unit.id), aura.spellId, t)
                            unit.hot_box[aura.spellId].bgtex:SetColorTexture(t/10, 0, 0, 1)
                        end
                    end
                end
            end

        else
            unit.role_box:Hide()
            unit.state_box:Hide()
            unit.hp_bar:Hide()
            for _, hot_box in pairs(unit.hot_box) do
                hot_box:Hide()
            end
        end
    end
end

NS.Raid = Raid