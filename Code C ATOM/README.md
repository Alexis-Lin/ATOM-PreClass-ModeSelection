# Code C ATOM · 圆屏设备端参考实现（LVGL）

ATOM 466×466 圆屏「课前」界面的**嵌入式 C 参考实现**，与 Flutter 端
`../Code Flutter/lib/workout_mode/atom_screens.dart` 一一对应：

```
待机（今日训练） → 模式列表（Live Coach / Record & Recap）
                 → 「开始前请确认」（3 条图标须知 + 不再显示脚注） → on_start()
```

基于 **LVGL**（小型圆屏 MCU 上最常用的 GUI 库），针对 **v8/v9** 公共 API 编写，**无其它依赖**。

---

## 文件

| 文件 | 作用 |
|---|---|
| `atom_ui.h` | 公共 API：`atom_ui_state_t`、`atom_start_cb_t`、`atom_ui_create()` |
| `atom_ui.c` | 三个页面 + 事件 + 设计 token（颜色/字号镜像 Flutter `tokens.dart`）|
| `demo_main.c` | 接线示例：如何构造 state、实现 `on_start`、调用 `atom_ui_create()` |

---

## 集成（三步）

```c
#include "atom_ui.h"

static void on_start(atom_mode_t mode, void *user) {
    // 用户在设备上确认「开始」→ 在这里真正启动本次训练
    // （开始采集、切到训练中画面、通知手机等）。
}

// lv_init() + 显示/输入驱动就绪后调用一次：
static atom_ui_state_t st = {
    .selected = ATOM_MODE_LIVE_COACH, .skip_confirm = false,
    .lang = ATOM_LANG_EN, .online = true,
    .course_name = "Back & Legs", .course_meta = "32 min - Strength",
};
atom_ui_create(lv_scr_act(), &st, on_start, NULL);
```

- **`on_start` 是唯一的「前进」出口**——UI 自己不做任何导航。
- `state` 由调用方持有并保活；`selected` / `skip_confirm` 会被回写，便于固件持久化「不再显示」。
- **门槛/权限不在 UI 里硬拦**：Plus / AI 额度 / 在线判断由账号与固件负责（与手机端一致，手机是主要把关方）。若要设备自己拦，在 `on_start` 里或按钮回调里检查 `state->online` 与账号权限即可。

---

## lv_conf.h 需要打开

- **字号**：`LV_FONT_MONTSERRAT_14/16/18/20`（源码里 `FONT_*` 宏引用，可按需改档位）。
- **符号**：默认符号字体即含 `LV_SYMBOL_IMAGE / GPS / WARNING / EYE_OPEN / REFRESH / OK / DUMMY`（须知行图标用的是这些占位符号）。
- **中文（可选）**：`ATOM_LANG_ZH` 需要一套 **CJK 字体**编进 LVGL（内置 Montserrat 不含中文）。默认 `ATOM_LANG_EN`；接了中文字体后把 `FONT_*` 指到该字体、并把 `state.lang` 设为 `ATOM_LANG_ZH` 即可。

---

## 待替换的占位（与设计对齐）

- **品牌绿** `#7CC00C`（`COL_BRAND`）—— 占位，替换为 BodyPark 正式绿。
- **须知行图标** —— 现用 LVGL 内置符号占位（入框/摆位/Beta 等），正式版换成设计师的品牌线性图标。
- **课程数据** —— `course_name / course_meta` 为占位，接真实课程。
- **微动效** —— 本参考页面切换为直接显隐；如需与手机端一致的「淡入 + 轻微缩放」，可用 LVGL 的
  `lv_obj_fade_in()` / `lv_anim_t`（缩放 zoom）在 `show_page()` 里补上。Flutter 端用的是 220ms、easeOutCubic。

---

## 与 Flutter 端的行为对照

| 行为 | Flutter (`atom_screens.dart`) | 本实现 (`atom_ui.c`) |
|---|---|---|
| 待机 → 模式列表 | `_startPressed` | `on_idle_start` |
| 选中态：仅选中卡显示副标 + 勾 | `_AtomTile(selected)` | `refresh_tiles()` |
| 开始 → 确认（或跳过） | `skipAtomConfirm` 判断 | `on_modes_start` |
| 须知按模式生成 | `_noticeRows()` | `build_notice()` |
| 「不再显示」脚注 | `_DontShowAgain`（Start 下方） | `build_confirm` 的 footnote |

> 结构校验通过（括号平衡），但**未在真实 LVGL 工程里编译**——请在你的板级工程 / LVGL 模拟器里 `#include` 后编译验证，并按上面的 lv_conf 项开启字体与符号。
