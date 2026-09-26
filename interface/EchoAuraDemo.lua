local addonName = ...

local ECHO_SPELL_ID = 364343
local containers = {}
local root
local running = false

local function printMessage(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffEchoAuraDemo:|r " .. message)
    end
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
    fill:SetColorTexture(1, 0.08, 0.08, 1)
end

local function setContainersEnabled(enabled)
    for i = 1, #containers do
        local container = containers[i]
        if enabled then
            container:Show()
            container:SetEnabled(true)
        else
            container:SetEnabled(false)
            container:Hide()
        end
    end
end

local function buildDemo()
    if root then return true end
    if not AuraUtil or not AuraUtil.IsValidFilterString then
        printMessage("This client does not expose the AuraContainer API.")
        return false
    end
    if InCombatLockdown() then
        printMessage("Start the demo out of combat.")
        return false
    end

    root = CreateFrame("Frame", nil, UIParent)
    root:SetSize(300, 190)
    root:SetPoint("CENTER", UIParent, "CENTER", 400, 0)
    root:SetFrameStrata("DIALOG")
    root:SetClampedToScreen(true)
    root:Show()

    local background = root:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(root)
    background:SetColorTexture(0.025, 0.04, 0.075, 0.96)

    local title = root:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", root, "TOPLEFT", 12, -10)
    title:SetText("Echo 364343: raid1-raid10")

    for i = 1, 10 do
        local unit = "raid" .. i
        local column = (i - 1) % 2
        local rowIndex = math.floor((i - 1) / 2)

        local row = CreateFrame("Frame", nil, root)
        row:SetSize(136, 25)
        row:SetPoint("TOPLEFT", root, "TOPLEFT", 12 + column * 142, -38 - rowIndex * 28)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        label:SetWidth(42)
        label:SetJustifyH("LEFT")
        label:SetText(unit)

        local cell = CreateFrame("Frame", nil, row)
        cell:SetSize(82, 22)
        cell:SetPoint("RIGHT", row, "RIGHT", 0, 0)

        local blue = cell:CreateTexture(nil, "BACKGROUND")
        blue:SetAllPoints(cell)
        blue:SetColorTexture(0.08, 0.28, 0.95, 1)

        local ok, container = pcall(CreateFrame, "AuraContainer", nil, cell,
            "CustomAuraContainerTemplate")
        if not ok or not container or type(container.AddAuraSlot) ~= "function" then
            for j = 1, #containers do
                pcall(containers[j].SetEnabled, containers[j], false)
                pcall(containers[j].Hide, containers[j])
            end
            containers = {}
            root:Hide()
            root = nil
            printMessage("Could not create a native AuraContainer. Is this WoW 12.1+?")
            return false
        end

        container:SetAllPoints(cell)
        container:SetUnit(unit)
        container:SetMouseClickEnabled(false)
        container:SetMouseMotionEnabled(false)

        local okSlot, button = pcall(container.AddAuraSlot, container, "echo", "HELPFUL", {
            candidateFilters = { includeSpellIDs = { [ECHO_SPELL_ID] = true } },
            initializeFrame = styleAuraButton,
        })
        if not okSlot or not button then
            pcall(container.SetEnabled, container, false)
            pcall(container.Hide, container)
            for j = 1, #containers do
                pcall(containers[j].SetEnabled, containers[j], false)
                pcall(containers[j].Hide, containers[j])
            end
            containers = {}
            root:Hide()
            root = nil
            printMessage("Could not register the Echo aura slot.")
            return false
        end

        button:SetAllPoints(cell)
        container:Show()
        containers[#containers + 1] = container
    end

    return true
end

local function startDemo()
    if running then
        printMessage("Already running.")
        return
    end
    if InCombatLockdown() then
        printMessage("Start the demo out of combat.")
        return
    end
    if not buildDemo() then return end

    root:Show()
    setContainersEnabled(true)
    running = true
    printMessage("Started. Blue = no Echo; red = Echo present.")
end


startDemo()