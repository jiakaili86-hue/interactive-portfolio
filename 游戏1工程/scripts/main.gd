extends Control

const SCREEN_SIZE := Vector2(390, 844)
const FIELD_RECT := Rect2(4, 72, 382, 536)
const PLAYER_ENTRY_Y := FIELD_RECT.position.y - 4.0
const ENEMY_ENTRY_Y := FIELD_RECT.end.y + 4.0
const PLAYER_SPAWN_Y := FIELD_RECT.end.y - 118.0
const ENEMY_SPAWN_Y := FIELD_RECT.position.y + 96.0
const ENEMY_REWARD_Y := FIELD_RECT.position.y + 4.0
const CARD_COUNT := 3
const RESOURCE_MAX := 10.0
const START_GOLD := 8.0
const START_ENERGY := 4.0
const GOLD_REGEN := 0.0
const ENERGY_REGEN := 0.42
const SURVIVE_TIME := 95.0
const DEPLOY_DRAG_SPACING := 42.0
const BOSS_POS := Vector2(195, 148)
const BOSS_RADIUS := 25.0
const BOSS_MAX_HP := 720.0
const BOSS_ATTACK_RANGE := 92.0
const BOSS_ATTACK_DAMAGE := 34.0
const BOSS_ATTACK_INTERVAL := 1.0
const HAND_CARD_SIZE := Vector2(112, 156)
const HAND_CARD_Y := 672.0
const HAND_CARD_GAP := 10.0
const MINI_CARD_SIZE := Vector2(114, 38)
const MINI_CARD_Y := 790.0
const ACTION_PANEL_RECT := Rect2(10, 608, 370, 176)
const CRUMB_ATTACK_DURATION := 1.20
const CRUMB_ATTACK_HIT_TIME := 0.38

var flavor_defs: Dictionary = {
	"acid": {"name": "酸", "color": Color("#88b76e"), "ink": Color("#3f6545")},
	"sweet": {"name": "甜", "color": Color("#d2b271"), "ink": Color("#725f39")},
	"bitter": {"name": "苦", "color": Color("#748b47"), "ink": Color("#405131")},
	"spicy": {"name": "辣", "color": Color("#d85f3f"), "ink": Color("#8d3427")},
	"salty": {"name": "咸", "color": Color("#7ca6bd"), "ink": Color("#3f6270")}
}

var unit_defs: Dictionary = {
	"pickle_leaf": {
		"name": "酸叶兵", "tier": 1, "hp": 68.0, "damage": 9.0, "speed": 38.0,
		"attack_range": 22.0, "lock_range": 112.0, "interval": 1.05, "radius": 8.5,
		"color": Color("#9fc978"), "role": "front"
	},
	"sour_mender": {
		"name": "酸雾童", "tier": 2, "hp": 54.0, "damage": 7.0, "speed": 34.0,
		"attack_range": 118.0, "lock_range": 190.0, "interval": 1.7, "radius": 8.0,
		"color": Color("#b8dd9d"), "role": "ranged", "slow": 0.8
	},
	"jar_guard": {
		"name": "坛甲卫", "tier": 3, "hp": 150.0, "damage": 17.0, "speed": 24.0,
		"attack_range": 36.0, "lock_range": 170.0, "interval": 1.65, "radius": 12.0,
		"color": Color("#b79970"), "role": "tank"
	},
	"sesame_dough": {
		"name": "糯米团", "tier": 1, "hp": 66.0, "damage": 9.0, "speed": 36.0,
		"attack_range": 22.0, "lock_range": 112.0, "interval": 1.08, "radius": 8.5,
		"color": Color("#ede6d8"), "accent": Color("#303030"), "role": "front"
	},
	"sesame_shadow": {
		"name": "芝麻影", "tier": 2, "hp": 46.0, "damage": 15.0, "speed": 50.0,
		"attack_range": 30.0, "lock_range": 999.0, "interval": 1.28, "radius": 8.0,
		"color": Color("#3f3b3b"), "role": "skirmish", "can_seek": true, "global_seek": true
	},
	"sweet_guard": {
		"name": "甜糯卫", "tier": 3, "hp": 120.0, "damage": 14.0, "speed": 28.0,
		"attack_range": 40.0, "lock_range": 180.0, "interval": 1.72, "radius": 11.0,
		"color": Color("#f0d7a4"), "role": "tank"
	},
	"bitter_sprout": {
		"name": "苦芽兵", "tier": 1, "hp": 58.0, "damage": 8.0, "speed": 39.0,
		"attack_range": 108.0, "lock_range": 176.0, "interval": 1.62, "radius": 8.0,
		"color": Color("#89a853"), "role": "ranged", "slow": 0.65
	},
	"bitter_guard": {
		"name": "苦藤卫", "tier": 2, "hp": 132.0, "damage": 12.0, "speed": 25.0,
		"attack_range": 30.0, "lock_range": 148.0, "interval": 1.48, "radius": 11.5,
		"color": Color("#657c42"), "role": "front"
	},
	"old_vine": {
		"name": "老藤兵", "tier": 3, "hp": 190.0, "damage": 22.0, "speed": 21.0,
		"attack_range": 44.0, "lock_range": 190.0, "interval": 1.95, "radius": 13.0,
		"color": Color("#506337"), "role": "tank"
	},
	"crumb": {
		"name": "碎味兵", "tier": 1, "hp": 46.0, "damage": 8.0, "speed": 38.0,
		"attack_range": 22.0, "lock_range": 108.0, "interval": 1.25, "radius": 8.0,
		"color": Color("#c9b98b"), "role": "front"
	},
	"salt_grunt": {
		"name": "盐粒卒", "tier": 1, "hp": 74.0, "damage": 10.0, "speed": 31.0,
		"attack_range": 23.0, "lock_range": 118.0, "interval": 1.18, "radius": 8.5,
		"color": Color("#dce5e7"), "role": "front"
	},
	"pepper_imp": {
		"name": "泡椒兵", "tier": 2, "hp": 50.0, "damage": 14.0, "speed": 51.0,
		"attack_range": 28.0, "lock_range": 999.0, "interval": 1.2, "radius": 8.0,
		"color": Color("#d85f3f"), "role": "skirmish", "can_seek": true, "global_seek": true
	},
	"fire_skewer": {
		"name": "火签客", "tier": 2, "hp": 70.0, "damage": 20.0, "speed": 45.0,
		"attack_range": 72.0, "lock_range": 999.0, "interval": 1.45, "radius": 9.0,
		"color": Color("#ef8a48"), "role": "skirmish", "can_seek": true, "global_seek": true
	},
	"pepper_jar": {
		"name": "泡椒坛卫", "tier": 3, "hp": 168.0, "damage": 18.0, "speed": 23.0,
		"attack_range": 39.0, "lock_range": 182.0, "interval": 1.76, "radius": 13.0,
		"color": Color("#b74735"), "role": "tank"
	}
}

var hero_defs: Array[Dictionary] = [
	{
		"id": "pickle", "name": "酸菜坛灵", "flavor": "acid", "portrait": "res://assets/heroes/hero_pickle_3x4.png",
		"troops": [
			{"unit": "pickle_leaf", "cost": 2, "count": 6, "formation": "wide", "cd": 4.0},
			{"unit": "sour_mender", "cost": 4, "count": 3, "formation": "line", "cd": 7.0},
			{"unit": "jar_guard", "cost": 6, "count": 1, "formation": "point", "cd": 12.0}
		],
		"skills": [
			{"name": "开坛酸雾", "cost": 3, "kind": "mist", "cd": 9.0},
			{"name": "酸叶护阵", "cost": 5, "kind": "shield", "cd": 14.0},
			{"name": "发酵增援", "cost": 7, "kind": "summon_jar", "cd": 18.0}
		]
	},
	{
		"id": "sesame", "name": "黑芝麻糯影灵", "flavor": "sweet", "portrait": "res://assets/heroes/hero_sesame_3x4.png",
		"troops": [
			{"unit": "sesame_dough", "cost": 2, "count": 6, "formation": "wide", "cd": 4.0},
			{"unit": "sesame_shadow", "cost": 4, "count": 3, "formation": "split", "cd": 8.0},
			{"unit": "sweet_guard", "cost": 6, "count": 1, "formation": "point", "cd": 11.0}
		],
		"skills": [
			{"name": "糯影分身", "cost": 3, "kind": "shadow", "cd": 9.0},
			{"name": "甜糯结界", "cost": 5, "kind": "heal", "cd": 14.0},
			{"name": "芝麻夜雨", "cost": 6, "kind": "rain", "cd": 16.0}
		]
	},
	{
		"id": "bitter", "name": "苦瓜藤师", "flavor": "bitter", "portrait": "res://assets/heroes/hero_bitter_3x4.png",
		"troops": [
			{"unit": "bitter_sprout", "cost": 2, "count": 5, "formation": "wide", "cd": 5.0},
			{"unit": "bitter_guard", "cost": 4, "count": 3, "formation": "line", "cd": 7.0},
			{"unit": "old_vine", "cost": 7, "count": 1, "formation": "point", "cd": 13.0}
		],
		"skills": [
			{"name": "苦藤缠绕", "cost": 4, "kind": "root", "cd": 12.0},
			{"name": "清苦压制", "cost": 5, "kind": "weaken", "cd": 14.0},
			{"name": "老藤守门", "cost": 7, "kind": "summon_vine", "cd": 20.0}
		]
	}
]

var boss_def: Dictionary = {
	"name": "泡椒火签王", "flavor": "spicy", "gold": 3.0, "gold_regen": 0.56, "think_timer": 1.9,
	"troops": [
		{"unit": "crumb", "cost": 2, "count": 4, "formation": "wide"},
		{"unit": "salt_grunt", "cost": 3, "count": 3, "formation": "line"},
		{"unit": "pepper_imp", "cost": 4, "count": 2, "formation": "split"},
		{"unit": "fire_skewer", "cost": 5, "count": 2, "formation": "line"},
		{"unit": "pepper_jar", "cost": 7, "count": 1, "formation": "point"}
	],
	"skills": [
		{"name": "辣油突袭", "timer": 9.0, "kind": "boss_dash"},
		{"name": "火签齐射", "timer": 15.0, "kind": "boss_barrage"},
		{"name": "开罐号令", "timer": 24.0, "kind": "boss_summon"}
	]
}

var rng := RandomNumberGenerator.new()
var gold := 5.0
var energy := 4.0
var boss_gold := 5.0
var boss_hp := BOSS_MAX_HP
var boss_attack_timer := 0.0
var units: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var texts: Array[Dictionary] = []
var boss_state: Dictionary = {}
var pending_deploy: Dictionary = {}
var pending_skill: Dictionary = {}
var deploy_preview_pos := Vector2.ZERO
var skill_preview_pos := Vector2.ZERO
var hovered_unit_id := -1
var selected_card := -1
# 冷却：键 "card_troopIdx" / "card_skillIdx"，值为剩余秒数
var deploy_cd_left: Dictionary = {}
var skill_cd_left: Dictionary = {}
# 死亡概率事件：单位死亡掷骰，10 种事件权重合计 20%（主流玩法），全局 2s 冷却防扎堆
const DEATH_EVENT_TABLE := [
	["meteor", 0.016],       # 陨石坠落：预警后圈内即死，最炸裂所以最稀有
	["haste", 0.016],        # 疾风过境：全场移速 +50%
	["storm", 0.020],        # 天怒雷暴：随机闪电不分敌我
	["hail", 0.020],         # 冰雹风暴：范围冰冻
	["rebirth", 0.020],      # 亡魂重生：死者复活成限时幽魂
	["ally_buff", 0.020],    # 同仇敌忾：死者一方加攻
	["enemy_buff", 0.020],   # 敌军狂暴：死者对面加攻
	["mass_heal", 0.020],    # 甘霖普降：全场回血
	["dot_zone", 0.024],     # 灼热毒雾：持续伤害区
	["gold_windfall", 0.024] # 天降横财：双方资源进账
]
const DEATH_EVENT_COOLDOWN := 2.0
# 事件徽章：左侧竖排，标识生效中的随机事件与剩余时间
# duration<=0 表示瞬发事件（固定停留 2.5s 不画进度条）；meteor 特殊：前 1s 预警红脉动
const EVENT_BADGE_DEFS := {
	"storm": {"glyph": "雷", "label": "天怒雷暴", "color": Color("#3d4a6b"), "duration": 2.6},
	"dot_zone": {"glyph": "毒", "label": "灼热毒雾", "color": Color("#5c6e33"), "duration": 4.5},
	"meteor": {"glyph": "陨", "label": "陨石坠落", "color": Color("#8d3427"), "duration": -3.5},
	"hail": {"glyph": "雹", "label": "冰雹风暴", "color": Color("#4f789f"), "duration": 2.6},
	"rebirth": {"glyph": "魂", "label": "亡魂重生", "color": Color("#6b4a7c"), "duration": 6.85},
	"ally_buff": {"glyph": "鼓", "label": "同仇敌忾", "color": Color("#8a6a1f"), "duration": 6.0},
	"enemy_buff": {"glyph": "狂", "label": "敌军狂暴", "color": Color("#a04a28"), "duration": 6.0},
	"gold_windfall": {"glyph": "财", "label": "天降横财", "color": Color("#8a6a1f"), "duration": -2.5},
	"mass_heal": {"glyph": "霖", "label": "甘霖普降", "color": Color("#3f6545"), "duration": -2.5},
	"haste": {"glyph": "疾", "label": "疾风过境", "color": Color("#4a7a72"), "duration": 5.0}
}
const EVENT_BADGE_MAX := 5
var event_badges: Array[Dictionary] = []
var death_events: Array[Dictionary] = []
var death_event_cd := 0.0
var event_banner_text := ""
var event_banner_timer := 0.0
var event_banner_color := Color("#5b4238")
# 事件触发中央大印记：触发瞬间画面中央浮现 1s 后淡出（替代顶部横幅）
var event_seal: Dictionary = {}
var game_over := false
var victory := false
var elapsed := 0.0
var survive_left := SURVIVE_TIME
var next_unit_id := 1
var status_text := "守住倒计时，或打倒敌方中线英雄；敌兵进我方领域即失败。"

