# 游戏1 美术资产需求

版本日期：2026-06-03

项目方向：竖屏卡牌部署防守怪物潮。角色全图索敌攻击，不做分路线塔防。参考体验偏“向僵尸开炮”的怪潮压迫和爽感，卡牌包装保持已有“火枪少女 / 冰弓少女”的华丽二次元幻想卡牌风格。

## 通用规范

- 文件格式：PNG。
- 色彩：sRGB。
- 透明背景：头像、图标、角色小人、敌人、特效序列需要透明背景。
- 命名：全部使用英文小写和下划线，放进对应目录。
- 卡牌大图比例：1086 x 1448，和现有卡一致。
- UI 图标比例：正方形，建议 256 x 256 或 512 x 512。
- 战斗小人方向：默认面向屏幕右上或正前方，便于在竖屏战场中识别。
- 文字安全区：卡牌大图上方标题区和右上费用区必须留干净，避免角色脸和武器穿进文字。

## 第一批：必须优先提供

### 1. 雷电少女卡牌

用途：远程群攻 / 连锁伤害卡。

目标文件：

- `assets/cards/card_lightning_mage.png`
- `assets/cards/card_lightning_mage_no_text.png`
- `assets/portraits/portrait_lightning_mage.png`
- `assets/icons/icon_skill_chain_lightning.png`
- `assets/units/unit_lightning_mage.png`

卡牌大图排版：

- 尺寸：1086 x 1448。
- 顶部标题：`雷电少女`。
- 右上费用圆章：`费用 160`。
- 中部角色：紫色雷电系少女，法杖、雷枪、浮游电环都可以。表情冷静、有压迫感。
- 左侧职业图标：雷电符号或电弧法阵。
- 底部三栏文字：`远程`、`冷却10秒`、`连锁群攻`。
- 底部描述：`攻击命中后，对附近敌人造成连锁伤害。`
- 主色：紫色、电蓝、亮白电光。边框可以用银紫金属。

无文字版：

- 保留边框、角色、背景、装饰。
- 去掉标题、费用数字、底部所有文字。
- 保留文字区域的浅色底板，方便后续程序动态写字。

头像：

- 尺寸：512 x 512。
- 内容：角色头肩像，清晰看到脸和雷电元素。
- 背景可有紫色闪电，但不能太花。

战斗小人：

- 尺寸：512 x 512 透明背景。
- 内容：Q版或半身小角色，能看出紫色雷电、武器轮廓。
- 屏幕内显示会缩到 40px 左右，所以外轮廓必须清楚。

技能图标：

- 尺寸：256 x 256 透明背景。
- 内容：一束雷电分叉击中多个目标。
- 不要文字。

### 2. 鼓舞少女卡牌

用途：辅助攻速光环。

目标文件：

- `assets/cards/card_inspire_bard.png`
- `assets/cards/card_inspire_bard_no_text.png`
- `assets/portraits/portrait_inspire_bard.png`
- `assets/icons/icon_skill_inspire_aura.png`
- `assets/units/unit_inspire_bard.png`

卡牌大图排版：

- 尺寸：1086 x 1448。
- 顶部标题：`鼓舞少女`。
- 右上费用圆章：`费用 130`。
- 中部角色：金色暖光系少女，战鼓、军旗、号角、麦克风任选，但更偏战场鼓舞。
- 左侧职业图标：旗帜、音符或光环。
- 底部三栏文字：`辅助`、`冷却10秒`、`攻速提升`。
- 底部描述：`部署后提升全队攻击速度。`
- 主色：金色、奶白、少量红色，氛围要积极热血。

无文字版、头像、战斗小人、技能图标同上规格。

技能图标内容：金色环形光波向外扩散，中央可有旗帜或鼓点。

### 3. 战术少女卡牌

用途：辅助增伤光环。

目标文件：

- `assets/cards/card_tactics_commander.png`
- `assets/cards/card_tactics_commander_no_text.png`
- `assets/portraits/portrait_tactics_commander.png`
- `assets/icons/icon_skill_damage_command.png`
- `assets/units/unit_tactics_commander.png`

卡牌大图排版：

