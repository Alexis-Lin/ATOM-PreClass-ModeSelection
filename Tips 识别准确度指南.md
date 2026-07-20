# 识别准确度 Tips · AI Accuracy Guide

怎样摆位与布置，才能让 ATOM 的 AI 计数与动作识别**尽可能准**。这是课前「开始前，摆好画面」引导页的详细版，可用于帮助中心 / 首课引导 /「查看详细 Tips」入口。

How to place and set up so ATOM's AI counting & tracking is **as accurate as possible** — the long-form version of the pre-workout "Set up before you start" screen (help center / first-run / "View full tips").

> 相关 Related：`PRD 课前模式选择.md`（§4.4 开始前确认 · Before-you-start）· `Demo UX 交互原型.html`

> 本文分**中英两个版本**：前半为中文，后半为 English，内容一致。
> This doc has a **Chinese half then an English half** — same content.

---
---

# 中文版

> **一句话心智**：把 ATOM 想成**教练的眼睛**——教练站在那儿能看清你的动作，ATOM 就能看清。

## 30 秒速览

**✅ 这样摆**
- 全身入框、**居中**，四周留余量
- 离 ATOM **0.5–1 米**
- **ATOM 约膝盖高最好**（配套三脚架最省事；放地面也行），别过度仰角
- **角度随意**：正对、侧对都不影响识别，跟课中动作提示摆即可
- **你当「主角」**：ATOM 只认画面里**最大**的人，背景有人没关系——你居中、离得够近就行
- 光线充足均匀、别逆光，别被器械挡住

**❌ 这些会让识别变不准**
- 身体被裁切 / 偏到一边 / 被器械挡住
- 太近或太远（偏离 0.5–1 米）
- ATOM 过度仰角，或没放平
- 逆光 / 反光 / 过暗
- 你没在画面中央，被更靠前的人抢了「主角」；或正对大镜子出现「镜中人」

## 1. 摆位与取景

- **全身入框、居中**：头顶到脚踝都在画面内，动作最大幅度时（深蹲、弓步、举臂）也不出框；四周留约一个身位余量，别贴边。
- **距离 0.5–1 米**：ATOM 是贴地广角设备，靠近也能收全身；太近会裁切、太远关节点变小、识别变糊。
- **高度约膝盖**：贴地/低处摆放，镜头约膝盖高（不是胸高）。**推荐配套 ATOM 三脚架**，最省事地架平架稳；放地面或稳固低台也行，别放在会滑动/晃动的东西上。
- **放平、别过度仰角**：画面地平线要正；设备低又近容易形成大仰角，站够 ~0.7 米、让全身完整入框即可缓解。
- **角度随意**：正对、侧对都不影响识别；每个动作有个更「清爽」的角度，跟课中提示走即可，不用纠结（拉远/撤退的机位通常也 OK）。
- **摆好别再动**：开练后不要移动设备，注意别被踢到。

> 自查：站到位后，抬手过头 + 下蹲，看四肢是否始终在框内。

## 2. 环境：光线 · 背景 · 着装

- **光线**：充足且均匀最好；**别逆光**（背对窗户/强光会变黑影）、别太暗，避开镜面/玻璃/地板的反光与眩光。
- **背景与「主角」**：ATOM **自动锁定画面里最大的人**，所以背景有人一般不影响——确保**你是最大、居中**的主体，别让别人更靠近镜头被误锁定；背景尽量简洁，**别正对大镜子**（镜中人会造成重复/误识别）。
- **着装**：贴身或轮廓清晰的运动服便于识别关节；避免过于宽松/飘动的衣物遮挡肢体，别与背景颜色太接近（全黑衣 + 全黑背景）。

## 3. 设备与 AI 预期

- **联网与设备**：AI 模式需 **ATOM 在线**（离线会被拦截）；多台时确认用的是身边这台（切换图标 → 设备列表）；电量充足，别中途关机。
- **Beta 预期**：Live Coach / Record & Recap 仍是 **Beta**，个别动作可能漏计/误计，请以自身判断为准（尤其大重量组）。**大部分识别问题来自摆位**——摆好能显著提升准确率。
- **报告与留存**：深度复盘报告持续迭代（留意 OTA），当前较简单，先管理好预期；**不用担心留存**——只要视频保存，日后每次算法升级都能对这段录像重新分析，历史训练也受益。

## 4. 识别不准时排查

| 现象 | 优先检查 |
|---|---|
| 漏计 / 少数 | 全身入框？动作幅度处出框？光线够？ |
| 多计 / 重复 | 画面里有他人 / 镜中的你 / 背景晃动？ |
| 完全识别不到 | 逆光变黑影？距离太远？镜头被挡？ |
| 中途变差 | 设备被碰移位？光线变化（有人开关灯）？ |
| 无法开始 | ATOM 在线？Plus 会员？选对设备？ |

