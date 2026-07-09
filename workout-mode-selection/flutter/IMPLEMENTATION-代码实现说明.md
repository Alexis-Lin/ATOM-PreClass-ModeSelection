# Flutter 代码实现说明 · Implementation Notes

课前「选择上课模式」的 Flutter 实现。**纯 `flutter/material`，零第三方依赖**，逻辑与 UI 解耦，方便工程师直接二次开发 / 调试。

> 对应设计：`../PRD-课前模式选择.md`、`../prototype-课前模式选择.html`

---

## 1. 如何运行 · Run

```bash
cd workout-mode-selection/flutter
flutter pub get
flutter run          # 或 flutter run -d chrome 跑 Web
```

`lib/main.dart` 是**演示壳**（含预览开关：配对 none/one/two、ATOM 在线/无网、Plus、语言），可直接调试所有状态。真实业务里删掉 demo，只复用 `lib/workout_mode/`。

---

## 2. 目录结构 · Structure

```
lib/
├── main.dart                      # 演示壳（预览开关 + 手机弹窗 + ATOM 圆屏）—— 非生产
└── workout_mode/                  # ★ 可复用模块
    ├── models.dart                # 枚举与数据类（无 UI 依赖）
    ├── strings.dart               # ★ 全部中英文案（L）—— 改文案只动这里
    ├── tokens.dart                # 设计 token（颜色/圆角）
    ├── controller.dart            # ★ 全部业务逻辑（ChangeNotifier）
    ├── shared.dart                # 公用小组件（胶囊按钮 / Radio / Plus 标 / Beta 提示 / 弹窗壳）
    ├── phone_sheet.dart           # 手机端弹窗 + 模式卡 + 门槛/设备列表弹窗
    ├── course_notice.dart         # 整页「课前须知」+ 数据保存二次弹窗（云端 / 存 ATOM）
    └── atom_screens.dart          # ATOM 466×466 圆屏 + 整屏开始前确认
```

**关注点分离**：`controller.dart` 是唯一的规则来源；UI 只读它的判定函数，不自己算逻辑。**所有文案集中在 `strings.dart`（`L`）**，便于按「精确 + 精简 + 少折行 + 必要时才呈现」的原则统一打磨。

### 方向 F（当前采用）
保留**具名三选一**（Live Coach / Record & Recap / Manual Log）——决策与理解成本最低——并在卡片上方加一条心智提示（`flexNote`）：*「不确定？三种模式课中随时能切换，先随便选一个就好。」* 其它「开关式」结构（A/C/D/E）留在 `../explorations/` 备查。

### 完整流程
模式弹窗（具名三选一 + flexNote）→ **AI 模式** 点 CTA → 整页**课前须知**（Live Coach：严格取景 do/avoid + Beta 提示；Record & Recap：宽松取景 + 报告迭代/算法升级说明）→ 底部一行不显眼的**数据去向**（默认「同步到云端」· 更改）可展开二次弹窗（**云端【推荐】** vs **仅存 ATOM【需 SD 卡】**；无 SD → 告警「本次不会保留」；报告依赖云端；隐私说明 + 隐私协议）→ `I'm ready` → `onStart`。**Manual Log** 不走须知直接开始。

---

## 3. 核心逻辑（controller.dart）· Source of truth

三个判定函数是整套交互的地基：

| 方法 | 含义 |
|---|---|
| `isLocked(mode)` | 缺前置条件（无设备 / 无 Plus）→ 灰化锁定，点击弹门槛说明 |
| `missing(mode)` | 返回缺哪些（设备优先），驱动门槛弹窗文案与按钮 |
| `canStart(mode)` | 能否真正开始：AI 模式还需 ATOM **在线**（离线无法提供影像 → 拦截）|

规则要点：
- **Live Coach / Record & Recap** 需 `设备 + Plus`；**Manual Log** 永远可用。
- 手机**只判联网**，无「距离」检测 → 只有 `online / noNetwork` 两态。
- 选中项若因状态变化被锁 → `_reconcileSelection()` 自动回退到可用模式；AI 仅离线不算锁定（可选中，但 CTA 拦截）。