var resource_label: Label
var status_label: Label
var restart_button: Button
var card_buttons: Array[Button] = []
var option_buttons: Array[Button] = []
var option_cd_overlays: Array[Control] = []
var hero_textures: Dictionary = {}
var battle_bg_texture: Texture2D
var enemy_gate_overlay_texture: Texture2D
var player_deploy_overlay_texture: Texture2D
var crumb_walk_texture: Texture2D
var crumb_attack_texture: Texture2D
# 数据驱动兵种精灵表：我方=背视角资产，敌方=正视角资产；hit_time 对齐各自图集的全力攻击帧
const UNIT_SPRITE_DEFS := {
	"crumb": {
		"walk": "res://assets/sprites/enemy_crumb_walk_sheet_14.png", "attack": "res://assets/sprites/enemy_crumb_attack_sheet.png",
		"walk_frames": 14, "attack_frames": 14, "fps": 7.0, "hit_time": 0.38, "anchor": 0.82
	},
	"pickle_leaf": {
		"walk": "res://assets/sprites/player_pickle_leaf_walk_sheet.png", "attack": "res://assets/sprites/player_pickle_leaf_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 7.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
	"sour_mender": {
		"walk": "res://assets/sprites/player_sour_mender_walk_sheet.png", "attack": "res://assets/sprites/player_sour_mender_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 7.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
	"jar_guard": {
		"walk": "res://assets/sprites/player_jar_guard_walk_sheet.png", "attack": "res://assets/sprites/player_jar_guard_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 6.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
	"sesame_dough": {
		"walk": "res://assets/sprites/player_sesame_dough_walk_sheet.png", "attack": "res://assets/sprites/player_sesame_dough_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 7.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
	"sesame_shadow": {
		"walk": "res://assets/sprites/player_sesame_shadow_walk_sheet.png", "attack": "res://assets/sprites/player_sesame_shadow_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 9.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true,
		"dir_walk": "res://assets/sprites/player_sesame_shadow_dir_walk.png", "dir_attack": "res://assets/sprites/player_sesame_shadow_dir_attack.png",
		"dir_rows": 5, "dir_walk_frames": 1, "dir_attack_frames": 1
	},
	"sweet_guard": {
		"walk": "res://assets/sprites/player_sweet_guard_walk_sheet.png", "attack": "res://assets/sprites/player_sweet_guard_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 6.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
	"bitter_sprout": {
		"walk": "res://assets/sprites/player_bitter_sprout_walk_sheet.png", "attack": "res://assets/sprites/player_bitter_sprout_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 7.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
	"bitter_guard": {
		"walk": "res://assets/sprites/player_bitter_guard_walk_sheet.png", "attack": "res://assets/sprites/player_bitter_guard_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 6.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
	"old_vine": {
		"walk": "res://assets/sprites/player_old_vine_walk_sheet.png", "attack": "res://assets/sprites/player_old_vine_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 5.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
	"salt_grunt": {
		"walk": "res://assets/sprites/enemy_salt_grunt_walk_sheet.png", "attack": "res://assets/sprites/enemy_salt_grunt_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 6.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
	"pepper_imp": {
		"walk": "res://assets/sprites/enemy_pepper_imp_walk_sheet.png", "attack": "res://assets/sprites/enemy_pepper_imp_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 9.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true,
		"dir_walk": "res://assets/sprites/enemy_pepper_imp_dir_walk.png", "dir_attack": "res://assets/sprites/enemy_pepper_imp_dir_attack.png",
		"dir_rows": 5, "dir_walk_frames": 1, "dir_attack_frames": 1
	},
	"fire_skewer": {
		"walk": "res://assets/sprites/enemy_fire_skewer_walk_sheet.png", "attack": "res://assets/sprites/enemy_fire_skewer_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 8.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true,
		"dir_walk": "res://assets/sprites/enemy_fire_skewer_dir_walk.png", "dir_attack": "res://assets/sprites/enemy_fire_skewer_dir_attack.png",
		"dir_rows": 5, "dir_walk_frames": 1, "dir_attack_frames": 1
	},
	"pepper_jar": {
		"walk": "res://assets/sprites/enemy_pepper_jar_walk_sheet.png", "attack": "res://assets/sprites/enemy_pepper_jar_attack_sheet.png",
		"walk_frames": 8, "attack_frames": 8, "fps": 5.0, "hit_time": 0.62, "anchor": 0.78, "flip_attack": true
	},
}
var unit_sprite_textures: Dictionary = {}
# 全图刺客防穿帮：多向精灵图（5 行=正/前斜/侧/后斜/背），缺图时自动回退单视角
var unit_dir_textures: Dictionary = {}
var boss_portrait_texture: Texture2D
var boss_body_texture: Texture2D
var boss_skewer_texture: Texture2D
var hit_spark_texture: Texture2D
var boss_aura_texture: Texture2D
var boss_barrage_burst_texture: Texture2D
var smoke_puff_texture: Texture2D
var skill_fx_textures: Dictionary = {}
var card_press: Array[float] = []
var card_flash: Array[float] = []
var panel_anim := 0.0
# 英雄技能 cut-in 立绘动画：施放技能时立绘色带横扫入场；Boss 大招从右侧反向扫入
const CUTIN_DURATION := 1.05
var cutin_timer := 0.0
var cutin_hero_index := -1
var cutin_skill_name := ""
var cutin_is_boss := false
var tutorial_hint_timer := 9.0
# Kenney CC0 音效（Impact/Interface/Digital/Jingles 包）：每个事件多变体随机轮换 + 8 路播放器池 + 同名冷却（60ms）防止齐射刷屏
const SFX_VOLUMES := {
	"deploy": -10.0, "attack_melee": -9.0, "attack_ranged": -12.0, "hit": -16.0,
	"death": -8.0, "skill": -5.0, "boss_warning": -7.0, "boss_skill": -5.0,
	"victory": -5.0, "defeat": -5.0, "click": -14.0
}
var sfx_streams: Dictionary = {}
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_cooldowns: Dictionary = {}
# 战斗 BGM：Samurai Nights by Majadroid（CC-BY，署名见 assets/music/CREDITS.txt）
var bgm_player: AudioStreamPlayer = null
# Game feel：屏幕震动（衰减随机偏移）+ 顿帧（短暂冻结游戏更新，仍渲染）
var screen_shake := 0.0
var hitstop_timer := 0.0
# 流程状态：title（标题画面）/ battle（战斗）；QA 模式直接进 battle
var game_state := "battle"
var title_elapsed := 0.0
var title_start_button: Button = null
var end_restart_button: Button = null

func _add_screen_shake(amount: float) -> void:
	screen_shake = max(screen_shake, amount)

func _add_hitstop(duration: float) -> void:
	hitstop_timer = max(hitstop_timer, duration)

func _ready() -> void:
	rng.randomize()
	custom_minimum_size = SCREEN_SIZE
	get_viewport().size = Vector2i(SCREEN_SIZE)
	get_viewport().transparent_bg = false
	RenderingServer.set_default_clear_color(Color("#efe8db"))
	_load_fonts()
	_load_art_assets()
	_load_sfx()
	_build_ui()
	# 非 QA 模式从标题画面进入
	var is_qa := false
	for arg in OS.get_cmdline_user_args():
		if String(arg).begins_with("--qa"):
			is_qa = true
			break
	if not is_qa:
		_enter_title()
	_restart_game()
	if "--qa-initial-screenshot" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_initial_screenshot")
	elif "--qa-screenshot" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_visual_screenshot")
	elif "--qa-run" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_simulation")
	elif "--qa-effects-screenshot" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_effects_screenshot")
	elif "--qa-events-screenshot" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_events_screenshot")
	elif "--qa-units-screenshot" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_units_screenshot")
	elif "--qa-facing-screenshot" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_facing_screenshot")
	elif "--qa-title-screenshot" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_title_screenshot")
	elif "--qa-balance" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_balance")
	elif "--qa-end-screenshot" in OS.get_cmdline_user_args():
		call_deferred("_run_qa_end_screenshot")

func _process(delta: float) -> void:
	if game_state == "title":
		title_elapsed += delta
		queue_redraw()
		return
	# 屏幕震动：随机偏移整个画布节点，指数衰减
	if screen_shake > 0.05:
		position = Vector2(rng.randf_range(-screen_shake, screen_shake), rng.randf_range(-screen_shake, screen_shake))
		screen_shake *= pow(0.0001, delta)
	else:
		position = Vector2.ZERO
		screen_shake = 0.0
	if game_over:
		if end_restart_button and not end_restart_button.visible:
			end_restart_button.visible = true
		# 结算时压低 BGM 给胜负 jingle 让位，随后停掉
		if bgm_player and bgm_player.playing:
			bgm_player.volume_db -= delta * 24.0
			if bgm_player.volume_db < -44.0:
				bgm_player.stop()
		_update_feedback(delta)
		queue_redraw()
		return
	# 顿帧：冻结游戏更新但保持渲染，强化重击反馈
	if hitstop_timer > 0.0:
		hitstop_timer -= delta
		queue_redraw()
		return
	elapsed += delta
	tutorial_hint_timer = max(0.0, tutorial_hint_timer - delta)
	survive_left = max(0.0, SURVIVE_TIME - elapsed)
	gold += GOLD_REGEN * delta
	energy = min(RESOURCE_MAX, energy + ENERGY_REGEN * delta)
	_tick_cooldowns(delta)
	cutin_timer = max(0.0, cutin_timer - delta)
	_update_boss(delta)
	_update_units(delta)
	_update_death_events(delta)
	_update_boss_attack(delta)
	_check_survive_victory()
	_update_feedback(delta)
	_update_ui()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if game_over or game_state == "title":
		return
	if event is InputEventMouseMotion and pending_deploy.is_empty() and pending_skill.is_empty():
		_update_hovered_unit(event.position)
	if not pending_skill.is_empty():
		_handle_pending_skill_input(event)
		return
	if pending_deploy.is_empty():
		return
	_handle_pending_deploy_input(event)

func _handle_pending_deploy_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		deploy_preview_pos = _clamp_deploy_pos(event.position)
		if bool(pending_deploy.get("pressing", false)):
			_update_drag_deploy(event.position)
		queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _begin_pending_deploy_press(event.position):
				get_viewport().set_input_as_handled()
		elif bool(pending_deploy.get("pressing", false)):
			_finish_pending_deploy_press(event.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		deploy_preview_pos = _clamp_deploy_pos(event.position)
		if bool(pending_deploy.get("pressing", false)):
			_update_drag_deploy(event.position)
		queue_redraw()
	elif event is InputEventScreenTouch:
		if event.pressed:
			if _begin_pending_deploy_press(event.position):
				get_viewport().set_input_as_handled()
		elif bool(pending_deploy.get("pressing", false)):
			_finish_pending_deploy_press(event.position)
			get_viewport().set_input_as_handled()

func _handle_pending_skill_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		skill_preview_pos = _clamp_skill_pos(event.position)
		queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _try_cast_pending_skill(event.position):
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		skill_preview_pos = _clamp_skill_pos(event.position)
		queue_redraw()
	elif event is InputEventScreenTouch:
		if event.pressed:
			if _try_cast_pending_skill(event.position):
				get_viewport().set_input_as_handled()

func _draw() -> void:
	if game_state == "title":
		_draw_title_screen()
		return
	_draw_background()
	_draw_ambient()
	_draw_ground_effects()
	_draw_death_event_zones()
	_draw_field_boss()
	_draw_units()
	_draw_effects()
	_draw_event_seal()
	_draw_event_badges()
	_draw_skill_cutin()
	_draw_deploy_preview()
	_draw_skill_preview()
	_draw_cards()
	_draw_option_panel()
	_draw_end_overlay()

# 标题画面：战场背景全屏 + 暗角 + 描金标题 + 印章点缀
const TITLE_BOSS_FOOT_Y := 506.0
const TITLE_BOSS_H := 312.0

func _draw_title_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("#efe8db"), true)
	if battle_bg_texture:
		_draw_texture_cover(battle_bg_texture, Rect2(Vector2.ZERO, SCREEN_SIZE), Color(1, 1, 1, 0.9))
	# 上下暗角加重，让中部主角浮出
	for i in range(10):
		var t := float(10 - i) / 10.0
		draw_rect(Rect2(0, i * 24.0, SCREEN_SIZE.x, 24.0), Color(0.14, 0.08, 0.06, 0.1 + 0.14 * t), true)
		draw_rect(Rect2(0, SCREEN_SIZE.y - (i + 1) * 30.0, SCREEN_SIZE.x, 30.0), Color(0.12, 0.07, 0.05, 0.1 + 0.16 * t), true)
	# 主角身后暖色辐射光晕：分层圆叠出柔和径向 + 收紧的亮核
	var glow_center := Vector2(SCREEN_SIZE.x * 0.5, 340.0)
	for i in range(14):
		var gr := 270.0 - float(i) * 17.0
		draw_circle(glow_center, gr, Color(0.86, 0.44, 0.21, 0.03))
	for i in range(5):
		draw_circle(glow_center, 90.0 - float(i) * 15.0, Color(0.95, 0.6, 0.3, 0.035))
	# Boss 主角：踩火焰座静态立绘，轻微呼吸
	_draw_title_boss()
	var breath := 1.0 + sin(title_elapsed * 1.6) * 0.012
	var title_y := 178.0
	# 主标题
	var title_font := _font_medium()
	var title_size := int(round(54.0 * breath))
	draw_string_outline(title_font, Vector2(0, title_y), "百味守阵", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_SIZE.x, title_size, 9, Color(0.16, 0.09, 0.06, 0.9))
	draw_string(title_font, Vector2(0, title_y), "百味守阵", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_SIZE.x, title_size, Color("#fff3dd"))
	# 副标题
	draw_string_outline(_font(), Vector2(0, title_y + 38.0), "泡 菜 武 侠 · 兵 线 守 阵", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_SIZE.x, 15, 5, Color(0.16, 0.09, 0.06, 0.85))
	draw_string(_font(), Vector2(0, title_y + 38.0), "泡 菜 武 侠 · 兵 线 守 阵", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_SIZE.x, 15, Color("#f3ddb8"))
	# 红印章：标题右下角「食灵」
	var seal := Rect2(SCREEN_SIZE.x * 0.5 + 96.0, title_y + 8.0, 34.0, 34.0)
	var seal_style := StyleBoxFlat.new()
	seal_style.bg_color = Color("#b8402f")
	seal_style.set_corner_radius_all(4)
	seal_style.draw(get_canvas_item(), seal)
	draw_string(_font_medium(), seal.position + Vector2(0, 14.0), "食", HORIZONTAL_ALIGNMENT_CENTER, seal.size.x, 13, Color("#fff3dd"))
	draw_string(_font_medium(), seal.position + Vector2(0, 29.0), "灵", HORIZONTAL_ALIGNMENT_CENTER, seal.size.x, 13, Color("#fff3dd"))
	# 开始按钮上方的细金分隔线
	var line_y := 596.0
	draw_line(Vector2(96, line_y), Vector2(294, line_y), Color(0.79, 0.62, 0.36, 0.5), 1.5)
	draw_circle(Vector2(SCREEN_SIZE.x * 0.5, line_y), 3.0, Color(0.79, 0.62, 0.36, 0.7))
	# 底部署名行
	draw_string(_font(), Vector2(0, SCREEN_SIZE.y - 24.0), "美术 / 音效 / 代码 · AI 全流程制作", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_SIZE.x, 10, Color(1.0, 0.95, 0.86, 0.55))

# 标题用 Boss 立绘：复用战斗内全身像 + 火焰座，但静态化（仅轻呼吸），不随蓄力抖动
func _draw_title_boss() -> void:
	var center_x := SCREEN_SIZE.x * 0.5
	var ground_pos := Vector2(center_x, TITLE_BOSS_FOOT_Y)
	var s := TITLE_BOSS_H / BOSS_ART_CHAR_H
	var art_origin := Vector2(center_x - BOSS_ART_CHAR_CENTER_X * s, TITLE_BOSS_FOOT_Y - BOSS_ART_CHAR_FOOT_Y * s)
	# 贴地火焰座：压扁椭圆，前后两半夹住身体
	var base_xf := Transform2D.IDENTITY.translated(-ground_pos).scaled(Vector2(1.0, 0.36)).translated(ground_pos)
	var ring_d := 188.0
	var aura_frame := int(floor(title_elapsed * 8.0)) % 8
	var ring_tint := Color(1.0, 1.0, 1.0, 0.9)
	draw_set_transform_matrix(base_xf)
	draw_circle(ground_pos, 76.0, Color(0, 0, 0, 0.18))
	if boss_aura_texture:
		var ring_dst := Rect2(ground_pos - Vector2(ring_d, ring_d) * 0.5, Vector2(ring_d, ring_d))
		draw_texture_rect_region(boss_aura_texture, ring_dst, Rect2(aura_frame * 128.0, 0.0, 128.0, 128.0), ring_tint)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	# 火签串层（身体后）
	var skewer_pivot := art_origin + BOSS_ART_SKEWER_PIVOT * s
	var skewer_angle := 0.045 * sin(title_elapsed * 1.7 + 0.7)
	if boss_skewer_texture:
		var skewer_xf := Transform2D.IDENTITY.translated(-skewer_pivot).rotated(skewer_angle).translated(skewer_pivot)
		draw_set_transform_matrix(skewer_xf)
		draw_texture_rect(boss_skewer_texture, Rect2(art_origin + BOSS_ART_SKEWER_OFF * s, BOSS_ART_SKEWER_SIZE * s), false)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	# 身体层：呼吸 + 轻摇
	if boss_body_texture:
		var breathe := 1.0 + 0.016 * sin(title_elapsed * 2.4)
		var sway := 0.018 * sin(title_elapsed * 1.3)
		var foot_pivot := Vector2(center_x, TITLE_BOSS_FOOT_Y)
		var body_xf := Transform2D.IDENTITY.translated(-foot_pivot).scaled(Vector2(1.0, breathe)).rotated(sway).translated(foot_pivot)
		draw_set_transform_matrix(body_xf)
		draw_texture_rect(boss_body_texture, Rect2(art_origin + BOSS_ART_BODY_OFF * s, BOSS_ART_BODY_SIZE * s), false)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	# 火焰座前缘
	if boss_aura_texture:
		draw_set_transform_matrix(base_xf)
		var front_dst := Rect2(ground_pos + Vector2(-ring_d * 0.5, 0.0), Vector2(ring_d, ring_d * 0.5))
		draw_texture_rect_region(boss_aura_texture, front_dst, Rect2(aura_frame * 128.0, 64.0, 128.0, 64.0), ring_tint)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	# 升腾火星
	for i in range(9):
		var cycle := title_elapsed * 0.55 + float(i) * 0.111
		var ph := fmod(cycle, 1.0)
		var seed_v := float(i) * 31.7 + floorf(cycle) * 7.7
		var ex := center_x + sin(seed_v * 12.9898) * 64.0
		var ey: float = TITLE_BOSS_FOOT_Y - 4.0 - ph * (96.0 + sin(seed_v * 3.1) * 24.0)
		var ember_alpha: float = (1.0 - ph) * 0.6
		var ember_size: float = 1.6 + fmod(seed_v, 2.0)
		draw_circle(Vector2(ex + sin(ph * 9.0 + seed_v) * 6.0, ey), ember_size, Color(1.0, 0.78 - ph * 0.3, 0.32, ember_alpha))

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.position = Vector2.ZERO
	bg.size = SCREEN_SIZE
	bg.color = Color("#efe8db")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.z_index = -100
	add_child(bg)

	restart_button = Button.new()
	restart_button.text = "重开"
	restart_button.position = Vector2(322, 18)
	restart_button.size = Vector2(52, 30)
	restart_button.add_theme_font_override("font", _font_medium())
	restart_button.pressed.connect(_restart_game)
	add_child(restart_button)

	resource_label = Label.new()
	resource_label.position = Vector2(18, 602)
	resource_label.size = Vector2(354, 24)
	resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resource_label.add_theme_font_override("font", _font())
	resource_label.add_theme_font_size_override("font_size", 13)
	resource_label.add_theme_color_override("font_color", Color("#4b4038"))
	add_child(resource_label)

	status_label = Label.new()
	status_label.position = Vector2(20, 632)
	status_label.size = Vector2(350, 18)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_override("font", _font())
	status_label.add_theme_font_size_override("font_size", 10)
	status_label.add_theme_color_override("font_color", Color("#6c5c50"))
	add_child(status_label)

	card_buttons.clear()
	card_press.clear()
	card_flash.clear()
	var start_x := _hand_start_x(HAND_CARD_SIZE.x, HAND_CARD_GAP)
	for index in range(CARD_COUNT):
		var button := Button.new()
		button.position = Vector2(start_x + index * (HAND_CARD_SIZE.x + HAND_CARD_GAP), HAND_CARD_Y)
		button.size = HAND_CARD_SIZE
		button.text = ""
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_stylebox_override("normal", _transparent_style())
		button.add_theme_stylebox_override("hover", _transparent_style())
		button.add_theme_stylebox_override("pressed", _transparent_style())
		button.button_down.connect(_on_card_button_down.bind(index))
		button.button_up.connect(_on_card_button_up.bind(index))
		button.pressed.connect(_on_card_pressed.bind(index))
		add_child(button)
		card_buttons.append(button)
		card_press.append(0.0)
		card_flash.append(0.0)

	title_start_button = Button.new()
	title_start_button.text = "开 始 游 戏"
	title_start_button.position = Vector2(SCREEN_SIZE.x * 0.5 - 92.0, 624.0)
	title_start_button.size = Vector2(184, 54)
	title_start_button.visible = false
	title_start_button.focus_mode = Control.FOCUS_NONE
	title_start_button.add_theme_font_override("font", _font_medium())
	title_start_button.add_theme_font_size_override("font_size", 20)
	title_start_button.add_theme_color_override("font_color", Color("#fff3dd"))
	title_start_button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	title_start_button.add_theme_color_override("font_pressed_color", Color("#f3ddb8"))
	title_start_button.add_theme_stylebox_override("normal", _button_style(Color("#a8492f"), Color("#caa05c")))
	title_start_button.add_theme_stylebox_override("hover", _button_style(Color("#bb5639"), Color("#e0bb74")))
	title_start_button.add_theme_stylebox_override("pressed", _button_style(Color("#8d3a26"), Color("#caa05c")))
	title_start_button.pressed.connect(_start_battle)
	add_child(title_start_button)

	end_restart_button = Button.new()
	end_restart_button.text = "再 来 一 局"
	end_restart_button.position = Vector2(SCREEN_SIZE.x * 0.5 - 76.0, 470.0)
	end_restart_button.size = Vector2(152, 44)
	end_restart_button.visible = false
	end_restart_button.focus_mode = Control.FOCUS_NONE
	end_restart_button.add_theme_font_override("font", _font_medium())
	end_restart_button.add_theme_font_size_override("font_size", 18)
	end_restart_button.add_theme_color_override("font_color", Color("#fff3dd"))
	end_restart_button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	end_restart_button.add_theme_color_override("font_pressed_color", Color("#f3ddb8"))
	end_restart_button.add_theme_stylebox_override("normal", _button_style(Color("#a8492f"), Color("#caa05c")))
	end_restart_button.add_theme_stylebox_override("hover", _button_style(Color("#bb5639"), Color("#e0bb74")))
	end_restart_button.add_theme_stylebox_override("pressed", _button_style(Color("#8d3a26"), Color("#caa05c")))
	end_restart_button.pressed.connect(_restart_game)
	add_child(end_restart_button)

	option_buttons.clear()
	option_cd_overlays.clear()
	for index in range(6):
		var button := Button.new()
		button.visible = false
		button.size = Vector2(110, 34)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_override("font", _font())
		button.add_theme_font_size_override("font_size", 9)
		button.add_theme_color_override("font_color", Color("#3f342d"))
		button.add_theme_stylebox_override("normal", _button_style(Color("#fff7e8ef"), Color("#8e7661")))
		button.add_theme_stylebox_override("hover", _button_style(Color("#fff0ca"), Color("#bd8d49")))
		button.add_theme_stylebox_override("pressed", _button_style(Color("#ead6ae"), Color("#8e7661")))
		button.pressed.connect(_on_option_pressed.bind(index))
		add_child(button)
		option_buttons.append(button)
		# 冷却进度遮罩：暗色蒙版随冷却恢复向右收缩，前沿金色亮线 + 底部恢复条
		var overlay := Control.new()
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		button.add_child(overlay)
		overlay.draw.connect(_draw_cd_overlay.bind(overlay, index))
		option_cd_overlays.append(overlay)
	_layout_card_buttons()

func _option_cd_ratio_and_left(index: int) -> Vector2:
	# 返回 (剩余/总时长, 剩余秒)；index 0-2 派兵，3-5 技能
	if selected_card < 0:
		return Vector2.ZERO
	var hero: Dictionary = hero_defs[selected_card]
	if index < 3:
		var left := _deploy_cd_remaining(selected_card, index)
		if left <= 0.0:
			return Vector2.ZERO
		return Vector2(left / float(hero["troops"][index].get("cd", 6.0)), left)
	var skill_left := _skill_cd_remaining(selected_card, index - 3)
	if skill_left <= 0.0:
		return Vector2.ZERO
	return Vector2(skill_left / float(hero["skills"][index - 3].get("cd", 12.0)), skill_left)

func _draw_cd_overlay(overlay: Control, index: int) -> void:
	var cd_info := _option_cd_ratio_and_left(index)
	var ratio: float = clamp(cd_info.x, 0.0, 1.0)
	if ratio <= 0.0:
		return
	var sz := overlay.size
	var inset := 2.0
	var sweep_x: float = inset + (sz.x - inset * 2.0) * (1.0 - ratio)
	# 暗色蒙版盖住未恢复部分（右侧），随时间向右收缩
	overlay.draw_rect(Rect2(sweep_x, inset, sz.x - inset - sweep_x, sz.y - inset * 2.0), Color(0.18, 0.13, 0.09, 0.42))
	# 前沿亮线：金色微脉动
	var pulse := 0.65 + 0.35 * sin(elapsed * 7.0)
	overlay.draw_rect(Rect2(sweep_x - 1.0, inset, 2.4, sz.y - inset * 2.0), Color(1.0, 0.84, 0.45, 0.55 + 0.35 * pulse))
	# 底部恢复进度条：已恢复部分亮色填充
	var bar_y := sz.y - inset - 3.5
	overlay.draw_rect(Rect2(inset, bar_y, sz.x - inset * 2.0, 3.5), Color(0.25, 0.2, 0.14, 0.5))
	overlay.draw_rect(Rect2(inset, bar_y, (sz.x - inset * 2.0) * (1.0 - ratio), 3.5), Color(1.0, 0.78, 0.36, 0.95))

func _enter_title() -> void:
	game_state = "title"
	title_elapsed = 0.0
	if title_start_button:
		title_start_button.visible = true
	if restart_button:
		restart_button.visible = false
	if resource_label:
		resource_label.visible = false
	if end_restart_button:
		end_restart_button.visible = false
	if status_label:
		status_label.visible = false
	for button in card_buttons:
		button.visible = false
	for button in option_buttons:
		button.visible = false

func _start_battle() -> void:
	game_state = "battle"
	_play_sfx("click", 0.0)
	if title_start_button:
		title_start_button.visible = false
	if restart_button:
		restart_button.visible = true
	if resource_label:
		resource_label.visible = true
	if status_label:
		status_label.visible = true
	for button in card_buttons:
		button.visible = true
	_restart_game()

func _restart_game() -> void:
	if bgm_player and bgm_player.stream:
		bgm_player.volume_db = -16.0
		if not bgm_player.playing:
			bgm_player.play()
	gold = START_GOLD
	energy = START_ENERGY
	boss_gold = float(boss_def["gold"])
	boss_hp = BOSS_MAX_HP
	boss_attack_timer = 0.35
	elapsed = 0.0
	survive_left = SURVIVE_TIME
	next_unit_id = 1
	units.clear()
	effects.clear()
	texts.clear()
	pending_deploy.clear()
	pending_skill.clear()
	deploy_cd_left.clear()
	skill_cd_left.clear()
	death_events.clear()
	death_event_cd = 0.0
	event_banner_timer = 0.0
	event_seal = {}
	event_badges.clear()
	deploy_preview_pos = _default_deploy_pos()
	skill_preview_pos = FIELD_RECT.get_center()
	hovered_unit_id = -1
	selected_card = -1
	panel_anim = 0.0
	game_over = false
	victory = false
	if end_restart_button:
		end_restart_button.visible = false
	status_text = "守住倒计时，或打倒敌方中线英雄；敌兵进我方领域即失败。"
	tutorial_hint_timer = 9.0
	boss_state = {
		"think_timer": float(boss_def["think_timer"]),
		"skill_timers": _boss_skill_timer_defaults(),
		"skill_warned": _boss_skill_warned_defaults()
	}
	_hide_options()
	_update_ui()
	queue_redraw()

func _update_boss(delta: float) -> void:
	boss_gold = min(RESOURCE_MAX, boss_gold + float(boss_def["gold_regen"]) * delta)
	boss_state["think_timer"] = float(boss_state["think_timer"]) - delta
	if float(boss_state["think_timer"]) <= 0.0:
		_boss_try_deploy()
		boss_state["think_timer"] = rng.randf_range(1.6, 2.5)
	var timers: Array = boss_state["skill_timers"]
	var warned: Array = boss_state["skill_warned"]
	for index in range(timers.size()):
		timers[index] = float(timers[index]) - delta
		if float(timers[index]) <= 3.0 and not bool(warned[index]):
			_add_boss_warning(index)
			warned[index] = true
		if float(timers[index]) <= 0.0:
			_cast_boss_skill(index)
			var skill: Dictionary = boss_def["skills"][index]
			timers[index] = float(skill["timer"])
			warned[index] = false
	boss_state["skill_timers"] = timers
	boss_state["skill_warned"] = warned

func _boss_skill_timer_defaults() -> Array[float]:
	var timers: Array[float] = []
	for skill in boss_def["skills"]:
		timers.append(float(skill["timer"]))
	return timers

func _boss_skill_warned_defaults() -> Array[bool]:
	var warned: Array[bool] = []
	for skill in boss_def["skills"]:
		warned.append(false)
	return warned

func _next_boss_skill_time() -> float:
	if boss_state.is_empty() or not boss_state.has("skill_timers"):
		return 0.0
	var timers: Array = boss_state["skill_timers"]
	if timers.is_empty():
		return 0.0
	var next_time := INF
	for timer in timers:
		next_time = min(next_time, float(timer))
	return next_time

func _boss_try_deploy() -> void:
	var affordable: Array[Dictionary] = []
	var stage := _boss_stage()
	for i in range(boss_def["troops"].size()):
		var troop: Dictionary = boss_def["troops"][i]
		if i > stage + 2:
			continue
		if boss_gold >= float(troop["cost"]):
			affordable.append(troop)
	if affordable.is_empty():
		return
	var troop: Dictionary = _pick_boss_troop(affordable, stage)
	boss_gold -= float(troop["cost"])
	_spawn_enemy_wave(troop, "boss")

func _boss_stage() -> int:
	if elapsed >= 60.0:
		return 2
	if elapsed >= 30.0:
		return 1
	return 0

func _pick_boss_troop(affordable: Array[Dictionary], stage: int) -> Dictionary:
	var roll := rng.randf()
	var desired_tier := 1
	if stage == 0:
		desired_tier = 1 if roll < 0.75 else 2
	elif stage == 1:
		desired_tier = 1 if roll < 0.55 else (2 if roll < 0.90 else 3)
	else:
		desired_tier = 1 if roll < 0.40 else (2 if roll < 0.80 else 3)
	var candidates: Array[Dictionary] = []
	for troop in affordable:
		var unit: Dictionary = unit_defs[troop["unit"]]
		if int(unit["tier"]) == desired_tier:
			candidates.append(troop)
	if candidates.is_empty():
		candidates = affordable
	return candidates[rng.randi_range(0, candidates.size() - 1)]

func _spawn_pack(side: String, troop: Dictionary, source: String) -> void:
	var center_x := rng.randf_range(FIELD_RECT.position.x + 54.0, FIELD_RECT.end.x - 54.0)
	var base_y := PLAYER_SPAWN_Y if side == "player" else ENEMY_SPAWN_Y
	_spawn_pack_at(side, troop, source, Vector2(center_x, base_y))

func _spawn_pack_count_at(side: String, troop: Dictionary, source: String, center_pos: Vector2, count: int) -> void:
	var pack := troop.duplicate()
	pack["count"] = max(1, count)
	_spawn_pack_at(side, pack, source, center_pos)

func _spawn_pack_at(side: String, troop: Dictionary, source: String, center_pos: Vector2) -> void:
	var count := int(troop["count"])
	var formation := String(troop.get("formation", "wide"))
	var center_x := center_pos.x
	var base_y := center_pos.y
	var points := _formation_points(count, formation)
	_play_sfx("deploy")
	for point in points:
		var pos := Vector2(
			clamp(center_x + point.x, FIELD_RECT.position.x + 18.0, FIELD_RECT.end.x - 18.0),
			base_y + point.y * (1.0 if side == "player" else -1.0)
		)
		if side == "player":
			if bool(troop.get("free_cast", false)):
				pos = _clamp_skill_pos(pos)
			else:
				pos = _clamp_deploy_pos(pos)
		_spawn_unit(side, String(troop["unit"]), pos, source)
	_add_effect(Vector2(center_x, base_y), _source_color(source, side), "spawn")

func _spawn_enemy_wave(troop: Dictionary, source: String) -> void:
	var count := int(troop["count"])
	var used_x: Array[float] = []
	for i in range(count):
		var x := _random_enemy_spawn_x(used_x)
		used_x.append(x)
		var pos := Vector2(x, ENEMY_SPAWN_Y + rng.randf_range(-5.0, 20.0))
		_spawn_unit("enemy", String(troop["unit"]), pos, source)
	_add_effect(Vector2(195.0, ENEMY_SPAWN_Y + 8.0), _source_color(source, "enemy"), "spawn")

func _random_enemy_spawn_x(used_x: Array[float]) -> float:
	var left := FIELD_RECT.position.x + 18.0
	var right := FIELD_RECT.end.x - 18.0
	for attempt in range(12):
		var x := rng.randf_range(left, right)
		var too_close := false
		for used in used_x:
			if abs(x - used) < 34.0:
				too_close = true
				break
		if not too_close:
			return x
	return rng.randf_range(left, right)

func _formation_points(count: int, formation: String, stable: bool = false) -> Array[Vector2]:
	var points: Array[Vector2] = []
	if count <= 1:
		return [Vector2.ZERO]
	for i in range(count):
		var offset := float(i) - float(count - 1) * 0.5
		if formation == "point":
			var x := offset * 8.0 if stable else rng.randf_range(-12.0, 12.0)
			var y := 0.0 if stable else rng.randf_range(-4.0, 4.0)
			points.append(Vector2(x, y))
		elif formation == "line":
			points.append(Vector2(offset * 28.0, abs(offset) * 3.0))
		elif formation == "split":
			points.append(Vector2(offset * 30.0, (float(i % 2) - 0.5) * 26.0))
		else:
			var y := (float(i % 2) - 0.5) * 10.0 if stable else rng.randf_range(-8.0, 8.0)
			points.append(Vector2(offset * 30.0, y))
	return points

func _spawn_unit(side: String, unit_id: String, pos: Vector2, source: String) -> void:
	var def: Dictionary = unit_defs[unit_id]
	var unit := {
		"id": next_unit_id,
		"side": side,
		"unit_id": unit_id,
		"name": String(def["name"]),
		"pos": pos,
		"spawn_pos": pos,
		"target_id": -1,
		"hp": float(def["hp"]),
		"max_hp": float(def["hp"]),
		"damage": float(def["damage"]),
		"speed": float(def["speed"]),
		"tier": int(def["tier"]),
		"role": String(def.get("role", "front")),
		"attack_range": float(def["attack_range"]),
		"lock_range": float(def["lock_range"]),
		"interval": float(def["interval"]),
		"attack_timer": rng.randf_range(0.0, 0.4),
		"anim_state": "walk",
		"attack_anim_time": 0.0,
		"attack_hit_done": false,
		"attack_target_id": -1,
		"face_dir": Vector2(0.0, -1.0) if side == "player" else Vector2(0.0, 1.0),
		"radius": float(def["radius"]),
		"color": def["color"],
		"accent": def.get("accent", Color("#2f2a27")),
		"source": source,
		"slow_timer": 0.0,
		"shield": 0.0,
		"weaken_timer": 0.0,
		"hit_flash": 0.0,
		"frozen_timer": 0.0,
		"rally_timer": 0.0,
		"haste_timer": 0.0,
		"is_ghost": false,
		"ghost_timer": 0.0,
		"can_seek": bool(def.get("can_seek", false))
	}
	next_unit_id += 1
	units.append(unit)

func _update_units(delta: float) -> void:
	for i in range(units.size()):
		var unit: Dictionary = units[i]
		unit["attack_timer"] = max(0.0, float(unit["attack_timer"]) - delta)
		unit["slow_timer"] = max(0.0, float(unit["slow_timer"]) - delta)
		unit["weaken_timer"] = max(0.0, float(unit["weaken_timer"]) - delta)
		unit["hit_flash"] = max(0.0, float(unit.get("hit_flash", 0.0)) - delta)
		unit["rally_timer"] = max(0.0, float(unit.get("rally_timer", 0.0)) - delta)
		unit["haste_timer"] = max(0.0, float(unit.get("haste_timer", 0.0)) - delta)
		# 幽魂重生体：限时存在，时间到自行消散
		if bool(unit.get("is_ghost", false)):
			unit["ghost_timer"] = float(unit.get("ghost_timer", 0.0)) - delta
			if float(unit["ghost_timer"]) <= 0.0:
				unit["hp"] = 0.0
		# 冰冻：完全停止行动
		if float(unit.get("frozen_timer", 0.0)) > 0.0:
			unit["frozen_timer"] = float(unit["frozen_timer"]) - delta
			units[i] = unit
			continue
		if _update_active_attack_animation(i, unit, delta):
			unit = units[i]
			unit["pos"] = _block_cross_side_overlap(i, unit)
			units[i] = unit
			continue
		var attack_target_index := _resolve_attack_target(i, unit)
		if attack_target_index >= 0:
			if float(unit["attack_timer"]) <= 0.0:
				if _uses_attack_animation(unit):
					unit = _begin_attack_animation(unit, attack_target_index)
				else:
					_attack_unit(i, attack_target_index)
					unit["attack_timer"] = float(unit["interval"])
			unit["pos"] = _block_cross_side_overlap(i, unit)
			units[i] = unit
			continue
		var target_index := _resolve_target(i, unit)
		if target_index >= 0:
			var target: Dictionary = units[target_index]
			var distance := (target["pos"] as Vector2).distance_to(unit["pos"] as Vector2)
			if distance <= float(unit["attack_range"]) + float(target["radius"]):
				if float(unit["attack_timer"]) <= 0.0:
					if _uses_attack_animation(unit):
						unit = _begin_attack_animation(unit, target_index)
					else:
						_attack_unit(i, target_index)
						unit["attack_timer"] = float(unit["interval"])
			elif bool(unit.get("can_seek", false)):
				var seek_dir := (target["pos"] as Vector2) - (unit["pos"] as Vector2)
				if seek_dir.length() > 0.001:
					unit["face_dir"] = seek_dir.normalized()
				unit["pos"] = _move_towards(unit, target["pos"], delta)
			elif String(unit.get("role", "")) == "ranged":
				unit["pos"] = _advance(unit, delta * 0.18)
			else:
				unit["pos"] = _advance(unit, delta * 0.45)
		elif _handle_boss_objective(i, unit, delta):
			unit = units[i]
		else:
			unit["pos"] = _advance(unit, delta)
		unit["pos"] = _separate_from_friends(i, unit, delta)
		unit["pos"] = _block_cross_side_overlap(i, unit)
		units[i] = unit
	_check_entry_victory()
	_remove_dead_units()

func _uses_attack_animation(unit: Dictionary) -> bool:
	return unit_sprite_textures.get(String(unit["unit_id"]), {}).get("attack") != null

# 伤害结算时刻须对齐各自图集的「全力攻击」帧，配置在 UNIT_SPRITE_DEFS.hit_time
func _attack_hit_time(unit: Dictionary) -> float:
	var sprite_def: Dictionary = UNIT_SPRITE_DEFS.get(String(unit["unit_id"]), {})
	return float(sprite_def.get("hit_time", CRUMB_ATTACK_HIT_TIME))

func _begin_attack_animation(unit: Dictionary, target_index: int) -> Dictionary:
	unit["anim_state"] = "attack"
	unit["attack_anim_time"] = 0.0
	unit["attack_hit_done"] = false
	unit["attack_target_id"] = int(units[target_index]["id"]) if target_index >= 0 and target_index < units.size() else -1
	unit["attack_timer"] = float(unit["interval"])
	# 记录目标在左还是右，攻击精灵图按此水平镜像，让刺击方向对准目标
	if target_index >= 0 and target_index < units.size():
		unit["attack_dir_x"] = signf(float((units[target_index]["pos"] as Vector2).x) - float((unit["pos"] as Vector2).x))
		# 多向精灵：朝向对准目标，防全图刺客背身穿帮
		var to_target := (units[target_index]["pos"] as Vector2) - (unit["pos"] as Vector2)
		if to_target.length() > 0.001:
			unit["face_dir"] = to_target.normalized()
	return unit

func _update_active_attack_animation(unit_index: int, unit: Dictionary, delta: float) -> bool:
	if String(unit.get("anim_state", "walk")) != "attack":
		return false
	var previous_time := float(unit.get("attack_anim_time", 0.0))
	var current_time := previous_time + delta
	unit["attack_anim_time"] = current_time
	var hit_time := _attack_hit_time(unit)
	if not bool(unit.get("attack_hit_done", false)) and previous_time < hit_time and current_time >= hit_time:
		var target_index := _unit_index_by_id(int(unit.get("attack_target_id", -1)))
		if target_index >= 0:
			var target: Dictionary = units[target_index]
			var distance := (target["pos"] as Vector2).distance_to(unit["pos"] as Vector2)
			if String(target["side"]) != String(unit["side"]) and distance <= float(unit["attack_range"]) + float(target["radius"]) + 4.0:
				_attack_unit(unit_index, target_index)
		unit["attack_hit_done"] = true
	if current_time >= CRUMB_ATTACK_DURATION:
		unit["anim_state"] = "walk"
		unit["attack_anim_time"] = 0.0
		unit["attack_hit_done"] = false
		unit["attack_target_id"] = -1
	units[unit_index] = unit
	return true

func _resolve_attack_target(index: int, unit: Dictionary) -> int:
	var best_index := -1
	var best_score := INF
	for other_index in range(units.size()):
		if other_index == index:
			continue
		var other: Dictionary = units[other_index]
		if String(other["side"]) == String(unit["side"]):
			continue
		var distance := (other["pos"] as Vector2).distance_to(unit["pos"] as Vector2)
		if distance > float(unit["attack_range"]) + float(other["radius"]):
			continue
		if _is_straight_melee(unit) and not _is_target_in_front(unit, other):
			continue
		var gate_bonus: float = -40.0 if _is_near_own_gate(unit, other) else 0.0
		var tier_bonus: float = -float(unit_defs[String(other["unit_id"])]["tier"]) * 4.0
		var score: float = distance + gate_bonus + tier_bonus
		if score < best_score:
			best_score = score
			best_index = other_index
	if best_index >= 0:
		units[index]["target_id"] = int(units[best_index]["id"])
	return best_index

func _handle_boss_objective(unit_index: int, unit: Dictionary, delta: float) -> bool:
	if String(unit["side"]) != "player" or boss_hp <= 0.0:
		return false
	var distance := (unit["pos"] as Vector2).distance_to(BOSS_POS)
	var attack_distance: float = float(unit["attack_range"]) + BOSS_RADIUS
	var lock_distance: float = max(float(unit["lock_range"]), BOSS_ATTACK_RANGE) + BOSS_RADIUS
	if distance <= attack_distance:
		if float(unit["attack_timer"]) <= 0.0:
			_attack_boss(unit)
			unit["attack_timer"] = float(unit["interval"])
		units[unit_index] = unit
		return true
	if distance <= lock_distance and bool(unit.get("can_seek", false)):
		var to_boss := BOSS_POS - (unit["pos"] as Vector2)
		if to_boss.length() > 0.001:
			unit["face_dir"] = to_boss.normalized()
		unit["pos"] = _move_towards(unit, BOSS_POS, delta)
		units[unit_index] = unit
		return true
	return false

func _attack_boss(attacker: Dictionary) -> void:
	if game_over or boss_hp <= 0.0:
		return
	var damage := float(attacker["damage"])
	if float(attacker.get("weaken_timer", 0.0)) > 0.0:
		damage *= 0.62
	if float(attacker.get("rally_timer", 0.0)) > 0.0:
		damage *= 1.35
	_damage_boss(damage, attacker["color"], "敌方中线英雄被击败，胜利！")

func _damage_boss(damage: float, color: Color, win_text: String) -> void:
	if game_over or boss_hp <= 0.0:
		return
	boss_hp = max(0.0, boss_hp - damage)
	_add_effect(BOSS_POS, color, "hit")
	_add_text(BOSS_POS + Vector2(14, -20), "-%d" % int(round(damage)), Color("#8d3427"))
	if boss_hp <= 0.0:
		game_over = true
		victory = true
		_play_sfx("victory", 0.0)
		_set_status(win_text)

func _update_boss_attack(delta: float) -> void:
	if game_over or boss_hp <= 0.0:
		return
	boss_attack_timer = max(0.0, boss_attack_timer - delta)
	if boss_attack_timer > 0.0:
		return
	var target_index := _nearest_player_for_boss()
	if target_index < 0:
		return
	var target: Dictionary = units[target_index]
	target["hp"] = float(target["hp"]) - BOSS_ATTACK_DAMAGE
	target["hit_flash"] = 0.16
	units[target_index] = target
	boss_attack_timer = BOSS_ATTACK_INTERVAL
	_add_projectile_effect(BOSS_POS, target["pos"], flavor_defs[boss_def["flavor"]]["color"], "boss_shot")
	_add_effect(target["pos"], flavor_defs[boss_def["flavor"]]["color"], "hit")
	_play_sfx("hit")
	_add_text(target["pos"] + Vector2(8, -16), "-%d" % int(BOSS_ATTACK_DAMAGE), Color("#8d3427"))

func _nearest_player_for_boss() -> int:
	var best_index := -1
	var best_distance := INF
	for i in range(units.size()):
		if String(units[i]["side"]) != "player":
			continue
		var distance := (units[i]["pos"] as Vector2).distance_to(BOSS_POS)
		if distance > BOSS_ATTACK_RANGE + float(units[i]["radius"]):
			continue
		if distance < best_distance:
			best_distance = distance
			best_index = i
	return best_index

func _check_survive_victory() -> void:
	if game_over:
		return
	if survive_left <= 0.0:
		game_over = true
		victory = true
		_play_sfx("victory", 0.0)
		_set_status("守住了整场怪潮，胜利！")

func _resolve_target(index: int, unit: Dictionary) -> int:
	var existing_id := int(unit.get("target_id", -1))
	var existing_index := _unit_index_by_id(existing_id)
	var search_range := float(unit["lock_range"])
	if bool(unit.get("global_seek", false)):
		search_range = 999.0
	if existing_index >= 0:
		var existing: Dictionary = units[existing_index]
		var dist := (existing["pos"] as Vector2).distance_to(unit["pos"] as Vector2)
		if dist <= search_range * 1.12 and (not _is_straight_melee(unit) or _is_target_in_front(unit, existing)):
			return existing_index
	var best_index := -1
	var best_score := INF
	for other_index in range(units.size()):
		if other_index == index:
			continue
		var other: Dictionary = units[other_index]
		if String(other["side"]) == String(unit["side"]):
			continue
		var distance := (other["pos"] as Vector2).distance_to(unit["pos"] as Vector2)
		if distance > search_range:
			continue
		if _is_straight_melee(unit) and not _is_target_in_front(unit, other):
			continue
		var gate_bonus := -80.0 if _is_near_own_gate(unit, other) else 0.0
		var lane_bonus: float = abs(float(other["pos"].x) - float(unit["pos"].x)) * 0.28
		var tier_bonus: float = -float(unit_defs[String(other["unit_id"])]["tier"]) * 8.0 if bool(unit.get("global_seek", false)) else 0.0
		var score: float = distance + gate_bonus + lane_bonus + tier_bonus
		if score < best_score:
			best_score = score
			best_index = other_index
	if best_index >= 0:
		units[index]["target_id"] = int(units[best_index]["id"])
	else:
		units[index]["target_id"] = -1
	return best_index

func _is_near_own_gate(unit: Dictionary, other: Dictionary) -> bool:
	if String(unit["side"]) == "player":
		return float(other["pos"].y) > FIELD_RECT.end.y - 72.0
	return float(other["pos"].y) < FIELD_RECT.position.y + 72.0

func _unit_speed_factor(unit: Dictionary) -> float:
	var factor := 0.45 if float(unit["slow_timer"]) > 0.0 else 1.0
	if float(unit.get("haste_timer", 0.0)) > 0.0:
		factor *= 1.5
	return factor

func _move_towards(unit: Dictionary, target_pos: Vector2, delta: float) -> Vector2:
	var pos: Vector2 = unit["pos"]
	var direction := (target_pos - pos).normalized()
	return pos + direction * float(unit["speed"]) * _unit_speed_factor(unit) * delta

func _advance(unit: Dictionary, delta: float) -> Vector2:
	var pos: Vector2 = unit["pos"]
	var direction := -1.0 if String(unit["side"]) == "player" else 1.0
	pos.y += direction * float(unit["speed"]) * _unit_speed_factor(unit) * delta
	pos.x = clamp(pos.x, FIELD_RECT.position.x + 14.0, FIELD_RECT.end.x - 14.0)
	return pos

func _is_straight_melee(unit: Dictionary) -> bool:
	return String(unit.get("role", "")) in ["front", "tank"] and not bool(unit.get("can_seek", false))

func _is_target_in_front(unit: Dictionary, other: Dictionary) -> bool:
	# 敌方向屏幕下方推进（y 增大），我方向上推进（y 减小）；-4 像素容错避免横向并排时抖动
	var forward_dir := 1.0 if String(unit["side"]) == "enemy" else -1.0
	var dy := float((other["pos"] as Vector2).y) - float((unit["pos"] as Vector2).y)
	return dy * forward_dir >= -4.0

func _block_cross_side_overlap(index: int, unit: Dictionary) -> Vector2:
	var pos: Vector2 = unit["pos"]
	for other_index in range(units.size()):
		if other_index == index:
			continue
		var other: Dictionary = units[other_index]
		if String(other["side"]) == String(unit["side"]):
			continue
		var delta_pos := pos - (other["pos"] as Vector2)
		var dist := delta_pos.length()
		var min_dist := float(unit["radius"]) + float(other["radius"]) + 1.5
		if dist >= min_dist:
			continue
		if dist <= 0.01:
			# 完全重叠时沿自己来路方向退出，避免除零
			var back_dir := -1.0 if String(unit["side"]) == "enemy" else 1.0
			delta_pos = Vector2(0.0, back_dir)
			dist = 0.01
		pos += delta_pos.normalized() * (min_dist - dist)
	pos.x = clamp(pos.x, FIELD_RECT.position.x + 12.0, FIELD_RECT.end.x - 12.0)
	return pos

func _separate_from_friends(index: int, unit: Dictionary, delta: float) -> Vector2:
	var pos: Vector2 = unit["pos"]
	for other_index in range(units.size()):
		if other_index == index:
			continue
		var other: Dictionary = units[other_index]
		if String(other["side"]) != String(unit["side"]):
			continue
		var delta_pos := pos - (other["pos"] as Vector2)
		var dist := delta_pos.length()
		var min_dist := float(unit["radius"]) + float(other["radius"]) + 3.0
		if dist > 0.01 and dist < min_dist:
			pos += delta_pos.normalized() * (min_dist - dist) * 1.6 * delta
	pos.x = clamp(pos.x, FIELD_RECT.position.x + 12.0, FIELD_RECT.end.x - 12.0)
	return pos

func _check_entry_victory() -> void:
	if game_over:
		return
	for index in range(units.size() - 1, -1, -1):
		var unit: Dictionary = units[index]
		if String(unit["side"]) == "enemy" and float(unit["pos"].y) >= ENEMY_ENTRY_Y:
			game_over = true
			victory = false
			_play_sfx("defeat", 0.0)
			_set_status("%s 闯入我方领域，失败！" % unit["name"])
			return
		if String(unit["side"]) == "player" and float(unit["pos"].y) <= PLAYER_ENTRY_Y:
			if _can_attack_boss(unit):
				continue
			_convert_runner_to_reward(index)

func _can_attack_boss(unit: Dictionary) -> bool:
	if boss_hp <= 0.0:
		return false
	return (unit["pos"] as Vector2).distance_to(BOSS_POS) <= float(unit["attack_range"]) + BOSS_RADIUS

func _convert_runner_to_reward(index: int) -> void:
	if index < 0 or index >= units.size():
		return
	var unit: Dictionary = units[index]
	var tier := int(unit_defs[String(unit["unit_id"])]["tier"])
	var gold_gain := 0.3 + tier * 0.25
	var energy_gain := 0.1 + tier * 0.18
	gold += gold_gain
	energy = min(RESOURCE_MAX, energy + energy_gain)
	_add_effect(unit["pos"], Color("#d8b158"), "skill")
	_add_text(unit["pos"] + Vector2(-16, -8), "+%.1f金 +%.1f能" % [gold_gain, energy_gain], Color("#725f39"))
	units.remove_at(index)
	_set_status("%s 越过敌方后场，转化为资源。" % unit["name"])

func _attack_unit(attacker_index: int, target_index: int) -> void:
	if attacker_index < 0 or attacker_index >= units.size() or target_index < 0 or target_index >= units.size():
		return
	var attacker: Dictionary = units[attacker_index]
	var target: Dictionary = units[target_index]
	var damage := float(attacker["damage"])
	if float(attacker.get("weaken_timer", 0.0)) > 0.0:
		damage *= 0.62
	if float(attacker.get("rally_timer", 0.0)) > 0.0:
		damage *= 1.35
	var shield := float(target.get("shield", 0.0))
	var blocked := 0.0
	if shield > 0.0:
		var absorb: float = min(shield, damage)
		shield -= absorb
		damage -= absorb
		blocked = absorb
		target["shield"] = shield
	target["hp"] = float(target["hp"]) - damage
	target["hit_flash"] = 0.13
	var def: Dictionary = unit_defs[String(attacker["unit_id"])]
	if def.has("slow"):
		target["slow_timer"] = max(float(target.get("slow_timer", 0.0)), float(def["slow"]))
	if String(attacker.get("role", "")) == "ranged":
		# 弹道从精灵图「出手位」（身体上半部朝目标一侧）射出，而非脚底中心
		var shot_dir: Vector2 = ((target["pos"] as Vector2) - (attacker["pos"] as Vector2)).normalized()
		var muzzle: Vector2 = (attacker["pos"] as Vector2) + shot_dir * float(attacker["radius"]) + Vector2(0, -float(attacker["radius"]) * 1.1)
		_add_projectile_effect(muzzle, target["pos"], attacker["color"], "ranged_shot")
		_play_sfx("attack_ranged")
	elif bool(attacker.get("global_seek", false)):
		_add_projectile_effect(attacker["pos"], target["pos"], attacker["color"], "seek_slash")
		_play_sfx("attack_melee")
	else:
		_play_sfx("attack_melee")
	_add_effect(target["pos"], attacker["color"], "hit")
	var target_pos: Vector2 = target["pos"]
	if damage > 0.01:
		_add_text(target_pos + Vector2(7.0, -16.0), "-%d" % int(round(damage)), Color("#8d3427") if String(target["side"]) == "player" else Color("#405131"))
	elif blocked > 0.01:
		_add_text(target_pos + Vector2(-8.0, -16.0), "挡", Color("#725f39"))
	units[target_index] = target

func _remove_dead_units() -> void:
	for index in range(units.size() - 1, -1, -1):
		var unit: Dictionary = units[index]
		if float(unit["hp"]) <= 0.0:
			# 死亡掷骰：按权重表抽事件（幽魂消散不再掷骰，全局冷却防扎堆）
			if not game_over and death_event_cd <= 0.0 and not bool(unit.get("is_ghost", false)):
				var roll := rng.randf()
				var acc := 0.0
				for entry in DEATH_EVENT_TABLE:
					acc += float(entry[1])
					if roll < acc:
						_trigger_death_event(unit, String(entry[0]))
						break
			if String(unit["side"]) == "enemy":
				var tier := int(unit_defs[String(unit["unit_id"])]["tier"])
				var gold_gain := 0.45 + float(tier) * 0.35
				var energy_gain := 0.08 + float(tier) * 0.06
				gold += gold_gain
				energy = min(RESOURCE_MAX, energy + energy_gain)
				_add_text((unit["pos"] as Vector2) + Vector2(-18.0, -26.0), "+%.1f金币" % gold_gain, Color("#725f39"))
				_add_text((unit["pos"] as Vector2) + Vector2(14.0, -10.0), "+%.1f技" % energy_gain, Color("#3f6270"))
			effects.append({
				"pos": unit["pos"], "color": unit["color"], "time": 0.9, "max_time": 0.9,
				"radius": float(unit["radius"]), "kind": "death",
				"unit_id": String(unit["unit_id"]), "seed": int(unit["id"])
			})
			_play_sfx("death", 0.1)
			_add_screen_shake(1.6)
			units.remove_at(index)

# ============ 死亡概率事件系统 ============

func _trigger_death_event(dead_unit: Dictionary, kind: String) -> void:
	death_event_cd = DEATH_EVENT_COOLDOWN
	var origin: Vector2 = dead_unit["pos"]
	var dead_side := String(dead_unit["side"])
	if kind == "storm":
		death_events.append({"kind": "storm", "timer": 2.6, "strike_cd": 0.15})
		_show_event_banner("天怒雷暴！敌我皆遭天谴", Color("#3d4a6b"))
	elif kind == "dot_zone":
		var zone_pos := _death_event_zone_pos(origin)
		death_events.append({"kind": "dot_zone", "pos": zone_pos, "radius": 72.0, "timer": 4.5, "tick": 0.0})
		_show_event_banner("灼热毒雾弥漫，久留必伤", Color("#5c6e33"))
	elif kind == "meteor":
		var meteor_pos := _death_event_zone_pos(origin)
		death_events.append({"kind": "meteor", "pos": meteor_pos, "radius": 48.0, "timer": 1.0, "warn_total": 1.0})
		_show_event_banner("陨石坠落！红圈之内皆化灰烬", Color("#8d3427"))
	elif kind == "hail":
		var hail_pos := _death_event_zone_pos(origin)
		death_events.append({"kind": "hail", "pos": hail_pos, "radius": 80.0, "timer": 2.4, "applied": false})
		_show_event_banner("冰雹骤至，寒气封身", Color("#4f789f"))
	elif kind == "rebirth":
		death_events.append({"kind": "rebirth", "unit": dead_unit.duplicate(true), "pos": origin, "timer": 0.85})
		_show_event_banner("死而不僵！亡魂即将再战", Color("#6b4a7c"))
	elif kind == "ally_buff":
		_buff_side(dead_side, 6.0)
		_show_event_banner("%s同仇敌忾，攻势大涨！" % ("我方" if dead_side == "player" else "敌方"), Color("#8a6a1f"))
	elif kind == "enemy_buff":
		var other := "enemy" if dead_side == "player" else "player"
		_buff_side(other, 6.0)
		_show_event_banner("%s趁势狂暴，攻势大涨！" % ("我方" if other == "player" else "敌方"), Color("#8d3427"))
	elif kind == "gold_windfall":
		gold += 3.0
		energy = min(RESOURCE_MAX, energy + 1.0)
		boss_gold = min(RESOURCE_MAX, boss_gold + 3.0)
		_add_text(origin + Vector2(-30.0, -22.0), "+3金 +1能", Color("#8a6a1f"))
		_show_event_banner("天降横财！双方军资进账", Color("#8a6a1f"))
	elif kind == "mass_heal":
		for i in range(units.size()):
			var heal := float(units[i]["max_hp"]) * 0.35
			units[i]["hp"] = min(float(units[i]["max_hp"]), float(units[i]["hp"]) + heal)
			effects.append({"pos": units[i]["pos"], "color": Color("#86c06a"), "time": 0.5, "max_time": 0.5, "radius": float(units[i]["radius"]) + 6.0, "kind": "buff_glow"})
		_show_event_banner("甘霖普降，全场回血", Color("#3f6545"))
	elif kind == "haste":
		for i in range(units.size()):
			units[i]["haste_timer"] = max(float(units[i].get("haste_timer", 0.0)), 5.0)
		death_events.append({"kind": "haste_wind", "timer": 5.0})
		_show_event_banner("疾风过境！全场脚下生风", Color("#4a7a72"))
	_add_event_badge(kind)
	_play_sfx("boss_warning", 0.0)

# 同种事件再触发时刷新原徽章时间；新事件追加在底部，超出上限挤掉最旧的
func _add_event_badge(kind: String) -> void:
	if not EVENT_BADGE_DEFS.has(kind):
		return
	var def: Dictionary = EVENT_BADGE_DEFS[kind]
	_show_event_seal(def)
	var duration := float(def["duration"])
	var total: float = absf(duration)
	for i in range(event_badges.size()):
		if String(event_badges[i]["kind"]) == kind:
			event_badges[i]["time_left"] = total
			return
	event_badges.append({
		"kind": kind, "glyph": String(def["glyph"]), "label": String(def["label"]),
		"color": def["color"], "time_left": total, "total": total, "instant": duration < 0.0
	})
	if event_badges.size() > EVENT_BADGE_MAX:
		event_badges.remove_at(0)

func _show_event_banner(text: String, color: Color) -> void:
	# 顶部横幅已停用，状态保留以兼容旧调用；视觉改由中央大印记承担
	event_banner_text = text
	event_banner_color = color
	event_banner_timer = 0.0

# 中央大印记：触发即满显、轻微放大并在 1s 内淡出消失
func _show_event_seal(def: Dictionary) -> void:
	event_seal = {
		"glyph": String(def["glyph"]),
		"label": String(def["label"]),
		"color": def["color"],
		"timer": 1.0,
		"total": 1.0
	}

# 事件落点：优先砸向随机存活单位附近（战斗热区），无单位则砸场地中央附近
func _death_event_zone_pos(fallback: Vector2) -> Vector2:
	var pos := fallback
	if not units.is_empty():
		pos = units[rng.randi_range(0, units.size() - 1)]["pos"]
	pos += Vector2(rng.randf_range(-34.0, 34.0), rng.randf_range(-34.0, 34.0))
	return Vector2(
		clamp(pos.x, FIELD_RECT.position.x + 30.0, FIELD_RECT.end.x - 30.0),
		clamp(pos.y, FIELD_RECT.position.y + 60.0, FIELD_RECT.end.y - 40.0)
	)

func _update_death_events(delta: float) -> void:
	death_event_cd = max(0.0, death_event_cd - delta)
	event_banner_timer = max(0.0, event_banner_timer - delta)
	if not event_seal.is_empty():
		event_seal["timer"] = float(event_seal["timer"]) - delta
		if float(event_seal["timer"]) <= 0.0:
			event_seal = {}
	for i in range(event_badges.size() - 1, -1, -1):
		event_badges[i]["time_left"] = float(event_badges[i]["time_left"]) - delta
		if float(event_badges[i]["time_left"]) <= 0.0:
			event_badges.remove_at(i)
	for idx in range(death_events.size() - 1, -1, -1):
		var ev: Dictionary = death_events[idx]
		ev["timer"] = float(ev["timer"]) - delta
		var kind := String(ev["kind"])
		if kind == "storm":
			ev["strike_cd"] = float(ev.get("strike_cd", 0.0)) - delta
			if float(ev["strike_cd"]) <= 0.0:
				ev["strike_cd"] = 0.34
				_storm_strike()
		elif kind == "dot_zone":
			ev["tick"] = float(ev.get("tick", 0.0)) - delta
			if float(ev["tick"]) <= 0.0:
				ev["tick"] = 0.3
				_damage_all_in_radius(ev["pos"], float(ev["radius"]), 2.4)
		elif kind == "meteor":
			if float(ev["timer"]) <= 0.0:
				_meteor_impact(ev["pos"], float(ev["radius"]))
		elif kind == "hail":
			if not bool(ev.get("applied", false)):
				ev["applied"] = true
				_apply_freeze(ev["pos"], float(ev["radius"]), 2.6, 8.0)
		elif kind == "rebirth":
			if float(ev["timer"]) <= 0.0:
				_revive_ghost(ev["unit"])
		if float(ev["timer"]) <= 0.0:
			death_events.remove_at(idx)

func _storm_strike() -> void:
	var strike_pos: Vector2
	if not units.is_empty():
		strike_pos = units[rng.randi_range(0, units.size() - 1)]["pos"]
	else:
		strike_pos = _death_event_zone_pos(FIELD_RECT.get_center())
	for i in range(units.size()):
		if (units[i]["pos"] as Vector2).distance_to(strike_pos) <= 26.0 + float(units[i]["radius"]):
			units[i]["hp"] = float(units[i]["hp"]) - 26.0
			units[i]["hit_flash"] = 0.18
	effects.append({"pos": strike_pos, "color": Color("#cfe0ff"), "time": 0.34, "max_time": 0.34, "radius": 26.0, "kind": "lightning", "seed": rng.randi_range(0, 999)})
	_add_screen_shake(2.6)
	_play_sfx("hit", 0.0)

func _damage_all_in_radius(center: Vector2, radius: float, damage: float) -> void:
	for i in range(units.size()):
		if (units[i]["pos"] as Vector2).distance_to(center) <= radius + float(units[i]["radius"]):
			units[i]["hp"] = float(units[i]["hp"]) - damage
			units[i]["hit_flash"] = max(float(units[i].get("hit_flash", 0.0)), 0.08)

func _meteor_impact(center: Vector2, radius: float) -> void:
	for i in range(units.size()):
		if (units[i]["pos"] as Vector2).distance_to(center) <= radius + float(units[i]["radius"]):
			units[i]["hp"] = 0.0
			units[i]["hit_flash"] = 0.2
			_add_text((units[i]["pos"] as Vector2) + Vector2(-8.0, -20.0), "灭", Color("#8d3427"))
	if BOSS_POS.distance_to(center) <= radius + BOSS_RADIUS:
		_damage_boss(60.0, Color("#e8743f"), "陨石砸穿了敌方中线英雄，胜利！")
		_add_text(BOSS_POS + Vector2(-22.0, -40.0), "-60 陨石", Color("#8d3427"))
	effects.append({"pos": center, "color": Color("#e8743f"), "time": 0.7, "max_time": 0.7, "radius": radius, "kind": "meteor_blast"})
	_add_screen_shake(8.0)
	_add_hitstop(0.08)
	_play_sfx("boss_skill", 0.0)

func _apply_freeze(center: Vector2, radius: float, duration: float, damage: float) -> void:
	for i in range(units.size()):
		if (units[i]["pos"] as Vector2).distance_to(center) <= radius + float(units[i]["radius"]):
			units[i]["frozen_timer"] = max(float(units[i].get("frozen_timer", 0.0)), duration)
			units[i]["hp"] = float(units[i]["hp"]) - damage
			units[i]["hit_flash"] = 0.1
	effects.append({"pos": center, "color": Color("#bcdcf0"), "time": 0.6, "max_time": 0.6, "radius": radius, "kind": "ice_burst"})
	_play_sfx("hit", -0.12)

func _buff_side(side: String, duration: float) -> void:
	for i in range(units.size()):
		if String(units[i]["side"]) == side:
			units[i]["rally_timer"] = max(float(units[i].get("rally_timer", 0.0)), duration)
			effects.append({"pos": units[i]["pos"], "color": Color("#e8c25a"), "time": 0.5, "max_time": 0.5, "radius": float(units[i]["radius"]) + 6.0, "kind": "buff_glow"})

func _revive_ghost(snapshot: Dictionary) -> void:
	var ghost: Dictionary = snapshot.duplicate(true)
	ghost["id"] = next_unit_id
	next_unit_id += 1
	# 亡灵更强：复活血量更厚、伤害更高、移速更快、存在更久（强化"死而不僵"的存在感）
	ghost["hp"] = float(ghost["max_hp"]) * 0.7
	ghost["damage"] = float(ghost["damage"]) * 1.6
	ghost["speed"] = float(ghost["speed"]) * 1.15
	ghost["is_ghost"] = true
	ghost["ghost_timer"] = 8.0
	ghost["shield"] = 0.0
	ghost["frozen_timer"] = 0.0
	ghost["weaken_timer"] = 0.0
	ghost["hit_flash"] = 0.0
	ghost["attack_timer"] = 0.3
	ghost["anim_state"] = "walk"
	ghost["attack_anim_time"] = 0.0
	ghost["attack_hit_done"] = false
	ghost["attack_target_id"] = -1
	ghost["target_id"] = -1
	units.append(ghost)
	effects.append({"pos": ghost["pos"], "color": Color("#9a7ab0"), "time": 0.6, "max_time": 0.6, "radius": float(ghost["radius"]) + 10.0, "kind": "rebirth_glow"})
	_add_text((ghost["pos"] as Vector2) + Vector2(-16.0, -24.0), "魂归！", Color("#6b4a7c"))
	_play_sfx("deploy", 0.1)

func _unit_index_by_id(id: int) -> int:
	for index in range(units.size()):
		if int(units[index]["id"]) == id:
			return index
	return -1

func _update_hovered_unit(pos: Vector2) -> void:
	var previous_id := hovered_unit_id
	hovered_unit_id = _unit_id_at_position(pos)
	if previous_id != hovered_unit_id:
		queue_redraw()

func _unit_id_at_position(pos: Vector2) -> int:
	var best_id := -1
	var best_distance := INF
	for unit in units:
		var unit_pos: Vector2 = unit["pos"]
		var hit_radius: float = max(float(unit["radius"]) + 8.0, 18.0)
		var distance: float = unit_pos.distance_to(pos)
		if distance <= hit_radius and distance < best_distance:
			best_distance = distance
			best_id = int(unit["id"])
	return best_id

func _player_deploy_rect() -> Rect2:
	return Rect2(FIELD_RECT.position.x + 12.0, FIELD_RECT.end.y - 144.0, FIELD_RECT.size.x - 24.0, 118.0)

func _default_deploy_pos() -> Vector2:
	return Vector2(FIELD_RECT.get_center().x, PLAYER_SPAWN_Y)

func _clamp_deploy_pos(pos: Vector2) -> Vector2:
	var rect := _player_deploy_rect()
	return Vector2(
		clamp(pos.x, rect.position.x + 18.0, rect.end.x - 18.0),
		clamp(pos.y, rect.position.y + 18.0, rect.end.y - 18.0)
	)

func _clamp_skill_pos(pos: Vector2) -> Vector2:
	return Vector2(
		clamp(pos.x, FIELD_RECT.position.x + 14.0, FIELD_RECT.end.x - 14.0),
		clamp(pos.y, FIELD_RECT.position.y + 14.0, FIELD_RECT.end.y - 14.0)
	)

func _skill_radius(kind: String) -> float:
	if kind == "mist":
		return 106.0
	if kind == "shield":
		return 118.0
	if kind == "summon_jar":
		return 48.0
	if kind == "shadow":
		return 58.0
	if kind == "heal":
		return 132.0
	if kind == "rain":
		return 168.0
	if kind == "root":
		return 126.0
	if kind == "weaken":
		return 146.0
	if kind == "summon_vine":
		return 54.0
	return 96.0

func _skill_hint(kind: String) -> String:
	if kind == "mist":
		return "范围伤害 + 强减速"
	if kind == "shield":
		return "范围护盾"
	if kind == "summon_jar":
		return "定点召唤坦兵"
	if kind == "shadow":
		return "定点召唤突击兵"
	if kind == "heal":
		return "范围治疗 + 小护盾"
	if kind == "rain":
		return "大范围轰炸"
	if kind == "root":
		return "范围缠绕定身"
	if kind == "weaken":
		return "范围削弱 + 破血"
	if kind == "summon_vine":
		return "定点召唤重兵"
	return "范围技能"

func _skill_tag(kind: String) -> String:
	if kind in ["mist", "rain"]:
		return "伤害"
	if kind in ["shield"]:
		return "守护"
	if kind in ["summon_jar", "shadow", "summon_vine"]:
		return "召唤"
	if kind == "heal":
		return "治疗"
	if kind == "root":
		return "控制"
	if kind == "weaken":
		return "削弱"
	return "技能"

func _skill_target_text(kind: String) -> String:
	if kind in ["shield", "heal"]:
		return "友军范围"
	if kind in ["summon_jar", "shadow", "summon_vine"]:
		return "落点出兵"
	return "敌方范围"

func _skill_result_text(kind: String) -> String:
	if kind == "mist":
		return "酸雾命中：伤害 + 强减速"
	if kind == "shield":
		return "护阵展开：友军获得护盾"
	if kind == "summon_jar":
		return "坛甲卫入场：前排抗线"
	if kind == "shadow":
		return "糯影突袭：追踪切入"
	if kind == "heal":
		return "甜糯结界：治疗 + 小护盾"
	if kind == "rain":
		return "夜雨落下：大范围轰炸"
	if kind == "root":
		return "苦藤缠绕：定身 + 伤害"
	if kind == "weaken":
		return "清苦压制：削弱 + 破血"
	if kind == "summon_vine":
		return "老藤守门：重兵驻场"
	return "技能释放"

func _skill_short_hint(kind: String) -> String:
	if kind == "mist":
		return "伤害/强减速"
	if kind == "shield":
		return "范围护盾"
	if kind == "summon_jar":
		return "召坦兵"
	if kind == "shadow":
		return "召突击兵"
	if kind == "heal":
		return "治疗/护盾"
	if kind == "rain":
		return "大范围伤害"
	if kind == "root":
		return "定身/伤害"
	if kind == "weaken":
		return "削弱/破血"
	if kind == "summon_vine":
		return "召重兵"
	return "范围技能"

func _skill_button_text(skill: Dictionary) -> String:
	var kind := String(skill["kind"])
	return "%s %s\n%d能 %s" % [String(skill["name"]), _skill_tag(kind), int(skill["cost"]), _skill_short_hint(kind)]

func _tick_cooldowns(delta: float) -> void:
	for key in deploy_cd_left.keys():
		deploy_cd_left[key] = float(deploy_cd_left[key]) - delta
		if float(deploy_cd_left[key]) <= 0.0:
			deploy_cd_left.erase(key)
	for key in skill_cd_left.keys():
		skill_cd_left[key] = float(skill_cd_left[key]) - delta
		if float(skill_cd_left[key]) <= 0.0:
			skill_cd_left.erase(key)

func _deploy_cd_remaining(card_index: int, troop_index: int) -> float:
	return float(deploy_cd_left.get("%d_%d" % [card_index, troop_index], 0.0))

func _skill_cd_remaining(card_index: int, skill_index: int) -> float:
	return float(skill_cd_left.get("%d_%d" % [card_index, skill_index], 0.0))

func _start_deploy_cd(card_index: int, troop_index: int) -> void:
	var troop: Dictionary = hero_defs[card_index]["troops"][troop_index]
	deploy_cd_left["%d_%d" % [card_index, troop_index]] = float(troop.get("cd", 6.0))

func _start_skill_cd(card_index: int, skill_index: int) -> void:
	var skill: Dictionary = hero_defs[card_index]["skills"][skill_index]
	skill_cd_left["%d_%d" % [card_index, skill_index]] = float(skill.get("cd", 12.0))

func _begin_deploy_troop(card_index: int, troop_index: int) -> void:
	var cd_left := _deploy_cd_remaining(card_index, troop_index)
	if cd_left > 0.0:
		_set_status("「%s」冷却中，还需 %.1f 秒。" % [unit_defs[hero_defs[card_index]["troops"][troop_index]["unit"]]["name"], cd_left])
		return
	var hero: Dictionary = hero_defs[card_index]
	var troop: Dictionary = hero["troops"][troop_index]
	var unit_price := _troop_unit_price(troop)
	if gold + 0.001 < unit_price:
		_set_status("金币不足，%s 需要 %.1f 金币/个。" % [unit_defs[troop["unit"]]["name"], unit_price])
		return
	pending_deploy = {
		"card_index": card_index,
		"troop_index": troop_index,
		"hero_id": String(hero["id"]),
		"placed_count": 0,
		"pressing": false,
		"drag_mode": false,
		"has_last_place": false,
		"last_place_pos": Vector2.ZERO,
		"press_pos": Vector2.ZERO
	}
	deploy_preview_pos = _default_deploy_pos()
	_hide_options()
	_set_status("单击释放整组；按住拖动逐个铺兵。「%s」%.1f金/个，最多%d个。" % [unit_defs[troop["unit"]]["name"], unit_price, int(troop["count"])])
	queue_redraw()

func _try_place_pending_deploy(pos: Vector2) -> bool:
	if pending_deploy.is_empty():
		return false
	deploy_preview_pos = _clamp_deploy_pos(pos)
	if not _player_deploy_rect().has_point(pos):
		_set_status("请单击绿色部署区内的位置。")
		queue_redraw()
		return false
	_commit_pending_deploy_group(deploy_preview_pos)
	return true

func _begin_pending_deploy_press(pos: Vector2) -> bool:
	if pending_deploy.is_empty():
		return false
	deploy_preview_pos = _clamp_deploy_pos(pos)
	if not _player_deploy_rect().has_point(pos):
		_set_status("请单击绿色部署区内的位置。")
		queue_redraw()
		return false
	pending_deploy["pressing"] = true
	pending_deploy["drag_mode"] = false
	pending_deploy["press_pos"] = deploy_preview_pos
	pending_deploy["has_last_place"] = false
	pending_deploy["placed_count"] = 0
	queue_redraw()
	return true

func _update_drag_deploy(pos: Vector2) -> void:
	if pending_deploy.is_empty() or not bool(pending_deploy.get("pressing", false)):
		return
	deploy_preview_pos = _clamp_deploy_pos(pos)
	var press_pos: Vector2 = pending_deploy["press_pos"]
	if not bool(pending_deploy.get("drag_mode", false)) and deploy_preview_pos.distance_to(press_pos) >= 12.0:
		pending_deploy["drag_mode"] = true
		_place_single_pending_unit(press_pos)
	if bool(pending_deploy.get("drag_mode", false)):
		if not bool(pending_deploy.get("has_last_place", false)):
			_place_single_pending_unit(deploy_preview_pos)
			return
		var last_pos: Vector2 = pending_deploy["last_place_pos"]
		if deploy_preview_pos.distance_to(last_pos) >= DEPLOY_DRAG_SPACING:
			_place_single_pending_unit(deploy_preview_pos)

func _finish_pending_deploy_press(pos: Vector2) -> void:
	if pending_deploy.is_empty():
		return
	deploy_preview_pos = _clamp_deploy_pos(pos)
	var drag_mode := bool(pending_deploy.get("drag_mode", false))
	if drag_mode:
		_update_drag_deploy(pos)
		var placed := int(pending_deploy.get("placed_count", 0))
		_set_status("拖动铺兵完成，已释放 %d 个。" % placed)
		pending_deploy.clear()
	else:
		_commit_pending_deploy_group(deploy_preview_pos)
	queue_redraw()

func _place_single_pending_unit(pos: Vector2) -> bool:
	if pending_deploy.is_empty():
		return false
	var card_index := int(pending_deploy["card_index"])
	var troop_index := int(pending_deploy["troop_index"])
	var hero: Dictionary = hero_defs[card_index]
	var troop: Dictionary = hero["troops"][troop_index]
	var max_count := int(troop["count"])
	var placed := int(pending_deploy.get("placed_count", 0))
	var unit_price := _troop_unit_price(troop)
	if placed >= max_count:
		return false
	if gold + 0.001 < unit_price:
		_set_status("金币不足，已释放 %d 个。" % placed)
		return false
	gold -= unit_price
	if placed == 0:
		_start_deploy_cd(card_index, troop_index)
	_spawn_pack_count_at("player", troop, String(hero["id"]), _clamp_deploy_pos(pos), 1)
	placed += 1
	pending_deploy["placed_count"] = placed
	pending_deploy["has_last_place"] = true
	pending_deploy["last_place_pos"] = _clamp_deploy_pos(pos)
	_set_status("%s 铺兵 %d/%d，剩余金币 %.1f。" % [unit_defs[troop["unit"]]["name"], placed, max_count, gold])
	_update_ui()
	return true

func _commit_pending_deploy_group(pos: Vector2) -> void:
	if pending_deploy.is_empty():
		return
	var card_index := int(pending_deploy["card_index"])
	var troop_index := int(pending_deploy["troop_index"])
	var hero: Dictionary = hero_defs[card_index]
	var troop: Dictionary = hero["troops"][troop_index]
	var unit_price := _troop_unit_price(troop)
	var max_count := int(troop["count"])
	var count: int = min(max_count, int(floor((gold + 0.001) / unit_price)))
	if count <= 0:
		_set_status("金币不足，部署取消。")
		pending_deploy.clear()
		return
	var total_cost := unit_price * float(count)
	gold -= total_cost
	_start_deploy_cd(card_index, troop_index)
	_spawn_pack_count_at("player", troop, String(hero["id"]), _clamp_deploy_pos(pos), count)
	_set_status("%s 在指定位置派出「%s」x%d，消耗 %.1f 金。" % [hero["name"], unit_defs[troop["unit"]]["name"], count, total_cost])
	pending_deploy.clear()
	_update_ui()
	queue_redraw()

func _troop_unit_price(troop: Dictionary) -> float:
	return float(troop["cost"]) / max(1.0, float(troop["count"]))

func _deploy_player_troop(card_index: int, troop_index: int) -> void:
	var hero: Dictionary = hero_defs[card_index]
	var troop: Dictionary = hero["troops"][troop_index]
	if _deploy_cd_remaining(card_index, troop_index) > 0.0:
		_set_status("「%s」冷却中，还需 %.1f 秒。" % [unit_defs[troop["unit"]]["name"], _deploy_cd_remaining(card_index, troop_index)])
		return
	var unit_price := _troop_unit_price(troop)
	var max_count := int(troop["count"])
	var count: int = min(max_count, int(floor((gold + 0.001) / unit_price)))
	if count <= 0:
		_set_status("金币不足，%s 需要 %.1f 金币/个。" % [unit_defs[troop["unit"]]["name"], unit_price])
		return
	var total_cost := unit_price * float(count)
	gold -= total_cost
	_start_deploy_cd(card_index, troop_index)
	_spawn_pack_count_at("player", troop, String(hero["id"]), _default_deploy_pos(), count)
	_set_status("%s 派出「%s」x%d，消耗 %.1f 金。" % [hero["name"], unit_defs[troop["unit"]]["name"], count, total_cost])
	_hide_options()

func _cast_player_skill(card_index: int, skill_index: int) -> void:
	_cast_player_skill_at(card_index, skill_index, _default_skill_pos(card_index, skill_index))

func _default_skill_pos(card_index: int, skill_index: int) -> Vector2:
	var hero: Dictionary = hero_defs[card_index]
	var skill: Dictionary = hero["skills"][skill_index]
	var kind := String(skill["kind"])
	if kind in ["shield", "heal"]:
		return _frontline_point("player")
	if kind in ["summon_jar", "shadow", "summon_vine"]:
		return _default_deploy_pos()
	return _frontline_point("enemy")

func _begin_cast_skill(card_index: int, skill_index: int) -> void:
	var hero: Dictionary = hero_defs[card_index]
	var skill: Dictionary = hero["skills"][skill_index]
	if _skill_cd_remaining(card_index, skill_index) > 0.0:
		_set_status("「%s」冷却中，还需 %.1f 秒。" % [skill["name"], _skill_cd_remaining(card_index, skill_index)])
		return
	var cost := float(skill["cost"])
	if energy + 0.001 < cost:
		_set_status("能量不足，%s 需要 %d 点。" % [skill["name"], int(cost)])
		return
	pending_skill = {
		"card_index": card_index,
		"skill_index": skill_index,
		"hero_id": String(hero["id"])
	}
	pending_deploy.clear()
	skill_preview_pos = _default_skill_pos(card_index, skill_index)
	_hide_options()
	_set_status("单击战场释放「%s」：%s。" % [skill["name"], _skill_hint(String(skill["kind"]))])
	queue_redraw()

func _try_cast_pending_skill(pos: Vector2) -> bool:
	if pending_skill.is_empty():
		return false
	skill_preview_pos = _clamp_skill_pos(pos)
	if not FIELD_RECT.has_point(pos):
		_set_status("请单击战场区域内的位置释放技能。")
		queue_redraw()
		return false
	_commit_pending_skill()
	return true

func _commit_pending_skill() -> void:
	if pending_skill.is_empty():
		return
	var card_index := int(pending_skill["card_index"])
	var skill_index := int(pending_skill["skill_index"])
	_cast_player_skill_at(card_index, skill_index, skill_preview_pos)
	pending_skill.clear()
	_update_ui()
	queue_redraw()

func _cast_player_skill_at(card_index: int, skill_index: int, cast_pos: Vector2) -> void:
	var hero: Dictionary = hero_defs[card_index]
	var skill: Dictionary = hero["skills"][skill_index]
	if _skill_cd_remaining(card_index, skill_index) > 0.0:
		_set_status("「%s」冷却中，还需 %.1f 秒。" % [skill["name"], _skill_cd_remaining(card_index, skill_index)])
		return
	var cost := float(skill["cost"])
	if energy + 0.001 < cost:
		_set_status("能量不足，%s 需要 %d 点。" % [skill["name"], int(cost)])
		return
	energy -= cost
	_start_skill_cd(card_index, skill_index)
	var kind := String(skill["kind"])
	var effect_center := _clamp_skill_pos(cast_pos)
	if kind == "mist":
		_damage_enemies(_skill_radius(kind), 64.0, 3.6, effect_center)
		_add_skill_visual("mist", effect_center, flavor_defs[hero["flavor"]]["color"])
	elif kind == "shield":
		_shield_player_units(98.0, effect_center, _skill_radius(kind))
		_add_skill_visual("shield_wave", effect_center, flavor_defs[hero["flavor"]]["color"])
	elif kind == "summon_jar":
		_spawn_pack_at("player", {"unit": "jar_guard", "count": 2, "formation": "line", "free_cast": true}, String(hero["id"]), effect_center)
		_add_skill_visual("summon", effect_center, flavor_defs[hero["flavor"]]["color"])
	elif kind == "shadow":
		_spawn_pack_at("player", {"unit": "sesame_shadow", "count": 4, "formation": "split", "free_cast": true}, String(hero["id"]), effect_center)
		_add_skill_visual("shadow", effect_center, flavor_defs[hero["flavor"]]["color"])
	elif kind == "heal":
		for i in range(units.size()):
			if String(units[i]["side"]) == "player" and (units[i]["pos"] as Vector2).distance_to(effect_center) <= _skill_radius(kind) + float(units[i]["radius"]):
				units[i]["hp"] = min(float(units[i]["max_hp"]), float(units[i]["hp"]) + 54.0)
				units[i]["shield"] = max(float(units[i].get("shield", 0.0)), 24.0)
				_add_text((units[i]["pos"] as Vector2) + Vector2(-15.0, -19.0), "+54", Color("#725f39"))
		_add_skill_visual("heal", effect_center, flavor_defs[hero["flavor"]]["color"])
	elif kind == "rain":
		_damage_enemies(_skill_radius(kind), 56.0, 1.8, effect_center)
		_add_skill_visual("rain", effect_center, flavor_defs[hero["flavor"]]["color"])
	elif kind == "root":
		_root_enemies_in_radius(effect_center, _skill_radius(kind), 6.0)
		_damage_enemies(_skill_radius(kind), 24.0, 4.6, effect_center)
		_add_skill_visual("root", effect_center, flavor_defs[hero["flavor"]]["color"])
	elif kind == "weaken":
		for i in range(units.size()):
			if String(units[i]["side"]) == "enemy" and (units[i]["pos"] as Vector2).distance_to(effect_center) <= _skill_radius(kind) + float(units[i]["radius"]):
				units[i]["weaken_timer"] = 7.5
				units[i]["hp"] = float(units[i]["hp"]) - 20.0
				units[i]["hit_flash"] = 0.16
				_add_text((units[i]["pos"] as Vector2) + Vector2(7.0, -18.0), "-20 弱", Color("#3f342d"))
		_add_skill_visual("weaken", effect_center, flavor_defs[hero["flavor"]]["color"])
	elif kind == "summon_vine":
		_spawn_pack_at("player", {"unit": "old_vine", "count": 2, "formation": "line", "free_cast": true}, String(hero["id"]), effect_center)
		_add_skill_visual("vine", effect_center, flavor_defs[hero["flavor"]]["color"])
	var flavor: Dictionary = flavor_defs[hero["flavor"]]
	_add_effect(effect_center, flavor["color"], "skill")
	_add_text(effect_center + Vector2(-86.0, -_skill_radius(kind) * 0.42), _skill_result_text(kind), flavor["ink"])
	_set_status("%s 释放「%s」：%s。" % [hero["name"], skill["name"], _skill_result_text(kind)])
	cutin_timer = CUTIN_DURATION
	cutin_hero_index = card_index
	cutin_skill_name = String(skill["name"])
	cutin_is_boss = false
	_play_sfx("skill", 0.03)
	_add_screen_shake(4.0)
	_add_hitstop(0.05)
	_hide_options()

func _cast_boss_skill(skill_index: int) -> void:
	var skill: Dictionary = boss_def["skills"][skill_index]
	var kind := String(skill["kind"])
	if kind == "boss_dash":
		_spawn_enemy_wave({"unit": "pepper_imp", "count": 4, "formation": "split"}, "boss")
	elif kind == "boss_barrage":
		_damage_players(999.0, 20.0, 1.4, Vector2(195, 342))
		_add_skill_visual("boss_barrage", Vector2(195, 342), flavor_defs["spicy"]["color"])
	elif kind == "boss_summon":
		_spawn_enemy_wave({"unit": "pepper_jar", "count": 1, "formation": "point"}, "boss")
		_spawn_enemy_wave({"unit": "fire_skewer", "count": 2, "formation": "line"}, "boss")
	_add_effect(Vector2(195.0, ENEMY_SPAWN_Y + 22.0), flavor_defs["spicy"]["color"], "skill")
	_set_status("敌方 Boss 释放「%s」" % skill["name"])
	cutin_timer = CUTIN_DURATION
	cutin_hero_index = -1
	cutin_skill_name = String(skill["name"])
	cutin_is_boss = true
	_play_sfx("boss_skill", 0.02)
	_add_screen_shake(7.0)
	_add_hitstop(0.1)

func _add_boss_warning(skill_index: int) -> void:
	var skill: Dictionary = boss_def["skills"][skill_index]
	var kind := String(skill["kind"])
	# 预警分两类：召唤技(突袭/号令)=援军来袭提示；齐射=全场受击提示
	var mode := "reinforce" if (kind == "boss_dash" or kind == "boss_summon") else "aoe"
	effects.append({
		"pos": FIELD_RECT.get_center(),
		"color": flavor_defs["spicy"]["color"],
		"time": 3.0,
		"max_time": 3.0,
		"radius": 0.0,
		"kind": "boss_warning",
		"warn_mode": mode,
		"text": String(skill["name"])
	})
	_play_sfx("boss_warning", 0.0)

func _damage_enemies(radius: float, damage: float, slow: float, center: Vector2) -> void:
	if boss_hp > 0.0 and BOSS_POS.distance_to(center) <= radius + BOSS_RADIUS:
		_damage_boss(damage, Color("#9fc978"), "技能击败敌方中线英雄，胜利！")
	for i in range(units.size()):
		if String(units[i]["side"]) != "enemy":
			continue
		if (units[i]["pos"] as Vector2).distance_to(center) <= radius:
			units[i]["hp"] = float(units[i]["hp"]) - damage
			units[i]["slow_timer"] = max(float(units[i].get("slow_timer", 0.0)), slow)
			units[i]["hit_flash"] = 0.16
			_add_effect(units[i]["pos"], Color("#9fc978"), "hit")
			_add_text((units[i]["pos"] as Vector2) + Vector2(7.0, -18.0), "-%d 慢" % int(round(damage)), Color("#405131"))

func _damage_players(radius: float, damage: float, slow: float, center: Vector2) -> void:
	for i in range(units.size()):
		if String(units[i]["side"]) != "player":
			continue
		if (units[i]["pos"] as Vector2).distance_to(center) <= radius:
			units[i]["hp"] = float(units[i]["hp"]) - damage
			units[i]["slow_timer"] = max(float(units[i].get("slow_timer", 0.0)), slow)
			units[i]["hit_flash"] = 0.16
			_add_effect(units[i]["pos"], Color("#d85f3f"), "hit")
			_add_text((units[i]["pos"] as Vector2) + Vector2(7.0, -18.0), "-%d" % int(round(damage)), Color("#8d3427"))

func _shield_player_units(amount: float, center: Vector2, radius: float) -> void:
	for i in range(units.size()):
		if String(units[i]["side"]) == "player" and (units[i]["pos"] as Vector2).distance_to(center) <= radius + float(units[i]["radius"]):
			units[i]["shield"] = max(float(units[i].get("shield", 0.0)), amount)
			_add_effect(units[i]["pos"], Color("#d2b271"), "shield")
			_add_text((units[i]["pos"] as Vector2) + Vector2(-12.0, -18.0), "盾", Color("#725f39"))

func _root_enemies_in_radius(center: Vector2, radius: float, duration: float) -> void:
	for i in range(units.size()):
		if String(units[i]["side"]) != "enemy":
			continue
		if (units[i]["pos"] as Vector2).distance_to(center) <= radius + float(units[i]["radius"]):
			units[i]["slow_timer"] = max(float(units[i].get("slow_timer", 0.0)), duration)
			_add_effect(units[i]["pos"], Color("#748b47"), "shield")
			_add_text((units[i]["pos"] as Vector2) + Vector2(-12.0, -18.0), "缠", Color("#405131"))

func _root_fast_enemies(duration: float) -> void:
	var sorted: Array = []
	for i in range(units.size()):
		if String(units[i]["side"]) == "enemy":
			sorted.append(i)
	sorted.sort_custom(func(a: int, b: int) -> bool:
		return float(units[a]["speed"]) > float(units[b]["speed"])
	)
	for n in range(min(5, sorted.size())):
		units[sorted[n]]["slow_timer"] = duration
		_add_effect(units[sorted[n]]["pos"], Color("#748b47"), "shield")

func _frontline_point(side: String) -> Vector2:
	var found := false
	var point := Vector2(195, 342)
	for unit in units:
		if String(unit["side"]) != side:
			continue
		if not found:
			point = unit["pos"]
			found = true
		elif side == "enemy" and unit["pos"].y > point.y:
			point = unit["pos"]
		elif side == "player" and unit["pos"].y < point.y:
			point = unit["pos"]
	return point

func _source_color(source: String, side: String) -> Color:
	if side == "enemy":
		return flavor_defs[boss_def["flavor"]]["color"]
	for hero in hero_defs:
		if String(hero["id"]) == source:
			return flavor_defs[hero["flavor"]]["color"]
	return Color("#d8b158")

func _update_feedback(delta: float) -> void:
	var target_panel := 1.0 if selected_card >= 0 else 0.0
	panel_anim = move_toward(panel_anim, target_panel, delta * 8.0)
	for index in range(card_press.size()):
		card_press[index] = move_toward(card_press[index], 0.0, delta * 8.0)
		card_flash[index] = move_toward(card_flash[index], 0.0, delta * 4.4)
	for index in range(effects.size() - 1, -1, -1):
		effects[index]["time"] = float(effects[index]["time"]) - delta
		effects[index]["radius"] = float(effects[index]["radius"]) + 38.0 * delta
		if float(effects[index]["time"]) <= 0.0:
			effects.remove_at(index)
	for index in range(texts.size() - 1, -1, -1):
		texts[index]["time"] = float(texts[index]["time"]) - delta
		texts[index]["pos"] = (texts[index]["pos"] as Vector2) + Vector2(0, -24 * delta)
		if float(texts[index]["time"]) <= 0.0:
			texts.remove_at(index)

func _update_ui() -> void:
	resource_label.text = ""
	status_label.text = ""
	resource_label.visible = false
	status_label.visible = false
	_layout_card_buttons()
	for button in card_buttons:
		button.disabled = game_over
	if selected_card >= 0:
		_update_option_buttons()

func _hand_start_x(card_w: float, gap: float) -> float:
	return (SCREEN_SIZE.x - card_w * CARD_COUNT - gap * float(CARD_COUNT - 1)) * 0.5

func _layout_card_buttons() -> void:
	if card_buttons.is_empty():
		return
	var compact := selected_card >= 0
	var card_size := MINI_CARD_SIZE if compact else HAND_CARD_SIZE
	var gap := 10.0 if compact else HAND_CARD_GAP
	var start_x := _hand_start_x(card_size.x, gap)
	var y := MINI_CARD_Y if compact else HAND_CARD_Y
	for index in range(card_buttons.size()):
		card_buttons[index].position = Vector2(start_x + index * (card_size.x + gap), y)
		card_buttons[index].size = card_size

func _on_card_button_down(index: int) -> void:
	if index >= 0 and index < card_press.size():
		card_press[index] = 1.0

func _on_card_button_up(index: int) -> void:
	if index >= 0 and index < card_press.size():
		card_press[index] = 0.0
		card_flash[index] = 1.0

func _on_card_pressed(index: int) -> void:
	if game_over:
		return
	if not pending_deploy.is_empty():
		pending_deploy.clear()
	if not pending_skill.is_empty():
		pending_skill.clear()
	selected_card = -1 if selected_card == index else index
	if selected_card >= 0:
		_show_options(index)
	else:
		_hide_options()
	card_flash[index] = 1.0

func _show_options(card_index: int) -> void:
	selected_card = card_index
	_play_sfx("click", 0.0)
	_update_option_buttons()
	for button in option_buttons:
		button.visible = true
	_position_option_buttons()
	_set_status("选择 %s 的派兵或技能。" % hero_defs[card_index]["name"])

func _update_option_buttons() -> void:
	if selected_card < 0:
		return
	var hero: Dictionary = hero_defs[selected_card]
	for i in range(3):
		var troop: Dictionary = hero["troops"][i]
		var unit: Dictionary = unit_defs[troop["unit"]]
		var unit_price := _troop_unit_price(troop)
		var deploy_cd := _deploy_cd_remaining(selected_card, i)
		if deploy_cd > 0.0:
			option_buttons[i].text = "派兵 %s\n冷却 %.1fs" % [unit["name"], deploy_cd]
		else:
			option_buttons[i].text = "派兵 %s\nx%d  %.1f金/个" % [unit["name"], int(troop["count"]), unit_price]
		option_buttons[i].disabled = gold + 0.001 < unit_price or deploy_cd > 0.0
		_set_option_button_style(option_buttons[i], false, option_buttons[i].disabled)
	for i in range(3):
		var skill: Dictionary = hero["skills"][i]
		var button := option_buttons[i + 3]
		var skill_cd := _skill_cd_remaining(selected_card, i)
		if skill_cd > 0.0:
			button.text = "%s %s\n冷却 %.1fs" % [String(skill["name"]), _skill_tag(String(skill["kind"])), skill_cd]
		else:
			button.text = _skill_button_text(skill)
		button.disabled = energy + 0.001 < float(skill["cost"]) or skill_cd > 0.0
		_set_option_button_style(button, true, button.disabled)
	for overlay in option_cd_overlays:
		overlay.queue_redraw()

func _set_option_button_style(button: Button, is_skill: bool, is_disabled: bool) -> void:
	var fill := Color("#eef7df") if not is_skill else Color("#e6f0fb")
	var border := Color("#6f914b") if not is_skill else Color("#4f789f")
	if is_disabled:
		fill = Color("#d9d0bf")
		border = Color("#9a8d7b")
	button.add_theme_stylebox_override("normal", _button_style(fill, border))
	button.add_theme_stylebox_override("hover", _button_style(fill.lightened(0.08), border.lightened(0.12)))
	button.add_theme_stylebox_override("pressed", _button_style(fill.darkened(0.08), border))

func _position_option_buttons() -> void:
	for i in range(6):
		var col := 0 if i < 3 else 1
		var row := i if i < 3 else i - 3
		option_buttons[i].size = Vector2(110, 34)
		option_buttons[i].position = Vector2(142 + col * 118.0, 680 + row * 34.0)

func _hide_options() -> void:
	selected_card = -1
	for button in option_buttons:
		button.visible = false

func _on_option_pressed(index: int) -> void:
	if selected_card < 0:
		return
	if index < 3:
		_begin_deploy_troop(selected_card, index)
	else:
		_begin_cast_skill(selected_card, index - 3)

func _set_status(text: String) -> void:
	status_text = text

func _load_art_assets() -> void:
	hero_textures.clear()
	battle_bg_texture = ResourceLoader.load("res://assets/backgrounds/bg_battle_base_food_wuxia.png") as Texture2D
	enemy_gate_overlay_texture = ResourceLoader.load("res://assets/backgrounds/bg_enemy_gate_overlay.png") as Texture2D
	player_deploy_overlay_texture = ResourceLoader.load("res://assets/backgrounds/bg_player_deploy_overlay.png") as Texture2D
	unit_sprite_textures.clear()
	unit_dir_textures.clear()
	for sprite_uid in UNIT_SPRITE_DEFS:
		var sprite_def: Dictionary = UNIT_SPRITE_DEFS[sprite_uid]
		var loaded := {}
		var walk_tex := ResourceLoader.load(String(sprite_def["walk"])) as Texture2D
		var attack_tex := ResourceLoader.load(String(sprite_def["attack"])) as Texture2D
		if walk_tex:
			loaded["walk"] = walk_tex
		if attack_tex:
			loaded["attack"] = attack_tex
		if not loaded.is_empty():
			unit_sprite_textures[sprite_uid] = loaded
		# 多向精灵图（按需，缺图回退单视角）
		var dir_loaded := {}
		var dir_walk_path := String(sprite_def.get("dir_walk", ""))
		var dir_attack_path := String(sprite_def.get("dir_attack", ""))
		if not dir_walk_path.is_empty() and ResourceLoader.exists(dir_walk_path):
			var dw := ResourceLoader.load(dir_walk_path) as Texture2D
			if dw:
				dir_loaded["walk"] = dw
		if not dir_attack_path.is_empty() and ResourceLoader.exists(dir_attack_path):
			var da := ResourceLoader.load(dir_attack_path) as Texture2D
			if da:
				dir_loaded["attack"] = da
		if not dir_loaded.is_empty():
			unit_dir_textures[sprite_uid] = dir_loaded
	# QA 兼容字段
	crumb_walk_texture = unit_sprite_textures.get("crumb", {}).get("walk")
	crumb_attack_texture = unit_sprite_textures.get("crumb", {}).get("attack")
	boss_portrait_texture = ResourceLoader.load("res://assets/enemies/boss_pepper_portrait.png") as Texture2D
	boss_body_texture = ResourceLoader.load("res://assets/enemies/boss_body_main.png") as Texture2D
	boss_skewer_texture = ResourceLoader.load("res://assets/enemies/boss_skewer.png") as Texture2D
	hit_spark_texture = ResourceLoader.load("res://assets/effects/hit_spark_sheet.png") as Texture2D
	boss_aura_texture = ResourceLoader.load("res://assets/effects/fx_boss_aura_sheet.png") as Texture2D
	boss_barrage_burst_texture = ResourceLoader.load("res://assets/effects/fx_boss_barrage_burst.png") as Texture2D
	smoke_puff_texture = _build_smoke_puff_texture()
	skill_fx_textures.clear()
	for fx_kind in ["mist", "shield_wave", "summon", "shadow", "heal", "rain", "root", "weaken", "vine"]:
		var fx_texture := ResourceLoader.load("res://assets/effects/fx_%s_sheet.png" % fx_kind) as Texture2D
		if fx_texture:
			skill_fx_textures[fx_kind] = fx_texture
	for hero in hero_defs:
		var path := String(hero.get("portrait", ""))
		if path.is_empty():
			continue
		var texture := ResourceLoader.load(path) as Texture2D
		if texture:
			hero_textures[String(hero["id"])] = texture

# 软边径向渐隐圆贴图：烟雾团基元（draw_circle 是硬边，画不出柔软烟雾）
func _build_smoke_puff_texture() -> Texture2D:
	var side := 64
	var image := Image.create(side, side, false, Image.FORMAT_RGBA8)
	var center := Vector2(side * 0.5, side * 0.5)
	for y in range(side):
		for x in range(side):
			var dist := Vector2(x + 0.5, y + 0.5).distance_to(center) / (side * 0.5)
			var falloff: float = clampf(1.0 - dist, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, pow(falloff, 1.8)))
	return ImageTexture.create_from_image(image)

func _hero_texture(hero: Dictionary) -> Texture2D:
	return hero_textures.get(String(hero["id"]), null) as Texture2D

func _load_sfx() -> void:
	sfx_streams.clear()
	for sfx_name in SFX_VOLUMES:
		var variants: Array = []
		for i in range(8):
			var path := "res://assets/sfx/sfx_%s_%d.wav" % [sfx_name, i]
			if not ResourceLoader.exists(path):
				break
			var stream := ResourceLoader.load(path) as AudioStream
			if stream:
				variants.append(stream)
		if variants.is_empty():
			# 兼容旧单文件命名
			var legacy := ResourceLoader.load("res://assets/sfx/sfx_%s.wav" % sfx_name) as AudioStream
			if legacy:
				variants.append(legacy)
		if not variants.is_empty():
			sfx_streams[sfx_name] = variants
	for player in sfx_players:
		player.queue_free()
	sfx_players.clear()
	for i in range(8):
		var player := AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)
	if bgm_player == null:
		bgm_player = AudioStreamPlayer.new()
		add_child(bgm_player)
	var bgm := ResourceLoader.load("res://assets/music/bgm_battle.mp3") as AudioStreamMP3
	if bgm:
		bgm.loop = true
		bgm_player.stream = bgm
		bgm_player.volume_db = -16.0

func _play_sfx(sfx_name: String, pitch_jitter := 0.06) -> void:
	if not sfx_streams.has(sfx_name):
		return
	var now := Time.get_ticks_msec()
	if now - int(sfx_cooldowns.get(sfx_name, -1000)) < 60:
		return
	sfx_cooldowns[sfx_name] = now
	var variants: Array = sfx_streams[sfx_name]
	for player in sfx_players:
		if not player.playing:
			player.stream = variants[rng.randi_range(0, variants.size() - 1)]
			player.volume_db = float(SFX_VOLUMES.get(sfx_name, -10.0))
			player.pitch_scale = 1.0 + rng.randf_range(-pitch_jitter, pitch_jitter)
			player.play()
			return

func _draw_texture_cover(texture: Texture2D, rect: Rect2, modulate := Color.WHITE) -> void:
	var tex_size := Vector2(texture.get_width(), texture.get_height())
	if tex_size.x <= 0.0 or tex_size.y <= 0.0 or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var src := Rect2(Vector2.ZERO, tex_size)
	var src_aspect := tex_size.x / tex_size.y
	var dst_aspect := rect.size.x / rect.size.y
	if src_aspect > dst_aspect:
		var crop_w := tex_size.y * dst_aspect
		src.position.x = (tex_size.x - crop_w) * 0.5
		src.size.x = crop_w
	else:
		var crop_h := tex_size.x / dst_aspect
		src.position.y = (tex_size.y - crop_h) * 0.5
		src.size.y = crop_h
	draw_texture_rect_region(texture, rect, src, modulate)

func _scaled_rect(rect: Rect2, scale: float, y_offset := 0.0) -> Rect2:
	var center := rect.get_center() + Vector2(0, y_offset)
	var size := rect.size * scale
	return Rect2(center - size * 0.5, size)

func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("#efe8db"), true)
	if battle_bg_texture:
		_draw_texture_cover(battle_bg_texture, FIELD_RECT, Color(1, 1, 1, 0.9))
		draw_rect(FIELD_RECT, Color(1.0, 0.957, 0.86, 0.18), true)
	else:
		draw_rect(FIELD_RECT, Color("#f8f1df"), true)
	if enemy_gate_overlay_texture:
		var enemy_overlay_rect := Rect2(FIELD_RECT.position.x, FIELD_RECT.position.y, FIELD_RECT.size.x, 108.0)
		_draw_texture_cover(enemy_gate_overlay_texture, enemy_overlay_rect, Color(1, 1, 1, 0.9))
	if player_deploy_overlay_texture:
		var overlay_rect := Rect2(FIELD_RECT.position.x, FIELD_RECT.end.y - 126.0, FIELD_RECT.size.x, 126.0)
		_draw_texture_cover(player_deploy_overlay_texture, overlay_rect, Color(1, 1, 1, 0.88))
	draw_rect(FIELD_RECT, Color("#846c58"), false, 2.0)
	_draw_entry_zones()
	_draw_tutorial_hint()
	_draw_deploy_zone()
	_draw_boss_hud()
	_draw_resource_bars()

# 环境氛围层：暖光呼吸 + 飘浮微尘，让静态战场有空气流动感（画在背景之上、角色之下）
func _draw_ambient() -> void:
	# 光线呼吸：整片战场一层极淡暖光缓慢明灭，模拟日光浮动
	var breathe := 0.5 + 0.5 * sin(elapsed * 0.55)
	draw_rect(FIELD_RECT, Color(1.0, 0.95, 0.78, 0.035 + 0.03 * breathe), true)
	# 顶部柔和光晕：随呼吸略涨落，给画面一个光源方向
	var glow_center := Vector2(FIELD_RECT.position.x + FIELD_RECT.size.x * 0.5, FIELD_RECT.position.y + 34.0)
	for i in range(3):
		draw_circle(glow_center, 150.0 + float(i) * 66.0, Color(1.0, 0.93, 0.72, 0.016 + 0.01 * breathe))
	# 飘浮微粒：孢子/微尘自下而上缓升、横向摇曳、明灭闪烁
	var mote_count := 26
	for i in range(mote_count):
		var fi := float(i)
		var speed := 7.0 + fmod(fi * 13.1, 9.0)
		var span := FIELD_RECT.size.y + 40.0
		var prog := fmod(elapsed * speed / span + fi * 0.137, 1.0)
		var y := FIELD_RECT.end.y + 20.0 - prog * span
		if y < FIELD_RECT.position.y or y > FIELD_RECT.end.y:
			continue
		var base_x := FIELD_RECT.position.x + fmod(fi * 53.7, FIELD_RECT.size.x)
		var sway := sin(elapsed * (0.5 + fmod(fi, 3.0) * 0.3) + fi) * (8.0 + fmod(fi, 4.0) * 4.0)
		var x: float = clamp(base_x + sway, FIELD_RECT.position.x + 4.0, FIELD_RECT.end.x - 4.0)
		var edge_fade: float = clamp(min(y - FIELD_RECT.position.y, FIELD_RECT.end.y - y) / 50.0, 0.0, 1.0)
		var twinkle := 0.45 + 0.55 * (0.5 + 0.5 * sin(elapsed * 2.0 + fi * 1.7))
		var sz := 1.2 + fmod(fi * 7.3, 2.0)
		# 草木孢子配色：抹茶绿为主、蜂蜜琥珀点缀，在浅米色场地上才有对比；亮米色背景下纯白看不见
		var core := Color(0.55, 0.69, 0.36)
		if int(fi) % 3 == 0:
			core = Color(0.84, 0.62, 0.28)
		var a := twinkle * edge_fade
		# 柔光 halo + 实心核心，飘浮发光的孢子感
		draw_circle(Vector2(x, y), sz * 2.3, Color(core.r, core.g, core.b, 0.10 * a))
		draw_circle(Vector2(x, y), sz, Color(core.r, core.g, core.b, 0.34 * a))

func _draw_entry_zones() -> void:
	var enemy_y := FIELD_RECT.position.y + 18.0
	var player_y := FIELD_RECT.end.y - 22.0
	for i in range(5):
		var alpha := 0.08 - float(i) * 0.012
		draw_rect(Rect2(FIELD_RECT.position.x, FIELD_RECT.position.y + float(i) * 8.0, FIELD_RECT.size.x, 8.0), Color(0.85, 0.42, 0.24, alpha), true)
		draw_rect(Rect2(FIELD_RECT.position.x, FIELD_RECT.end.y - float(i + 1) * 9.0, FIELD_RECT.size.x, 9.0), Color(0.38, 0.66, 0.34, alpha), true)
	draw_line(Vector2(FIELD_RECT.position.x + 16.0, enemy_y), Vector2(FIELD_RECT.end.x - 16.0, enemy_y + 7.0), Color("#b7473566"), 2.0)
	draw_line(Vector2(FIELD_RECT.position.x + 16.0, player_y), Vector2(FIELD_RECT.end.x - 16.0, player_y - 8.0), Color("#4e934980"), 2.0)
	for i in range(5):
		var x := FIELD_RECT.position.x + 44.0 + float(i) * ((FIELD_RECT.size.x - 88.0) / 4.0)
		draw_line(Vector2(x, enemy_y - 7.0), Vector2(x, enemy_y + 8.0), Color("#b7473588"), 1.5)
		draw_circle(Vector2(x, enemy_y - 9.0), 2.8, Color("#d85f3f99"))
	for i in range(4):
		var x := FIELD_RECT.position.x + 58.0 + float(i) * ((FIELD_RECT.size.x - 116.0) / 3.0)
		draw_arc(Vector2(x, player_y + 3.0), 12.0, PI * 0.12, PI * 0.88, 18, Color("#4e934988"), 1.5)
		draw_circle(Vector2(x, player_y + 3.0), 2.5, Color("#77b66c99"))

func _draw_deploy_zone() -> void:
	var rect := _player_deploy_rect()
	var fill := Color("#78b66c16")
	var border := Color("#5e9a5530")
	if not pending_deploy.is_empty():
		fill = Color("#78b66c2f")
		border = Color("#4e9349aa")
	draw_rect(rect, fill, true)
	draw_rect(rect, border, false, 2.0)
	if not pending_deploy.is_empty():
		draw_string(_font(), rect.position + Vector2(10, 17), "单击整组 / 拖动逐个铺兵", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#405131"))

func _draw_tutorial_hint() -> void:
	if game_over or tutorial_hint_timer <= 0.0:
		return
	if selected_card >= 0 or not pending_deploy.is_empty() or not pending_skill.is_empty():
		return
	var alpha: float = clamp(tutorial_hint_timer / 2.2, 0.0, 1.0)
	var panel := Rect2(34, 536, 322, 42)
	_draw_ink_panel(panel, Color(1.0, 0.969, 0.882, 0.88 * alpha), Color(0.47, 0.38, 0.28, 0.82 * alpha), 10.0, false)
	draw_string(_font(), panel.position + Vector2(0, 16), "1 点英雄卡   2 选派兵/技能   3 点战场释放", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 12, Color(0.29, 0.23, 0.18, alpha))
	draw_string(_font(), panel.position + Vector2(0, 33), "拖动战场可连续布兵，技能会先显示范围预览", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 10, Color(0.42, 0.34, 0.28, alpha))

# 技能 cut-in：玩家立绘色带从左横扫入场、短停、向右扫出；Boss 从右反向扫入（参考格斗/塔防技能卡入演出）
func _draw_skill_cutin() -> void:
	if cutin_timer <= 0.0 or (cutin_hero_index < 0 and not cutin_is_boss):
		return
	var t := CUTIN_DURATION - cutin_timer
	var dir := -1.0 if cutin_is_boss else 1.0
	var offset_x := 0.0
	var band_alpha := 1.0
	if t < 0.16:
		var p: float = t / 0.16
		offset_x = dir * -440.0 * pow(1.0 - p, 2.0)
	elif t < 0.78:
		offset_x = dir * (t - 0.16) * 14.0
	else:
		var p2: float = (t - 0.78) / (CUTIN_DURATION - 0.78)
		offset_x = dir * (8.7 + 440.0 * p2 * p2)
		band_alpha = 1.0 - p2 * 0.5
	var band_color: Color
	var ink: Color
	var texture: Texture2D
	var owner_name := ""
	if cutin_is_boss:
		var spicy: Dictionary = flavor_defs["spicy"]
		band_color = spicy["color"]
		ink = spicy["ink"] if spicy.has("ink") else Color("#8d3427")
		texture = boss_portrait_texture
		owner_name = String(boss_def["name"])
	else:
		var hero: Dictionary = hero_defs[cutin_hero_index]
		var flavor: Dictionary = flavor_defs[hero["flavor"]]
		band_color = flavor["color"]
		ink = flavor["ink"]
		texture = _hero_texture(hero)
		owner_name = String(hero["name"])
	var band_y := 236.0
	var band_h := 72.0
	var skew := 18.0 * dir
	var left := -50.0 + offset_x
	var right := 410.0 + offset_x
	band_color.a = 0.96 * band_alpha
	ink.a = band_alpha
	draw_colored_polygon(PackedVector2Array([
		Vector2(left + skew, band_y), Vector2(right + skew, band_y),
		Vector2(right - skew, band_y + band_h), Vector2(left - skew, band_y + band_h)
	]), band_color)
	draw_line(Vector2(left + skew, band_y), Vector2(right + skew, band_y), ink, 2.0)
	draw_line(Vector2(left - skew, band_y + band_h), Vector2(right - skew, band_y + band_h), ink, 2.0)
	# Boss 立绘与文字靠右排版，与入场方向一致
	var portrait_x := 286.0 if cutin_is_boss else 22.0
	var text_x := 30.0 if cutin_is_boss else 92.0
	var text_align := HORIZONTAL_ALIGNMENT_RIGHT if cutin_is_boss else HORIZONTAL_ALIGNMENT_LEFT
	var portrait := Rect2(Vector2(portrait_x + offset_x, band_y + 4.0), Vector2(52.0, band_h - 8.0))
	draw_rect(portrait.grow(2.0), ink, true)
	if texture:
		_draw_texture_cover(texture, portrait, Color(1, 1, 1, band_alpha))
	else:
		draw_rect(portrait, band_color, true)
	draw_string(_font(), Vector2(text_x + offset_x, band_y + 34.0), cutin_skill_name, text_align, 240, 24, Color(1.0, 0.97, 0.92, band_alpha))
	draw_string(_font(), Vector2(text_x + 2.0 + offset_x, band_y + 56.0), owner_name, text_align, 220, 12, Color(1.0, 0.97, 0.92, 0.85 * band_alpha))

func _draw_deploy_preview() -> void:
	if pending_deploy.is_empty():
		return
	var card_index := int(pending_deploy["card_index"])
	var troop_index := int(pending_deploy["troop_index"])
	var hero: Dictionary = hero_defs[card_index]
	var troop: Dictionary = hero["troops"][troop_index]
	var unit: Dictionary = unit_defs[troop["unit"]]
	var flavor: Dictionary = flavor_defs[hero["flavor"]]
	var points := _formation_points(int(troop["count"]), String(troop.get("formation", "wide")), true)
	var preview_color: Color = unit["color"]
	preview_color.a = 0.68
	var preview_uid := String(troop["unit"])
	for point in points:
		var pos := _clamp_deploy_pos(deploy_preview_pos + point)
		draw_circle(pos + Vector2(0, 8), 9.0, Color(0, 0, 0, 0.12))
		# 有精灵图的兵种预览半透明小兵走路帧首帧，与落地后形象一致
		if unit_sprite_textures.has(preview_uid) and unit_sprite_textures[preview_uid].get("walk"):
			var sprite_def: Dictionary = UNIT_SPRITE_DEFS[preview_uid]
			# 与落地后一致：按 4 档体型规则，避免预览与实际大小不符
			var draw_side: float = _unit_draw_side(unit)
			var size := Vector2(draw_side, draw_side)
			var dst := Rect2(pos - Vector2(size.x * 0.5, size.y * float(sprite_def.get("anchor", 0.78))), size)
			draw_texture_rect_region(unit_sprite_textures[preview_uid]["walk"], dst, Rect2(Vector2.ZERO, Vector2(256, 256)), Color(1.0, 1.0, 1.0, 0.72))
		else:
			draw_circle(pos, float(unit["radius"]), preview_color)
			draw_arc(pos, float(unit["radius"]), 0.0, TAU, 18, flavor["ink"], 1.5)
	var area_color: Color = flavor["color"]
	area_color.a = 0.16
	var ring_color: Color = flavor["ink"]
	ring_color.a = 0.65
	draw_circle(deploy_preview_pos, 28.0, area_color)
	draw_arc(deploy_preview_pos, 28.0, 0.0, TAU, 32, ring_color, 2.0)

func _draw_skill_preview() -> void:
	if pending_skill.is_empty():
		return
	var card_index := int(pending_skill["card_index"])
	var skill_index := int(pending_skill["skill_index"])
	var hero: Dictionary = hero_defs[card_index]
	var skill: Dictionary = hero["skills"][skill_index]
	var kind := String(skill["kind"])
	var flavor: Dictionary = flavor_defs[hero["flavor"]]
	var radius := _skill_radius(kind)
	var fill: Color = flavor["color"]
	fill.a = 0.13
	var ring: Color = flavor["ink"]
	ring.a = 0.72
	draw_circle(skill_preview_pos, radius, fill)
	if kind in ["summon_jar", "shadow", "summon_vine"]:
		draw_rect(Rect2(skill_preview_pos - Vector2(radius, radius * 0.45), Vector2(radius * 2.0, radius * 0.9)), Color(fill.r, fill.g, fill.b, 0.18), true)
		draw_rect(Rect2(skill_preview_pos - Vector2(radius, radius * 0.45), Vector2(radius * 2.0, radius * 0.9)), ring, false, 2.0)
	elif kind == "rain":
		for i in range(7):
			var x := skill_preview_pos.x - radius * 0.55 + i * radius * 0.18
			draw_line(Vector2(x, skill_preview_pos.y - radius * 0.45), Vector2(x - 18.0, skill_preview_pos.y + radius * 0.35), ring, 2.0)
	elif kind == "root":
		for i in range(6):
			var angle := float(i) * TAU / 6.0
			draw_line(skill_preview_pos, skill_preview_pos + Vector2(cos(angle), sin(angle)) * radius * 0.72, ring, 2.0)
	elif kind == "heal":
		draw_line(skill_preview_pos + Vector2(-18, 0), skill_preview_pos + Vector2(18, 0), ring, 4.0)
		draw_line(skill_preview_pos + Vector2(0, -18), skill_preview_pos + Vector2(0, 18), ring, 4.0)
	elif kind == "shield":
		draw_arc(skill_preview_pos, radius * 0.72, -0.6, PI + 0.6, 42, ring, 4.0)
	elif kind == "weaken":
		draw_line(skill_preview_pos + Vector2(-26, -18), skill_preview_pos + Vector2(26, 18), ring, 4.0)
		draw_arc(skill_preview_pos, radius * 0.55, 0.0, TAU, 40, ring, 3.0)
	else:
		draw_arc(skill_preview_pos, radius, 0.0, TAU, 64, ring, 3.0)
	draw_arc(skill_preview_pos, radius, 0.0, TAU, 64, ring, 2.0)
	var label := "%s  %s  半径%.0f" % [_skill_target_text(kind), _skill_hint(kind), radius]
	var label_rect := Rect2(skill_preview_pos + Vector2(-118, -radius - 30), Vector2(236, 22))
	label_rect.position.x = clamp(label_rect.position.x, FIELD_RECT.position.x + 6.0, FIELD_RECT.end.x - label_rect.size.x - 6.0)
	label_rect.position.y = max(FIELD_RECT.position.y + 8.0, label_rect.position.y)
	draw_rect(label_rect, Color("#fff7e8e8"), true)
	draw_rect(label_rect, ring, false, 1.5)
	draw_string(_font(), label_rect.position + Vector2(0, 16), label, HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x, 11, Color("#4b4038"))

# Boss 预警期蓄力进度：0=未蓄力，1=即将释放（取所有已预警技能中最近的）
func _boss_charge_progress() -> float:
	var timers: Array = boss_state.get("skill_timers", [])
	var warned: Array = boss_state.get("skill_warned", [])
	var best := 0.0
	for i in range(min(timers.size(), warned.size())):
		if bool(warned[i]) and float(timers[i]) > 0.0:
			best = max(best, 1.0 - clampf(float(timers[i]) / 3.0, 0.0, 1.0))
	return best

# Boss 全身立绘切件元数据（原图全图坐标 682x1024，由 tmp/split_boss_fullbody.py 产出）
const BOSS_ART_BODY_OFF := Vector2(23, 29)
const BOSS_ART_BODY_SIZE := Vector2(535, 963)
const BOSS_ART_SKEWER_OFF := Vector2(350, 75)
const BOSS_ART_SKEWER_SIZE := Vector2(241, 255)
const BOSS_ART_SKEWER_PIVOT := Vector2(361, 280)
const BOSS_ART_CHAR_CENTER_X := 285.0
const BOSS_ART_CHAR_FOOT_Y := 984.0
const BOSS_ART_CHAR_H := 963.0
const BOSS_CHAR_SCREEN_H := 130.0

# 贴地灼热危险环：替代旧红圈。基线低调阴燃，蓄力(charge)时扩张+变亮+火星沿环翻涌
func _draw_boss_danger_ring(ground_pos: Vector2, charge: float) -> void:
	var ring_xf := Transform2D.IDENTITY.translated(-ground_pos).scaled(Vector2(1.0, 0.42)).translated(ground_pos)
	draw_set_transform_matrix(ring_xf)
	var pulse := 0.5 + 0.5 * sin(elapsed * 3.2)
	var r := BOSS_ATTACK_RANGE * (1.0 + charge * 0.12)
	# 内填充：阴燃热区，蓄力时升温发亮
	draw_circle(ground_pos, r, Color(0.62, 0.18, 0.08, 0.05 + 0.03 * pulse + charge * 0.16))
	# 主环：暗红基线 → 蓄力转炽橙
	var edge := Color(0.78, 0.26, 0.12, 1.0).lerp(Color(1.0, 0.7, 0.3, 1.0), charge)
	edge.a = 0.42 + 0.2 * pulse + charge * 0.35
	draw_arc(ground_pos, r, 0.0, TAU, 72, edge, 2.0 + charge * 2.4)
	# 内圈预警：蓄力时一道炽亮收束环向中心逼近，给"何时落"的读秒感
	if charge > 0.0:
		draw_arc(ground_pos, r * (1.0 - charge * 0.55), 0.0, TAU, 64, Color(1.0, 0.85, 0.5, 0.3 + charge * 0.5), 1.8 + charge * 1.5)
	# 沿环翻涌的火星：基线少而暗，蓄力时多而亮
	var spark_n := 10 + int(charge * 14.0)
	var spin := elapsed * (0.8 + charge * 2.4)
	for i in range(spark_n):
		var a := spin + float(i) * TAU / float(spark_n)
		var jitter := sin((float(i) * 12.9 + floorf(elapsed * 4.0)) * 7.3)
		var sr := r * (0.96 + 0.05 * jitter)
		var sp := ground_pos + Vector2(cos(a), sin(a)) * sr
		draw_circle(sp, 1.4 + charge * 1.8, Color(1.0, 0.74 - 0.2 * (0.5 + 0.5 * jitter), 0.32, 0.4 + charge * 0.5))
	draw_set_transform_matrix(Transform2D.IDENTITY)

func _draw_field_boss() -> void:
	if boss_hp <= 0.0:
		return
	var charge := _boss_charge_progress()
	# 临爆前 0.8s 身体高频抖动
	var boss_pos := BOSS_POS
	if charge > 0.72:
		boss_pos += Vector2(sin(elapsed * 46.0), cos(elapsed * 39.0)) * 2.2 * (charge - 0.72) / 0.28
	var ground_pos := boss_pos + Vector2(0, 30)
	var s := BOSS_CHAR_SCREEN_H / BOSS_ART_CHAR_H
	# 全身像：脚底踩在火焰座中心稍上，前缘火焰会舔到靴子
	var art_origin := Vector2(boss_pos.x - BOSS_ART_CHAR_CENTER_X * s, ground_pos.y + 4.0 - BOSS_ART_CHAR_FOOT_Y * s)
	# 攻击范围：贴地灼热危险环，蓄力时整圈扩张、变亮、火星翻涌
	_draw_boss_danger_ring(ground_pos, charge)
	# 贴地火焰座：把火环贴图压扁成与地面平行的椭圆，前后两半夹住身体
	var base_xf := Transform2D.IDENTITY.translated(-ground_pos).scaled(Vector2(1.0, 0.36)).translated(ground_pos)
	var ring_d: float = 138.0 + charge * 26.0
	var aura_frame := int(floor(elapsed * (8.0 + charge * 8.0))) % 8
	var ring_tint := Color(1.0, 1.0, 1.0, 0.82 + charge * 0.18)
	draw_set_transform_matrix(base_xf)
	draw_circle(ground_pos, 54.0, Color(0, 0, 0, 0.16))
	if boss_aura_texture:
		var ring_dst := Rect2(ground_pos - Vector2(ring_d, ring_d) * 0.5, Vector2(ring_d, ring_d))
		draw_texture_rect_region(boss_aura_texture, ring_dst, Rect2(aura_frame * 128.0, 0.0, 128.0, 128.0), ring_tint)
	# 蓄力收束弧：双层能量弧沿地面椭圆轨道向火焰座收拢
	if charge > 0.0:
		for i in range(3):
			var arc_phase := elapsed * (2.2 + charge * 4.5) + float(i) * TAU / 3.0
			var arc_radius: float = 98.0 - charge * 56.0
			var arc_alpha: float = 0.35 + charge * 0.6
			draw_arc(ground_pos, arc_radius, arc_phase, arc_phase + 1.3, 18, Color(0.553, 0.204, 0.153, arc_alpha), 4.5 + charge * 2.5)
			draw_arc(ground_pos, arc_radius, arc_phase + 0.12, arc_phase + 1.18, 16, Color(1.0, 0.88, 0.6, arc_alpha), 2.0 + charge * 1.5)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	# 火签串层（在身体后面）：绕签杆探出点轻晃，蓄力时晃动加剧
	var skewer_pivot := art_origin + BOSS_ART_SKEWER_PIVOT * s
	var skewer_angle := 0.045 * sin(elapsed * 1.7 + 0.7) + charge * 0.022 * sin(elapsed * 26.0)
	if boss_skewer_texture:
		var skewer_xf := Transform2D.IDENTITY.translated(-skewer_pivot).rotated(skewer_angle).translated(skewer_pivot)
		draw_set_transform_matrix(skewer_xf)
		draw_texture_rect(boss_skewer_texture, Rect2(art_origin + BOSS_ART_SKEWER_OFF * s, BOSS_ART_SKEWER_SIZE * s), false)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	# 身体层：呼吸起伏 + 轻微摇摆（绕脚底中心）
	if boss_body_texture:
		var breathe := 1.0 + 0.016 * sin(elapsed * (2.4 + charge * 5.0))
		var sway := 0.018 * sin(elapsed * 1.3)
		var foot_pivot := Vector2(boss_pos.x, ground_pos.y + 4.0)
		var body_xf := Transform2D.IDENTITY.translated(-foot_pivot).scaled(Vector2(1.0, breathe)).rotated(sway).translated(foot_pivot)
		draw_set_transform_matrix(body_xf)
		draw_texture_rect(boss_body_texture, Rect2(art_origin + BOSS_ART_BODY_OFF * s, BOSS_ART_BODY_SIZE * s), false)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	# 火焰座前缘：只画火环贴图下半部分，盖在身体下缘前面
	if boss_aura_texture:
		draw_set_transform_matrix(base_xf)
		var front_dst := Rect2(ground_pos + Vector2(-ring_d * 0.5, 0.0), Vector2(ring_d, ring_d * 0.5))
		draw_texture_rect_region(boss_aura_texture, front_dst, Rect2(aura_frame * 128.0, 64.0, 128.0, 64.0), ring_tint)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	# 升腾火星：从火焰座沿身体两侧上飘
	for i in range(7):
		var cycle := elapsed * 0.55 + float(i) * 0.1428
		var ph := fmod(cycle, 1.0)
		var seed_v := float(i) * 31.7 + floorf(cycle) * 7.7
		var ex := boss_pos.x + sin(seed_v * 12.9898) * 44.0
		var ey: float = ground_pos.y - 4.0 - ph * (62.0 + sin(seed_v * 3.1) * 18.0)
		var ember_alpha: float = (1.0 - ph) * (0.55 + charge * 0.4)
		var ember_size: float = 1.4 + fmod(seed_v, 1.7)
		draw_circle(Vector2(ex + sin(ph * 9.0 + seed_v) * 5.0, ey), ember_size, Color(1.0, 0.78 - ph * 0.3, 0.32, ember_alpha))
	# 蓄力白热核心：聚在胸口纹章处，越临爆越亮
	if charge > 0.0:
		var chest := art_origin + Vector2(278.0, 495.0) * s
		draw_circle(chest, 9.0 + charge * 14.0, Color(1.0, 0.62, 0.3, 0.05 + charge * 0.2))
		draw_circle(chest, 4.0 + charge * 7.0, Color(1.0, 0.95, 0.85, 0.08 + charge * 0.4))
	# 贴地血条（详细数值在左上 HUD）
	var hp_ratio: float = clamp(boss_hp / BOSS_MAX_HP, 0.0, 1.0)
	var bar := Rect2(ground_pos + Vector2(-36, 24), Vector2(72, 6))
	draw_rect(bar.grow(1.5), Color("#5c4c40"), true)
	draw_rect(bar, Color("#dbcab1"), true)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * hp_ratio, bar.size.y)), Color("#d85f3f"), true)

func _draw_boss_hud() -> void:
	var font := _font()
	var panel := Rect2(8, 10, 236, 42)
	_draw_ink_panel(panel, Color("#fff7e8ee"), Color("#6b5849"))
	var portrait := Rect2(panel.position + Vector2(7, 6), Vector2(30, 30))
	if boss_portrait_texture:
		_draw_texture_cover(boss_portrait_texture, portrait, Color.WHITE)
		draw_rect(portrait, Color("#5d433b"), false, 2.0)
	else:
		draw_rect(portrait, Color("#d85f3f"), true)
		draw_rect(portrait, Color("#5d433b"), false, 2.0)
		draw_circle(portrait.get_center() + Vector2(-3, -2), 7, Color("#f3b35a"))
		draw_line(portrait.get_center() + Vector2(-9, 8), portrait.get_center() + Vector2(9, -8), Color("#fff0d1"), 2.0)
	draw_string(font, panel.position + Vector2(46, 19), String(boss_def["name"]), HORIZONTAL_ALIGNMENT_LEFT, 116, 13, Color("#4d423a"))
	var flavor: Dictionary = flavor_defs[boss_def["flavor"]]
	draw_rect(Rect2(panel.position + Vector2(198, 9), Vector2(28, 20)), flavor["color"], true)
	draw_rect(Rect2(panel.position + Vector2(198, 9), Vector2(28, 20)), Color("#5d433b"), false, 1.0)
	draw_string(font, panel.position + Vector2(205, 25), String(flavor["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#fff8ee"))
	var hp_ratio: float = clamp(boss_hp / BOSS_MAX_HP, 0.0, 1.0)
	_draw_bar(Rect2(panel.position + Vector2(46, 25), Vector2(142, 7)), hp_ratio, Color("#d85f3f"), Color("#d5c4a9"))

	var timer_panel := Rect2(250, 14, 64, 34)
	_draw_ink_panel(timer_panel, Color("#fff7e8ee"), Color("#6b5849"), 8.0, false)
	draw_string(font, timer_panel.position + Vector2(0, 14), "倒计时", HORIZONTAL_ALIGNMENT_CENTER, timer_panel.size.x, 9, Color("#76675d"))
	draw_string(font, timer_panel.position + Vector2(0, 31), "%.0fs" % ceil(survive_left), HORIZONTAL_ALIGNMENT_CENTER, timer_panel.size.x, 15, Color("#4d423a"))

func _draw_resource_bars() -> void:
	var gold_box := Rect2(24, 626, 158, 20)
	var skill_box := Rect2(204, 626, 160, 20)
	_draw_ink_panel(gold_box, Color("#fff7e8df"), Color("#8e7661"), 10.0, false)
	draw_string(_font(), gold_box.position + Vector2(10, 15), "金币 %.1f  派兵" % gold, HORIZONTAL_ALIGNMENT_LEFT, gold_box.size.x - 20, 11, Color("#725f39"))
	_draw_ink_panel(skill_box, Color("#edf5ffdf"), Color("#4f789f"), 10.0, false)
	draw_string(_font(), skill_box.position + Vector2(8, 9), "技能点 %.1f/10" % energy, HORIZONTAL_ALIGNMENT_LEFT, skill_box.size.x - 16, 10, Color("#3f6270"))
	_draw_bar(Rect2(skill_box.position + Vector2(8, 12), Vector2(skill_box.size.x - 16, 6)), energy / RESOURCE_MAX, Color("#8fb5d8"), Color("#c9d5df"))

func _draw_bar(rect: Rect2, ratio: float, fill: Color, back: Color) -> void:
	var radius := int(rect.size.y * 0.5)
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color("#5c4c40")
	frame.set_corner_radius_all(radius + 2)
	frame.draw(get_canvas_item(), rect.grow(2.0))
	var back_style := StyleBoxFlat.new()
	back_style.bg_color = back
	back_style.set_corner_radius_all(radius)
	back_style.draw(get_canvas_item(), rect)
	var fill_width: float = rect.size.x * clamp(ratio, 0.0, 1.0)
	if fill_width > 2.0:
		var fill_style := StyleBoxFlat.new()
		fill_style.bg_color = fill
		fill_style.set_corner_radius_all(radius)
		fill_style.draw(get_canvas_item(), Rect2(rect.position, Vector2(fill_width, rect.size.y)))
		# 顶部高光，体积感
		draw_line(rect.position + Vector2(radius * 0.6, 1.2),
			rect.position + Vector2(fill_width - radius * 0.6, 1.2),
			Color(1.0, 1.0, 1.0, 0.42), 1.0)

# 兵种可辨识：脚环颜色按职责、体型按 tier 放大、血条长度随血量上限
func _unit_role_ring_color(role: String) -> Color:
	match role:
		"ranged":
			return Color("#4f93a6")   # 远程=青
		"skirmish":
			return Color("#cf5a3c")   # 游击=红
		_:
			return Color("#a9824e")   # 前排/坦克=暖棕

# 体型只分 4 档：低等(t1)/中等(t2)/高等(t3)/亡灵，同档统一大小，不按金币逐个微调
const UNIT_SIZE_T1 := 34.0
const UNIT_SIZE_T2 := 50.0
const UNIT_SIZE_T3 := 70.0
const UNIT_SIZE_GHOST := 46.0

func _unit_draw_side(unit: Dictionary) -> float:
	if bool(unit.get("is_ghost", false)):
		return UNIT_SIZE_GHOST
	match int(unit.get("tier", 1)):
		3:
			return UNIT_SIZE_T3
		2:
			return UNIT_SIZE_T2
		_:
			return UNIT_SIZE_T1

# 血条像素宽随 max_hp 拉开：脆皮约 20px，重甲约 40px，一眼看出血量厚薄
func _unit_hp_bar_width(max_hp: float) -> float:
	return clamp(14.0 + max_hp * 0.13, 18.0, 44.0)

func _draw_units() -> void:
	var sorted_units := units.duplicate()
	sorted_units.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return (a["pos"] as Vector2).y < (b["pos"] as Vector2).y
	)
	for unit in sorted_units:
		_draw_unit(unit)

func _draw_unit(unit: Dictionary) -> void:
	var pos: Vector2 = unit["pos"]
	var radius := float(unit["radius"])
	var side := String(unit["side"])
	var color: Color = unit["color"]
	var outline := Color("#55463c")
	var dir := -1.0 if side == "player" else 1.0
	if bool(unit.get("global_seek", false)):
		var trail_color: Color = color
		trail_color.a = 0.26
		# 拖影朝向 = 移动反方向（全图刺客任意方向冲，不再固定竖向）
		var fdir := unit.get("face_dir", Vector2(0.0, -1.0)) as Vector2
		if fdir.length() < 0.01:
			fdir = Vector2(0.0, -1.0)
		fdir = fdir.normalized()
		var back := -fdir
		var perp := Vector2(-back.y, back.x)
		draw_line(pos + back * radius * 2.6, pos, trail_color, 5.0)
		draw_line(pos + back * radius * 1.8 + perp * radius * 0.5, pos, trail_color, 3.0)
	elif String(unit.get("role", "")) == "ranged" and int(unit["id"]) == hovered_unit_id:
		var range_color: Color = color
		range_color.a = 0.2
		draw_circle(pos, float(unit["attack_range"]), Color(range_color.r, range_color.g, range_color.b, 0.08))
		draw_arc(pos, float(unit["attack_range"]), 0.0, TAU, 64, range_color, 2.4)
		draw_string(_font(), pos + Vector2(-38, -float(unit["attack_range"]) - 8), "远程 %.0f" % float(unit["attack_range"]), HORIZONTAL_ALIGNMENT_CENTER, 76, 11, range_color)
	elif int(unit["id"]) == hovered_unit_id:
		var hover_color: Color = color
		hover_color.a = 0.16
		draw_arc(pos, float(unit["attack_range"]), 0.0, TAU, 48, hover_color, 2.0)
	# 统一代码椭圆投影接地（精灵图自带阴影缩放后过淡，不足以提供接地感）
	draw_set_transform(pos + Vector2(0, radius * 0.9), 0.0, Vector2(1.35, 0.34))
	draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.22))
	# 职责脚环：远程=青 / 游击=红 / 前排坦克=暖棕，坦克环更粗以呼应体型
	var ring_col := _unit_role_ring_color(String(unit.get("role", "front")))
	ring_col.a = 0.78
	var ring_w := 2.6 if String(unit.get("role", "")) == "tank" else 1.8
	draw_arc(Vector2.ZERO, radius * 1.18, 0.0, TAU, 28, ring_col, ring_w)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _draw_unit_sprite_if_available(unit, pos, radius, side):
		return
	draw_circle(pos, radius, color)
	if float(unit.get("hit_flash", 0.0)) > 0.0:
		var flash_alpha: float = clamp(float(unit.get("hit_flash", 0.0)) / 0.16, 0.0, 1.0)
		draw_circle(pos, radius * 0.92, Color(1, 1, 1, 0.58 * flash_alpha))
	draw_arc(pos, radius, 0.0, TAU, 20, outline, 2.0)
	draw_circle(pos + Vector2(dir * 2.2, -2.0), max(1.8, radius * 0.18), Color("#2d2926"))
	draw_line(pos + Vector2(-radius * 0.55, radius * 0.18), pos + Vector2(radius * 0.65, radius * 0.18), outline, 2.0)
	if float(unit.get("shield", 0.0)) > 0.0:
		draw_arc(pos, radius + 5.0, -0.4, TAU - 0.4, 26, Color("#f3d783aa"), 2.5)
	if float(unit.get("slow_timer", 0.0)) > 0.0:
		draw_arc(pos, radius + 8.0, 0.4, PI + 0.4, 18, Color("#8bc0d8aa"), 2.0)
	if float(unit.get("weaken_timer", 0.0)) > 0.0:
		draw_line(pos + Vector2(-radius * 0.7, -radius * 0.72), pos + Vector2(radius * 0.72, radius * 0.72), Color("#3f342dcc"), 2.0)
		draw_line(pos + Vector2(radius * 0.72, -radius * 0.72), pos + Vector2(-radius * 0.7, radius * 0.72), Color("#3f342dcc"), 2.0)
	_draw_status_icons(unit, pos, radius)
	_draw_unit_hp_bar(unit, pos, radius, radius + 8.0, side)

# 血条：长度随 max_hp、居中绘制；幽魂用琥珀金，玩家绿、敌军红
func _draw_unit_hp_bar(unit: Dictionary, pos: Vector2, radius: float, lift: float, side: String) -> void:
	var hp_ratio: float = clamp(float(unit["hp"]) / float(unit["max_hp"]), 0.0, 1.0)
	var bar_w := _unit_hp_bar_width(float(unit["max_hp"]))
	var bar_top := pos + Vector2(-bar_w * 0.5, -lift)
	var fill_col := Color("#77b66c") if side == "player" else Color("#d85f3f")
	if bool(unit.get("is_ghost", false)):
		fill_col = Color("#e8b53a")   # 幽魂专属琥珀金血条
	draw_rect(Rect2(bar_top, Vector2(bar_w, 3)), Color("#5e5148"), true)
	draw_rect(Rect2(bar_top, Vector2(bar_w * hp_ratio, 3)), fill_col, true)

# 多向精灵图行布局：0=正(朝下) 1=前斜45° 2=正侧(朝右) 3=后斜45° 4=背(朝上)；左向用水平镜像
# 返回 Vector2i(row, flip)；flip=1 时水平镜像。face_dir 为屏幕坐标(y 向下)
func _facing_to_row_flip(face_dir: Vector2) -> Vector2i:
	if face_dir.length() < 0.001:
		return Vector2i(4, 0)
	var deg := rad_to_deg(atan2(face_dir.y, face_dir.x))
	if deg >= -22.5 and deg < 22.5:
		return Vector2i(2, 0)    # 右 → 正侧
	elif deg >= 22.5 and deg < 67.5:
		return Vector2i(1, 0)    # 右下 → 前斜
	elif deg >= 67.5 and deg < 112.5:
		return Vector2i(0, 0)    # 下 → 正面
	elif deg >= 112.5 and deg < 157.5:
		return Vector2i(1, 1)    # 左下 → 前斜镜像
	elif deg >= 157.5 or deg < -157.5:
		return Vector2i(2, 1)    # 左 → 正侧镜像
	elif deg >= -157.5 and deg < -112.5:
		return Vector2i(3, 1)    # 左上 → 后斜镜像
	elif deg >= -112.5 and deg < -67.5:
		return Vector2i(4, 0)    # 上 → 背面
	else:
		return Vector2i(3, 0)    # 右上 → 后斜

func _dir_attack_motion(phase: float) -> float:
	phase = clampf(phase, 0.0, 1.0)
	if phase < 0.24:
		return lerpf(0.0, -4.2, phase / 0.24)       # 蓄力后撤
	if phase < 0.52:
		return lerpf(-4.2, 8.5, (phase - 0.24) / 0.28) # 突进出手
	return lerpf(8.5, 0.0, (phase - 0.52) / 0.48)   # 回收

func _draw_dir_attack_swoosh(unit: Dictionary, pos: Vector2, radius: float, face_dir: Vector2, phase: float) -> void:
	if phase < 0.22 or phase > 0.68:
		return
	if face_dir.length() < 0.001:
		return
	var fdir := face_dir.normalized()
	var perp := Vector2(-fdir.y, fdir.x)
	var t: float = clampf((phase - 0.22) / 0.46, 0.0, 1.0)
	var alpha := sin(t * PI) * 0.58
	var col: Color = unit.get("color", Color.WHITE)
	col.a = alpha
	var start := pos + fdir * radius * 0.25 - perp * radius * 0.18
	var mid := pos + fdir * radius * 1.35 + perp * radius * 0.28
	var end := pos + fdir * radius * 2.45
	draw_line(start, mid, col, 3.0)
	draw_line(mid, end, Color(1.0, 0.94, 0.72, alpha * 0.85), 1.8)
	draw_circle(end, max(1.4, radius * 0.14), Color(1.0, 0.92, 0.64, alpha))

func _draw_unit_sprite_if_available(unit: Dictionary, pos: Vector2, radius: float, side: String) -> bool:
	var uid := String(unit["unit_id"])
	if not unit_sprite_textures.has(uid):
		return false
	var sprite_def: Dictionary = UNIT_SPRITE_DEFS[uid]
	var texs: Dictionary = unit_sprite_textures[uid]
	var texture: Texture2D = texs.get("walk")
	var frame_count := int(sprite_def.get("walk_frames", 8))
	var frame := int(floor(elapsed * float(sprite_def.get("fps", 7.0)) + float(int(unit["id"]) % frame_count))) % frame_count
	var attacking := String(unit.get("anim_state", "walk")) == "attack" and texs.get("attack") != null
	if attacking:
		texture = texs["attack"]
		frame_count = int(sprite_def.get("attack_frames", 8))
		var attack_time: float = clamp(float(unit.get("attack_anim_time", 0.0)), 0.0, CRUMB_ATTACK_DURATION - 0.001)
		frame = clamp(int(floor(attack_time / CRUMB_ATTACK_DURATION * float(frame_count))), 0, frame_count - 1)
	# 多向精灵：按朝向选行 + 左右镜像（缺多向图时本段不触发，沿用单视角）
	var has_dir := false
	var dir_row := 0
	var dir_flip := false
	if unit_dir_textures.has(uid):
		var dt: Dictionary = unit_dir_textures[uid]
		# 缺方向攻击图时，攻击也用方向行走图（保证朝向正确，不穿帮）
		var use_attack: bool = attacking and dt.has("attack")
		var dtex := (dt.get("attack") if use_attack else dt.get("walk")) as Texture2D
		if dtex != null:
			has_dir = true
			texture = dtex
			var dframes := int(sprite_def.get("dir_attack_frames", 1)) if use_attack else int(sprite_def.get("dir_walk_frames", 1))
			if use_attack:
				var dat: float = clamp(float(unit.get("attack_anim_time", 0.0)), 0.0, CRUMB_ATTACK_DURATION - 0.001)
				frame = clamp(int(floor(dat / CRUMB_ATTACK_DURATION * float(dframes))), 0, dframes - 1)
			else:
				frame = int(floor(elapsed * float(sprite_def.get("fps", 7.0)) + float(int(unit["id"]) % dframes))) % dframes
			var rf := _facing_to_row_flip(unit.get("face_dir", Vector2(0.0, -1.0)))
			dir_row = rf.x
			dir_flip = rf.y == 1
	if texture == null:
		return false
	var src := Rect2(Vector2(frame * 256, (dir_row * 256) if has_dir else 0), Vector2(256, 256))
	# 体型按 4 档规则：低/中/高/亡灵，同档统一，强弱一眼可辨
	var draw_side: float = _unit_draw_side(unit)
	var size := Vector2(draw_side, draw_side)
	# 幽魂：贴图上浮飘动、灵体化（去饱和偏冷青 + 半透明 + 闪烁）
	var ghost := bool(unit.get("is_ghost", false))
	var draw_pos := pos
	var tint := Color.WHITE
	if ghost:
		draw_pos = pos + Vector2(0, -2.0 + sin(elapsed * 3.0 + float(unit["id"])) * 2.0)
		var flicker := 0.58 + 0.12 * sin(elapsed * 9.0 + float(unit["id"]) * 1.7)
		tint = Color(0.62, 0.78, 0.95, flicker)
	var attack_phase := 0.0
	if has_dir and attacking:
		attack_phase = clampf(float(unit.get("attack_anim_time", 0.0)) / CRUMB_ATTACK_DURATION, 0.0, 1.0)
		var fdir := unit.get("face_dir", Vector2(0.0, -1.0)) as Vector2
		if fdir.length() > 0.001:
			draw_pos += fdir.normalized() * _dir_attack_motion(attack_phase)
			size *= 1.0 + sin(attack_phase * PI) * 0.035
	# 多向图为单帧静态姿态，行走时加轻微上下浮动补足生气
	if has_dir and not attacking:
		draw_pos.y += sin(elapsed * 9.0 + float(unit["id"]) * 1.3) * 1.6
	var dst := Rect2(draw_pos - Vector2(size.x * 0.5, size.y * float(sprite_def.get("anchor", 0.78))), size)
	# 多向图按朝向镜像；单视角图沿用「攻击图默认朝右上、目标在左侧时镜像」
	var flip: bool = dir_flip if has_dir else (attacking and bool(sprite_def.get("flip_attack", false)) and float(unit.get("attack_dir_x", 1.0)) < 0.0)
	if flip:
		draw_set_transform(Vector2(2.0 * draw_pos.x, 0.0), 0.0, Vector2(-1.0, 1.0))
	draw_texture_rect_region(texture, dst, src, tint)
	if flip:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if has_dir and attacking:
		_draw_dir_attack_swoosh(unit, draw_pos, radius, unit.get("face_dir", Vector2(0.0, -1.0)) as Vector2, attack_phase)
	if ghost:
		_draw_ghost_aura(draw_pos, radius)
	if float(unit.get("hit_flash", 0.0)) > 0.0:
		draw_rect(dst, Color(1, 1, 1, 0.28), true)
	_draw_status_icons(unit, pos, radius)
	# 血条贴在体型顶部上沿，随放大后的尺寸抬高，不论大小都浮在头顶
	_draw_unit_hp_bar(unit, pos, radius, draw_side * 0.42 + 8.0, side)
	return true

# 幽魂灵体辉光：冷青柔光 + 上升魂雾，强化"复活体"读感
func _draw_ghost_aura(pos: Vector2, radius: float) -> void:
	var glow := 0.18 + 0.08 * sin(elapsed * 5.0)
	draw_circle(pos + Vector2(0, -radius * 0.6), radius * 1.5, Color(0.5, 0.66, 0.92, glow))
	for i in range(3):
		var ph := fmod(elapsed * 0.8 + float(i) * 0.333, 1.0)
		var wx := pos.x + sin((float(i) * 21.7 + floorf(elapsed * 0.8)) * 11.0) * radius * 0.8
		var wy := pos.y - radius * 0.3 - ph * radius * 2.2
		draw_circle(Vector2(wx, wy), 2.2 * (1.0 - ph) + 0.6, Color(0.66, 0.82, 1.0, (1.0 - ph) * 0.5))

func _draw_status_icons(unit: Dictionary, pos: Vector2, radius: float) -> void:
	# 冰冻：角色罩一层冰壳；幽魂：紫雾轮廓——先画罩层再画图标
	if float(unit.get("frozen_timer", 0.0)) > 0.0:
		draw_circle(pos + Vector2(0, -radius * 0.4), radius * 1.15, Color(0.62, 0.8, 0.94, 0.32))
		draw_arc(pos + Vector2(0, -radius * 0.4), radius * 1.15, 0.0, TAU, 24, Color(0.5, 0.72, 0.9, 0.7), 1.6)
		# 冰棱小三角
		for i in range(3):
			var spike_base := pos + Vector2(-radius * 0.7 + float(i) * radius * 0.7, -radius * 1.3)
			draw_colored_polygon(PackedVector2Array([
				spike_base, spike_base + Vector2(5.0, 0.0), spike_base + Vector2(2.5, -7.0)
			]), Color(0.78, 0.9, 0.98, 0.85))
	if bool(unit.get("is_ghost", false)):
		var ghost_pulse := 0.5 + 0.2 * sin(elapsed * 6.0)
		draw_arc(pos + Vector2(0, -radius * 0.4), radius * 1.2, 0.0, TAU, 24, Color(0.6, 0.45, 0.72, ghost_pulse), 2.0)
	var icons: Array[Dictionary] = []
	if float(unit.get("shield", 0.0)) > 0.0:
		icons.append({"text": "盾", "color": Color("#d2b271")})
	if float(unit.get("slow_timer", 0.0)) > 0.0:
		icons.append({"text": "慢", "color": Color("#8fb5d8")})
	if float(unit.get("weaken_timer", 0.0)) > 0.0:
		icons.append({"text": "弱", "color": Color("#3f342d")})
	if float(unit.get("frozen_timer", 0.0)) > 0.0:
		icons.append({"text": "冻", "color": Color("#4f789f")})
	if float(unit.get("rally_timer", 0.0)) > 0.0:
		icons.append({"text": "怒", "color": Color("#a04a28")})
	if float(unit.get("haste_timer", 0.0)) > 0.0:
		icons.append({"text": "疾", "color": Color("#3f7a6e")})
	if bool(unit.get("is_ghost", false)):
		icons.append({"text": "魂", "color": Color("#6b4a7c")})
	if icons.is_empty():
		return
	var start_x := pos.x - float(icons.size() - 1) * 7.0
	for i in range(icons.size()):
		var icon: Dictionary = icons[i]
		var icon_color: Color = icon["color"]
		var icon_pos := Vector2(start_x + float(i) * 14.0, pos.y - radius - 17.0)
		draw_circle(icon_pos, 6.0, Color("#fff7e8dd"))
		draw_arc(icon_pos, 6.0, 0.0, TAU, 16, icon_color, 1.2)
		draw_string(_font(), icon_pos + Vector2(-4.5, 3.5), String(icon["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, icon_color)

# 施法法阵画在地面与角色之间；影分身是人形剪影，仍留在角色之上的特效层
const GROUND_FX_KINDS := ["mist", "rain", "root", "weaken", "heal", "shield_wave", "summon", "vine", "boss_barrage"]

func _draw_ground_effects() -> void:
	for effect in effects:
		if String(effect.get("kind", "")) in GROUND_FX_KINDS:
			var alpha: float = clamp(float(effect["time"]) / float(effect["max_time"]), 0.0, 1.0)
			_draw_skill_effect(effect, alpha)

# 死亡事件地面区域：陨石红圈预警 / 毒雾 / 冰雹区，画在地面与角色之间
func _draw_death_event_zones() -> void:
	for ev in death_events:
		var kind := String(ev["kind"])
		if kind == "meteor":
			var pos: Vector2 = ev["pos"]
			var radius := float(ev["radius"])
			var progress: float = 1.0 - clamp(float(ev["timer"]) / float(ev.get("warn_total", 1.0)), 0.0, 1.0)
			var pulse := 0.7 + 0.3 * sin(elapsed * 16.0)
			draw_circle(pos, radius, Color(0.72, 0.22, 0.12, 0.14 + 0.08 * pulse))
			draw_arc(pos, radius, 0.0, TAU, 48, Color(0.78, 0.2, 0.1, 0.55 + 0.3 * pulse), 2.5)
			# 内圈随预警时间收缩，给"何时落地"的读秒感
			draw_arc(pos, radius * (1.0 - progress * 0.92) + 3.0, 0.0, TAU, 36, Color(1.0, 0.6, 0.3, 0.8), 2.0)
			# 落点十字
			draw_line(pos + Vector2(-7, 0), pos + Vector2(7, 0), Color(1.0, 0.5, 0.3, 0.9), 1.6)
			draw_line(pos + Vector2(0, -7), pos + Vector2(0, 7), Color(1.0, 0.5, 0.3, 0.9), 1.6)
		elif kind == "dot_zone":
			var zone_pos: Vector2 = ev["pos"]
			var zone_r := float(ev["radius"])
			var fade: float = clamp(float(ev["timer"]) / 1.2, 0.0, 1.0)
			draw_circle(zone_pos, zone_r, Color(0.45, 0.54, 0.2, 0.16 * fade))
			draw_arc(zone_pos, zone_r, 0.0, TAU, 48, Color(0.4, 0.5, 0.18, 0.5 * fade), 2.0)
			# 毒雾气泡：确定性相位上浮
			for i in range(8):
				var bub_cycle := elapsed * 0.9 + float(i) * 0.125
				var bub_ph := fmod(bub_cycle, 1.0)
				var bub_seed := float(i) * 17.3 + floorf(bub_cycle) * 3.7
				var bx := zone_pos.x + sin(bub_seed * 12.98) * zone_r * 0.7
				var by: float = zone_pos.y + cos(bub_seed * 7.1) * zone_r * 0.4 - bub_ph * 16.0
				draw_circle(Vector2(bx, by), 2.0 + fmod(bub_seed, 2.2), Color(0.62, 0.72, 0.34, (1.0 - bub_ph) * 0.5 * fade))
		elif kind == "hail":
			var hail_pos: Vector2 = ev["pos"]
			var hail_r := float(ev["radius"])
			var hail_fade: float = clamp(float(ev["timer"]) / 0.8, 0.0, 1.0)
			draw_circle(hail_pos, hail_r, Color(0.62, 0.78, 0.88, 0.13 * hail_fade))
			draw_arc(hail_pos, hail_r, 0.0, TAU, 48, Color(0.45, 0.65, 0.82, 0.5 * hail_fade), 2.0)
			# 下落的冰雹线
			for i in range(9):
				var drop_cycle := elapsed * 2.6 + float(i) * 0.111
				var drop_ph := fmod(drop_cycle, 1.0)
				var drop_seed := float(i) * 23.7 + floorf(drop_cycle) * 5.3
				var dx := hail_pos.x + sin(drop_seed * 9.4) * hail_r * 0.82
				var dy: float = hail_pos.y - 60.0 + drop_ph * 70.0
				draw_line(Vector2(dx, dy - 7.0), Vector2(dx + 2.0, dy), Color(0.82, 0.92, 1.0, (1.0 - drop_ph * 0.5) * 0.75 * hail_fade), 1.8)
		elif kind == "haste_wind":
			# 疾风：全场横向风纹线，循环左→右掠过
			var wind_fade: float = clamp(float(ev["timer"]) / 0.8, 0.0, 1.0)
			for i in range(7):
				var wind_cycle := elapsed * 1.4 + float(i) * 0.143
				var wind_ph := fmod(wind_cycle, 1.0)
				var wind_seed := float(i) * 31.7 + floorf(wind_cycle) * 4.1
				var wy := FIELD_RECT.position.y + 50.0 + fmod(wind_seed * 13.7, FIELD_RECT.size.y - 90.0)
				var wx: float = FIELD_RECT.position.x + wind_ph * FIELD_RECT.size.x
				var wlen := 26.0 + fmod(wind_seed, 18.0)
				var wind_alpha: float = sin(wind_ph * PI) * 0.4 * wind_fade
				draw_line(Vector2(wx - wlen, wy), Vector2(wx, wy), Color(0.55, 0.78, 0.72, wind_alpha), 1.6)
				draw_line(Vector2(wx - wlen * 0.6, wy + 3.0), Vector2(wx - 4.0, wy + 3.0), Color(0.55, 0.78, 0.72, wind_alpha * 0.6), 1.2)

# 事件徽章：战场左侧竖排，图标+短名+底部剩余时间细条；瞬发事件固定停留淡出
func _draw_event_badges() -> void:
	var badge_size := Vector2(88.0, 22.0)
	var base_pos := Vector2(FIELD_RECT.position.x + 8.0, FIELD_RECT.position.y + 86.0)
	for i in range(event_badges.size()):
		var badge: Dictionary = event_badges[i]
		var time_left := float(badge["time_left"])
		var total := float(badge["total"])
		var theme: Color = badge["color"]
		var instant := bool(badge["instant"])
		var is_meteor := String(badge["kind"]) == "meteor"
		# 透明度：入场 0.2s 淡入，最后 0.4s 淡出，常态 0.65
		var fade_in: float = clampf((total - time_left) / 0.2, 0.0, 1.0)
		var fade_out: float = clampf(time_left / 0.4, 0.0, 1.0)
		var badge_alpha := 0.65 * fade_in * fade_out
		# 持续型事件最后 1 秒轻微脉动提醒将结束；陨石预警期（前 1s）红色急促脉动
		var pulse := 1.0
		if not instant and time_left < 1.0:
			pulse = 1.0 + 0.12 * sin(elapsed * 10.0)
		var meteor_warning := is_meteor and time_left > total - 1.0
		if meteor_warning:
			pulse = 1.0 + 0.25 * sin(elapsed * 18.0)
		var rect := Rect2(base_pos + Vector2(0.0, float(i) * 27.0), badge_size)
		var fill := Color(1.0, 0.97, 0.91, badge_alpha)
		var border := theme
		border.a = badge_alpha * 1.25 * pulse
		_draw_ink_panel(rect, fill, border, 6.0, false)
		# 左侧圆形图标
		var icon_center := rect.position + Vector2(12.0, badge_size.y * 0.5)
		var icon_color := theme
		if meteor_warning:
			icon_color = Color(0.78, 0.2, 0.1)
		draw_circle(icon_center, 8.0, Color(icon_color.r, icon_color.g, icon_color.b, badge_alpha * 1.1 * pulse))
		draw_string(_font_medium(), icon_center + Vector2(-5.0, 4.0), String(badge["glyph"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.97, 0.91, badge_alpha * 1.5))
		# 事件短名
		var text_color := Color(0.3, 0.25, 0.21, badge_alpha * 1.4)
		draw_string(_font_medium(), rect.position + Vector2(25.0, 13.5), String(badge["label"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, text_color)
		# 底部剩余时间细条：仅持续型事件画（抬离边框线，避免和描边糊在一起）
		if not instant:
			var bar_y := rect.end.y - 5.0
			var bar_track_w := badge_size.x - 32.0
			var bar_x := rect.position.x + 25.0
			var bar_w: float = bar_track_w * clampf(time_left / total, 0.0, 1.0)
			draw_rect(Rect2(bar_x, bar_y, bar_track_w, 3.0), Color(0.3, 0.25, 0.21, badge_alpha * 0.4), true)
			draw_rect(Rect2(bar_x, bar_y, bar_w, 3.0), Color(theme.r, theme.g, theme.b, clampf(badge_alpha * 1.8, 0.0, 1.0)), true)

# 事件触发中央大印记：画面中央浮现，轻微放大，1s 内淡出消失
func _draw_event_seal() -> void:
	if event_seal.is_empty():
		return
	var t: float = clamp(float(event_seal["timer"]) / float(event_seal["total"]), 0.0, 1.0)
	# 入场前 0.15s 快速放大到位，随后整体淡出
	var grow: float = clamp((1.0 - t) / 0.15, 0.0, 1.0)
	var scale := 0.78 + 0.22 * grow
	var alpha := t            # 线性淡出
	var center := Vector2(FIELD_RECT.position.x + FIELD_RECT.size.x * 0.5, FIELD_RECT.position.y + FIELD_RECT.size.y * 0.42)
	var theme: Color = event_seal["color"]
	var r := 70.0 * scale
	# 外层柔光
	draw_circle(center, r * 1.25, Color(theme.r, theme.g, theme.b, 0.10 * alpha))
	# 印记盘：宣纸底 + 双层主题描边
	draw_circle(center, r, Color(0.99, 0.96, 0.90, 0.40 * alpha))
	draw_arc(center, r, 0.0, TAU, 64, Color(theme.r, theme.g, theme.b, 0.85 * alpha), 3.0)
	draw_arc(center, r - 6.0, 0.0, TAU, 64, Color(theme.r, theme.g, theme.b, 0.45 * alpha), 1.4)
	# 旋绕的印记缺口装饰
	for i in range(4):
		var a := float(i) * TAU / 4.0 + (1.0 - t) * 0.6
		draw_arc(center, r - 6.0, a + 0.18, a + (TAU / 4.0) - 0.18, 16, Color(theme.r, theme.g, theme.b, 0.7 * alpha), 2.2)
	# 事件大字 + 名称
	var glyph_color := Color(theme.r * 0.85, theme.g * 0.85, theme.b * 0.85, alpha)
	draw_string(_font_medium(), center + Vector2(-26.0 * scale, 18.0 * scale), String(event_seal["glyph"]), HORIZONTAL_ALIGNMENT_CENTER, 52.0 * scale, int(52.0 * scale), glyph_color)
	draw_string(_font_medium(), center + Vector2(-70.0, r + 20.0), String(event_seal["label"]), HORIZONTAL_ALIGNMENT_CENTER, 140.0, 15, Color(theme.r * 0.8, theme.g * 0.8, theme.b * 0.8, alpha))

func _draw_effects() -> void:
	for effect in effects:
		var alpha: float = clamp(float(effect["time"]) / float(effect["max_time"]), 0.0, 1.0)
		var color: Color = effect["color"]
		var kind := String(effect.get("kind", ""))
		if kind in GROUND_FX_KINDS:
			continue
		elif kind == "shadow":
			_draw_skill_effect(effect, alpha)
		elif kind in ["ranged_shot", "seek_slash", "boss_shot"]:
			_draw_projectile_effect(effect, alpha)
		elif kind == "boss_warning":
			_draw_boss_warning_effect(effect, alpha)
		elif kind == "hit" and hit_spark_texture:
			var progress: float = 1.0 - alpha
			var frame: int = clampi(int(progress * 8.0), 0, 7)
			var src := Rect2(frame * 128.0, 0.0, 128.0, 128.0)
			var size := 38.0
			var dst := Rect2((effect["pos"] as Vector2) - Vector2(size, size) * 0.5, Vector2(size, size))
			draw_texture_rect_region(hit_spark_texture, dst, src, Color(1.0, 1.0, 1.0, clamp(alpha * 1.6, 0.0, 1.0)))
		elif kind == "death":
			_draw_death_effect(effect, alpha)
		elif kind == "lightning":
			_draw_lightning_effect(effect, alpha)
		elif kind == "meteor_blast":
			_draw_meteor_blast_effect(effect, alpha)
		elif kind == "ice_burst":
			_draw_ice_burst_effect(effect, alpha)
		elif kind == "buff_glow":
			_draw_buff_glow_effect(effect, alpha)
		elif kind == "rebirth_glow":
			_draw_rebirth_glow_effect(effect, alpha)
		else:
			color.a = 0.42 * alpha
			draw_arc(effect["pos"], float(effect["radius"]), 0.0, TAU, 36, color, 3.0)
	for t in texts:
		var alpha: float = clamp(float(t["time"]) / float(t["max_time"]), 0.0, 1.0)
		var age: float = 1.0 - alpha
		var color: Color = t["color"]
		color.a = alpha
		# 弹跳入场：前 18% 字号从 1.45 倍弹回 1.0，随后缓缓上浮淡出
		var pop: float = 1.0 + 0.45 * clampf(1.0 - age / 0.18, 0.0, 1.0)
		var rise: float = -14.0 * (1.0 - pow(1.0 - age, 2.4))
		var font_size := int(round(13.0 * pop))
		var draw_pos: Vector2 = (t["pos"] as Vector2) + Vector2(0.0, rise)
		# 深色描边提高可读性
		var outline := Color(0.18, 0.12, 0.08, 0.7 * alpha)
		draw_string_outline(_font_medium(), draw_pos, String(t["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 3, outline)
		draw_string(_font_medium(), draw_pos, String(t["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

# 死亡消散（v2 烟雾版）：本体短白闪后快速隐去（不缩放不下沉），多团软边烟雾错峰膨胀上飘盖住消失瞬间
func _draw_death_effect(effect: Dictionary, alpha: float) -> void:
	var pos: Vector2 = effect["pos"]
	var radius := float(effect["radius"])
	var color: Color = effect["color"]
	var progress: float = 1.0 - alpha
	var uid := String(effect.get("unit_id", ""))
	var fx_seed := int(effect.get("seed", 0))
	# 本体：原位原尺寸，前 12% 白闪，25% 内快速淡出（之后完全交给烟雾）
	var body_alpha: float = clampf(1.0 - progress / 0.25, 0.0, 1.0)
	if body_alpha > 0.0 and unit_sprite_textures.has(uid) and unit_sprite_textures[uid].get("walk"):
		var sprite_def: Dictionary = UNIT_SPRITE_DEFS[uid]
		var draw_side: float = max(28.0, radius * 3.5)
		var size := Vector2(draw_side, draw_side)
		var dst := Rect2(pos - Vector2(size.x * 0.5, size.y * float(sprite_def.get("anchor", 0.78))), size)
		draw_texture_rect_region(unit_sprite_textures[uid]["walk"], dst, Rect2(Vector2.ZERO, Vector2(256, 256)), Color(1.0, 1.0, 1.0, body_alpha))
		if progress < 0.12:
			draw_rect(dst, Color(1.0, 1.0, 1.0, 0.75 * (1.0 - progress / 0.12)), true)
	# 烟雾：7 团错峰绽放——各团有相位差，膨胀 + 缓慢外漂 + 上升 + 渐隐；颜色为浅灰混 30% 本体色
	if smoke_puff_texture:
		# 背景是浅米色，烟雾必须偏深灰才有对比度（浅灰会隐形）
		var smoke_color := Color(
			0.40 + color.r * 0.26, 0.38 + color.g * 0.26, 0.36 + color.b * 0.26, 1.0)
		for i in range(7):
			var phase_offset := float((fx_seed * 7 + i * 13) % 10) * 0.018
			var puff_t: float = clampf((progress - phase_offset) / (1.0 - phase_offset), 0.0, 1.0)
			if puff_t <= 0.0:
				continue
			var angle := float(i) * TAU / 7.0 + float(fx_seed % 9) * 0.43
			var drift: float = 1.0 - pow(1.0 - puff_t, 2.2)
			var puff_pos := pos + Vector2(cos(angle), sin(angle) * 0.55) * radius * (0.35 + drift * 1.1) \
				+ Vector2(0.0, -radius * 0.2 - drift * radius * 1.3)
			var puff_side: float = radius * (0.9 + drift * 1.5) * (0.8 + float((fx_seed + i) % 4) * 0.1)
			var puff_alpha: float = 0.62 * sin(puff_t * PI)
			draw_texture_rect(smoke_puff_texture,
				Rect2(puff_pos - Vector2(puff_side, puff_side) * 0.5, Vector2(puff_side, puff_side)),
				false, Color(smoke_color.r, smoke_color.g, smoke_color.b, puff_alpha))
	# 地面淡环：烟雾散开的地面投影感
	var fly: float = 1.0 - pow(1.0 - progress, 2.0)
	draw_set_transform(pos + Vector2(0.0, radius * 0.9), 0.0, Vector2(1.35, 0.34))
	draw_arc(Vector2.ZERO, radius * (0.6 + fly * 1.2), 0.0, TAU, 24, Color(color.r, color.g, color.b, 0.3 * alpha), 1.6)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ============ 死亡事件 VFX ============

# 闪电：从画面上方劈到落点的折线主干 + 一条分叉 + 落点闪光
func _draw_lightning_effect(effect: Dictionary, alpha: float) -> void:
	var pos: Vector2 = effect["pos"]
	var fx_seed := int(effect.get("seed", 0))
	# 雷劈从落点上方约 120px 起笔（不从全场顶端拉线，避免穿过 Boss/横幅）
	var top := Vector2(pos.x + float((fx_seed % 7) - 3) * 8.0, max(FIELD_RECT.position.y + 8.0, pos.y - 120.0))
	var segments := 6
	var points := PackedVector2Array()
	points.append(top)
	for i in range(1, segments):
		var t := float(i) / float(segments)
		var jitter := sin(float(fx_seed) * 3.7 + float(i) * 9.13) * 16.0 * (1.0 - t * 0.5)
		points.append(top.lerp(pos, t) + Vector2(jitter, 0.0))
	points.append(pos)
	var bolt_alpha: float = clamp(alpha * 1.4, 0.0, 1.0)
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color(0.92, 0.95, 1.0, bolt_alpha), 3.2)
		draw_line(points[i], points[i + 1], Color(0.55, 0.66, 1.0, bolt_alpha * 0.55), 6.5)
	# 分叉：主干中段斜出一条短支
	if points.size() > 3:
		var branch_from: Vector2 = points[2]
		var branch_to := branch_from + Vector2(sin(float(fx_seed) * 5.1) * 26.0, 22.0)
		draw_line(branch_from, branch_to, Color(0.92, 0.95, 1.0, bolt_alpha * 0.7), 2.0)
	# 落点闪光
	draw_circle(pos, 9.0 + (1.0 - alpha) * 14.0, Color(0.9, 0.94, 1.0, alpha * 0.5))

# 陨石爆炸：火球残影 + 扩散冲击波环 + 飞溅碎屑
func _draw_meteor_blast_effect(effect: Dictionary, alpha: float) -> void:
	var pos: Vector2 = effect["pos"]
	var radius := float(effect["radius"])
	var progress: float = 1.0 - alpha
	# 核心火球：前半段存在，膨胀后熄灭
	var core_alpha: float = clampf(1.0 - progress / 0.45, 0.0, 1.0)
	if core_alpha > 0.0:
		draw_circle(pos, radius * (0.4 + progress * 0.5), Color(0.95, 0.62, 0.25, 0.7 * core_alpha))
		draw_circle(pos, radius * (0.22 + progress * 0.3), Color(1.0, 0.88, 0.55, 0.85 * core_alpha))
	# 冲击波环
	var wave_r: float = radius * (0.4 + progress * 1.1)
	draw_arc(pos, wave_r, 0.0, TAU, 48, Color(0.85, 0.4, 0.18, 0.75 * alpha), 3.5)
	draw_arc(pos, wave_r * 0.8, 0.0, TAU, 40, Color(0.6, 0.25, 0.12, 0.4 * alpha), 2.0)
	# 碎屑：沿固定角度飞出
	for i in range(8):
		var angle := float(i) * TAU / 8.0 + 0.4
		var dist: float = radius * (0.3 + progress * 1.25)
		var deb_pos := pos + Vector2(cos(angle), sin(angle) * 0.7) * dist
		draw_circle(deb_pos, 2.6 * alpha + 0.8, Color(0.45, 0.24, 0.14, alpha))

# 冰爆：放射冰棱 + 寒雾环
func _draw_ice_burst_effect(effect: Dictionary, alpha: float) -> void:
	var pos: Vector2 = effect["pos"]
	var radius := float(effect["radius"])
	var progress: float = 1.0 - alpha
	draw_circle(pos, radius * (0.4 + progress * 0.5), Color(0.72, 0.85, 0.95, 0.22 * alpha))
	draw_arc(pos, radius * (0.5 + progress * 0.55), 0.0, TAU, 40, Color(0.55, 0.75, 0.9, 0.6 * alpha), 2.2)
	for i in range(6):
		var angle := float(i) * TAU / 6.0 + 0.26
		var tip := pos + Vector2(cos(angle), sin(angle) * 0.8) * radius * (0.45 + progress * 0.5)
		var base_dir := Vector2(cos(angle + PI * 0.5), sin(angle + PI * 0.5) * 0.8) * 4.0
		var root := pos + Vector2(cos(angle), sin(angle) * 0.8) * radius * 0.18
		draw_colored_polygon(PackedVector2Array([root + base_dir, root - base_dir, tip]),
			Color(0.8, 0.91, 0.98, 0.8 * alpha))

# 增益光柱：单位脚下金环上扫 + 上升光粒
func _draw_buff_glow_effect(effect: Dictionary, alpha: float) -> void:
	var pos: Vector2 = effect["pos"]
	var radius := float(effect["radius"])
	var color: Color = effect["color"]
	var progress: float = 1.0 - alpha
	draw_set_transform(pos + Vector2(0.0, radius * 0.5), 0.0, Vector2(1.0, 0.36))
	draw_arc(Vector2.ZERO, radius * (0.5 + progress * 0.6), 0.0, TAU, 32, Color(color.r, color.g, color.b, 0.8 * alpha), 2.4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for i in range(5):
		var px := pos.x + sin(float(i) * 2.39 + 1.0) * radius * 0.55
		var py: float = pos.y + radius * 0.3 - progress * (20.0 + float(i) * 5.0)
		draw_circle(Vector2(px, py), 1.8, Color(color.r, color.g, color.b, alpha * 0.9))

# 重生紫雾：双层旋转弧 + 中心微光
func _draw_rebirth_glow_effect(effect: Dictionary, alpha: float) -> void:
	var pos: Vector2 = effect["pos"]
	var radius := float(effect["radius"])
	var progress: float = 1.0 - alpha
	var spin := progress * TAU * 1.5
	draw_arc(pos, radius * (0.5 + progress * 0.4), spin, spin + PI * 1.2, 24, Color(0.62, 0.45, 0.75, 0.75 * alpha), 2.6)
	draw_arc(pos, radius * (0.7 + progress * 0.5), -spin * 0.8, -spin * 0.8 + PI, 24, Color(0.5, 0.35, 0.65, 0.5 * alpha), 2.0)
	draw_circle(pos, radius * 0.25, Color(0.8, 0.66, 0.9, 0.4 * alpha))

# 火签齐射：贴地火爆贴图（快速放大冲入 + 轻旋 + 淡出）+ 冲击波环 + 白热核心闪
func _draw_boss_barrage_effect(pos: Vector2, radius: float, alpha: float) -> void:
	var progress := 1.0 - alpha
	var grow: float = clamp(progress / 0.3, 0.0, 1.0)
	# 地面冲击波环（压扁贴地）
	draw_set_transform(pos, 0.0, Vector2(1.0, 0.7))
	draw_arc(Vector2.ZERO, radius * (0.5 + grow * 0.62), 0.0, TAU, 48, Color(1.0, 0.6, 0.25, 0.5 * alpha), 3.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if boss_barrage_burst_texture:
		var scale: float = radius * 2.0 * (0.45 + 0.6 * grow) / 512.0
		var spin := progress * 0.5
		var fade: float = clamp(alpha * 1.6, 0.0, 1.0)
		var xf := Transform2D(spin, Vector2(scale, scale * 0.82), 0.0, pos)
		draw_set_transform_matrix(xf)
		draw_texture_rect(boss_barrage_burst_texture, Rect2(Vector2(-256, -256), Vector2(512, 512)), false, Color(1, 1, 1, fade))
		draw_set_transform_matrix(Transform2D.IDENTITY)
	# 早期白热核心闪光
	if progress < 0.35:
		var flash: float = 1.0 - progress / 0.35
		draw_circle(pos, radius * 0.42 * (0.6 + grow), Color(1.0, 0.95, 0.8, 0.5 * flash))

func _draw_skill_effect(effect: Dictionary, alpha: float) -> void:
	var pos: Vector2 = effect["pos"]
	var radius := float(effect["radius"])
	var color: Color = effect["color"]
	var kind := String(effect["kind"])
	if kind == "boss_barrage":
		_draw_boss_barrage_effect(pos, radius, alpha)
		return
	color.a = 0.34 * alpha
	var pulse := 1.0 - alpha
	var ring_color := Color(color.r, color.g, color.b, 0.72 * alpha)
	draw_arc(pos, radius * (0.72 + pulse * 0.28), 0.0, TAU, 72, ring_color, 3.0)
	draw_arc(pos, radius * (0.38 + pulse * 0.18), 0.0, TAU, 48, Color(color.r, color.g, color.b, 0.34 * alpha), 2.0)
	if skill_fx_textures.has(kind):
		var progress := 1.0 - alpha
		var frame: int = clampi(int(progress * 8.0), 0, 7)
		var src := Rect2(frame * 128.0, 0.0, 128.0, 128.0)
		var size := radius * 1.7
		var dst := Rect2(pos - Vector2(size, size) * 0.5, Vector2(size, size))
		# 图集自带 F6-F8 淡出帧，代码层只在生命最后 1/3 再叠加淡出，避免双重衰减发灰
		draw_texture_rect_region(skill_fx_textures[kind], dst, src, Color(1.0, 1.0, 1.0, clamp(alpha * 3.0, 0.0, 1.0)))
		return
	if kind == "mist":
		draw_circle(pos, radius * 0.72, color)
		for i in range(5):
			var offset := Vector2(cos(float(i) * TAU / 5.0), sin(float(i) * TAU / 5.0)) * radius * 0.42
			draw_arc(pos + offset, radius * 0.25, -0.5, PI + 0.7, 20, Color(color.r, color.g, color.b, 0.45 * alpha), 3.0)
	elif kind == "rain":
		for i in range(8):
			var x := pos.x - 116.0 + i * 34.0
			draw_line(Vector2(x, pos.y - 118.0 + i % 2 * 14.0), Vector2(x - 18.0, pos.y - 46.0), Color(color.r, color.g, color.b, 0.72 * alpha), 4.0)
		draw_arc(pos, radius * 0.55, 0.0, TAU, 48, Color(color.r, color.g, color.b, 0.34 * alpha), 3.0)
	elif kind == "root":
		for i in range(7):
			var angle := -PI * 0.95 + i * PI / 3.0
			var end := pos + Vector2(cos(angle), sin(angle)) * radius * 0.55
			draw_line(pos, end, Color(color.r, color.g, color.b, 0.72 * alpha), 4.0)
			draw_circle(end, 5.0, Color(color.r, color.g, color.b, 0.62 * alpha))
	elif kind == "weaken":
		var dark := Color("#3f342d")
		dark.a = 0.55 * alpha
		draw_arc(pos, radius * 0.62, -0.3, TAU - 0.3, 42, dark, 5.0)
		dark.a = 0.7 * alpha
		draw_line(pos + Vector2(-radius * 0.35, -radius * 0.25), pos + Vector2(radius * 0.35, radius * 0.25), dark, 4.0)
	elif kind == "heal":
		draw_circle(pos, radius * 0.44, Color(color.r, color.g, color.b, 0.2 * alpha))
		draw_line(pos + Vector2(-18, 0), pos + Vector2(18, 0), Color(color.r, color.g, color.b, 0.8 * alpha), 5.0)
		draw_line(pos + Vector2(0, -18), pos + Vector2(0, 18), Color(color.r, color.g, color.b, 0.8 * alpha), 5.0)
	elif kind == "shield_wave":
		draw_arc(pos, radius * 0.52, -0.7, PI + 0.7, 48, Color(color.r, color.g, color.b, 0.72 * alpha), 5.0)
		draw_arc(pos, radius * 0.72, -0.45, PI + 0.45, 48, Color(color.r, color.g, color.b, 0.32 * alpha), 3.0)
	elif kind == "shadow":
		var shadow_color := Color("#2f2a27")
		shadow_color.a = 0.55 * alpha
		for i in range(4):
			var offset := Vector2((float(i) - 1.5) * 22.0, sin(float(i)) * 10.0)
			draw_circle(pos + offset, 13.0, shadow_color)
		draw_arc(pos, radius * 0.48, 0.2, PI + 0.2, 40, Color(color.r, color.g, color.b, 0.42 * alpha), 4.0)
	elif kind == "vine":
		for i in range(4):
			var x := pos.x - 54.0 + i * 36.0
			draw_line(Vector2(x, pos.y + 32.0), Vector2(x + 16.0, pos.y - 26.0), Color(color.r, color.g, color.b, 0.75 * alpha), 5.0)
			draw_circle(Vector2(x + 16.0, pos.y - 26.0), 6.0, Color(color.r, color.g, color.b, 0.65 * alpha))
	elif kind == "boss_barrage":
		for i in range(9):
			var x := pos.x - 122.0 + float(i) * 30.5
			var top := Vector2(x + 26.0, pos.y - 132.0 + float(i % 3) * 10.0)
			var bottom := Vector2(x - 8.0, pos.y - 24.0 + float(i % 2) * 18.0)
			draw_line(top, bottom, Color(0.552, 0.204, 0.153, 0.76 * alpha), 4.0)
			draw_circle(bottom, 6.5, Color(color.r, color.g, color.b, 0.62 * alpha))
	else:
		draw_circle(pos, radius * 0.5, color)

func _draw_projectile_effect(effect: Dictionary, alpha: float) -> void:
	var from_pos: Vector2 = effect["from"]
	var to_pos: Vector2 = effect["to"]
	var color: Color = effect["color"]
	var kind := String(effect["kind"])
	var line_color := color
	line_color.a = 0.72 * alpha
	var head_color := color
	head_color.a = 0.95 * alpha
	if kind == "ranged_shot":
		# 飞行弹：亮头沿弹道推进，短拖尾渐隐，命中前不画整条直线
		var progress: float = clampf((1.0 - alpha) * 1.3, 0.0, 1.0)
		var head := from_pos.lerp(to_pos, progress)
		var tail := from_pos.lerp(to_pos, clampf(progress - 0.38, 0.0, 1.0))
		draw_line(tail, head, line_color, 3.2)
		draw_circle(head, 4.4, head_color)
		draw_circle(head, 2.0, Color(1.0, 1.0, 1.0, 0.92 * alpha))
		if progress >= 0.99:
			var burst: float = 4.0 + 5.0 * (1.0 - alpha)
			draw_circle(to_pos, burst, Color(head_color.r, head_color.g, head_color.b, 0.45 * alpha))
	elif kind == "seek_slash":
		var mid := from_pos.lerp(to_pos, 0.62)
		var direction := (to_pos - from_pos).normalized()
		var tangent := direction.orthogonal() * 12.0
		draw_line(from_pos + tangent, mid - tangent, line_color, 4.0)
		draw_line(mid - tangent, to_pos, line_color, 2.5)
	elif kind == "boss_shot":
		var boss_line := Color("#8d3427")
		boss_line.a = 0.72 * alpha
		var boss_hit := Color("#d85f3f")
		boss_hit.a = 0.7 * alpha
		draw_line(from_pos, to_pos, boss_line, 4.0)
		draw_circle(to_pos, 6.0, boss_hit)

func _draw_boss_warning_effect(effect: Dictionary, alpha: float) -> void:
	var urgency: float = clamp(1.0 - alpha, 0.0, 1.0)
	var countdown: int = max(1, int(ceil(float(effect["time"]))))
	var pulse := 0.5 + 0.5 * sin(elapsed * (5.0 + urgency * 11.0))
	var skill_name := String(effect.get("text", "技能"))
	if String(effect.get("warn_mode", "aoe")) == "reinforce":
		_draw_boss_reinforce_warning(skill_name, countdown, urgency, pulse)
	else:
		_draw_boss_aoe_warning(skill_name, countdown, urgency, pulse)

# 顶部读秒标签（两种预警共用）：名称常规 + 大号描边秒数
func _draw_boss_warning_label(text: String, countdown: int, top_y: float) -> void:
	var label_rect := Rect2(FIELD_RECT.position.x + FIELD_RECT.size.x * 0.5 - 92.0, top_y, 184, 22)
	_draw_ink_panel(label_rect, Color("#fff7e8f0"), Color("#8d3427"), 10.0, false)
	draw_string(_font(), label_rect.position + Vector2(-16, 16), text, HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x, 10, Color("#8d3427"))
	var cd_str := "%ds" % countdown
	var cd_pos := label_rect.position + Vector2(label_rect.size.x - 30.0, 17.0)
	draw_string_outline(_font_medium(), cd_pos, cd_str, HORIZONTAL_ALIGNMENT_LEFT, 28, 14, 3, Color(1.0, 0.96, 0.9, 0.9))
	draw_string(_font_medium(), cd_pos, cd_str, HORIZONTAL_ALIGNMENT_LEFT, 28, 14, Color("#8d3427"))

# 召唤预警：敌方闸门发光带 + 下行箭头（援军从顶部涌入），不再用误导的危险圈
func _draw_boss_reinforce_warning(skill_name: String, countdown: int, urgency: float, pulse: float) -> void:
	var warn := Color(0.86, 0.46, 0.20)
	var top := FIELD_RECT.position.y
	var band_h := 30.0
	draw_rect(Rect2(FIELD_RECT.position.x, top, FIELD_RECT.size.x, band_h), Color(warn.r, warn.g, warn.b, 0.10 + 0.12 * pulse))
	draw_line(Vector2(FIELD_RECT.position.x, top + band_h), Vector2(FIELD_RECT.end.x, top + band_h), Color(warn.r, warn.g, warn.b, 0.55 + 0.3 * pulse), 2.0)
	# 下行箭头：循环下落，表示援军方向
	for i in range(6):
		var x := FIELD_RECT.position.x + 34.0 + float(i) * (FIELD_RECT.size.x - 68.0) / 5.0
		var ay := top + 6.0 + fmod(elapsed * 26.0 + float(i) * 5.0, 18.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 6.0, ay), Vector2(x + 6.0, ay), Vector2(x, ay + 9.0)
		]), Color(warn.r, warn.g, warn.b, 0.55 + 0.35 * pulse))
	_draw_boss_warning_label("援军来袭 · " + skill_name, countdown, top + band_h + 6.0)

# 全场受击预警：战场红色脉动边框 + 极淡红填充（克制不糊屏），诚实表达"全体被打"
func _draw_boss_aoe_warning(skill_name: String, countdown: int, urgency: float, pulse: float) -> void:
	var danger := Color(0.85, 0.27, 0.16)
	draw_rect(FIELD_RECT, Color(danger.r, danger.g, danger.b, 0.035 + urgency * 0.09 + 0.025 * pulse), true)
	var bw := 3.0 + urgency * 3.0
	draw_rect(FIELD_RECT, Color(danger.r, danger.g, danger.b, 0.6 + 0.3 * pulse), false, bw)
	draw_rect(FIELD_RECT.grow(-6.0), Color(1.0, 0.7, 0.35, 0.3 + 0.3 * pulse), false, 1.5)
	_draw_boss_warning_label("全体受击 · " + skill_name, countdown, FIELD_RECT.position.y + 8.0)

func _add_effect(pos: Vector2, color: Color, kind: String) -> void:
	var radius := 12.0
	if kind == "skill":
		radius = 34.0
	elif kind == "death":
		radius = 18.0
	effects.append({"pos": pos, "color": color, "time": 0.45, "max_time": 0.45, "radius": radius, "kind": kind})

func _add_projectile_effect(from_pos: Vector2, to_pos: Vector2, color: Color, kind: String) -> void:
	effects.append({
		"from": from_pos,
		"to": to_pos,
		"pos": to_pos,
		"color": color,
		"time": 0.34,
		"max_time": 0.34,
		"radius": 0.0,
		"kind": kind
	})

func _add_skill_visual(kind: String, pos: Vector2, color: Color) -> void:
	var radius := 98.0
	var duration := 0.7
	if kind in ["summon", "shadow", "vine", "heal", "shield_wave"]:
		radius = 72.0
	if kind == "rain":
		radius = 150.0
		duration = 0.82
	elif kind == "boss_barrage":
		radius = 170.0
		duration = 0.72
	elif kind == "root":
		duration = 0.9
	effects.append({"pos": pos, "color": color, "time": duration, "max_time": duration, "radius": radius, "kind": kind})

func _add_text(pos: Vector2, text: String, color: Color) -> void:
	texts.append({"pos": pos, "text": text, "color": color, "time": 0.8, "max_time": 0.8})

func _draw_cards() -> void:
	for index in range(hero_defs.size()):
		var rect := Rect2(card_buttons[index].position, card_buttons[index].size)
		_draw_card(index, rect)

func _draw_card(index: int, rect: Rect2) -> void:
	var hero: Dictionary = hero_defs[index]
	var flavor: Dictionary = flavor_defs[hero["flavor"]]
	var selected := index == selected_card
	var compact := rect.size.y < 70.0
	var hovered := card_buttons[index].is_hovered()
	var press := card_press[index] if index < card_press.size() else 0.0
	var flash := card_flash[index] if index < card_flash.size() else 0.0
	if compact:
		_draw_compact_card(hero, rect, selected, hovered, press, flash)
		return
	var scale := 1.0
	var lift := 0.0
	if selected:
		scale = 1.03
		lift = -7.0
	elif hovered:
		scale = 1.015
		lift = -3.0
	if press > 0.01:
		scale = 0.965
		lift = 2.0
	var draw_rect := _scaled_rect(rect, scale, lift)
	if selected or flash > 0.0:
		var glow: Color = flavor["color"]
		glow.a = 0.24 + flash * 0.22
		var glow_style := StyleBoxFlat.new()
		glow_style.bg_color = glow
		glow_style.set_corner_radius_all(14)
		glow_style.draw(get_canvas_item(), draw_rect.grow(6.0))
	_draw_ink_panel(draw_rect, Color("#fff0c8") if selected else Color("#fff7e7"), Color("#8a7462"), 10.0, selected)
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = flavor["color"]
	header_style.corner_radius_top_left = 10
	header_style.corner_radius_top_right = 10
	header_style.draw(get_canvas_item(), Rect2(draw_rect.position, Vector2(draw_rect.size.x, 28)))
	draw_string(_font(), draw_rect.position + Vector2(8, 20), String(flavor["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff8ee"))
	draw_string(_font(), draw_rect.position + Vector2(40, 20), String(hero["name"]), HORIZONTAL_ALIGNMENT_LEFT, draw_rect.size.x - 46, 11, Color("#fff8ee"))
	var portrait_rect := Rect2(draw_rect.position + Vector2(17, 34), Vector2(78, 104))
	_draw_card_icon(hero, portrait_rect)
	var troops: Array = hero["troops"]
	var skills: Array = hero["skills"]
	draw_rect(Rect2(draw_rect.position + Vector2(7, 141), Vector2(draw_rect.size.x - 14, 10)), Color("#eadfc9"), true)
	draw_string(_font(), draw_rect.position + Vector2(9, 152), "兵 %.1f/%.1f/%.1f  技 %d/%d/%d" % [_troop_unit_price(troops[0]), _troop_unit_price(troops[1]), _troop_unit_price(troops[2]), int(skills[0]["cost"]), int(skills[1]["cost"]), int(skills[2]["cost"])], HORIZONTAL_ALIGNMENT_LEFT, draw_rect.size.x - 18, 8, Color("#5c5048"))

func _draw_compact_card(hero: Dictionary, rect: Rect2, selected: bool, hovered: bool, press: float, flash: float) -> void:
	var flavor: Dictionary = flavor_defs[hero["flavor"]]
	var scale := 0.97 if press > 0.01 else 1.0
	var draw_rect := _scaled_rect(rect, scale, -2.0 if hovered or selected else 0.0)
	if selected or flash > 0.0:
		var glow: Color = flavor["color"]
		glow.a = 0.18 + flash * 0.18
		var glow_style := StyleBoxFlat.new()
		glow_style.bg_color = glow
		glow_style.set_corner_radius_all(12)
		glow_style.draw(get_canvas_item(), draw_rect.grow(4.0))
	_draw_ink_panel(draw_rect, Color("#fff0c8") if selected else Color("#fff7e7"), flavor["ink"] if selected else Color("#8a7462"), 9.0, selected)
	var tag_style := StyleBoxFlat.new()
	tag_style.bg_color = flavor["color"]
	tag_style.corner_radius_top_left = 9
	tag_style.corner_radius_bottom_left = 9
	tag_style.draw(get_canvas_item(), Rect2(draw_rect.position, Vector2(28, draw_rect.size.y)))
	draw_string(_font(), draw_rect.position + Vector2(8, 25), String(flavor["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#fff8ee"))
	draw_string(_font(), draw_rect.position + Vector2(36, 24), String(hero["name"]), HORIZONTAL_ALIGNMENT_LEFT, draw_rect.size.x - 42, 12, Color("#4c4038"))

func _draw_card_icon(hero: Dictionary, rect: Rect2) -> void:
	var flavor: Dictionary = flavor_defs[hero["flavor"]]
	draw_rect(rect, Color("#eadfc9"), true)
	draw_rect(rect, Color("#b7a58c"), false, 1.0)
	var texture := _hero_texture(hero)
	if texture:
		_draw_texture_cover(texture, rect, Color.WHITE)
		draw_rect(rect, Color("#5f504640"), false, 1.0)
		return
	var center := rect.get_center()
	if hero["id"] == "pickle":
		draw_circle(center + Vector2(-12, 3), 13, Color("#b79970"))
		draw_circle(center + Vector2(-12, 3), 8, Color("#efe8db"))
		draw_arc(center + Vector2(12, -2), 18, -0.9, 1.6, 20, flavor["color"], 4.0)
	elif hero["id"] == "sesame":
		draw_circle(center + Vector2(-10, 2), 13, Color("#ede6d8"))
		draw_circle(center + Vector2(12, -3), 9, Color("#363232"))
		draw_arc(center + Vector2(8, 7), 22, 0.2, PI, 20, Color("#363232"), 3.0)
	else:
		draw_arc(center + Vector2(-6, 4), 22, -1.0, 1.2, 20, flavor["color"], 5.0)
		draw_line(center + Vector2(12, -18), center + Vector2(-12, 18), Color("#506337"), 3.0)

func _draw_option_panel() -> void:
	if selected_card < 0 or game_over:
		return
	var hero: Dictionary = hero_defs[selected_card]
	var flavor: Dictionary = flavor_defs[hero["flavor"]]
	var slide := (1.0 - panel_anim) * 32.0
	var panel := Rect2(ACTION_PANEL_RECT.position + Vector2(0, slide), ACTION_PANEL_RECT.size)
	_draw_ink_panel(panel, Color("#fff7e7f2"), flavor["ink"], 10.0)
	var portrait := Rect2(panel.position + Vector2(14, 44), Vector2(102, 136))
	draw_rect(portrait.grow(3.0), Color("#5f5046"), true)
	draw_rect(portrait, Color("#eadfc9"), true)
	var texture := _hero_texture(hero)
	if texture:
		_draw_texture_cover(texture, portrait, Color.WHITE)
	else:
		_draw_card_icon(hero, portrait)
	draw_rect(portrait, flavor["ink"], false, 2.0)
	draw_rect(Rect2(panel.position + Vector2(14, 12), Vector2(102, 24)), flavor["color"], true)
	draw_string(_font(), panel.position + Vector2(24, 29), String(flavor["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#fff8ee"))
	draw_string(_font(), panel.position + Vector2(52, 29), String(hero["name"]), HORIZONTAL_ALIGNMENT_LEFT, 94, 12, Color("#fff8ee"))
	var gold_header := Rect2(panel.position + Vector2(142, 16), Vector2(110, 38))
	var skill_header := Rect2(panel.position + Vector2(260, 16), Vector2(110, 38))
	_draw_ink_panel(gold_header, Color("#fff4d9"), Color("#8e7661"), 8.0, false)
	draw_string(_font(), gold_header.position + Vector2(0, 15), "金币 %.1f" % gold, HORIZONTAL_ALIGNMENT_CENTER, gold_header.size.x, 13, Color("#725f39"))
	draw_string(_font(), gold_header.position + Vector2(0, 31), "用于派兵", HORIZONTAL_ALIGNMENT_CENTER, gold_header.size.x, 9, Color("#725f39"))
	_draw_ink_panel(skill_header, Color("#edf5ff"), Color("#4f789f"), 8.0, false)
	draw_string(_font(), skill_header.position + Vector2(0, 13), "技能点 %.1f/10" % energy, HORIZONTAL_ALIGNMENT_CENTER, skill_header.size.x, 11, Color("#3f6270"))
	_draw_bar(Rect2(skill_header.position + Vector2(9, 22), Vector2(skill_header.size.x - 18, 7)), energy / RESOURCE_MAX, Color("#8fb5d8"), Color("#c9d5df"))
	draw_rect(Rect2(panel.position + Vector2(142, 56), Vector2(110, 14)), Color("#eef7df"), true)
	draw_rect(Rect2(panel.position + Vector2(260, 56), Vector2(110, 14)), Color("#e6f0fb"), true)
	draw_string(_font(), panel.position + Vector2(142, 67), "左列派兵", HORIZONTAL_ALIGNMENT_CENTER, 110, 9, Color("#3f6545"))
	draw_string(_font(), panel.position + Vector2(260, 67), "右列技能", HORIZONTAL_ALIGNMENT_CENTER, 110, 9, Color("#3f6270"))

func _draw_end_overlay() -> void:
	if not game_over:
		return
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0, 0, 0, 0.5), true)
	# 胜负主题色
	var seal_color := Color("#c8902f") if victory else Color("#6f7b86")
	var border_color := Color("#c69a4f") if victory else Color("#6a5e57")
	var title_text := "胜 利" if victory else "失 败"
	var seal_text := "胜" if victory else "败"
	var detail := ""
	if victory:
		detail = "击败「%s」" % boss_def["name"] if boss_hp <= 0.0 else "守住了整场怪潮"
	else:
		detail = "敌兵闯入我方领域"
	var panel := Rect2(54, 286, 282, 242)
	_draw_ink_panel(panel, Color("#fff7e8"), border_color, 12.0)
	# 顶部圆形印章徽记
	var seal_center := panel.position + Vector2(panel.size.x * 0.5, 46.0)
	for i in range(5):
		draw_circle(seal_center, 34.0 - float(i) * 2.0, Color(seal_color.r, seal_color.g, seal_color.b, 0.12 + 0.04 * float(i)))
	draw_circle(seal_center, 28.0, seal_color)
	draw_arc(seal_center, 28.0, 0.0, TAU, 40, Color(1.0, 0.96, 0.86, 0.85), 2.0)
	draw_string(_font_medium(), seal_center + Vector2(-15.0, 12.0), seal_text, HORIZONTAL_ALIGNMENT_CENTER, 30.0, 30, Color("#fff7e8"))
	# 主标题
	draw_string(_font_medium(), panel.position + Vector2(0, 112), title_text, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 32, Color("#5b4238"))
	# 详情 + 用时统计（在按钮上方）
	draw_string(_font(), panel.position + Vector2(0, 140), detail, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 14, Color("#6c5c50"))
	draw_string(_font(), panel.position + Vector2(0, 160), "用时 %d 秒 · 残敌 %d" % [int(round(elapsed)), _count_side("enemy")], HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 11, Color("#9a8a7c"))

func _count_side(side: String) -> int:
	var n := 0
	for u in units:
		if String(u["side"]) == side:
			n += 1
	return n

# 全局字体：霞鹜文楷（OFL 开源楷体，国风手写感）；加载失败回退系统字体
var game_font: Font = null
var game_font_medium: Font = null

func _font() -> Font:
	if game_font:
		return game_font
	return ThemeDB.fallback_font

func _font_medium() -> Font:
	if game_font_medium:
		return game_font_medium
	return _font()

func _load_fonts() -> void:
	game_font = ResourceLoader.load("res://assets/fonts/LXGWWenKaiLite-Regular.ttf") as Font
	game_font_medium = ResourceLoader.load("res://assets/fonts/LXGWWenKaiLite-Medium.ttf") as Font

func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0.24, 0.16, 0.1, 0.25)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 2)
	return style

# 国风面板：投影 + 圆角底 + 深棕外框 + 描金内线 + 四角金色角花
func _draw_ink_panel(rect: Rect2, fill: Color, border: Color, corner_radius := 8.0, gold_accent := true) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(int(corner_radius))
	style.shadow_color = Color(0.22, 0.14, 0.09, 0.3)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	style.draw(get_canvas_item(), rect)
	if not gold_accent:
		return
	# 描金内线
	var inner := StyleBoxFlat.new()
	inner.bg_color = Color(0, 0, 0, 0)
	inner.border_color = Color(0.78, 0.62, 0.33, 0.65)
	inner.set_border_width_all(1)
	inner.set_corner_radius_all(int(max(2.0, corner_radius - 3.0)))
	inner.draw(get_canvas_item(), rect.grow(-4.0))
	# 四角角花：短双线
	var gold := Color(0.72, 0.55, 0.26, 0.9)
	var arm: float = min(9.0, rect.size.x * 0.12)
	var inset := 2.5
	for corner_index in range(4):
		var cx: float = rect.position.x + inset if corner_index % 2 == 0 else rect.end.x - inset
		var cy: float = rect.position.y + inset if corner_index < 2 else rect.end.y - inset
		var dx: float = 1.0 if corner_index % 2 == 0 else -1.0
		var dy: float = 1.0 if corner_index < 2 else -1.0
		draw_line(Vector2(cx, cy + dy * 2.0), Vector2(cx + dx * arm, cy + dy * 2.0), gold, 1.4)
		draw_line(Vector2(cx + dx * 2.0, cy), Vector2(cx + dx * 2.0, cy + dy * arm), gold, 1.4)

func _transparent_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0)
	style.border_color = Color(1, 1, 1, 0)
	return style

func _run_qa_simulation() -> void:
	for i in range(900):
		if i == 60:
			_deploy_player_troop(0, 0)
		elif i == 180:
			_deploy_player_troop(1, 1)
		elif i == 300:
			energy = RESOURCE_MAX
			_cast_player_skill(0, 0)
		elif i == 420:
			gold = RESOURCE_MAX
			_deploy_player_troop(2, 2)
		_process(1.0 / 60.0)
	deploy_cd_left.clear()
	skill_cd_left.clear()
	var deploy_test_before := units.size()
	gold = RESOURCE_MAX
	_begin_deploy_troop(0, 0)
	var deploy_rect := _player_deploy_rect()
	var deploy_test_ok := _try_place_pending_deploy(deploy_rect.position + Vector2(1.0, 1.0))
	# 冷却拦截：刚派完的 (0,0) 立刻再点应被冷却挡住
	_begin_deploy_troop(0, 0)
	var deploy_cd_blocks_ok := pending_deploy.is_empty() and _deploy_cd_remaining(0, 0) > 0.0
	gold = RESOURCE_MAX
	_begin_deploy_troop(1, 0)
	deploy_test_ok = _try_place_pending_deploy(deploy_rect.end - Vector2(1.0, 1.0)) and deploy_test_ok
	var click_added_units := units.size() - deploy_test_before
	var drag_test_before := units.size()
	gold = RESOURCE_MAX
	_begin_deploy_troop(2, 0)
	var drag_start := deploy_rect.position + Vector2(42.0, 64.0)
	var drag_test_ok := _begin_pending_deploy_press(drag_start)
	for step in range(1, 7):
		_update_drag_deploy(drag_start + Vector2(float(step) * DEPLOY_DRAG_SPACING, 0.0))
	_finish_pending_deploy_press(drag_start + Vector2(6.0 * DEPLOY_DRAG_SPACING, 0.0))
	var drag_added_units := units.size() - drag_test_before
	var skill_test_before := effects.size()
	energy = RESOURCE_MAX
	_begin_cast_skill(0, 0)
	var skill_test_ok := _try_cast_pending_skill(FIELD_RECT.position + Vector2(34.0, 34.0))
	energy = RESOURCE_MAX
	_begin_cast_skill(2, 0)
	skill_test_ok = _try_cast_pending_skill(FIELD_RECT.end - Vector2(34.0, 34.0)) and skill_test_ok
	# 冷却拦截：刚放完的 (2,0) 立刻再点应被冷却挡住
	energy = RESOURCE_MAX
	_begin_cast_skill(2, 0)
	var skill_cd_blocks_ok := pending_skill.is_empty() and _skill_cd_remaining(2, 0) > 0.0
	var projectile_test_before := effects.size()
	_spawn_unit("player", "sour_mender", FIELD_RECT.position + Vector2(140.0, 342.0), "pickle")
	_spawn_unit("enemy", "crumb", FIELD_RECT.position + Vector2(152.0, 246.0), "boss")
	_attack_unit(units.size() - 2, units.size() - 1)
	var projectile_count := 0
	for effect in effects:
		if String(effect.get("kind", "")) in ["ranged_shot", "seek_slash", "boss_shot"]:
			projectile_count += 1
	var projectile_test_added := effects.size() - projectile_test_before
	var saved_units := units.duplicate(true)
	var saved_next_unit_id := next_unit_id
	units = []
	_spawn_unit("enemy", "crumb", FIELD_RECT.position + Vector2(190.0, 284.0), "qa")
	_spawn_unit("player", "pickle_leaf", FIELD_RECT.position + Vector2(190.0, 312.0), "qa")
	units[0]["attack_timer"] = 0.0
	var attack_target_hp_start := float(units[1]["hp"])
	_update_units(0.05)
	var crumb_attack_state_ok := String(units[0].get("anim_state", "")) == "attack"
	var attack_target_hp_before_hit := float(units[1]["hp"])
	_update_units(CRUMB_ATTACK_HIT_TIME + 0.03)
	var attack_target_hp_after_hit := float(units[1]["hp"])
	var crumb_attack_delayed_hit_ok := is_equal_approx(attack_target_hp_start, attack_target_hp_before_hit) and attack_target_hp_after_hit < attack_target_hp_before_hit
	units = saved_units
	next_unit_id = saved_next_unit_id
	saved_units = units.duplicate(true)
	saved_next_unit_id = next_unit_id
	units = []
	_spawn_unit("enemy", "crumb", FIELD_RECT.position + Vector2(190.0, 300.0), "qa")
	_spawn_unit("player", "pickle_leaf", FIELD_RECT.position + Vector2(190.0, 282.0), "qa")
	var melee_front_filter_ok := _resolve_attack_target(0, units[0]) == -1 and _resolve_attack_target(1, units[1]) == -1
	units = []
	_spawn_unit("enemy", "crumb", FIELD_RECT.position + Vector2(190.0, 282.0), "qa")
	_spawn_unit("player", "pickle_leaf", FIELD_RECT.position + Vector2(190.0, 300.0), "qa")
	var melee_front_attack_ok := _resolve_attack_target(0, units[0]) == 1 and _resolve_attack_target(1, units[1]) == 0
	units = []
	_spawn_unit("enemy", "crumb", FIELD_RECT.position + Vector2(190.0, 286.0), "qa")
	_spawn_unit("player", "pickle_leaf", FIELD_RECT.position + Vector2(190.0, 292.0), "qa")
	for step in range(48):
		_update_units(1.0 / 60.0)
	var cross_side_no_overlap_ok := false
	if units.size() >= 2:
		var overlap_distance := (units[0]["pos"] as Vector2).distance_to(units[1]["pos"] as Vector2)
		cross_side_no_overlap_ok = overlap_distance >= float(units[0]["radius"]) + float(units[1]["radius"]) - 0.5
	units = saved_units
	next_unit_id = saved_next_unit_id
	var attack_clear_rule := true
	# ---- 死亡事件系统断言 ----
	saved_units = units.duplicate(true)
	saved_next_unit_id = next_unit_id
	var saved_death_events := death_events.duplicate(true)
	var saved_event_cd := death_event_cd
	# 权重表合计应为 10%
	var event_total_weight := 0.0
	for entry in DEATH_EVENT_TABLE:
		event_total_weight += float(entry[1])
	var event_table_ok: bool = absf(event_total_weight - 0.20) < 0.0001 and DEATH_EVENT_TABLE.size() == 10
	# 陨石：圈内即死，圈外无伤
	units = []
	death_events = []
	_spawn_unit("player", "pickle_leaf", FIELD_RECT.position + Vector2(190.0, 300.0), "qa")
	_spawn_unit("enemy", "crumb", FIELD_RECT.position + Vector2(190.0, 460.0), "qa")
	var meteor_center: Vector2 = units[0]["pos"]
	_meteor_impact(meteor_center, 48.0)
	var meteor_kill_ok: bool = float(units[0]["hp"]) <= 0.0 and float(units[1]["hp"]) > 0.0
	# 冰冻：圈内单位获得 frozen_timer 且冻结期间不移动
	units = []
	_spawn_unit("enemy", "crumb", FIELD_RECT.position + Vector2(190.0, 300.0), "qa")
	_apply_freeze(units[0]["pos"], 60.0, 2.6, 8.0)
	var freeze_pos_before: Vector2 = units[0]["pos"]
	_update_units(0.2)
	var freeze_ok: bool = float(units[0]["frozen_timer"]) > 0.0 and (units[0]["pos"] as Vector2).is_equal_approx(freeze_pos_before)
	# 鼓舞：rally_timer 生效且伤害乘区为 1.5
	units = []
	_spawn_unit("player", "pickle_leaf", FIELD_RECT.position + Vector2(190.0, 300.0), "qa")
	_buff_side("player", 6.0)
	var rally_ok: bool = float(units[0]["rally_timer"]) > 0.0
	# 疾风：haste_timer 让速度乘区 = 1.5
	units[0]["haste_timer"] = 5.0
	var haste_ok: bool = is_equal_approx(_unit_speed_factor(units[0]), 1.5)
	# 幽魂重生：复活体为半血幽魂且限时
	units = []
	_spawn_unit("player", "pickle_leaf", FIELD_RECT.position + Vector2(190.0, 300.0), "qa")
	var dead_copy: Dictionary = units[0].duplicate(true)
	units = []
	_revive_ghost(dead_copy)
	var ghost_ok: bool = units.size() == 1 and bool(units[0]["is_ghost"]) and float(units[0]["ghost_timer"]) > 0.0
	# 徽章：同种刷新不叠加、瞬发标记正确、到期自动移除
	var saved_badges := event_badges.duplicate(true)
	event_badges = []
	death_events = []
	_add_event_badge("storm")
	_add_event_badge("storm")
	_add_event_badge("gold_windfall")
	var badge_ok: bool = event_badges.size() == 2 and not bool(event_badges[0]["instant"]) and bool(event_badges[1]["instant"])
	_update_death_events(10.0)
	badge_ok = badge_ok and event_badges.is_empty()
	event_badges = saved_badges
	units = saved_units
	next_unit_id = saved_next_unit_id
	death_events = saved_death_events
	death_event_cd = saved_event_cd
	var qa_path := "res://qa/qa_result.txt"
	var file := FileAccess.open(qa_path, FileAccess.WRITE)
	if file:
		file.store_line("qa=ok")
		file.store_line("units=%d" % units.size())
		file.store_line("deploy_click_ok=%s" % str(deploy_test_ok))
		file.store_line("deploy_added_units=%d" % click_added_units)
		file.store_line("drag_deploy_ok=%s" % str(drag_test_ok))
		file.store_line("drag_added_units=%d" % drag_added_units)
		file.store_line("deploy_cd_blocks_ok=%s" % str(deploy_cd_blocks_ok))
		file.store_line("skill_cd_blocks_ok=%s" % str(skill_cd_blocks_ok))
		file.store_line("pickle_leaf_cd=%.1f" % float(hero_defs[0]["troops"][0]["cd"]))
		file.store_line("summon_vine_cd=%.1f" % float(hero_defs[2]["skills"][2]["cd"]))
		file.store_line("pickle_leaf_unit_price=%.2f" % _troop_unit_price(hero_defs[0]["troops"][0]))
		file.store_line("skill_click_ok=%s" % str(skill_test_ok))
		file.store_line("skill_cutin_ok=%s" % str(cutin_timer > 0.0 and cutin_hero_index >= 0))
		file.store_line("skill_effects_added=%d" % (effects.size() - skill_test_before))
		file.store_line("projectile_effects=%d" % projectile_count)
		file.store_line("projectile_test_added=%d" % projectile_test_added)
		file.store_line("crumb_attack_sheet_loaded=%s" % str(crumb_attack_texture != null))
		file.store_line("crumb_attack_state_ok=%s" % str(crumb_attack_state_ok))
		file.store_line("crumb_attack_delayed_hit_ok=%s" % str(crumb_attack_delayed_hit_ok))
		file.store_line("melee_front_filter_ok=%s" % str(melee_front_filter_ok))
		file.store_line("melee_front_attack_ok=%s" % str(melee_front_attack_ok))
		file.store_line("cross_side_no_overlap_ok=%s" % str(cross_side_no_overlap_ok))
		file.store_line("attack_clear_rule=%s" % str(attack_clear_rule))
		file.store_line("event_table_ok=%s" % str(event_table_ok))
		file.store_line("event_meteor_kill_ok=%s" % str(meteor_kill_ok))
		file.store_line("event_freeze_ok=%s" % str(freeze_ok))
		file.store_line("event_rally_ok=%s" % str(rally_ok))
		file.store_line("event_haste_ok=%s" % str(haste_ok))
		file.store_line("event_ghost_ok=%s" % str(ghost_ok))
		file.store_line("event_badge_ok=%s" % str(badge_ok))
		file.store_line("sour_mender_range=%.0f/%.0f/%.2f" % [float(unit_defs["sour_mender"]["attack_range"]), float(unit_defs["sour_mender"]["lock_range"]), float(unit_defs["sour_mender"]["interval"])])
		file.store_line("old_vine_range=%.0f/%.0f/%.2f" % [float(unit_defs["old_vine"]["attack_range"]), float(unit_defs["old_vine"]["lock_range"]), float(unit_defs["old_vine"]["interval"])])
		file.store_line("sesame_shadow_global=%s" % str(bool(unit_defs["sesame_shadow"].get("global_seek", false))))
		file.store_line("gold=%.2f" % gold)
		file.store_line("energy=%.2f" % energy)
		file.store_line("boss_hp=%.2f" % boss_hp)
		file.store_line("survive_left=%.2f" % survive_left)
		file.store_line("boss_next_skill=%.2f" % _next_boss_skill_time())
		file.store_line("boss_attack_interval=%.2f" % BOSS_ATTACK_INTERVAL)
		file.store_line("game_over=%s" % str(game_over))
		file.store_line("victory=%s" % str(victory))
		file.store_line("sfx_events_loaded=%d/%d" % [sfx_streams.size(), SFX_VOLUMES.size()])
		var sfx_variant_total := 0
		for sfx_name in sfx_streams:
			sfx_variant_total += (sfx_streams[sfx_name] as Array).size()
		file.store_line("sfx_variants_total=%d" % sfx_variant_total)
	await get_tree().process_frame
	_capture_qa_screenshot()

# ============ 数值平衡模拟（headless 自动对战） ============
# 用贪心策略代替玩家：每 0.5s 随机派一种买得起且不在冷却的兵 + 放一个买得起的技能（瞄准最前沿敌兵）。
# 跑多局多英雄，统计胜率/结束时间/Boss 残血/事件频率/最近失守距离，写 qa/balance_result.txt。
func _run_qa_balance() -> void:
	var games_per_config := 24
	var dt := 1.0 / 30.0
	var max_steps := int((SURVIVE_TIME + 2.0) / dt)
	var prng := RandomNumberGenerator.new()
	# 全部用真实的「三英雄同时在手」配置，只变动决策间隔来逼近不同操作强度的玩家
	var configs := [
		{"name": "高手(0.5s/手)", "heroes": [0, 1, 2], "interval": 0.5},
		{"name": "熟练(1.5s/手)", "heroes": [0, 1, 2], "interval": 1.5},
		{"name": "普通(2.5s/手)", "heroes": [0, 1, 2], "interval": 2.5},
		{"name": "手忙(4.0s/手)", "heroes": [0, 1, 2], "interval": 4.0},
	]
	var lines: Array[String] = []
	lines.append("balance=ok")
	lines.append("games_per_config=%d" % games_per_config)
	lines.append("survive_time=%.0f gold_regen=%.2f energy_regen=%.2f boss_hp=%.0f" % [SURVIVE_TIME, GOLD_REGEN, ENERGY_REGEN, BOSS_MAX_HP])
	for config in configs:
		var heroes: Array = config["heroes"]
		var decision_interval := float(config["interval"])
		var wins := 0
		var survive_wins := 0
		var boss_wins := 0
		var entry_losses := 0
		var sum_end_time := 0.0
		var sum_boss_hp := 0.0
		var sum_events := 0
		var sum_player_alive := 0.0
		var sum_enemy_alive := 0.0
		var sum_min_margin := 0.0
		for g in range(games_per_config):
			var seed_v := 1000 + g * 7
			rng.seed = seed_v
			prng.seed = seed_v * 13 + 5
			_restart_game()
			var decision_acc := 0.0
			var event_count := 0
			var prev_event_cd := death_event_cd
			var min_margin := 9999.0
			for step in range(max_steps):
				decision_acc += dt
				if decision_acc >= decision_interval:
					decision_acc = 0.0
					_balance_player_policy(heroes, prng)
				_process(dt)
				# 通过全局冷却被重置来计数事件触发次数
				if death_event_cd > prev_event_cd + 0.01:
					event_count += 1
				prev_event_cd = death_event_cd
				# 记录最危险敌兵距失守线的最近距离
				var front_y := -9999.0
				for u in units:
					if String(u["side"]) == "enemy":
						front_y = max(front_y, float(u["pos"].y))
				if front_y > -9000.0:
					min_margin = min(min_margin, ENEMY_ENTRY_Y - front_y)
				if game_over:
					break
			var p_alive := 0
			var e_alive := 0
			for u in units:
				if String(u["side"]) == "player":
					p_alive += 1
				else:
					e_alive += 1
			sum_end_time += elapsed
			sum_boss_hp += boss_hp
			sum_events += event_count
			sum_player_alive += float(p_alive)
			sum_enemy_alive += float(e_alive)
			sum_min_margin += (min_margin if min_margin < 9000.0 else 0.0)
			if victory:
				wins += 1
				if boss_hp <= 0.0:
					boss_wins += 1
				else:
					survive_wins += 1
			else:
				entry_losses += 1
		var n := float(games_per_config)
		lines.append("---- %s ----" % config["name"])
		lines.append("win_rate=%.0f%% (survive=%d boss=%d) loss_entry=%d" % [100.0 * float(wins) / n, survive_wins, boss_wins, entry_losses])
		lines.append("avg_end_time=%.1fs avg_boss_hp=%.0f/%.0f (%.0f%%)" % [sum_end_time / n, sum_boss_hp / n, BOSS_MAX_HP, 100.0 * (sum_boss_hp / n) / BOSS_MAX_HP])
		lines.append("avg_events_per_game=%.2f avg_player_alive=%.1f avg_enemy_alive=%.1f avg_min_margin=%.0fpx" % [float(sum_events) / n, sum_player_alive / n, sum_enemy_alive / n, sum_min_margin / n])
	var bpath := "res://qa/balance_result.txt"
	var bfile := FileAccess.open(bpath, FileAccess.WRITE)
	if bfile:
		for line in lines:
			bfile.store_line(line)
		bfile.close()
	for line in lines:
		print(line)
	get_tree().quit()

func _run_qa_end_screenshot() -> void:
	var defeat := "--defeat" in OS.get_cmdline_user_args()
	for x in [110.0, 170.0, 230.0, 290.0]:
		_spawn_unit("enemy", "crumb", Vector2(x, 200.0), "qa")
	elapsed = 73.0
	boss_hp = 0.0 if not defeat else 240.0
	game_over = true
	victory = not defeat
	if end_restart_button:
		end_restart_button.visible = true
	queue_redraw()
	await get_tree().process_frame
	_capture_qa_screenshot()

func _balance_front_target() -> Vector2:
	var best_y := -9999.0
	var pos := FIELD_RECT.get_center()
	for u in units:
		if String(u["side"]) == "enemy" and float(u["pos"].y) > best_y:
			best_y = float(u["pos"].y)
			pos = u["pos"]
	return _clamp_skill_pos(pos)

func _balance_player_policy(active_heroes: Array, prng: RandomNumberGenerator) -> void:
	var target := _balance_front_target()
	for card in active_heroes:
		var skills: Array = hero_defs[card]["skills"]
		var affordable_skills: Array[int] = []
		for si in range(skills.size()):
			if _skill_cd_remaining(card, si) <= 0.0 and energy + 0.001 >= float(skills[si]["cost"]):
				affordable_skills.append(si)
		if not affordable_skills.is_empty():
			_cast_player_skill_at(card, affordable_skills[prng.randi_range(0, affordable_skills.size() - 1)], target)
	for card in active_heroes:
		var troops: Array = hero_defs[card]["troops"]
		var affordable_troops: Array[int] = []
		for ti in range(troops.size()):
			if _deploy_cd_remaining(card, ti) <= 0.0 and gold + 0.001 >= _troop_unit_price(troops[ti]):
				affordable_troops.append(ti)
		if not affordable_troops.is_empty():
			_deploy_player_troop(card, affordable_troops[prng.randi_range(0, affordable_troops.size() - 1)])

func _run_qa_visual_screenshot() -> void:
	gold = RESOURCE_MAX
	energy = RESOURCE_MAX
	_deploy_player_troop(0, 1)
	gold = RESOURCE_MAX
	_deploy_player_troop(1, 1)
	boss_gold = RESOURCE_MAX
	_boss_try_deploy()
	energy = RESOURCE_MAX
	_cast_player_skill(0, 0)
	for i in range(300):
		_process(1.0 / 60.0)
	_spawn_pack_at("player", {"unit": "sour_mender", "count": 1, "formation": "point"}, "pickle", Vector2(138, 458))
	# 截图演示用：三个酸叶兵走路帧 + 一个攻击帧定格
	for demo_x in [96.0, 144.0, 192.0]:
		_spawn_unit("player", "pickle_leaf", Vector2(demo_x, 520.0), "qa")
	_spawn_unit("player", "pickle_leaf", Vector2(240.0, 520.0), "qa")
	units[-1]["anim_state"] = "attack"
	units[-1]["attack_anim_time"] = 0.66
	units[-1]["attack_hit_done"] = true
	units[-1]["attack_dir_x"] = 1.0
	_spawn_unit("player", "pickle_leaf", Vector2(284.0, 520.0), "qa")
	units[-1]["anim_state"] = "attack"
	units[-1]["attack_anim_time"] = 0.66
	units[-1]["attack_hit_done"] = true
	units[-1]["attack_dir_x"] = -1.0
	# 攻击距离视觉核对：敌兵站在攻击判定边缘（attack_range 31 + 敌半径 9）
	_spawn_unit("enemy", "crumb", Vector2(252.0, 484.0), "qa")
	# 截图演示用：三个命中特效定格在不同帧（长寿命防止启动帧耗尽）
	for demo in [[Vector2(120, 380), 5.7], [Vector2(195, 420), 4.5], [Vector2(265, 460), 2.7]]:
		_add_effect(demo[0], Color("#d85f3f"), "hit")
		effects[-1]["time"] = float(demo[1])
		effects[-1]["max_time"] = 6.0
	selected_card = -1
	pending_skill.clear()
	pending_deploy.clear()
	hovered_unit_id = -1
	for unit in units:
		if String(unit.get("role", "")) == "ranged":
			hovered_unit_id = int(unit["id"])
			break
	_show_options(0)
	panel_anim = 1.0
	_add_boss_warning(1)
	# Boss 蓄力定格在临爆段（剩 0.8s → charge≈0.73，触发收束弧+抖动）
	var qa_timers: Array = boss_state["skill_timers"]
	var qa_warned: Array = boss_state["skill_warned"]
	qa_timers[1] = 0.8
	qa_warned[1] = true
	boss_state["skill_timers"] = qa_timers
	boss_state["skill_warned"] = qa_warned
	# Boss cut-in 定格在停留段中部
	cutin_timer = CUTIN_DURATION - 0.4
	cutin_hero_index = -1
	cutin_skill_name = "火签齐射"
	cutin_is_boss = true
	# 死亡消散三个进度定格：白闪段 / 烟雾绽放段 / 烟雾上飘淡出段（放在空旷区避免与演示兵重叠）
	# time/max_time 等比放大 10 倍：进度比例不变，但能扛住启动慢帧不被耗尽
	effects.append({"pos": Vector2(90.0, 400.0), "color": Color("#9fc978"), "time": 8.2, "max_time": 9.0, "radius": 8.5, "kind": "death", "unit_id": "pickle_leaf", "seed": 3})
	effects.append({"pos": Vector2(195.0, 442.0), "color": Color("#c9b98b"), "time": 5.0, "max_time": 9.0, "radius": 8.0, "kind": "death", "unit_id": "crumb", "seed": 5})
	effects.append({"pos": Vector2(305.0, 400.0), "color": Color("#dce5e7"), "time": 2.0, "max_time": 9.0, "radius": 8.5, "kind": "death", "unit_id": "salt_grunt", "seed": 8})
	await get_tree().process_frame
	_capture_qa_screenshot()

func _run_qa_effects_screenshot() -> void:
	selected_card = -1
	pending_skill.clear()
	pending_deploy.clear()
	hovered_unit_id = -1
	units = []
	var kinds: Array = ["mist", "shield_wave", "summon", "shadow", "heal", "rain", "root", "weaken", "vine", "boss_barrage"]
	var labels: Array = ["开坛酸雾", "酸叶护阵", "发酵增援", "糯影分身", "甜糯结界", "芝麻夜雨", "苦藤缠绕", "清苦压制", "老藤守门", "火签齐射"]
	var fx_colors: Array = [Color("#9fc978"), Color("#9fc978"), Color("#b79970"), Color("#3f3b3b"), Color("#f0d7a4"), Color("#3f3b3b"), Color("#506337"), Color("#506337"), Color("#506337"), Color("#d85f3f")]
	for i in range(kinds.size()):
		var col := i % 2
		var row := floori(float(i) * 0.5)
		var fx_pos := Vector2(110.0 + float(col) * 170.0, 130.0 + float(row) * 100.0)
		effects.append({"pos": fx_pos, "color": fx_colors[i], "time": 2.7, "max_time": 6.0, "radius": 44.0, "kind": kinds[i]})
		_add_text(fx_pos + Vector2(-26.0, -52.0), String(labels[i]), Color("#4d423a"))
		texts[-1]["time"] = 6.0
		texts[-1]["max_time"] = 6.0
	queue_redraw()
	await get_tree().process_frame
	_capture_qa_screenshot()

# 死亡事件展示：摆出预警圈/毒雾/冰雹/疾风 + 各事件 VFX + 状态单位 + 横幅，供截图验收
func _run_qa_events_screenshot() -> void:
	selected_card = -1
	pending_skill.clear()
	pending_deploy.clear()
	hovered_unit_id = -1
	units = []
	death_events = []
	effects.clear()
	# 区域类事件：陨石预警 / 毒雾 / 冰雹 / 疾风风纹
	death_events.append({"kind": "meteor", "pos": Vector2(100.0, 215.0), "radius": 46.0, "timer": 9.0, "warn_total": 10.0})
	death_events.append({"kind": "dot_zone", "pos": Vector2(285.0, 215.0), "radius": 58.0, "timer": 9.0, "tick": 9.0})
	death_events.append({"kind": "hail", "pos": Vector2(100.0, 370.0), "radius": 62.0, "timer": 9.0, "applied": true})
	death_events.append({"kind": "haste_wind", "timer": 9.0})
	_add_text(Vector2(68.0, 152.0), "陨石预警", Color("#8d3427"))
	_add_text(Vector2(253.0, 140.0), "灼热毒雾", Color("#5c6e33"))
	_add_text(Vector2(68.0, 292.0), "冰雹风暴", Color("#4f789f"))
	# 瞬时 VFX：闪电 / 陨石爆炸 / 冰爆 / 增益 / 重生
	effects.append({"pos": Vector2(195.0, 480.0), "color": Color("#cfe0ff"), "time": 5.2, "max_time": 6.0, "radius": 26.0, "kind": "lightning", "seed": 137})
	effects.append({"pos": Vector2(300.0, 480.0), "color": Color("#e8743f"), "time": 4.2, "max_time": 6.0, "radius": 44.0, "kind": "meteor_blast"})
	effects.append({"pos": Vector2(90.0, 480.0), "color": Color("#bcdcf0"), "time": 4.2, "max_time": 6.0, "radius": 40.0, "kind": "ice_burst"})
	effects.append({"pos": Vector2(250.0, 350.0), "color": Color("#e8c25a"), "time": 4.2, "max_time": 6.0, "radius": 22.0, "kind": "buff_glow"})
	effects.append({"pos": Vector2(330.0, 350.0), "color": Color("#9a7ab0"), "time": 4.2, "max_time": 6.0, "radius": 24.0, "kind": "rebirth_glow"})
	_add_text(Vector2(171.0, 430.0), "闪电", Color("#3d4a6b"))
	_add_text(Vector2(272.0, 416.0), "陨石爆炸", Color("#8d3427"))
	_add_text(Vector2(66.0, 426.0), "冰爆", Color("#4f789f"))
	_add_text(Vector2(228.0, 310.0), "增益", Color("#8a6a1f"))
	_add_text(Vector2(310.0, 310.0), "重生", Color("#6b4a7c"))
	# 状态单位：冰冻 / 幽魂 / 鼓舞+疾风
	_spawn_unit("player", "pickle_leaf", Vector2(100.0, 370.0), "qa")
	units[-1]["frozen_timer"] = 9.0
	_spawn_unit("player", "sesame_dough", Vector2(330.0, 350.0), "qa")
	units[-1]["is_ghost"] = true
	units[-1]["ghost_timer"] = 9.0
	_spawn_unit("enemy", "crumb", Vector2(250.0, 350.0), "qa")
	units[-1]["rally_timer"] = 9.0
	units[-1]["haste_timer"] = 9.0
	# 左侧事件徽章：持续型（进度条不同进度）+ 瞬发型 + 陨石预警态
	event_badges = []
	_add_event_badge("storm")
	_add_event_badge("dot_zone")
	event_badges[-1]["time_left"] = 2.2
	_add_event_badge("haste")
	event_badges[-1]["time_left"] = 0.8
	_add_event_badge("meteor")
	_add_event_badge("gold_windfall")
	# 中央大印记：定格在淡出中段以便截图验收（放在徽章之后避免被覆盖）
	_show_event_seal(EVENT_BADGE_DEFS["storm"])
	event_seal["timer"] = 0.7
	for t in texts:
		t["time"] = 6.0
		t["max_time"] = 6.0
	queue_redraw()
	await get_tree().process_frame
	_capture_qa_screenshot()

func _run_qa_units_screenshot() -> void:
	selected_card = -1
	pending_skill.clear()
	hovered_unit_id = -1
	units = []
	var order: Array = ["pickle_leaf", "sour_mender", "jar_guard", "sesame_dough", "sesame_shadow", "sweet_guard", "bitter_sprout", "bitter_guard", "old_vine", "crumb", "salt_grunt", "pepper_imp", "fire_skewer", "pepper_jar"]
	for i in range(order.size()):
		var uid: String = order[i]
		if not unit_defs.has(uid):
			continue
		var col := i % 3
		var row := floori(float(i) / 3.0)
		var base := Vector2(70.0 + float(col) * 110.0, 110.0 + float(row) * 88.0)
		var side := "enemy" if uid in ["crumb", "salt_grunt", "pepper_imp", "fire_skewer", "pepper_jar"] else "player"
		_spawn_unit(side, uid, base, "qa")
		_spawn_unit(side, uid, base + Vector2(46.0, 0.0), "qa")
		units[-1]["anim_state"] = "attack"
		units[-1]["attack_anim_time"] = 0.66
		units[-1]["attack_hit_done"] = true
		units[-1]["attack_dir_x"] = 1.0
		_add_text(base + Vector2(-8.0, -34.0), String(unit_defs[uid]["name"]), Color("#4d423a"))
		texts[-1]["time"] = 6.0
		texts[-1]["max_time"] = 6.0
	# 出兵悬浮预览核对：半透明小兵图替代旧色块
	pending_deploy = {"card_index": 0, "troop_index": 0, "placed_count": 0, "pressing": false, "drag_mode": false, "has_last_place": false, "last_place_pos": Vector2.ZERO, "press_pos": Vector2.ZERO}
	deploy_preview_pos = _default_deploy_pos()
	queue_redraw()
	await get_tree().process_frame
	_capture_qa_screenshot()

func _run_qa_facing_screenshot() -> void:
	# 8 向核对：3 个全图刺客各画 8 个朝向，验证多向选行/镜像正确不穿帮
	selected_card = -1
	pending_skill.clear()
	pending_deploy.clear()
	hovered_unit_id = -1
	units = []
	var dirs := [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)]
	var labels := ["右", "右下", "下", "左下", "左", "左上", "上", "右上"]
	var rows := [["sesame_shadow", "player"], ["pepper_imp", "enemy"], ["fire_skewer", "enemy"]]
	for r in range(rows.size()):
		var uid: String = rows[r][0]
		var side: String = rows[r][1]
		var y := 165.0 + float(r) * 190.0
		_add_text(Vector2(16.0, y - 78.0), String(unit_defs[uid]["name"]), Color("#4d423a"))
		texts[-1]["time"] = 9.0
		texts[-1]["max_time"] = 9.0
		for d in range(dirs.size()):
			var x := 34.0 + float(d) * 44.0
			_spawn_unit(side, uid, Vector2(x, y), "qa")
			units[-1]["face_dir"] = (dirs[d] as Vector2).normalized()
			# 中间行用攻击姿态，验证方向攻击图也不穿帮
			if r == 1:
				units[-1]["anim_state"] = "attack"
				units[-1]["attack_anim_time"] = 0.6
				units[-1]["attack_hit_done"] = true
			else:
				units[-1]["anim_state"] = "walk"
			if r == 0:
				_add_text(Vector2(x - 12.0, 84.0), labels[d], Color("#776a5f"))
				texts[-1]["time"] = 9.0
				texts[-1]["max_time"] = 9.0
	queue_redraw()
	await get_tree().process_frame
	_capture_qa_screenshot()

func _run_qa_initial_screenshot() -> void:
	selected_card = -1
	pending_skill.clear()
	pending_deploy.clear()
	hovered_unit_id = -1
	tutorial_hint_timer = 9.0
	for i in range(120):
		_process(1.0 / 60.0)
	await get_tree().process_frame
	_capture_qa_screenshot()

func _run_qa_title_screenshot() -> void:
	_enter_title()
	title_elapsed = 0.4
	await get_tree().process_frame
	_capture_qa_screenshot()

func _capture_qa_screenshot() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var should_quit := "--qa-run" in OS.get_cmdline_user_args() or "--qa-screenshot" in OS.get_cmdline_user_args() or "--qa-initial-screenshot" in OS.get_cmdline_user_args() or "--qa-effects-screenshot" in OS.get_cmdline_user_args() or "--qa-units-screenshot" in OS.get_cmdline_user_args() or "--qa-facing-screenshot" in OS.get_cmdline_user_args() or "--qa-title-screenshot" in OS.get_cmdline_user_args() or "--qa-events-screenshot" in OS.get_cmdline_user_args() or "--qa-end-screenshot" in OS.get_cmdline_user_args()
	if DisplayServer.get_name() == "headless":
		if should_quit:
			get_tree().quit()
		return
	await RenderingServer.frame_post_draw
	if "--qa-screenshot" in OS.get_cmdline_user_args():
		var texture := get_viewport().get_texture()
		if texture:
			var image := texture.get_image()
			if image:
				image.save_png("res://qa/latest_gameplay.png")
		if should_quit:
			get_tree().quit()
		return
	var save_path := "res://qa/latest_gameplay.png"
	if "--qa-initial-screenshot" in OS.get_cmdline_user_args():
		save_path = "res://qa/initial_gameplay.png"
	elif "--qa-effects-screenshot" in OS.get_cmdline_user_args():
		save_path = "res://qa/effects_showcase.png"
	elif "--qa-units-screenshot" in OS.get_cmdline_user_args():
		save_path = "res://qa/units_showcase.png"
	elif "--qa-facing-screenshot" in OS.get_cmdline_user_args():
		save_path = "res://qa/facing_check.png"
	elif "--qa-title-screenshot" in OS.get_cmdline_user_args():
		save_path = "res://qa/title_screen.png"
	elif "--qa-events-screenshot" in OS.get_cmdline_user_args():
		save_path = "res://qa/events_showcase.png"
	elif "--qa-end-screenshot" in OS.get_cmdline_user_args():
		save_path = "res://qa/end_overlay.png"
	var texture := get_viewport().get_texture()
	if texture:
		var image := texture.get_image()
		if image:
			image.save_png(save_path)
	if should_quit:
		get_tree().quit()
