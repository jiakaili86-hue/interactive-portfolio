"""批量处理特效绿幕/洋红幕素材：抠图、去溢色、按最大内容统一缩放、拼 8x1 图集（128px/格）。"""
from PIL import Image
import numpy as np

SRC_DIR = '/Users/lijiakai/.cursor/projects/Users-lijiakai-Desktop-my-claude/assets'
OUT_DIR = '/Users/lijiakai/游戏1/assets/effects'
CELL = 128

# (源文件, 幕布色, 输出名, 是否提亮)
# v3 正俯视法阵（与地面平行）+ boss 常驻威压光环；hit 与 shadow 沿用 v1 已确认版本
# 技能法阵统一提亮降透（用户反馈颜色太深）；boss 光环保持深色压迫感
LIGHTEN = 0.20   # 向白色提亮比例
ALPHA_MUL = 0.85 # 整体不透明度系数
JOBS = [
    ('fx3_mist_magenta.png', 'magenta', 'fx_mist_sheet.png', True),
    ('fx3_shield_magenta.png', 'magenta', 'fx_shield_wave_sheet.png', True),
    ('fx3_summon_green.png', 'green', 'fx_summon_sheet.png', True),
    ('fx3_heal_green.png', 'green', 'fx_heal_sheet.png', True),
    ('fx3_rain_green.png', 'green', 'fx_rain_sheet.png', True),
    ('fx3_root_magenta.png', 'magenta', 'fx_root_sheet.png', True),
    ('fx3_weaken_magenta.png', 'magenta', 'fx_weaken_sheet.png', True),
    ('fx3_vine_magenta.png', 'magenta', 'fx_vine_sheet.png', True),
    ('fx3_barrage_green.png', 'green', 'fx_boss_barrage_sheet.png', True),
    ('fx3_bossaura_green.png', 'green', 'fx_boss_aura_sheet.png', False),
]

def chroma_key(img, bg):
    a = np.array(img).astype(np.int16)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    if bg == 'green':
        mask = (g > 90) & (g > r * 1.25) & (g > b * 1.25)
        g = np.minimum(g, np.maximum(r, b))  # 去绿溢色
    else:
        mask = (r > 90) & (b > 90) & (r > g * 1.25) & (b > g * 1.25)
        r2 = np.minimum(r, np.maximum(g, b))
        b2 = np.minimum(b, np.maximum(g, r))
        r, b = r2, b2  # 去洋红溢色
    alpha = np.where(mask, 0, 255).astype(np.uint8)
    return np.stack([r, g, b, alpha], axis=-1).astype(np.uint8)

def lighten(arr):
    rgb = arr[..., :3].astype(np.float32)
    rgb = rgb + (255.0 - rgb) * LIGHTEN
    arr[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    arr[..., 3] = (arr[..., 3].astype(np.float32) * ALPHA_MUL).astype(np.uint8)
    return arr

for src_name, bg, out_name, do_lighten in JOBS:
    src = Image.open(f'{SRC_DIR}/{src_name}').convert('RGB')
    w, h = src.size
    cw, ch = w // 4, h // 2
    keyed = []
    for row in range(2):
        for col in range(4):
            cell = src.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
            arr = chroma_key(cell, bg)
            if do_lighten:
                arr = lighten(arr)
            keyed.append(arr)
    max_extent = 1
    infos = []
    for arr in keyed:
        ys, xs = np.nonzero(arr[..., 3])
        if len(xs) == 0:
            infos.append(None)
            continue
        x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
        infos.append((x0, y0, x1, y1))
        max_extent = max(max_extent, x1 - x0 + 1, y1 - y0 + 1)
    scale = (CELL - 8) / max_extent
    sheet = Image.new('RGBA', (CELL * 8, CELL), (0, 0, 0, 0))
    empty = 0
    for i, (arr, info) in enumerate(zip(keyed, infos)):
        if info is None:
            empty += 1
            continue
        x0, y0, x1, y1 = info
        crop = Image.fromarray(arr).crop((x0, y0, x1 + 1, y1 + 1))
        nw, nh = max(1, round(crop.width * scale)), max(1, round(crop.height * scale))
        crop = crop.resize((nw, nh), Image.LANCZOS)
        sheet.paste(crop, (i * CELL + (CELL - nw) // 2, (CELL - nh) // 2), crop)
    sheet.save(f'{OUT_DIR}/{out_name}')
    print(f'{out_name}: ok (empty_frames={empty}, scale={scale:.2f})')
