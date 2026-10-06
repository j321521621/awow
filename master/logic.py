import pyautogui
pyautogui.PAUSE = 0
pyautogui.MINIMUM_SLEEP = 0

from wow import wow

HK = {
    'raid1' : 'f7',
    'raid2' : 'f8',
    'raid3' : 'f9',
    'raid4' : 'f10',
    'raid5' : 'f11',
    'raid6' : 'f12',
    'raid7' : '7',
    'raid8' : '8',
    'raid9' : '9',
    'raid10' : '0',
    'raid11' : '-',
    'raid12' : '=',

    'raid13' : 'num1',
    'raid14' : 'num2',
    'raid15' : 'num3',
    'raid16' : 'num4',
    'raid17' : 'num5',
    'raid18' : 'num6',
    'raid19' : 'num7',
    'raid20' : 'num8',
    'raid21' : 'num9',
    'raid22' : 'num0',
    'raid23' : 'add',
    'raid24' : 'subtract',

    'lp' : 'delete',
    'nz' : 'home',
    'yg' : 'end',
    'jt' : 'pageup',
    'hx' : 'pagedown',
    'fc' : '[',
    'hp' : ']',
    'ly' : ';',

}


def on_1():   
    if wow.available == False:
        pass
    elif wow.channel:
        pass
    elif wow.cast_nz and wow.hx_count:
        pyautogui.press(HK[wow.target_nz])
        pyautogui.press(HK['nz'])
    elif wow.buff_bf and wow.short_hp >= 1.0:
        pyautogui.press(HK['fc'])
    elif wow.buff_bf == 2 and wow.buff_hx < 2:
        pyautogui.press(HK['fc'])
    elif wow.buff_bf < 2 and wow.cast_yg:
        pyautogui.press(HK['yg'])

def on_2():
    if wow.available == False:
        pass
    elif not wow.move:
        pyautogui.press(HK['lp'])

def on_3():
    if wow.available == False:
        pass
    elif wow.channel:
        pass
    elif wow.cast_jt and not wow.move:
        pyautogui.press(HK['jt'])
    elif wow.cast_hx and wow.buff_hx == 2:
        pyautogui.press(HK[wow.target_hx])
        pyautogui.press(HK['hx'])
    elif wow.buff_bf:
        pyautogui.press(HK['fc'])
    elif wow.cast_hx:
        pyautogui.press(HK[wow.target_hx])
        pyautogui.press(HK['hx'])
    elif wow.cast_hp and not wow.move:
        pyautogui.press(HK['hp'])

def on_4():
    pass