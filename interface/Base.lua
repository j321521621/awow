local addonName, NS = ...


local function create_frame(parent, left, top, width, height, background)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, height)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top)
    frame.awow = frame.awow or {}

    frame.awow.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.awow.background:SetAllPoints(frame)
    frame.awow.background:SetColorTexture(background[1], background[2], background[3], background[4])

    return frame
end

local function create_bar(parent, left, top, width, height)
    local frame = CreateFrame("StatusBar", nil, parent)
    frame:SetSize(width, height)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top)
    frame:SetMinMaxValues(0, 1)
    frame.awow = frame.awow or {}

    frame.awow.texture = frame:CreateTexture()
    frame.awow.texture:SetAllPoints()
    frame.awow.texture:SetColorTexture(0, 0, 1, 1)
    frame:SetStatusBarTexture(frame.awow.texture)

    frame.awow.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.awow.background:SetAllPoints()
    frame.awow.background:SetColorTexture(1, 0, 0, 1)

    return frame

end

local function create_hot(parent, left, top, width, height, unit, spellID)
    local frame = create_frame(parent, left, top, width, height, {1, 0, 0, 1})

    container = CreateFrame("AuraContainer", nil, frame, "CustomAuraContainerTemplate")

    container:SetAllPoints(frame)
    container:SetUnit(unit)
    container:SetMouseClickEnabled(false)
    container:SetMouseMotionEnabled(false)

    slot = container:AddAuraSlot("default", "HELPFUL", {
        candidateFilters = { includeSpellIDs = { [spellID] = true } },
        initializeFrame = function(slot)
            slot.echoAuraDemoFill = slot:CreateTexture(nil, "OVERLAY")
            slot.echoAuraDemoFill:SetAllPoints(slot)
            slot.echoAuraDemoFill:SetColorTexture(0, 0, 1, 1)

            slot.Count = slot:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
            slot.Count:SetPoint("CENTER", slot, "CENTER", 0, 0)
            slot:SetApplicationCount(slot.Count)
        end,
    })
    slot:SetAllPoints(container)

    return frame
end


NS.create_frame = create_frame
NS.create_bar = create_bar
NS.create_hot = create_hot