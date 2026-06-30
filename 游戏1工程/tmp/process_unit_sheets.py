"""兵种精灵图处理：洋红幕抠图、去溢色，按全帧统一包围盒裁剪（防帧间抖动），拼 8x1 横向图集（256px/格）。"""
from PIL import Image
import numpy as np

SRC_DIR = '/Users/lijiakai/.cursor/projects/Users-lijiakai-Desktop-my-claude/assets'
OUT_DIR = '/Users/lijiakai/游戏1/assets/sprites'
CELL = 256

# 我方兵种统一背视角（向上推进背对镜头）；敌方兵种正面（向下推进面对镜头）
# 按兵种分组：同组共享统一缩放（walk/attack 体型一致），组间互不影响
UNIT_GROUPS = {
    'pickle_leaf': [
        ('unit_pickle_walk_back2_magenta.png', 'player_pickle_leaf_walk_sheet.png'),
        ('unit_pickle_attack_back_magenta.png', 'player_pickle_leaf_attack_sheet.png'),
    ],
    'sour_mender': [
        ('unit_sourmender_walk_magenta.png', 'player_sour_mender_walk_sheet.png'),
        ('unit_sourmender_attack_magenta.png', 'player_sour_mender_attack_sheet.png'),
    ],
    'jar_guard': [
        ('unit_jarguard_walk_magenta.png', 'player_jar_guard_walk_sheet.png'),
        ('unit_jarguard_attack_magenta.png', 'player_jar_guard_attack_sheet.png'),
    ],
    'sesame_dough': [
        ('unit_sesamedough_walk_magenta.png', 'player_sesame_dough_walk_sheet.png'),
        ('unit_sesamedough_attack_magenta.png', 'player_sesame_dough_attack_sheet.png'),
    ],
    'sesame_shadow': [
        ('unit_sesameshadow_walk_magenta.png', 'player_sesame_shadow_walk_sheet.png'),
        ('unit_sesameshadow_attack_magenta.png', 'player_sesame_shadow_attack_sheet.png'),
    ],
    'sweet_guard': [
        ('unit_sweetguard_walk_magenta.png', 'player_sweet_guard_walk_sheet.png'),
        ('unit_sweetguard_attack_magenta.png', 'player_sweet_guard_attack_sheet.png'),
    ],
    'bitter_sprout': [
        ('unit_bittersprout_walk_magenta.png', 'player_bitter_sprout_walk_sheet.png'),
        ('unit_bittersprout_attack_magenta.png', 'player_bitter_sprout_attack_sheet.png'),
    ],
    'bitter_guard': [
        ('unit_bitterguard_walk_magenta.png', 'player_bitter_guard_walk_sheet.png'),
        ('unit_bitterguard_attack_magenta.png', 'player_bitter_guard_attack_sheet.png'),
    ],
    'old_vine': [
        ('unit_oldvine_walk_magenta.png', 'player_old_vine_walk_sheet.png'),
        ('unit_oldvine_attack_magenta.png', 'player_old_vine_attack_sheet.png'),
    ],
    'salt_grunt': [
        ('unit_saltgrunt_walk_magenta.png', 'enemy_salt_grunt_walk_sheet.png'),
        ('unit_saltgrunt_attack_magenta.png', 'enemy_salt_grunt_attack_sheet.png'),
    ],
    'pepper_imp': [
        ('unit_pepperimp_walk_magenta.png', 'enemy_pepper_imp_walk_sheet.png'),
        ('unit_pepperimp_attack_magenta.png', 'enemy_pepper_imp_attack_sheet.png'),
    ],
    'fire_skewer': [
        ('unit_fireskewer_walk_magenta.png', 'enemy_fire_skewer_walk_sheet.png'),
        ('unit_fireskewer_attack_magenta.png', 'enemy_fire_skewer_attack_sheet.png'),
    ],
    'pepper_jar': [
        ('unit_pepperjar_walk_magenta.png', 'enemy_pepper_jar_walk_sheet.png'),
        ('unit_pepperjar_attack_magenta.png', 'enemy_pepper_jar_attack_sheet.png'),
    ],
}

def strip_painted_shadow(arr):
    """剥离生成图自带的手绘落地阴影：位于下半部、低饱和低亮度的独立连通域。接地感统一交给游戏内代码椭圆影。"""
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
            # 下半部 + 平均低饱和 + 偏暗 = 手绘阴影
            if ys.mean() > h * 0.55 and sat.mean() < 0.30 and mx.mean() < 165:
                arr[ys, xs, 3] = 0
            # 小面积孤立暗色碎片 = 生成伪影（保留白色星花等亮色小元素）
            elif len(comp) < 1200 and rgb.mean() < 190:
                arr[ys, xs, 3] = 0
    return arr

def chroma_key_magenta(img):
    """软边缘抠图：按「洋红度」渐变 alpha（>=HI 全透明，<=LO 全不透明，中间线性过渡），
    边缘像素保留半透明，缩放到 30px 后锯齿显著减少；despill 仅作用于半透明边缘带。"""
    a = np.array(img).astype(np.float32)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    magenta_ness = np.minimum(r, b) - g          # 纯洋红≈255，角色本体≤0
    LO, HI = 40.0, 130.0
    alpha = np.clip((HI - magenta_ness) / (HI - LO), 0.0, 1.0)
    edge = alpha < 1.0                            # 仅边缘带去溢色，保护本体中的紫粉色
    r2 = np.where(edge, np.minimum(r, np.maximum(g, b)), r)
    b2 = np.where(edge, np.minimum(b, np.maximum(g, r)), b)
    return np.stack([r2, g, b2, alpha * 255.0], axis=-1).astype(np.uint8)

for unit_id, jobs in UNIT_GROUPS.items():
    # 第一遍：抠图 + 各表全帧包围盒
    sheets = []
    for src_name, out_name in jobs:
        src = Image.open(f'{SRC_DIR}/{src_name}').convert('RGB')
        w, h = src.size
        cw, ch = w // 4, h // 2
        keyed = []
        for row in range(2):
            for col in range(4):
                cell = src.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
                keyed.append(strip_painted_shadow(chroma_key_magenta(cell)))
        x0, y0, x1, y1 = cw, ch, 0, 0
        for arr in keyed:
            ys, xs = np.nonzero(arr[..., 3] > 20)
            if len(xs) == 0:
                continue
            x0, y0 = min(x0, xs.min()), min(y0, ys.min())
            x1, y1 = max(x1, xs.max()), max(y1, ys.max())
        sheets.append((out_name, keyed, (x0, y0, x1, y1)))

    # 第二遍：同一兵种所有动作表共用最大边长（统一缩放比例），按脚底对齐裁剪，避免切换动作时体型跳变
    global_side = max(max(b[2] - b[0], b[3] - b[1]) for _, _, b in sheets) + 12
    for out_name, keyed, (x0, y0, x1, y1) in sheets:
        cx = (x0 + x1) // 2
        by1 = y1 + 6                # 脚底 + 边距
        by0 = by1 - global_side
        bx0 = cx - global_side // 2
        sheet = Image.new('RGBA', (CELL * 8, CELL), (0, 0, 0, 0))
        for i, arr in enumerate(keyed):
            frame = Image.fromarray(arr).crop((bx0, by0, bx0 + global_side, by1))
            frame = frame.resize((CELL, CELL), Image.LANCZOS)
            sheet.paste(frame, (i * CELL, 0), frame)
        sheet.save(f'{OUT_DIR}/{out_name}')
        print(f'{unit_id}/{out_name}: ok (global_side={global_side})')
