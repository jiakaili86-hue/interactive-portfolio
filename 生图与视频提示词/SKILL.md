---
name: jimeng-seedream-seedance
description: 即梦 AI 提示词交付技能，覆盖 Seedream 5.0 生图、Seedance 2.0 生视频、全能参考 @ 映射、角色三视图、分镜图转视频、多段续拍/硬切、自拍 POV、真人一致性、导演流程图、场景四视图、画风模板与检索知识落盘。Use when Codex needs to create, revise, review, or structure 即梦/Seedream/Seedance image or video prompts, project Markdown deliverables, reference-material mappings, or reusable prompt rules.
---

# 即梦 Seedream / Seedance 提示词交付

## Source Routing

Before delivering final prompts, use these source files as needed:

- Always apply `01_即梦交付核心约束（每次必读）.md`.
- Use `02_提示词技法全文（生图+生视频方法论）.md` for formulas, camera language, five-dimension diagnosis, stability, cinematic expression, and Seedream / Seedance templates.
- Use `03_画风模版合集.md` only when a style trigger is present.
- Use `04_工作流合集.md` only when a workflow trigger is present.
- Use `检索与落盘方法/网络搜索质量规则.md` and `检索与落盘方法/检索知识落盘到规则.md` when web research is used or the user asks to write reusable knowledge back into rules.

Prefer searching headings with `rg -n "^#{1,4}\s" <file>` and reading only the relevant section. Do not copy long source text into the response.

## Default Delivery Logic

1. Identify the deliverable: Seedance video prompt, Seedream image prompt, project Markdown, style template, workflow, critique, or rule update.
2. If generating Seedance video, default to **全能参考生视频 + `@图片N` / `@视频N`**. Pure text video prompts are allowed only when the user explicitly asks for pure text / no reference / no `@`.
3. If generating Seedream assets, default to:
   - Characters: one 16:9 single-sheet three-view reference per character.
   - Props: no separate Seedream prompt unless the user explicitly names props to generate.
   - Scenes: no separate Seedream prompt unless the user explicitly asks for a scene image / four-view scene / 360 overview.
4. Preserve user-provided dialogue, narration, titles, and quoted copy **character for character**. Do not shorten, paraphrase, reorder, change punctuation, fix typos, or replace numbers unless the user explicitly authorizes it in this turn.
5. Keep generated video prompt bodies in Chinese by default. Do not include English labels such as `Subject`, `Camera`, `Cut to`, or `Transition to` unless the user requested that format or a proven template requires it.
6. Always include the text ban in Seedance prompt constraints unless the user explicitly wants visible text:
   `禁止生成字幕、禁止生成屏幕文字、禁止生成标题文字、禁止生成水印`.
7. Each Seedance segment must be 15 seconds or less. Allocate time by narrative need, dialogue length, action complexity, mouth-sync difficulty, and camera movement. Do not use equal thirds as filler.
8. Use positive visual language for the image body. Keep necessary prohibitions in a hard-rule line; avoid scattering `不要 / 禁止 / 没有 / 不出现` through shot descriptions.

## Project Markdown Structure

When creating a full project document, keep this order:

```markdown
## 1 用户台词定稿
## 2 备忘
## 3 时长
## 4 风格全局基底
## 4.5 素材清单与 @ 映射
## 5 Seedance 2.0 全能参考生视频 分镜关键词
## 6 Seedream 生图（按需）
## 7 核对与 @ 映射
```

Each video shot uses:

````markdown
### 镜头NN · 名称
建议时长：
模型：
本镜须绑定：
台词：
提示词（整段复制）：
```text
...
```
````

Use two-digit shot numbers (`镜头01`, `镜头02`). The code block must contain the actual copyable prompt and any required `@` references. Do not put product-entry explanations such as “全能参考生视频” inside the copyable block.

## Material Mapping And `@`

- Maintain a clear `## 4.5` mapping table: upload order, `@` name, source asset, purpose.
- The copyable Seedance prompt must reference the same `@图片N` / `@视频N` values as the mapping.
- Do not add prop `@` references automatically. Props use text description unless the user explicitly requested prop reference images.
- If a referenced asset is missing or unsuitable for a voice / character / scene, keep the user content and remove or revise only the invalid reference instruction.

## Five-Dimension Diagnosis

When the user provides reference assets, diagnose before writing the final prompt:

| Dimension | If locked by reference | If not locked |
|---|---|---|
| Subject and physical action | Do not repeat face, clothing, body, or fixed pose details | Write action, expression, body movement, and interaction |
| Environment and light | Do not redescribe scene details already in the image | Write space, weather, light direction, color temperature |
| Camera and optical behavior | Almost always write in text | Write shot size, angle, movement, focus behavior |
| Timeline and state change | Only omit for static display shots | Write timecodes, action beats, dialogue, end state |
| Aesthetic medium | Keep minimal if the reference strongly defines style | Write final style anchor and quality constraints |

