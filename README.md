# ATOM · 课前引导 / Pre-Class Guidance

**Pre-workout mode selection & setup guidance** for the ATOM smart fitness device — the flow a user goes through **before** a class starts, across the **phone app** and the **ATOM 466×466 round screen**. Bilingual (EN / 中文).

课前「上课模式选择 + 摆位引导」的完整设计：从课程预览到开始训练，覆盖**手机应用**与 **ATOM 圆屏**双端。这个仓库专做这一块，后续会持续迭代。

---

## 目录 · What's here

| 路径 | 内容 |
|---|---|
| **`Demo UX 交互原型.html`** | ★ 可交互原型（手机 + ATOM 双端，预览优先）。浏览器打开即可点。 |
| **`PRD 课前模式选择.md`** | 需求文档 · 交互流程（§4.6）· 逐页文案清单（§5.1）。 |
| **`Tips 识别准确度指南.md`** | 拍摄/摆位准确度详版（帮助中心 / 首课引导用）。 |
| **`Code Flutter/`** | 参考实现（纯 `flutter/material`，零第三方依赖）。见 `Code Flutter/实现说明.md`。 |
| **`Demo UX 素材图/`** | `UI-spec-en/zh.png`（全 24 屏总览）+ `flow-board.png`（交互流程图）+ `手机端/en·zh/`（iPhone 17 逐屏图）。 |

---

## 快速开始 · Quick start

- **看原型**：浏览器打开 `Demo UX 交互原型.html`。顶部开关可切换 配对 / 在线 / Plus / AI 额度 / 保存视频 / 中英；点「开始训练」进入完整流程。
- **跑代码**：`cd "Code Flutter" && flutter pub get && flutter run`。

---

## 设计要点 · Key points（详见 PRD）

- **预览优先**：两端都先落在课程预览 / 待机卡，点「开始训练」才进入模式选择。
- **具名三选一**：Live Coach / Record & Recap / Manual Log；未选中只显示标题，选中才展开说明。「课中随时能切」为卡片下方绿色小字，**AI 不可用时（无设备/无 Plus/离线）不显示**。
- **门槛**：两个 AI 模式需 **ATOM + Plus**；ATOM 离线拦截启动。Manual Log 永远可用。
- **课前须知（正向）**：教练心智「ATOM 就像教练的眼睛」+ 一张 OK 取景图 + 做到清单（**ATOM 约膝盖高度 · 离 0.5–1 米 · 居中 · 正/侧对 · 别被器械挡**）+「查看拍摄技巧」入口。**背景有人没关系**——ATOM 只认画面里最大的那个人，你居中、离得够近即可。反例/易错放到单独的**拍摄技巧页**。
- **数据保存（反向逻辑）**：默认**不引导不存** —— 课前只有 云端 / 仅存 ATOM。「不保存」是 **Settings 全局开关**；关掉后每次**引导去允许保存**。
- **规格**：iPhone 17（402×874pt）；字号 **20 / 16 / 14 / 12**；灰阶 + 单一品牌绿点缀（`#7CC00C` 占位）。

---

## 待替换的占位 · Placeholders

品牌绿确切色值 · 「正确 vs 错误」取景对照**矢量插画**（非实拍）· 课程数据（时长/动作/消耗）· 配套三脚架型号 · Pro 会员价格/额度上限 · 隐私协议链接。

---

*设计讨论稿，非最终视觉。Design draft, not final visual.*
