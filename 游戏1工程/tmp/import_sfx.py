"""网游风音效导入（v7）：CC0 素材 → 解码 → 掐静音 → 降调(低沉化) → 混层 → 峰值归一化 → 16bit/44.1k wav。
来源（均 CC0）：
- Kenney Impact Sounds / Interface Sounds（kenney.nl）
- RPG Sound Pack by artisticdude（opengameart.org/content/rpg-sound-pack）
- 85 Music Jingles by Kenney（OGA 镜像）
设计口径（用户定调）：低沉打击感、网游角色技能攻击味，不要电子游戏机/芯片音。
- 近战 = 挥砍 whoosh + 重拳 thud 双层混音再降调
- 技能 = 真实法术吟唱采样；死亡 = 黏液 squish（贴食物角色）
- 全线降调 10%~25% 压低频感
"""
import soundfile as sf
import numpy as np
import os

SRC = '/tmp/kenney_sfx'
OUT = '/Users/lijiakai/游戏1/assets/sfx'
IMPACT = f'{SRC}/kenney-impact-sounds-for-godot/addons/kenney impact sounds'
UI = f'{SRC}/kenney-interface-sounds/addons/kenney_interface_sounds'
RPG = f'{SRC}/rpgpack/RPG Sound Pack'
JINGLE = f'{SRC}/jingles/OGG'


def load_mono(path):
    data, sr = sf.read(path)
    if data.ndim > 1:
        data = data.mean(axis=1)
    return data.astype(np.float64), sr


def trim_silence(data, sr, thresh=0.004, pad_ms=6):
    idx = np.nonzero(np.abs(data) > thresh)[0]
    if len(idx) == 0:
        return data
    pad = int(sr * pad_ms / 1000)
    return data[max(0, idx[0] - pad):min(len(data), idx[-1] + pad)]


def pitch_shift(data, factor):
    """factor < 1 => 降调变慢（重采样法，打击类正合适）"""
    new_len = int(len(data) / factor)
    return np.interp(np.linspace(0, len(data) - 1, new_len), np.arange(len(data)), data)


def resample_to(data, sr, target=44100):
    if sr == target:
        return data
    new_len = int(len(data) * target / sr)
    return np.interp(np.linspace(0, len(data) - 1, new_len), np.arange(len(data)), data)


def mix_layers(layers, sr):
    """layers: [(data, delay_sec, gain)] 叠加混音"""
    total = max(len(d) + int(dl * sr) for d, dl, _ in layers)
    out = np.zeros(total)
    for d, dl, g in layers:
        start = int(dl * sr)
        out[start:start + len(d)] += d * g
    return out


def prep(path, pitch=1.0, max_dur=None, fade_out=0.12):
    data, sr = load_mono(path)
    data = resample_to(data, sr)
    sr = 44100
    data = trim_silence(data, sr)
    if pitch != 1.0:
        data = pitch_shift(data, pitch)
    if max_dur and len(data) > int(max_dur * sr):
        data = data[:int(max_dur * sr)]
        n = int(fade_out * sr)
        data[-n:] *= np.linspace(1.0, 0.0, n)
    return data, sr


def save(event, idx, data, sr, peak_target):
    data = data / (np.abs(data).max() + 1e-9) * peak_target
    name = f'sfx_{event}_{idx}.wav'
    sf.write(f'{OUT}/{name}', data.astype(np.float32), sr, subtype='PCM_16')
    print(f'{name}: {len(data)/sr:.2f}s')


# --- 近战：挥砍 whoosh + 重拳 thud 双层，整体降调 0.85 ---
swings = [f'{RPG}/battle/swing.wav', f'{RPG}/battle/swing2.wav', f'{RPG}/battle/swing3.wav']
for i in range(5):
    whoosh, sr = prep(swings[i % 3], pitch=0.9)
    punch, _ = prep(f'{IMPACT}/impact_punch_heavy_{i:03d}.ogg', pitch=0.8)
    mixed = mix_layers([(whoosh, 0.0, 0.7), (punch, 0.05, 1.0)], sr)
    save('attack_melee', i, mixed, sr, 0.95)

# --- 远程：挥掷 whoosh 降调 ---
for i, p in enumerate(swings):
    data, sr = prep(p, pitch=0.82)
    save('attack_ranged', i, data, sr, 0.8)

# --- 受击：轻碰撞降调 25% 变闷 ---
for i in range(3):
    data, sr = prep(f'{IMPACT}/impact_generic_light_{i:03d}.ogg', pitch=0.75)
    save('hit', i, data, sr, 0.75)

# --- 死亡：黏液 squish 降调（食物角色"噗叽"消散）---
for i, n in enumerate([1, 3, 5]):
    data, sr = prep(f'{RPG}/NPC/slime/slime{n}.wav', pitch=0.85)
    save('death', i, data, sr, 0.9)

# --- 部署：软质闷响落地 ---
for i in range(3):
    data, sr = prep(f'{IMPACT}/impact_soft_medium_{i:03d}.ogg', pitch=0.85)
    save('deploy', i, data, sr, 0.8)

# --- 技能：低频重击打底 + 法术声铺面（威胁感 = 低频 + 起音瞬态）---
thud0, sr = prep(f'{IMPACT}/impact_plate_heavy_000.ogg', pitch=0.6)
magic0, _ = prep(f'{RPG}/battle/magic1.wav', pitch=0.88)
mixed = mix_layers([(thud0, 0.0, 1.0), (magic0, 0.04, 0.8)], sr)
save('skill', 0, mixed, sr, 0.95)
thud1, sr = prep(f'{IMPACT}/impact_plate_heavy_002.ogg', pitch=0.6)
spell1, _ = prep(f'{RPG}/battle/spell.wav', pitch=0.88, max_dur=1.2)
mixed = mix_layers([(thud1, 0.0, 1.0), (spell1, 0.04, 0.75)], sr)
save('skill', 1, mixed, sr, 0.95)

# --- Boss 预警：金属鸣响降调 20%（不祥钟声）---
data, sr = prep(f'{RPG}/inventory/metal-ringing.wav', pitch=0.8)
save('boss_warning', 0, data, sr, 0.85)

# --- Boss 大招：重锣降调 + 低频怪吼衬底 ---
gong, sr = prep(f'{IMPACT}/impact_bell_heavy_000.ogg', pitch=0.85)
growl, _ = prep(f'{RPG}/NPC/giant/giant3.wav', pitch=0.75)
mixed = mix_layers([(growl, 0.0, 0.55), (gong, 0.06, 1.0)], sr)
save('boss_skill', 0, mixed, sr, 0.95)
gong2, sr = prep(f'{IMPACT}/impact_bell_heavy_001.ogg', pitch=0.85)
save('boss_skill', 1, gong2, sr, 0.95)

# --- 胜负 jingle：拨弦乐句（基频分析挑选，上行=胜 / 下行=败），非芯片音 ---
data, sr = prep(f'{JINGLE}/jingles_PIZZA/jingles_PIZZA02.ogg')
save('victory', 0, data, sr, 0.85)
data, sr = prep(f'{JINGLE}/jingles_PIZZA/jingles_PIZZA01.ogg')
save('defeat', 0, data, sr, 0.85)

# --- UI 点击 ---
for i, n in enumerate(['001', '002']):
    data, sr = prep(f'{UI}/click_{n}.wav')
    save('click', i, data, sr, 0.5)
