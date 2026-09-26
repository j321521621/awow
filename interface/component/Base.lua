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
    box.bg:SetColorTexture(1, 1, 1, 1) 

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


local function styleAuraButton(button)
    if button.SetMouseClickEnabled then button:SetMouseClickEnabled(false) end
    if button.SetMouseMotionEnabled then button:SetMouseMotionEnabled(false) end

    local fill = button.echoAuraDemoFill
    if not fill then
        fill = button:CreateTexture(nil, "OVERLAY")
        button.echoAuraDemoFill = fill
    end
    fill:SetAllPoints(button)
    fill:SetColorTexture(1, 0, 0, 1)
end

local function create_hot(parent, left, top, width, height, unit, spellID)
    print(parent, left, top, width, height, unit, spellID)

    local cell = CreateFrame("Frame", nil, parent)
    cell:SetSize(width, height)
    cell:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top)

    local blue = cell:CreateTexture(nil, "BACKGROUND")
    blue:SetAllPoints(cell)
    blue:SetColorTexture(0, 0, 1, 1)

    container = CreateFrame("AuraContainer", nil, cell, "CustomAuraContainerTemplate")

    container:SetAllPoints(cell)
    container:SetUnit(unit)
    container:SetMouseClickEnabled(false)
    container:SetMouseMotionEnabled(false)

    button = container.AddAuraSlot(container, "echo", "HELPFUL", {
        candidateFilters = { includeSpellIDs = { [spellID] = true } },
        initializeFrame = styleAuraButton,
    })

    button:SetAllPoints(cell)

    return cell
end


NS.create_frame = create_frame
NS.create_box = create_box
NS.create_bar = create_bar
NS.create_hot = create_hot