---

## 4. 集成方式 · Integrate

```dart
final controller = WorkoutModeController(
  devices: [AtomDevice(id: 'x', name: 'ATOM 449C', state: AtomConnState.online)],
  isPlus: true,
);

// 手机端：作为底部弹窗
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (_) => WorkoutModeSheet(
    controller: controller,
    onStart: (mode) => startWorkout(mode),   // 通过全部确认后触发
    onAddDevice: () => openPairingFlow(),     // 你的配对流程
    onGetPlus: () => openMembershipFlow(),    // 你的会员流程
  ),
);

// ATOM 端：设备屏
AtomRoundScreen(controller: controller, onStart: (mode) => startWorkout(mode));
```

交互内建：锁定卡点击 → 门槛弹窗；AI 模式点 CTA → 整页课前须知（内含数据去向二次弹窗、可「下次不再提示」）；多设备 → 切换图标弹设备列表；ATOM 端 Start → 整屏确认（可「不再显示」）。

数据去向由 controller 记忆：`dataChoice`（cloud/local）、`hasSdCard`；`skipNotice` 控制是否跳过手机端课前须知。

---

## 5. 需要进一步补的素材 · TODO for designer / engineer

| 项 | 现状（占位） | 需替换成 |
|---|---|---|
| **模式图标** | Material 内置（喇叭 / 摄像机 / 记事） | 设计稿线形图标：Live Coach 声波、Record & Recap 摄像机、Manual Log **手 + 笔** |
| **取景示意图** | `_FramingIllustration` / `_DeviceFrame`（人物图标占位） | 「正确 vs 错误」摆位对照插画（详见 `../TIPS-识别准确度指南.md`）|
| **隐私协议链接** | `l.privacyLink` 纯文本 | 接真实隐私协议页 |
| **数据去向持久化** | `dataChoice` / `skipNotice` 为内存态 | 落本地存储（记住用户偏好）|
| **品牌绿** | `Wm.brand = #7CC00C`（占位） | BodyPark 准确品牌色 + on-light 变体 `brandInk` |
| **Plus / 设备图标** | `Icons.diamond_outlined` / `Icons.adjust` | 会员宝石、ATOM 设备标识 |
| **配对 / 会员 / 开始流程** | demo 里是本地 mock | 接真实 `onAddDevice` / `onGetPlus` / `onStart` |
| **`skipAtomConfirm` 持久化** | 内存态 | 落到本地存储（每用户「不再显示」）|
| **文案** | 已给中英 | 产品/本地化终审 |
| **双端同步** | 两端共用同一 `controller` 规则 | 接真实的双端状态同步（BLE / 云）|

---

## 6. 状态矩阵 · State matrix

| 配对 | ATOM | Plus | AI 模式表现 | Manual Log |
|---|---|---|---|---|
| 无 | — | 任意 | 锁定，点击→添加设备 | 可用 |
| 有 | 在线 | 无 | 锁定，点击→开通 Plus | 可用 |
| 有 | 在线 | 有 | 可选 → 开始前确认 → 开始 | 可用 |
| 有 | 无网 | 有 | 可选，但 CTA 置灰「请确保 ATOM 在线」+ 顶部告警 | 可用 |
| 多台 | 混合 | 有 | 切换图标→设备列表二次选择；可切到在线设备 | 可用 |

---

## 7. 有意不在此处理 · Out of scope

低电量 / 固件升级（不硬卡）、Plus 课中到期、课中掉线降级、权限申请（解耦到进入模式后按需申请）—— 详见 `../PRD-课前模式选择.md` 第 2、7 节。

---

*说明：环境无 Flutter SDK，本代码按 Flutter 3.10+ / Dart 3 编写，未在本机编译；请工程师 `flutter pub get && flutter run` 验证并按第 5 节补素材。*
