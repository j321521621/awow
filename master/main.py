import mss
import mss.tools
import time
import numpy as np
import cv2

def capture_screen_to_numpy(region):
    start_time = time.time()
    with mss.mss() as sct:
        if not region:
            region = sct.monitors[0]
        img = np.array(sct.grab(region))
    end_time = time.time()
    print(end_time- start_time, region, img.shape)
    return img

def main():
    while True:
        img = capture_screen_to_numpy({'left': 0, 'top': 0, 'width': 200, 'height': 500})
        cv2.imwrite('master/screenshots/last.png', img)

main()