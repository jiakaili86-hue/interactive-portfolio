"""全身版 Boss 抠图：白底泛洪（无纹章，比半身版简单）。
封闭白洞先全部列出并生成调试标记图，人工确认后再杀。
"""
from PIL import Image, ImageDraw
import numpy as np
from collections import deque

SRC = '/Users/lijiakai/.cursor/projects/Users-lijiakai-Desktop-my-claude/assets/ChatGPT_Image_2026_6_12__14_59_44-5aea112b-bfae-40e6-9ed6-ce8c29aa2588.png'
OUT = '/Users/lijiakai/游戏1/assets/enemies/boss_fullbody_raw.png'
DEBUG = '/tmp/boss_fb_holes_debug.png'

img = Image.open(SRC).convert('RGB')
arr = np.asarray(img).astype(np.int32)
h, w, _ = arr.shape
min_ch = arr.min(axis=2)
whiteish = min_ch >= 235
soft_band = np.clip((235.0 - min_ch) / (235.0 - 195.0), 0.0, 1.0)  # 1=不透明

# 边界泛洪（迭代膨胀）
outside = np.zeros((h, w), dtype=bool)
outside[0, :] = whiteish[0, :]; outside[-1, :] = whiteish[-1, :]
outside[:, 0] |= whiteish[:, 0]; outside[:, -1] |= whiteish[:, -1]
while True:
    grown = outside.copy()
    grown[1:, :] |= outside[:-1, :]; grown[:-1, :] |= outside[1:, :]
    grown[:, 1:] |= outside[:, :-1]; grown[:, :-1] |= outside[:, 1:]
    grown &= whiteish
    if (grown == outside).all():
        break
    outside = grown

# 列出封闭白色连通块（潜在背景洞 vs 牙齿/高光）
enclosed = whiteish & ~outside
labels = np.zeros((h, w), np.int32); cur = 0
comps = []
for sy in range(h):
    for sx in np.nonzero(enclosed[sy] & (labels[sy] == 0))[0]:
        cur += 1; dq = deque([(sy, sx)]); labels[sy, sx] = cur; pix = []
        while dq:
            y, x = dq.popleft(); pix.append((y, x))
            for ny, nx in ((y-1, x), (y+1, x), (y, x-1), (y, x+1)):
                if 0 <= ny < h and 0 <= nx < w and enclosed[ny, nx] and labels[ny, nx] == 0:
                    labels[ny, nx] = cur; dq.append((ny, nx))
        if len(pix) >= 150:
            ys = [p[0] for p in pix]; xs = [p[1] for p in pix]
            comps.append((cur, len(pix), (min(xs), min(ys), max(xs), max(ys))))

dbg = img.copy()
d = ImageDraw.Draw(dbg)
for cid, area, bbox in comps:
    d.rectangle(bbox, outline=(0, 200, 0), width=3)
    d.text((bbox[0], max(0, bbox[1]-14)), f'{cid}:{area}', fill=(0, 120, 0))
dbg.save(DEBUG)
for c in comps:
    print('comp', c[0], 'area', c[1], 'bbox', c[2])

# 先存仅去外部白底的版本（软边），洞稍后处理
alpha = np.where(outside, 0.0, np.maximum(soft_band, np.where(whiteish, 0.0, 1.0)))
# 外部边缘软边：outside 邻接处用 soft_band
edge = outside.copy()
e2 = edge.copy()
e2[1:, :] |= edge[:-1, :]; e2[:-1, :] |= edge[1:, :]
e2[:, 1:] |= edge[:, :-1]; e2[:, :-1] |= edge[:, 1:]
rim = e2 & ~outside
alpha = np.where(rim, soft_band * 0.85, alpha)
rgba = np.dstack([arr.astype(np.uint8), (np.clip(alpha, 0, 1) * 255).astype(np.uint8)])
Image.fromarray(rgba, 'RGBA').save(OUT)
print('saved raw', OUT)