Then tell the user briefly which dimensions are already locked and which will be filled by text. The more complete the reference asset, the more the prompt should do subtraction.

## Seedream Image Rules

Use concrete, visual natural-language descriptions. Default formula:

```text
主体描述 + 动作/姿态 + 场景/环境 + 风格化 + 光影 + 视角/景别 + 色调/氛围 + 材质 + 尺寸比例
```

For character reference sheets, use the default animation-layout template unless the selected style overrides it:

```text
横版16比9画幅，单张角色设定图，严格分区禁止随机排版，同一角色同一套服装，特写区与全身三视图区须完全一致，同一发型同一服饰，禁止左右分区人物不一致，
画面左侧约三分之一宽度为面部特写区，正面面部大特写占满左栏高度，眉眼鼻嘴清晰，表情中性，
画面右侧约三分之二宽度内三等分三列，全身三视图人物IP设计，从左到右依次为正视图、侧视图、后视图，
[主体名]正视图，[主体名]侧视图，[主体名]后视图，
分区边界竖直清晰，对齐整齐，不重叠不穿模，
[主体描述]，[风格关键词]，[外观细节]，背景白底，无环境色，高清，人体结构正确，五官对称
```

Do not use `或 / 可 / 任选 / 之一` inside a single image prompt. If comparing variants, write one complete prompt per variant.

For scene images, only generate when requested. Add `无人物，无人影，空旷场景，无文字，无标识，无水印` unless people or text are explicitly required.

For props, only generate when requested. Simple props usually stay as text in the video prompt.

## Seedance Video Rules

Default formula:

```text
主体 + 动作 + 场景 + 光影 + 镜头语言 + 风格 + 画质 + 约束
```

For multi-shot prompts:

- Use Chinese transition words: `切换至`, `硬切至`, `过渡至`.
- Default to timecodes such as `[00:00-00:05]`.
- Use one main camera movement per shot.
- Use one main action per shot when possible.
- Put dialogue directly into the action sentence, preserving user wording exactly.
- Integrate sound effects naturally: footsteps, fabric movement, wind, impact, room tone. Do not add BGM by default for templates that prohibit it.

Use this quality tail, adapting only when the scene requires targeted additions:

```text
4K超高清 画面稳定 动作流畅自然 细节清晰 电影质感 人体结构正确 关节自然弯曲 五官清晰 面部稳定不变形 无畸变 无多余肢体 无模糊 无闪烁 无重影 人物比例正确 背景稳定 禁止生成字幕 禁止生成屏幕文字 禁止生成标题文字 禁止生成水印
```

For dialogue, prefer close-up / medium-close shots at the spoken beat unless the action-space relation is more important. If a line is too long for one 15-second segment, split into multiple generated videos and edit later; do not alter the line.

## Shot Design

Choose shot size and angle for narrative purpose:

- Establishing world: wide / full shot.
- Introduce action: medium shot.
- Emotion or reaction: close-up.
- Key detail or turn: insert / extreme close-up.
- Power / hero entry: low angle, visible lower-angle elements.
- Vulnerability / judgment: high angle, visible top / ground relationship.
- Dialogue relationship: two-shot, over-shoulder, or alternating close-ups while respecting the 180-degree line.

For difficult angles, add concrete visible evidence: top of head for high angle, chin / ceiling / sky for low angle, back of head and destination for rear view, side profile details for side view.

For multi-person scenes, lock screen-visible relations before mood:

- foreground / middle ground / background
- near camera / far from camera
- left / center / right
- facing camera / side-facing / back-facing
- gaze target
- where each key prop is

Avoid abstract directions alone, such as `旁边`, `后方`, `远处`, without screen coordinates.

## Style Triggers

Use only the matching style section. Do not mix mutually exclusive style terms in the same video unless the user explicitly asks for a deliberate transition, in which case split into separate generations.

| Style | Trigger examples | Key constraints |
|---|---|---|
| A 超写实实拍真人 | 超写实真人、实拍真人、真人口播、电影短片 | Use realistic skin, specific light, stable face; avoid wax, plastic, CGI. For hyper-real human three-views, use three equal panels rather than left-face + right-three-view. |
| B 2D 动漫赛璐璐 | 2D 动漫、赛璐璐、日漫、动漫视频关键词 | Clean line art, crisp outlines, flat colors, hard-edge shadows; no real skin, 3D render, oil paint, or soft melting lines. |
| C 搞笑彩绘极简 | 搞笑彩绘极简、搞笑彩绘风极简 | White-list visible objects; use simple emotional color backgrounds; no unrequested props, scenery, text, clutter, or BGM. |
| D 手绘铅笔速写 | 铅笔速写、线稿动画、黑白线稿、炭笔 | Black / gray pencil line, paper texture, hatching; no cel shading, 3D render, or realistic skin. |
| E 3D 球员风格化图片 | 3D球员风格化、球员皮克斯风、4头身卡通球员 | Research player visual anchors first; output 16:9 three-view stylized player sheet with specific kit, number, body, hair, and face anchors. |