- 尺寸：1086 x 1448。
- 顶部标题：`战术少女`。
- 右上费用圆章：`费用 150`。
- 中部角色：绿色/青绿色战术指挥官少女，拿战术板、指挥旗、地图投影或机械终端。
- 左侧职业图标：棋子、准星地图、指挥箭头。
- 底部三栏文字：`辅助`、`冷却12秒`、`伤害提升`。
- 底部描述：`部署后提升全队造成的伤害。`
- 主色：青绿、白、黑金点缀。感觉聪明、精密、可靠。

技能图标内容：上升箭头、准星、战术地图叠加。

### 4. 召唤塔少女卡牌

用途：建筑位，周期召唤士兵。

目标文件：

- `assets/cards/card_summon_tower.png`
- `assets/cards/card_summon_tower_no_text.png`
- `assets/portraits/portrait_summon_tower.png`
- `assets/icons/icon_skill_summon_soldier.png`
- `assets/units/unit_summon_tower.png`
- `assets/units/unit_summoned_soldier.png`

卡牌大图排版：

- 尺寸：1086 x 1448。
- 顶部标题：`召唤塔少女`。
- 右上费用圆章：`费用 180`。
- 中部角色：金棕色机械召唤师少女，身后有小型召唤塔、传送门、齿轮法阵。
- 左侧职业图标：塔、传送门或士兵剪影。
- 底部三栏文字：`建筑`、`冷却15秒`、`召唤士兵`。
- 底部描述：`周期召唤士兵，拦截并攻击怪物。`
- 主色：金棕、琥珀、钢铁灰。要有“持续生产战力”的感觉。

召唤士兵：

- 尺寸：512 x 512 透明背景。
- 内容：小型守卫兵或机械士兵，轮廓简单，武器清晰。
- 色彩：金色/钢铁色，和召唤塔少女同阵营。

## 第二批：怪物潮资源

### 5. 骷髅怪

目标文件：

- `assets/enemies/enemy_skeleton.png`
- `assets/enemies/enemy_skeleton_hit.png`

规格：

- 尺寸：512 x 512 透明背景。
- 风格：Q版怪物，白骨、破布、红色血条下可读性强。
- 姿态：向下方推进，双臂张开或拿短刀。
- `hit` 版本：偏白或受击高亮，用于命中闪烁。

### 6. 幽灵怪

目标文件：

- `assets/enemies/enemy_ghost.png`
- `assets/enemies/enemy_ghost_hit.png`

规格：

- 尺寸：512 x 512 透明背景。
- 风格：蓝白半透明幽灵，速度感强。
- 外轮廓要明确，避免在深蓝战场上看不清。

### 7. 恶魔怪

目标文件：

- `assets/enemies/enemy_demon.png`
- `assets/enemies/enemy_demon_hit.png`

规格：

- 尺寸：512 x 512 透明背景。
- 风格：红色小恶魔，角、爪、厚血量感。
- 需要比骷髅和幽灵更重、更硬。

### 8. 后续 Boss 预留

目标文件：

- `assets/enemies/boss_horde_lord.png`
- `assets/enemies/boss_horde_lord_hit.png`

规格：

- 尺寸：768 x 768 透明背景。
- 风格：怪潮领主，体型大，适合第 5 波或第 10 波出现。
- 需要明显弱点或核心，比如胸口红色晶核。

## 第三批：战斗特效

### 9. 子弹和命中特效

目标文件：

- `assets/vfx/projectile_fire.png`
- `assets/vfx/projectile_ice.png`
- `assets/vfx/projectile_lightning.png`
- `assets/vfx/hit_fire.png`
- `assets/vfx/hit_ice.png`
- `assets/vfx/hit_lightning.png`

规格：

- 尺寸：256 x 256 透明背景。
- 子弹：中心清楚，外圈发光，缩到 8-16px 仍能看。
- 命中：圆形爆点或冲击环，不要遮挡太久。

### 10. 光环特效

目标文件：

- `assets/vfx/aura_inspire.png`
- `assets/vfx/aura_tactics.png`
- `assets/vfx/aura_summon.png`

规格：

- 尺寸：512 x 512 透明背景。
- 鼓舞光环：金色扩散环。
- 战术光环：绿色网格/箭头环。
- 召唤光环：金色传送阵。

## 第四批：背景与 UI

