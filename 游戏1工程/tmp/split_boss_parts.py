"""把 boss_pepper_body.png 切成两层：
- boss_body_main.png：人物本体（含手、签杆下段）
- boss_skewer.png：火签串（签杆上段+食物+火焰），游戏内绕锚点轻晃
切线：y<470 时 x=872 竖线；y 470~720 沿 (872,470)->(890,720) 斜线。
锚点（旋转轴）：(860, 550)，即签杆从肩甲后探出的位置。
输出元数据供 main.gd 使用。
"""
from PIL import Image
import numpy as np

SRC = '/Users/lijiakai/游戏1/assets/enemies/boss_pepper_body.png'
img = Image.open(SRC).convert('RGBA')
arr = np.asarray(img)
h, w = arr.shape[:2]

xs = np.arange(w)[None, :].repeat(h, 0).astype(np.float64)
ys = np.arange(h)[:, None].repeat(w, 1).astype(np.float64)
# 分段切线：避开马尾(y<185)、肩甲(280~470)，在签杆探出点(860,555)附近收窄
cut_x = np.full((h, w), 1e9)
seg1 = ys < 185
seg2 = (ys >= 185) & (ys < 280)
seg3 = (ys >= 280) & (ys < 470)
seg4 = (ys >= 470) & (ys < 555)
seg5 = (ys >= 555) & (ys < 680)
seg5 = (ys >= 555) & (ys < 683)
cut_x = np.where(seg1, 1000.0, cut_x)
cut_x = np.where(seg2, 892.0, cut_x)
cut_x = np.where(seg3, 888.0, cut_x)
cut_x = np.where(seg4, 860.0, cut_x)
cut_x = np.where(seg5, 860.0 + (ys - 555.0) * (950.0 - 860.0) / (683.0 - 555.0), cut_x)
skewer_mask = xs >= cut_x

body = arr.copy()
body[..., 3] = np.where(skewer_mask, 0, body[..., 3])
skewer = arr.copy()
skewer[..., 3] = np.where(~skewer_mask, 0, skewer[..., 3])

def crop_save(a, path):
    al = a[..., 3]
    yy, xx = np.nonzero(al > 5)
    pad = 3
    box = (max(0, xx.min()-pad), max(0, yy.min()-pad), min(w, xx.max()+pad+1), min(h, yy.max()+pad+1))
    Image.fromarray(a).crop(box).save(path)
    print(path, 'box', box, 'size', (box[2]-box[0], box[3]-box[1]))
    return box

b_box = crop_save(body, '/Users/lijiakai/游戏1/assets/enemies/boss_body_main.png')
s_box = crop_save(skewer, '/Users/lijiakai/游戏1/assets/enemies/boss_skewer.png')

# 锚点与参考点（全图坐标系）
pivot = (860.0, 550.0)
print('--- main.gd 用元数据（全图坐标 1397x1024）---')
print('body crop offset:', b_box[:2], ' skewer crop offset:', s_box[:2])
print('pivot in skewer-local:', (pivot[0]-s_box[0], pivot[1]-s_box[1]))
print('pivot in full:', pivot)
