BagsBar:Hide()
SetCVar("cameraDistanceMaxZoomFactor", 2.6)

local customBindings = {
    {"ACTIONBUTTON1", nil}, 
    {"ACTIONBUTTON2", nil},
    {"ACTIONBUTTON3", nil},
    {"ACTIONBUTTON4", nil},
    {"ACTIONBUTTON5", nil},
    {"ACTIONBUTTON6", nil},
    {"ACTIONBUTTON7", nil},
    {"ACTIONBUTTON8", nil},
    {"ACTIONBUTTON9", nil},
    {"ACTIONBUTTON10", nil},
    {"ACTIONBUTTON11", nil},
    {"ACTIONBUTTON12", "."},

    {"MULTIACTIONBAR1BUTTON1", nil},
    {"MULTIACTIONBAR1BUTTON2", nil},
    {"MULTIACTIONBAR1BUTTON3", nil},
    {"MULTIACTIONBAR1BUTTON4", nil},
    {"MULTIACTIONBAR1BUTTON5", "ALT-1"},
    {"MULTIACTIONBAR1BUTTON6", "ALT-2"},
    {"MULTIACTIONBAR1BUTTON7", "ALT-3"},
    {"MULTIACTIONBAR1BUTTON8", "ALT-4"},
    {"MULTIACTIONBAR1BUTTON9", "1"},
    {"MULTIACTIONBAR1BUTTON10", "2"},
    {"MULTIACTIONBAR1BUTTON11", "3"},
    {"MULTIACTIONBAR1BUTTON12", "4"},
    
    {"MULTIACTIONBAR2BUTTON1", nil},
    {"MULTIACTIONBAR2BUTTON2", nil},
    {"MULTIACTIONBAR2BUTTON3", nil},
    {"MULTIACTIONBAR2BUTTON4", nil},
    {"MULTIACTIONBAR2BUTTON5", "F1"},
    {"MULTIACTIONBAR2BUTTON6", "F3"},
    {"MULTIACTIONBAR2BUTTON7", nil},
    {"MULTIACTIONBAR2BUTTON8", nil},
    {"MULTIACTIONBAR2BUTTON9", "F2"},
    {"MULTIACTIONBAR2BUTTON10", "F4"},
    {"MULTIACTIONBAR2BUTTON11", nil},
    {"MULTIACTIONBAR2BUTTON12", nil},

    
    {"MULTIACTIONBAR3BUTTON1", nil},
    {"MULTIACTIONBAR3BUTTON2", nil},
    {"MULTIACTIONBAR3BUTTON3", nil},
    {"MULTIACTIONBAR3BUTTON4", nil},
    {"MULTIACTIONBAR3BUTTON5", nil},
    {"MULTIACTIONBAR3BUTTON6", nil},
    {"MULTIACTIONBAR3BUTTON7", "Q"},
    {"MULTIACTIONBAR3BUTTON8", "Z"},
    {"MULTIACTIONBAR3BUTTON9", nil},
    {"MULTIACTIONBAR3BUTTON10", nil},
    {"MULTIACTIONBAR3BUTTON11", "E"},
    {"MULTIACTIONBAR3BUTTON12", "C"},

    
    {"MULTIACTIONBAR4BUTTON1", "F6"},
    {"MULTIACTIONBAR4BUTTON2", "F7"},
    {"MULTIACTIONBAR4BUTTON3", "F8"},
    {"MULTIACTIONBAR4BUTTON4", "F9"},
    {"MULTIACTIONBAR4BUTTON5", "F10"},
    {"MULTIACTIONBAR4BUTTON6", "F11"},
    {"MULTIACTIONBAR4BUTTON7", "F12"},
    {"MULTIACTIONBAR4BUTTON8", "F13"},
    {"MULTIACTIONBAR4BUTTON9", "F14"},
    {"MULTIACTIONBAR4BUTTON10", "F15"},
    {"MULTIACTIONBAR4BUTTON11", "F16"},
    {"MULTIACTIONBAR4BUTTON12", "F17"},

    
    {"MULTIACTIONBAR5BUTTON1", "F19"},
    {"MULTIACTIONBAR5BUTTON2", "F19"},
    {"MULTIACTIONBAR5BUTTON3", "F20"},
    {"MULTIACTIONBAR5BUTTON4", "F21"},
    {"MULTIACTIONBAR5BUTTON5", "F22"},
    {"MULTIACTIONBAR5BUTTON6", "F23"},
    {"MULTIACTIONBAR5BUTTON7", "F24"},
    {"MULTIACTIONBAR5BUTTON8", "NUMPAD0"},
    {"MULTIACTIONBAR5BUTTON9", "NUMPAD1"},
    {"MULTIACTIONBAR5BUTTON10", "NUMPAD2"},
    {"MULTIACTIONBAR5BUTTON11", "NUMPAD3"},
    {"MULTIACTIONBAR5BUTTON12", "NUMPAD4"},
    
    {"MULTIACTIONBAR6BUTTON1", "NUMPAD5"},
    {"MULTIACTIONBAR6BUTTON2", "NUMPAD6"},
    {"MULTIACTIONBAR6BUTTON3", "NUMPAD7"},
    {"MULTIACTIONBAR6BUTTON4", "NUMPAD8"},
    {"MULTIACTIONBAR6BUTTON5", "NUMPAD9"},
    {"MULTIACTIONBAR6BUTTON6", "NUMPADPLUS"},
    {"MULTIACTIONBAR6BUTTON7", "NUMPADMINUS"},
    {"MULTIACTIONBAR6BUTTON8", "NUMPADMULTIPLY"},
    {"MULTIACTIONBAR6BUTTON9", "NUMPADDIVIDE"},
    {"MULTIACTIONBAR6BUTTON10", "NUMPADDECIMAL"},
    {"MULTIACTIONBAR6BUTTON11", nil},
    {"MULTIACTIONBAR6BUTTON12", nil},
}

SLASH_BINDBARS1 = "/bindbars"

-- 3. 绑定命令的回调函数
SlashCmdList["BINDBARS"] = function(msg)
    if InCombatLockdown() then
        print("无法在战斗中修改快捷键，请脱战后再试！")
        return
    end


    for _, item in ipairs(customBindings) do
        local command = item[1]
        local key = item[2]
        local key1, key2 = GetBindingKey(command)
        print(command, key1, key2)
        if key1 then
            SetBinding(key1, nil)
        end
        if key2 then
            SetBinding(key2, nil)
        end
        if key then
            SetBinding(key, command)
        end
    end

    for i = 1, 30 do
        local macroName = "FCR" .. i
        local macroText = "/focus raid" .. i

        while true do
            local index = GetMacroIndexByName(macroName)
            if index and index > 0 then
                DeleteMacro(index)
            else
                break
            end
        end

        local newIndex = CreateMacro(macroName, 132532, macroText, nil)
        if not newIndex then
            print("|cffff0000[警告]|r 创建 " .. macroName .. " 失败：账号通用宏栏位已满！")
            break
        end
    end

    SaveBindings(2)
    print(string.format("|cFF00FF00[按键助手]|r 绑定成功！"))
end