### 11. 主战场背景

目标文件：

- `assets/backgrounds/bg_battle_horde_city.png`

规格：

- 尺寸：780 x 1000，程序会适配 390 x 500 战斗区域。
- 内容：上方怪物入口、下方红色防线、中间开阔战斗区域。
- 风格：暗色幻想城市/废墟/城墙前线。
- 要求：不能太花，角色和怪物必须清楚。中间 70% 区域降低对比度，留给战斗。
- 不需要画路线。

### 12. 部署区背景

目标文件：

- `assets/backgrounds/bg_deploy_panel.png`

规格：

- 尺寸：780 x 540。
- 内容：深色卡牌战术台、魔法阵或机械控制台。
- 需要能承载远程、辅助、建筑三行格子。

### 13. 卡牌 UI 框

目标文件：

- `assets/ui/card_frame_ranged.png`
- `assets/ui/card_frame_support.png`
- `assets/ui/card_frame_tower.png`
- `assets/ui/card_frame_disabled.png`
- `assets/ui/card_frame_selected.png`

规格：

- 尺寸：512 x 704 透明背景。
- 用途：以后程序把角色图、费用、冷却、描述写进去。
- 远程：红/蓝/紫都可，但边框形状统一。
- 辅助：金/绿。
- 建筑：金棕/钢铁。
- 选中框：亮金色高光。
- 禁用框：灰暗遮罩感。

### 14. 战斗 HUD UI

目标文件：

- `assets/ui/hud_top_panel.png`
- `assets/ui/icon_coin.png`
- `assets/ui/icon_wave.png`
- `assets/ui/icon_base_hp.png`
- `assets/ui/button_restart.png`

规格：

- 顶栏：780 x 88，半透明深色幻想金属框。
- 金币图标：金币或魔晶。
- 波次图标：怪潮爪印或旗帜。
- 防线图标：城墙/护盾。
- 重开按钮：可带回旋箭头，不要写字也可以。

### 15. 部署格 UI

目标文件：

- `assets/ui/slot_ranged_empty.png`
- `assets/ui/slot_support_empty.png`
- `assets/ui/slot_tower_empty.png`
- `assets/ui/slot_selected.png`
- `assets/ui/slot_occupied.png`
- `assets/ui/slot_upgrade_ready.png`

规格：

- 尺寸：256 x 180 透明背景。
- 空位：颜色区分行类型，但不要太亮。
- 选中可放：金色边框。
- 已部署：更实、更亮。
- 可升级：角落有上箭头或发光。

## 第五批：可选包装资源

### 16. 开始界面插图

目标文件：

- `assets/backgrounds/bg_title_hero_vs_horde.png`

规格：

- 尺寸：1170 x 2532。
- 内容：几名少女角色守住下方防线，上方怪潮压下来。
- 文字不要画进图里，标题由程序写。

### 17. 胜利 / 失败插图

目标文件：

- `assets/ui/result_victory.png`
- `assets/ui/result_defeat.png`

规格：

- 尺寸：780 x 900 透明或半透明背景。
- 胜利：角色站在防线前，金色光。
- 失败：防线裂开，红色警报，但不要太恐怖。

## 当前已有资源

已有：

- `assets/cards/card_fire_gunner.png`
- `assets/cards/card_ice_archer.png`

建议补同款无文字版、头像、小人、技能图标：

- `assets/cards/card_fire_gunner_no_text.png`
- `assets/portraits/portrait_fire_gunner.png`
- `assets/icons/icon_skill_fire_shot.png`
- `assets/units/unit_fire_gunner.png`
- `assets/cards/card_ice_archer_no_text.png`
- `assets/portraits/portrait_ice_archer.png`
- `assets/icons/icon_skill_ice_arrow.png`
- `assets/units/unit_ice_archer.png`

## 交付优先级

第一优先级：

雷电少女、鼓舞少女、战术少女、召唤塔少女四张完整卡牌，以及对应头像、技能图标、战斗小人。

第二优先级：

骷髅、幽灵、恶魔三种怪物图，以及火/冰/雷命中特效。

第三优先级：

战场背景、部署区背景、卡牌 UI 框、部署格 UI。

第四优先级：

标题界面、胜利失败图、Boss。