## 待补素材

- **「正确 vs 错误」对照矢量插画**（并排，非实拍）：✓ 全身入框 / 稳定水平 / 顺光 vs ✕ 被裁切 / 仰拍 / 逆光 / 多人入镜。当前原型为示意火柴人，正式版由设计师出一套矢量对照图。
- 可选：**首课 3 步布置动画**（放设备 → 后退到位 → 试举确认入框）。

---
---

# English

> **Mindset**: Think of ATOM as your coach's eyes — if a coach standing there could see your form, so can ATOM.

## 30-second TL;DR

**✅ Do this**
- Whole body in frame, **centered**, with margin around you
- Stand **0.5–1 m** from ATOM
- **Knee height is best** (the ATOM tripod is easiest; the floor works too) — no steep upward tilt
- **Angle is free**: front-on or side-on both track fine; just follow the in-workout cue
- **Be the subject**: ATOM tracks the **largest** person in view, so background people are fine — just be centered and close enough
- Good, even light; no backlight; nothing blocking you

**❌ These hurt accuracy**
- Body cut off / off to one side / blocked by gear
- Too close or too far (off the 0.5–1 m range)
- ATOM tilted steeply up, or not level
- Backlight / glare / too dark
- You're not centered and a closer person steals the "subject"; or facing a large mirror creates a "mirror double"

## 1. Placement & framing

- **Whole body, centered**: head to ankles in frame, and still in frame at full range of motion (squats, lunges, arms overhead); leave about one body-width of margin, don't hug the edge.
- **Distance 0.5–1 m**: ATOM is a low, wide-angle device, so it captures the whole body even up close; too close cuts you off, too far shrinks the keypoints and blurs tracking.
- **Around knee height**: place it low, lens ~knee high (not chest high). **The ATOM tripod is recommended** — the easiest way to get it level and steady; the floor or a stable low surface works too, just not on anything that slides or wobbles.
- **Level, no steep tilt**: keep the horizon straight; a low, close device creates a big upward angle — standing ~0.7 m back with your whole body in frame fixes it.
- **Angle is free**: front-on and side-on both track fine; each exercise has a slightly "cleaner" angle — follow the in-workout cue, don't overthink it (a pulled-back shot is usually fine too).
- **Don't move it once set**: leave the device put once you start, and mind you don't kick it.

> Self-check: once in position, reach overhead + squat and see if your limbs stay in frame the whole time.

## 2. Environment: light · background · clothing

- **Light**: bright and even is best; **no backlight** (facing a window / strong light turns you into a silhouette), not too dark, and avoid glare/reflections off mirrors, glass, or the floor.
- **Background & subject**: ATOM **locks onto the largest person in view**, so background people usually don't matter — just make sure **you're the largest, centered** subject and no one closer to the lens gets mis-locked; keep the background simple and **don't face a large mirror** (a mirror double causes double/false counts).
- **Clothing**: fitted or clearly-outlined workout gear helps joint tracking; avoid very loose / flowing clothes that hide your limbs, and don't blend into the background (all-black outfit + all-black wall).

## 3. Device & expectations

- **Online & device**: AI modes need **ATOM online** (offline is blocked); with multiple units, confirm you're using the one next to you (switch icon → device list); keep it charged so it doesn't die mid-session.
- **Beta expectations**: Live Coach / Record & Recap are still **Beta** — some reps may be missed or miscounted, so use your own judgment (especially on heavy sets). **Most accuracy issues come from placement** — setting up well improves it a lot.
- **Reports & retention**: deeper recap reports are shipping over time (watch for OTA); today's is basic, so set expectations. **Nothing is lost** — as long as the video is saved, every future algorithm upgrade can re-analyze it, so past workouts benefit too.

## 4. Troubleshooting

| Symptom | Check first |
|---|---|
| Under-counting / missed reps | Whole body in frame? Out of frame at peak ROM? Enough light? |
| Over-counting / duplicates | Another person / your mirror reflection / moving background? |
| Not detected at all | Backlit silhouette? Too far away? Lens blocked? |
| Gets worse mid-session | Device bumped / moved? Lighting changed (someone hit the lights)? |
| Can't start | ATOM online? Plus member? Right device selected? |

## Assets to design

- **A "right vs wrong" vector illustration** (side by side, not a photo): ✓ full body / level / well-lit vs ✕ cut off / tilted up / backlit / multiple people. The prototype uses a placeholder stick figure; the final should be a proper vector set by the designer.
- Optional: a **3-step first-run setup animation** (place device → step back → test rep to confirm framing).

---

*本文为设计/内容讨论稿。This is a design/content draft.*
