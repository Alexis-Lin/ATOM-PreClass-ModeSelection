# 课前模式选择与说明 · Workout Mode Selection

课前的「上课模式」选择弹窗设计说明。覆盖 **手机应用内弹窗** 与 **ATOM 设备 466×466 圆屏** 两种入口，中英双语。

Design spec for the pre-workout **mode selection** flow — both the **in-app phone modal** and the **ATOM 466×466 round device screen**, in English and 中文.

> 交互原型（可点）：`prototype-课前模式选择.html`（同目录，浏览器打开即可）。
> Interactive prototype: open `prototype-课前模式选择.html` in a browser.

---

## 1. 三种模式 · The three modes

命名沿「AI 参与度」光谱：实时驱动 → 自动 → 全手动（类比：自动驾驶 / 自动挡 / 手动挡）。
Names sit on an "AI involvement" ladder — real-time → automatic → manual.

| 模式 Mode | 一句话 One-liner | 适合 Best for | 依赖 Requires |
|---|---|---|---|
| **Live Coach** 实时教练 | 训练时实时计数并给出动作提示<br>Real-time counting and form cues while you move | 想被带着练、需要即时反馈的人<br>anyone who wants to be coached through every rep | ATOM + Plus |
| **Record & Recap** 录制复盘 | 全程安静记录，练完给你一份详细报告<br>Records quietly, then reports back after | 想要影像、数据与报告，又不想被打扰的进阶用户<br>experienced users who want the video, data & a report — without the chatter | ATOM + Plus |
| **Manual Log** 手动记录 | 自己手动记录组数、次数与重量<br>Enter your sets, reps and weight yourself | 不需要摄像头、想快速手动记录的时候<br>quick manual tracking when you don't need the camera | 免费 Free |

- **Live Coach** 常驻 `Beta` 说明（放在选项底部，不在标题旁）：*ATOM 仍在迭代，个别动作可能漏计/误计，请以自身判断为准。*
- **Live Coach / Record & Recap** 标题旁带 `Plus` 会员小标签；图标为线形（喇叭 / 摄像机）。
- **Manual Log** 图标为「手 + 笔」，强调手动记账。

---

## 2. 依赖与门槛 · Gating

两道门槛：**🔒 ATOM 硬件** 与 **✦ Plus 会员**。两个 AI 模式都需要。
Two gates — the **ATOM device** and a **Plus membership**; both AI modes need both.

- 未满足时该模式**置灰锁定**，点击弹出说明弹窗（缺设备 → 添加设备；缺会员 → 开通 Plus），**不在页面常驻横幅**，保持干净。
- Manual Log 永远可用，不依赖设备 / 网络 / 会员。

---

## 3. 设备与网络状态 · Device & network states

手机**只能判断 ATOM 是否联网**，无法判断距离，因此**没有「不在附近」检测**。
The phone only knows whether ATOM is **online**, not how far away it is — so there is **no "not nearby" detection**.

| 配对 Paired | 状态 Status | 行为 Behaviour |
|---|---|---|
| 未配对 None | — | AI 模式锁定，点击引导添加设备 |
| 单台 One | 在线 Online | 可启动 |
| 单台 One | 无网络 No network | **拦截启动**：ATOM 离线无法提供影像支持，提示「请确保 ATOM 在线」 |
| 多台 Two+ | — | 设备行前置**切换图标 → 弹列表**二次选择用哪台 ATOM（一部手机可配多台，类比 iPhone ↔ 多块 Apple Watch）|

- 无网时若另一台设备在线，告警会附带「也可切换到在线的设备」。
- 「靠近提醒」为**柔性**：并入开始前确认弹窗，不做硬卡点。

---

## 4. 开始前确认 · Pre-start confirmation

启动任一 **AI 模式**都会先弹「开始前请确认」（Manual Log 无摄像头，不弹）。
Starting either **AI mode** shows a "before you start" check first (Manual Log skips it — no camera).

**手机端 · Phone**（底部弹窗 checklist）：
1. AI 模式仍在 beta，动作可能漏记或误记。
2. 确保 ATOM 在线并放在手边。
3. 保持人物完整入框，不要遮挡或奇怪角度。

**ATOM 圆屏 · Device**（**独立整屏**，不透明、无蒙层，可 × 关闭、可「不再显示」）：
1. AI 仍在 beta，动作可能漏记或误记。
2. 请完整入框，不要遮挡。

---

## 5. ATOM 圆屏 · Round device screen

- 标题：**Workout mode / 上课模式**（不带 select、不带课名）。
- 仅 **Live Coach** 与 **Record & Recap** 两个模式（Manual Log 留在手机端）。
- 选项标题与说明**分两行**；**只有选中的卡片显示说明**，其余只显示标题。
- 白字黑底，品牌绿标选中；大触控目标，内容压在圆形安全区内。
- 开始前确认为独立整屏（见上）。

---

## 6. 有意不在此处理 · Intentionally out of scope

以下按业务判断**不在本弹窗做硬卡点 / 不在此解决**：
- ATOM 低电量 / 需固件升级 → 不硬卡。
- Plus 会员课中到期 → 不会发生。
- 课中 ATOM 掉线 → 属课中异常，可降级到 Manual Log，但在课中流程处理，非本页。
- 权限（如询问是否上传录像）→ **解耦**：先进入 Record & Recap，再按需申请权限。

---

## 7. 待定 · Open questions

- 手机端标题行的 `Plus` 标签是否保留。
- 品牌绿的确切色值（原型内 `#7cc00c` 为占位近似值）。
- 是否需要「连接中 / 配对中」过渡态。

---

*本目录为设计讨论稿，非最终视觉稿。Prototype for discussion, not final visual design.*
