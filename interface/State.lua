print("HeroMatrix show")

local CMD_ID = "MYADDON"
SLASH_MYADDON1 = "/hs"
function SlashCmdList.MYADDON(msg)
    local args = strtrim(msg)
    
    if args == "" then
        print("|cff00ffff[MyAddon]|r 命令帮助：")
        print("  /hs toggle - 开关插件")
        print("  /hs reset  - 重置设置")
    elseif args == "toggle" then
        -- 执行开关逻辑
        print("|cff00ff00[hs]|r 已切换状态")
    elseif args == "reset" then
        -- 执行重置逻辑
        print("|cffff0000[hs]|r 设置已重置")
    else
        print("|cffff0000[hs]|r 未知参数，输入 /myadd 查看帮助")
    end
end