For any animation style, keep characters, scenes, and props in one unified film style and rendering language. If references conflict, state that the final video uses the target style and each reference only locks its intended dimension.

## Workflow Triggers

Use only the workflow needed by the user’s request.

### A. Storyboard / 9-Grid To Video

Trigger: 九宫格分镜, 3x3 分镜, storyboard 转视频, 分镜图生视频.

Default formal workflow:

1. Upload character three-views and scene references to GPT Image 2.
2. Generate individual storyboard frames and refine each frame.
3. Assemble accepted frames into a 3x3 grid.
4. Upload grid plus character / scene references to Seedance.
5. Write a motion-driven prompt that references the grid order and transition motivations.

Storyboard images describe what the audience sees. Do not put timecodes, camera motion, or arrows into static storyboard prompts unless the user requested a director board.

### B. Multi-Segment Continuation / Hard Cut

Trigger: 接着拍, 延续上一段, 第二段, 硬切新镜头, 多段保持一致.

First decide route:

- **Extension**: same shot continues from last frame. Write that the new clip continues from `@视频1` last frame and keeps pose, camera, hand position, props, scene, light, environment sound.
- **Hard cut / new segment**: new camera, shot size, or action. Write that `@视频1` is only for character, voice, style, scene, or story continuity, and do not inherit the final-frame composition.

Never combine extension language with “do not reference the last frame” in the same prompt.

Before delivery, make an anchor table in your reasoning: previous end position, pose, held props, gaze, emotion, key object position, and scene aftereffects. Carry persistent states forward unless the story explicitly changes them.

### C. Selfie / Vlog POV

Trigger: 手机自拍感, 前置摄像头, 自拍视角, selfie POV, vlog.

Overwrite camera language with:

- phone front-camera selfie view
- fixed or nearly fixed camera
- subject looking into the phone camera
- device outside the frame unless the user asks to show it
- light wide-angle distortion, real selfie background
- no dolly, orbit, drone, or third-person view

### D. Real-Person Approval And Consistency

Trigger: 真人照上传失败, 过审, 多段脸不稳, 真人图不让上传.

Prefer compliant official identity / digital-person workflows for the user’s own likeness. For fast testing, use style-transfer reference images, multi-view cards, smaller face area, or first-frame mode as engineering workarounds. Still use `@图片N` after upload and keep character descriptors consistent across segments.

### E. Director Flowchart / Storyboard Board

Trigger: 导演流程图, 导演分镜板, 带表格的分镜板.

Use GPT Image 2 for high-density Chinese board layouts. Decide simple / standard / full board by complexity. When using a hand-drawn pencil board as `@图片1` in Seedance, always write:

- final video adopts the target style
- `@图片1` is only for narrative and composition
- ignore all text, tables, labels, arrows, keyword chips, diagrams, and paper / pencil style
- upload independent character three-views because board thumbnails are too small to lock faces

### F. Scene Four-View

Trigger: 四宫格场景图, 场景多视角图, 场景 360 总览, 场景四视图.

Only create when explicitly requested. Use four fixed views: front, left side, rear, 45-degree isometric top. Include no people, shadows, silhouettes, text, or watermarks. When feeding it to Seedance, say to ignore grid divisions and labels; use only architecture, light, object position, and spatial orientation.

## Web Research And Rule Updates

When unsure about current platform capability, a real-world visual subject, a sports/player reference, or a new prompt trend, ask or search as appropriate. If web search is used for reusable prompt knowledge:

- Prefer recent sources from the current or previous year.
- Prioritize high-interaction Douyin, Xiaohongshu, Bilibili, WeChat Channels, official pages, or high-quality summaries of those communities.
- Use at least 3-5 distinct sources / posts when possible.
- Before editing content, summarize up to 10 directly relevant deduplicated findings. If fewer than 10 are available, say so and list all usable findings.
- Do not paste long articles or marketing copy into rules. Convert findings into operational checklists, tables, or formula additions.
- If the conclusion will be reused, write it into the most relevant existing rule area rather than creating duplicate rule files.

## Final Self-Check

Before sending final prompts:

- Are all required `@图片N` / `@视频N` references present, mapped, and consistent with upload order?
- Did the user explicitly allow any pure-text video, prop image, or scene image exception?
- Are all video clips 15 seconds or less?
- Are timecodes allocated by real narrative need rather than equal filler?
- Are user dialogue and narration copied exactly?
- Is every shot described as a visible screen image with concrete positions, actions, camera behavior, and end state?
- Are style words mutually compatible?
- Are subtitle, screen text, title text, and watermark bans present?
- Are simple props described in text rather than expanded into unnecessary reference images?
- Are persistent states from previous clips carried forward or explicitly changed?
- Does the response include copyable prompt blocks, not only file paths or explanations?
