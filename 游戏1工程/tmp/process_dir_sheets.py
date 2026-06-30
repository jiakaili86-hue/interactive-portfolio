#!/usr/bin/env python3
"""把"5 向横排 turnaround"（品红底）处理成游戏读取的方向贴图：
   输出 256 宽 x (5*256) 高 的竖排，每行一个朝向(0正/1前斜/2正侧/3后斜/4背)，单帧。
   用法: process_dir_sheets.py <input.png> <output.png> [num_cells=5] [scaleref.png]
   scaleref：可选。用该图(通常是同单位的行走 turnaround)的最大内容高度定缩放，
            保证攻击图与行走图同尺寸、不会切换时忽大忽小。
"""
import sys
import numpy as np
from PIL import Image

CELL = 256
TARGET_H = 222.0          # 内容统一缩放后的最大高度（256 格内留边）
BASELINE = 238            # 脚底基线（约 256*0.93），与单视角 anchor 0.78 接近
N = int(sys.argv[3]) if len(sys.argv) > 3 else 5


def chroma_key_magenta(rgb: np.ndarray) -> np.ndarray:
    r = rgb[..., 0].astype(np.int16)
    g = rgb[..., 1].astype(np.int16)
    b = rgb[..., 2].astype(np.int16)
    # 品红：R、B 高，G 低
    bg = (r > 110) & (b > 110) & (g < r * 0.72) & (g < b * 0.72)
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    # 去溢色：残留偏品红的边缘像素，把 R、B 压到不超过 G 太多
    spill = (~bg) & (r > g) & (b > g) & ((r - g) + (b - g) > 40)
    r2 = r.copy(); b2 = b.copy()
    cap = g + 18
    r2 = np.where(spill, np.minimum(r, cap), r)
    b2 = np.where(spill, np.minimum(b, cap), b)
    out = np.stack([r2, g, b2, alpha], axis=-1).astype(np.uint8)
    return out


def content_bbox(rgba: np.ndarray):
    a = rgba[..., 3]
    ys, xs = np.where(a > 40)
    if len(xs) == 0:
        return None
    return xs.min(), ys.min(), xs.max() + 1, ys.max() + 1


def keyed_cells(path: str):
    img = Image.open(path).convert("RGB")
    w, h = img.size
    cw = w // N
    out = []
    for i in range(N):
        crop = img.crop((i * cw, 0, (i + 1) * cw, h))
        out.append(chroma_key_magenta(np.array(crop)))
    return out


def max_content_height(cells_list):
    hs = []
    for c in cells_list:
        b = content_bbox(c)
        if b is not None:
            hs.append(b[3] - b[1])
    return max(hs) if hs else 1


def main():
    cells = keyed_cells(sys.argv[1])
    boxes = [content_bbox(c) for c in cells]
    # 缩放基准：默认用自身最高朝向；给了 scaleref 则用参考图(行走图)的最高朝向
    if len(sys.argv) > 4:
        max_ch = max_content_height(keyed_cells(sys.argv[4]))
    else:
        max_ch = max((b[3] - b[1]) for b in boxes if b is not None)
    scale = TARGET_H / float(max_ch)
    out = Image.new("RGBA", (CELL, CELL * N), (0, 0, 0, 0))
    for i, (keyed, box) in enumerate(zip(cells, boxes)):
        if box is None:
            continue
        x0, y0, x1, y1 = box
        sub = Image.fromarray(keyed[y0:y1, x0:x1], "RGBA")
        nw = max(1, int(round(sub.width * scale)))
        nh = max(1, int(round(sub.height * scale)))
        sub = sub.resize((nw, nh), Image.LANCZOS)
        px = int(round((CELL - nw) / 2.0))                 # 水平居中
        py = int(round(i * CELL + BASELINE - nh))          # 脚底对齐基线
        out.alpha_composite(sub, (px, py))
    out.save(sys.argv[2])
    print("saved", sys.argv[2], out.size, "scale=%.3f rows=%d" % (scale, N))


if __name__ == "__main__":
    main()
