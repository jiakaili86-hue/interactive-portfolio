"""全身版切件：在签杆交界处做虚拟切断，连通块自动分层。
- cut 区域内像素归身体层（签杆视觉延续）
- 切断后含种子点(食物串)的连通块 + 右上浮空块(火焰) = 签串层
- 其余 = 身体层
"""
from PIL import Image
import numpy as np
from collections import deque

SRC = '/Users/lijiakai/游戏1/assets/enemies/boss_fullbody_raw.png'
img = Image.open(SRC).convert('RGBA')
arr = np.asarray(img)
h, w = arr.shape[:2]
solid = arr[..., 3] > 5

# 多边形套索：圈定食物串+火焰区域（沿头发右缘与肩甲上缘的空隙走线）
POLY = [(452, 298), (444, 270), (452, 246), (470, 232), (488, 206), (486, 170),
        (498, 130), (516, 92), (520, 40), (682, 40), (682, 360), (600, 352),
        (545, 340), (500, 338), (478, 344), (460, 322), (448, 312)]
poly_img = Image.new('L', (w, h), 0)
from PIL import ImageDraw
ImageDraw.Draw(poly_img).polygon(POLY, fill=255)
poly_mask = np.asarray(poly_img) > 127

skewer_sel = solid & poly_mask
body_alpha = np.where(skewer_sel, 0, arr[..., 3])
skewer_alpha = np.where(skewer_sel, arr[..., 3], 0)

def save_part(alpha, path):
    a = arr.copy()
    a[..., 3] = alpha
    ys2, xs2 = np.nonzero(alpha > 5)
    pad = 3
    box = (max(0, int(xs2.min()) - pad), max(0, int(ys2.min()) - pad),
           min(w, int(xs2.max()) + pad + 1), min(h, int(ys2.max()) + pad + 1))
    Image.fromarray(a).crop(box).save(path)
    print(path, 'box', box, 'size', (box[2] - box[0], box[3] - box[1]))

save_part(body_alpha, '/Users/lijiakai/游戏1/assets/enemies/boss_body_main.png')
save_part(skewer_alpha, '/Users/lijiakai/游戏1/assets/enemies/boss_skewer.png')
print('pivot in full coords: (452, 298)')
