local addonName, NS = ...

local function create_box(frame, left, top, width, height) 
    local box = CreateFrame("Frame", "RangeSquareFrame", frame)
    box:SetSize(width, height)
    box:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)

    box.bgtex = box:CreateTexture(nil, "BACKGROUND")
    box.bgtex:SetAllPoints()
    box.bgtex:SetColorTexture(1, 1, 1, 1) 

    return box
end


local function create_bar(frame, left, top, width, height)

    local bar = CreateFrame("StatusBar", nil, frame)
    bar:SetSize(width, height)
    bar:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)
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
NS.create_box = create_box
NS.create_bar = create_bar