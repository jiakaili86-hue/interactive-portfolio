"""风格统一 pass v2：重做糯米团/糯影分身/盐粒卒三兵种的图集。
流程与 process_unit_sheets.py 相同：洋红幕抠图、剥手绘阴影、全帧统一包围盒、拼 8x1 横向图集。
糯影分身本体即深色，跳过暗色碎片清理避免误删烟雾尾。"""
from PIL import Image
import numpy as np

SRC_DIR = '/Users/lijiakai/.cursor/projects/Users-lijiakai-Desktop-my-claude/assets'
OUT_DIR = '/Users/lijiakai/游戏1/assets/sprites'
CELL = 256

UNIT_GROUPS = {
    'sesame_dough': [
        ('unit_sesamedough_walk_magenta_v2.png', 'player_sesame_dough_walk_sheet.png'),
        ('unit_sesamedough_attack_magenta_v2.png', 'player_sesame_dough_attack_sheet.png'),
    ],
    'sesame_shadow': [
        ('unit_sesameshadow_walk_magenta_v2.png', 'player_sesame_shadow_walk_sheet.png'),
        ('unit_sesameshadow_attack_magenta_v2.png', 'player_sesame_shadow_attack_sheet.png'),
    ],
    'salt_grunt': [
        ('unit_saltgrunt_walk_magenta_v2.png', 'enemy_salt_grunt_walk_sheet.png'),
        ('unit_saltgrunt_attack_magenta_v2.png', 'enemy_salt_grunt_attack_sheet.png'),
    ],
}
DARK_BODY_UNITS = {'sesame_shadow'}

def strip_painted_shadow(arr, keep_dark=False):
    h, w = arr.shape[:2]
    alpha = arr[..., 3] > 60
    visited = np.zeros((h, w), dtype=bool)
    for sy in range(h):
        for sx in range(w):
            if not alpha[sy, sx] or visited[sy, sx]:
                continue
            stack = [(sy, sx)]
            visited[sy, sx] = True
            comp = []
            while stack:
                y, x = stack.pop()
                comp.append((y, x))
                for ny, nx in ((y-1,x),(y+1,x),(y,x-1),(y,x+1)):
                    if 0 <= ny < h and 0 <= nx < w and alpha[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = True
                        stack.append((ny, nx))
            ys = np.array([p[0] for p in comp]); xs = np.array([p[1] for p in comp])
            rgb = arr[ys, xs, :3].astype(np.float32)
            mx, mn = rgb.max(axis=1), rgb.min(axis=1)
            sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1.0), 0.0)
            if keep_dark:
                # 深色本体兵种：只删极小的孤立碎片（<200px），不按颜色判断
                if len(comp) < 200:
                    arr[ys, xs, 3] = 0
                continue
            if ys.mean() > h * 0.55 and sat.mean() < 0.30 and mx.mean() < 165 and len(comp) < 2500:
                arr[ys, xs, 3] = 0
            elif len(comp) < 1200 and rgb.mean() < 190:
                arr[ys, xs, 3] = 0
    return arr

def chroma_key_magenta(img):
    a = np.array(img).astype(np.float32)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    magenta_ness = np.minimum(r, b) - g
    LO, HI = 40.0, 130.0
    alpha = np.clip((HI - magenta_ness) / (HI - LO), 0.0, 1.0)
    edge = alpha < 1.0
    r2 = np.where(edge, np.minimum(r, np.maximum(g, b)), r)
    b2 = np.where(edge, np.minimum(b, np.maximum(g, r)), b)
    return np.stack([r2, g, b2, alpha * 255.0], axis=-1).astype(np.uint8)

for unit_id, jobs in UNIT_GROUPS.items():
    keep_dark = unit_id in DARK_BODY_UNITS
    sheets = []
    for src_name, out_name in jobs:
        src = Image.open(f'{SRC_DIR}/{src_name}').convert('RGB')
        w, h = src.size
        cw, ch = w // 4, h // 2
        keyed = []
        for row in range(2):
            for col in range(4):
                cell = src.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
                keyed.append(strip_painted_shadow(chroma_key_magenta(cell), keep_dark))
        x0, y0, x1, y1 = cw, ch, 0, 0
        for arr in keyed:
            ys, xs = np.nonzero(arr[..., 3] > 20)
            if len(xs) == 0:
                continue
            x0, y0 = min(x0, xs.min()), min(y0, ys.min())
            x1, y1 = max(x1, xs.max()), max(y1, ys.max())
        sheets.append((out_name, keyed, (x0, y0, x1, y1)))

    global_side = max(max(b[2] - b[0], b[3] - b[1]) for _, _, b in sheets) + 12
    for out_name, keyed, (x0, y0, x1, y1) in sheets:
        cx = (x0 + x1) // 2
        by1 = y1 + 6
        by0 = by1 - global_side
        bx0 = cx - global_side // 2
        sheet = Image.new('RGBA', (CELL * 8, CELL), (0, 0, 0, 0))
        for i, arr in enumerate(keyed):
            frame = Image.fromarray(arr).crop((bx0, by0, bx0 + global_side, by1))
            frame = frame.resize((CELL, CELL), Image.LANCZOS)
            sheet.paste(frame, (i * CELL, 0), frame)
        sheet.save(f'{OUT_DIR}/{out_name}')
        print(f'{unit_id}/{out_name}: ok (global_side={global_side})')
