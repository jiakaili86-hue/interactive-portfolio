"""Boss 全身立绘抠图。
原图 = 人物（带黑描边）+ 背后红色辣椒纹章（无描边）+ 白底。
头发颜色与纹章几乎相同，无法纯按颜色区分；但人物所有形状均有
深色描边包裹，泛洪填充会被描边挡住，因此：
  removable = 白色系 | 纹章红系
  从图像边界对 removable 做泛洪 -> 命中的都是背景（白底+纹章）
  人物内部即使有同色头发也不会被吃掉（描边阻断连通）。
之后腐蚀 2px 去掉抠图红边/灰边，再做 1px 软边。
"""
from PIL import Image
import numpy as np

SRC = '/Users/lijiakai/.cursor/projects/Users-lijiakai-Desktop-my-claude/assets/boss_pepper_king_portrait.png'
OUT = '/Users/lijiakai/游戏1/assets/enemies/boss_pepper_body.png'
PREVIEW = '/Users/lijiakai/游戏1/qa/source_previews/boss_cutout_preview.png'

img = Image.open(SRC).convert('RGB')
arr = np.asarray(img).astype(np.int32)
h, w, _ = arr.shape
r, g, b = arr[..., 0], arr[..., 1], arr[..., 2]
min_ch = arr.min(axis=2)

whiteish = min_ch >= 200
# 纹章红：红主导、绿蓝压低（与头发同色但靠描边阻断）
emblemish = (r >= 90) & (r <= 200) & (g < 75) & (b < 75)
removable = whiteish | emblemish

# 从边界泛洪：用迭代膨胀实现（与 removable 取交）
outside = np.zeros((h, w), dtype=bool)
outside[0, :] = removable[0, :]
outside[-1, :] = removable[-1, :]
outside[:, 0] = removable[:, 0]
outside[:, -1] = removable[:, -1]
while True:
    grown = outside.copy()
    grown[1:, :] |= outside[:-1, :]
    grown[:-1, :] |= outside[1:, :]
    grown[:, 1:] |= outside[:, :-1]
    grown[:, :-1] |= outside[:, 1:]
    grown &= removable
    if (grown == outside).all():
        break
    outside = grown

keep = ~outside

# 腐蚀 2px：去掉纹章/白底的 AA 残边
for _ in range(2):
    er = keep.copy()
    er[1:, :] &= keep[:-1, :]
    er[:-1, :] &= keep[1:, :]
    er[:, 1:] &= keep[:, :-1]
    er[:, :-1] &= keep[:, 1:]
    keep = er

# 清掉孤立小岛（被困在人物外的纹章残块）：保留面积 > 1500 的连通块
from collections import deque
labels = np.zeros((h, w), dtype=np.int32)
cur = 0
sizes = {}
for sy in range(h):
    row = keep[sy]
    for sx in np.nonzero(row & (labels[sy] == 0))[0]:
        cur += 1
        dq = deque([(sy, sx)])
        labels[sy, sx] = cur
        n = 0
        while dq:
            y, x = dq.popleft()
            n += 1
            for ny, nx in ((y-1, x), (y+1, x), (y, x-1), (y, x+1)):
                if 0 <= ny < h and 0 <= nx < w and keep[ny, nx] and labels[ny, nx] == 0:
                    labels[ny, nx] = cur
                    dq.append((ny, nx))
        sizes[cur] = n
good = {k for k, v in sizes.items() if v > 1500}
keep &= np.isin(labels, list(good))

# 软边：mask 做 3x3 均值得到 alpha
m = keep.astype(np.float64)
soft = m.copy()
soft[1:, :] += m[:-1, :]; soft[:-1, :] += m[1:, :]
soft[:, 1:] += m[:, :-1]; soft[:, :-1] += m[:, 1:]
soft = np.clip(soft / 4.0, 0.0, 1.0)
soft[~keep] *= 0.6  # 外侧羽化更轻，防灰边

rgba = np.dstack([arr.astype(np.uint8), (soft * 255).astype(np.uint8)])
out = Image.fromarray(rgba, 'RGBA')

ys, xs = np.nonzero(soft > 0.05)
pad = 4
box = (max(0, int(xs.min()) - pad), max(0, int(ys.min()) - pad),
       min(w, int(xs.max()) + pad), min(h, int(ys.max()) + pad))
out = out.crop(box)
out.save(OUT)
print('saved', OUT, out.size, 'kept_components:', len(good))

# 预览：放到米色底上看效果
bg = Image.new('RGBA', out.size, (235, 222, 195, 255))
bg.alpha_composite(out)
import os
os.makedirs(os.path.dirname(PREVIEW), exist_ok=True)
bg.convert('RGB').save(PREVIEW)
print('preview', PREVIEW)
