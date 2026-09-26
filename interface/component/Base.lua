local addonName, NS = ...


local function create_frame(parent, left, top, width, height)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, height)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(0, 0, 0, 1)

    return frame
end


local function create_box(parent, left, top, width, height) 
    local box = CreateFrame("Frame", nil, parent)
    box:SetSize(width, height)
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top)

    box.bg = box:CreateTexture(nil, "BACKGROUND")
    box.bg:SetAllPoints()
    box.bg:SetColorTexture(0, 0, 1, 1) 

    return box
end

local function create_bar(parent, left, top, width, height)

    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetSize(width, height)
    bar:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top)
    bar:SetMinMaxValues(0, 1)

    local texture = bar:CreateTexture()
    texture:SetAllPoints()
    texture:SetColorTexture(0, 0, 0.5, 1)
    bar:SetStatusBarTexture(texture)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.5, 0, 0, 1)

    return bar

end



local function create_hot(parent, left, top, width, height, unit, spellID)
    local frame = create_box(parent, left, top, width, height)

    container = CreateFrame("AuraContainer", nil, frame, "CustomAuraContainerTemplate")

    container:SetAllPoints(frame)
    container:SetUnit(unit)
    container:SetMouseClickEnabled(false)
    container:SetMouseMotionEnabled(false)

    button = container:AddAuraSlot("default", "HELPFUL", {
        candidateFilters = { includeSpellIDs = { [spellID] = true } },
        initializeFrame = function(button)
            button.echoAuraDemoFill = button:CreateTexture(nil, "OVERLAY")
            button.echoAuraDemoFill:SetAllPoints(button)
            button.echoAuraDemoFill:SetColorTexture(1, 0, 0, 1)
        end,
    })

    button:SetAllPoints(container)

    return frame
end


NS.create_frame = create_frame
NS.create_box = create_box
NS.create_bar = create_bar
NS.create_hot = create_hot