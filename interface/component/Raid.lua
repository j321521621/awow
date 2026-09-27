local addonName, NS = ...


local Raid = {}
Raid.__index = Raid

function Raid:New(parent, left, top, hotids)
    local self = setmetatable({}, Raid)

    self.frame = NS.create_frame(parent, left, top, 80 * 6, 8 * 5, {0, 0, 0, 1})
    self.unit = {}
    for i = 1, 30 do
        local row = (i - 1) % 5
        local col = math.floor((i - 1) / 5)
        local baseLeft = left + col * 80
        local baseTop = top - row * 8

        self.unit[i] = {
            id = "raid" .. i,
            role_box = NS.create_frame(self.frame, baseLeft + 0, baseTop, 5, 5, {0, 0, 0, 1}),
            state_box = NS.create_frame(self.frame, baseLeft + 8, baseTop, 5, 5, {1, 1, 1, 1}),
            hp_bar = NS.create_bar(self.frame, baseLeft + 16, baseTop, 36, 5),
            hot_box = {},
        }

        for j, hotid in ipairs(hotids) do
            self.unit[i].hot_box[j] =
            NS.create_hot(self.frame, baseLeft + 56 + (j - 1) * 5, baseTop, 5, 5, self.unit[i].id, hotid)
        end
    end

    return self
end

function Raid:Update()
    for _, unit in ipairs(self.unit) do
        if UnitExists(unit.id) and not UnitIsDeadOrGhost(unit.id) then
            unit.role_box:Show()
            unit.state_box:Show()
            unit.hp_bar:Show()
            for _, hot_box in pairs(unit.hot_box) do
                hot_box:Show()
            end

            local c = select(3, UnitClass(unit.id))/20
            local role = UnitGroupRolesAssigned(unit.id)
            if role == "TANK" then
                unit.role_box.awow.background:SetColorTexture(c, 0, 0, 1)
            elseif role == "HEALER" then
                unit.role_box.awow.background:SetColorTexture(0, c, 0, 1)
            else
                unit.role_box.awow.background:SetColorTexture(0, 0, c, 1)
            end

            if UnitIsUnit(unit.id, "player") then
                unit.state_box:SetAlpha(1.0)
            else
                unit.state_box:SetAlphaFromBoolean(UnitInRange(unit.id), 1.0, 0.5)
            end
            
            unit.hp_bar:SetMinMaxValues(0, UnitHealthMax(unit.id))
            unit.hp_bar:SetValue(UnitHealth(unit.id))


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