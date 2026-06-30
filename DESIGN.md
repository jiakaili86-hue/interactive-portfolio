# Design System

## Theme

深色电影放映空间。访客在普通室内光线下用桌面或手机快速浏览，页面像一块正在播放作品的屏幕，文字和控件保持安静。

## Color Strategy

Committed palette。主体使用带轻微绿色倾向的黑灰，项目拥有各自的单一信号色。

- Canvas: `oklch(0.12 0.008 120)`
- Text: `oklch(0.93 0.008 95)`
- Muted text: `oklch(0.68 0.008 95)`
- Divider: `oklch(0.93 0.008 95 / 0.18)`
- Ronin accent: `oklch(0.73 0.10 55)`
- Dissolve accent: `oklch(0.79 0.03 240)`
- Lanyard accent: `oklch(0.85 0.16 105)`

## Typography

- Display: `"Arial Narrow", "Roboto Condensed", "Microsoft YaHei", sans-serif`
- Interface and body: `"Arial", "Microsoft YaHei", sans-serif`
- Project titles use strong scale contrast and compact line height.
- Body copy stays under 65 characters per line.
- Letter spacing remains `0`; short metadata labels may use uppercase without added tracking.

## Layout

- First fold: 86 to 90 percent of viewport height, full-bleed media.
- Fixed top navigation: identity on the left, role and project count on the right.
- Project title anchored low and left; project selector anchored right on desktop and bottom on mobile.
- A narrow next-section strip remains visible in the first viewport.
- Desktop uses an asymmetric 8/4 composition; mobile stacks media information above a horizontal project selector.

## Motion

- Initial reveal: one coordinated 700 to 900ms sequence.
- Project switch: old media fades and scales down slightly; new media reveals through a horizontal clip.
- Text uses a short masked vertical reveal, not repeated typing animation.
- Cursor halo follows pointer with easing only over the hero.
- Transitions use ease-out-quint curves and never animate layout properties.
- Reduced motion changes all transitions to short opacity changes.

## Components

### Project Stage

Layered full-bleed videos or images. Only the active media is visible and active video playback is resumed.

### Project Selector

Three semantic buttons with index, Chinese title and medium. Hover or focus previews a project; click or Enter opens it.

### Primary Project Link

A circular arrow icon and concise “进入作品” label. It follows the active project URL.

### Archive Strip

A restrained band below the hero that identifies the creator and links to the broader practice without competing with selected projects.

## Responsive Behavior

- At widths below 760px, title size reduces by breakpoint rather than viewport-scaled text.
- Project selector becomes a three-column bottom rail.
- Background media keeps a stable full-screen crop.
- Pointer halo and wheel navigation are disabled on touch-first devices.

