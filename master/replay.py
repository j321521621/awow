import sys
import pickle
import numpy as np
import cv2
from wow import State


def plot(data, f):
    print(data[0])
    row_height = 60
    row_pad = 2
    width = 900
    rate = 30

    row = int(data[-1][0]) * rate // width + 1
    img = np.ones((row * (row_height + row_pad), width, 3), dtype = np.uint8) * 0

    precd = 0
    for t, cda, cd in data:

        x = t * rate
        y1 = cda * row_height
        y2 = min(cd * rate, row_height) 

        basex = x % width
        basey = x // width * (row_height + row_pad)
        

        if cd > 0 and precd == 0:
            img[int(basey) : int(basey) + row_height, int(basex), 0]= 255
        precd = cd

        img[int(basey + y1), int(basex), 2] = 255
        img[int(basey + y2), int(basex), 1] = 255

    cv2.imwrite(f, img)


with open(sys.argv[1], "rb") as f:
    data = []
    state = State()
    while True:
        try:
            d = pickle.load(f)
        except EOFError:
            break
        
        state.add(d)
        data.append([state.now, d['cd2'], state.cd2])

    plot(data, 'cd2.png')
        