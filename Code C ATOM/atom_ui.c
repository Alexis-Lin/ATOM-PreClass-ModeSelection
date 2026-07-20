/*
 * atom_ui.c — ATOM 466×466 round device pre-workout UI (LVGL, embedded C).
 * See atom_ui.h for the public API and atom_screens.dart for the Flutter twin.
 *
 * Screens: idle → mode list → "before you start" confirm → on_start().
 * Single-screen device, so state lives in one file-static context.
 */
#include "atom_ui.h"
#include <stddef.h>

/* ── design tokens (mirror Code Flutter/lib/workout_mode/tokens.dart) ─────── */
#define COL_BG          lv_color_hex(0x000000) /* OLED black                  */
#define COL_CARD        lv_color_hex(0x151614)
#define COL_CARD_LINE   lv_color_hex(0x2A2C28)
#define COL_CARD_SEL    lv_color_hex(0x1A1D15)
#define COL_TEXT        lv_color_hex(0xF2F4EF)
#define COL_SUB         lv_color_hex(0x8B918A)
#define COL_BRAND       lv_color_hex(0x7CC00C) /* lime accent (placeholder)   */
#define COL_CHIP        lv_color_hex(0x1C1F18) /* notice icon chip bg         */
#define COL_FOOT        lv_color_hex(0x8A9086) /* footnote, unchecked         */
#define COL_FOOT_ON     lv_color_hex(0xC4CABD) /* footnote, checked           */

#define SCREEN      466
#define SAFE_PAD     40   /* keep content off the round edges                 */
#define TILE_W      354   /* ≈ 0.76 × 466                                     */

/* These fonts must be enabled in lv_conf.h (LV_FONT_MONTSERRAT_*). */
#define FONT_BIG    &lv_font_montserrat_20
#define FONT_TITLE  &lv_font_montserrat_18
#define FONT_NAME   &lv_font_montserrat_16
#define FONT_BODY   &lv_font_montserrat_14

/* ── strings (EN + ZH; ZH needs a CJK font — see README) ─────────────────── */
typedef struct {
    const char *kicker;        /* "TODAY'S WORKOUT" */
    const char *start_workout; /* idle button       */
    const char *start;         /* modes/confirm button */
    const char *modes_title;   /* "Workout mode"    */
    const char *coach_name, *coach_sub;
    const char *recap_name, *recap_sub;
    const char *confirm_title; /* "Before you start" */
    const char *dont_show;
    const char *coach_notice[3];
    const char *recap_notice[3];
} atom_strings_t;

static const atom_strings_t STR[2] = {
    /* EN */ {
        .kicker = "TODAY'S WORKOUT", .start_workout = "Start workout", .start = "Start",
        .modes_title = "Workout mode",
        .coach_name = "Live Coach", .coach_sub = "Live counting and cues.",
        .recap_name = "Record & Recap", .recap_sub = "Records quietly, reports after.",
        .confirm_title = "Before you start", .dont_show = "Don't show again",
        .coach_notice = { "Whole body in frame",
                          "ATOM at knee height or on the floor",
                          "Beta - use your own judgment" },
        .recap_notice = { "Stay in frame - front or side both fine",
                          "Good light, just you in view",
                          "Deeper recaps coming via OTA" },
    },
    /* ZH */ {
        .kicker = "今日训练", .start_workout = "开始训练", .start = "开始",
        .modes_title = "上课模式",
        .coach_name = "实时教练", .coach_sub = "实时计数、动作提示。",
        .recap_name = "录制复盘", .recap_sub = "安静录制，练后出报告。",
        .confirm_title = "开始前请确认", .dont_show = "不再显示",
        .coach_notice = { "全身入框",
                          "ATOM 约膝盖高，或放地上",
                          "Beta——请自行判断" },
        .recap_notice = { "全程在画面里，正对侧对都行",
                          "光线充足，画面里只有你",
                          "更深复盘随 OTA 上线" },
    },
};

/* Icons per notice row (LVGL built-in symbols — designer swaps for brand art). */
static const char *COACH_ICON[3] = { LV_SYMBOL_IMAGE, LV_SYMBOL_GPS, LV_SYMBOL_WARNING };
static const char *RECAP_ICON[3] = { LV_SYMBOL_IMAGE, LV_SYMBOL_EYE_OPEN, LV_SYMBOL_REFRESH };

/* ── context (single instance) ───────────────────────────────────────────── */
typedef struct {
    atom_ui_state_t *st;
    atom_start_cb_t  on_start;
    void            *user;
    lv_obj_t *page_idle, *page_modes, *page_confirm;
    lv_obj_t *tile[2], *tile_sub[2], *tile_check[2];
    lv_obj_t *notice_list;              /* repopulated per mode when confirm opens */
    lv_obj_t *dont_box, *dont_lbl;      /* footnote check + label                  */
} atom_ui_t;

static atom_ui_t g;

static const atom_strings_t *S(void) { return &STR[g.st->lang]; }

/* ── small builders ──────────────────────────────────────────────────────── */

static void style_page(lv_obj_t *p) {
    lv_obj_set_size(p, SCREEN, SCREEN);
    lv_obj_center(p);
    lv_obj_set_style_bg_color(p, COL_BG, 0);
    lv_obj_set_style_bg_opa(p, LV_OPA_COVER, 0);
    lv_obj_set_style_border_width(p, 0, 0);
    lv_obj_set_style_radius(p, 0, 0);
    lv_obj_set_style_pad_all(p, 0, 0);
    lv_obj_clear_flag(p, LV_OBJ_FLAG_SCROLLABLE);
}

static lv_obj_t *make_label(lv_obj_t *parent, const char *txt,
                            const lv_font_t *font, lv_color_t color) {
    lv_obj_t *l = lv_label_create(parent);
    lv_label_set_text(l, txt);
    lv_obj_set_style_text_font(l, font, 0);
    lv_obj_set_style_text_color(l, color, 0);
    return l;
}

/* A brand-lime pill button with dark text. */
static lv_obj_t *make_button(lv_obj_t *parent, const char *txt,
                             lv_event_cb_t cb) {
    lv_obj_t *b = lv_obj_create(parent);
    lv_obj_set_height(b, LV_SIZE_CONTENT);
    lv_obj_set_style_pad_hor(b, 34, 0);
    lv_obj_set_style_pad_ver(b, 12, 0);
    lv_obj_set_style_bg_color(b, COL_BRAND, 0);
    lv_obj_set_style_bg_opa(b, LV_OPA_COVER, 0);
    lv_obj_set_style_radius(b, LV_RADIUS_CIRCLE, 0);
    lv_obj_set_style_border_width(b, 0, 0);
    lv_obj_clear_flag(b, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_add_flag(b, LV_OBJ_FLAG_CLICKABLE);
    lv_obj_add_event_cb(b, cb, LV_EVENT_CLICKED, NULL);
    lv_obj_t *l = make_label(b, txt, FONT_NAME, lv_color_hex(0x0F1408));
    lv_obj_center(l);
    return b;
}

/* One "before you start" notice row: icon chip + text. */
static void make_notice_row(lv_obj_t *parent, const char *symbol, const char *txt) {
    lv_obj_t *row = lv_obj_create(parent);
    lv_obj_set_width(row, LV_PCT(100));
    lv_obj_set_height(row, LV_SIZE_CONTENT);
    lv_obj_set_style_bg_opa(row, LV_OPA_TRANSP, 0);
    lv_obj_set_style_border_width(row, 0, 0);
    lv_obj_set_style_pad_all(row, 0, 0);
    lv_obj_clear_flag(row, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_set_flex_flow(row, LV_FLEX_FLOW_ROW);
    lv_obj_set_flex_align(row, LV_FLEX_ALIGN_START, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);

    lv_obj_t *chip = lv_obj_create(row);
    lv_obj_set_size(chip, 30, 30);
    lv_obj_set_style_bg_color(chip, COL_CHIP, 0);
    lv_obj_set_style_bg_opa(chip, LV_OPA_COVER, 0);
    lv_obj_set_style_radius(chip, 9, 0);
    lv_obj_set_style_border_width(chip, 0, 0);
    lv_obj_set_style_pad_all(chip, 0, 0);
    lv_obj_clear_flag(chip, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_t *ic = make_label(chip, symbol, FONT_BODY, COL_BRAND);
    lv_obj_center(ic);

    lv_obj_t *l = make_label(row, txt, FONT_BODY, COL_FOOT_ON);
    lv_obj_set_style_pad_left(l, 11, 0);
    lv_obj_set_width(l, TILE_W - 30 - 11);
    lv_label_set_long_mode(l, LV_LABEL_LONG_WRAP);
}

/* ── navigation ──────────────────────────────────────────────────────────── */
static void show_page(lv_obj_t *page) {
    lv_obj_add_flag(g.page_idle, LV_OBJ_FLAG_HIDDEN);
    lv_obj_add_flag(g.page_modes, LV_OBJ_FLAG_HIDDEN);
    lv_obj_add_flag(g.page_confirm, LV_OBJ_FLAG_HIDDEN);
    lv_obj_clear_flag(page, LV_OBJ_FLAG_HIDDEN);
}

static void refresh_tiles(void) {
    for (int i = 0; i < 2; i++) {
        bool sel = (g.st->selected == (atom_mode_t)i);
        lv_obj_set_style_bg_color(g.tile[i], sel ? COL_CARD_SEL : COL_CARD, 0);
        lv_obj_set_style_border_color(g.tile[i], sel ? COL_BRAND : COL_CARD_LINE, 0);
        /* only the selected tile shows its one-line explanation + check */
        if (sel) {
            lv_obj_clear_flag(g.tile_sub[i], LV_OBJ_FLAG_HIDDEN);
            lv_obj_clear_flag(g.tile_check[i], LV_OBJ_FLAG_HIDDEN);
        } else {
            lv_obj_add_flag(g.tile_sub[i], LV_OBJ_FLAG_HIDDEN);
            lv_obj_add_flag(g.tile_check[i], LV_OBJ_FLAG_HIDDEN);
        }
    }
}

/* Rebuild the confirm notice list for the currently selected mode. */
static void build_notice(void) {
    lv_obj_clean(g.notice_list); /* drop previous rows */
    const atom_strings_t *s = S();
    bool coach = (g.st->selected == ATOM_MODE_LIVE_COACH);
    const char *const *txt = coach ? s->coach_notice : s->recap_notice;
    const char *const *ic  = coach ? COACH_ICON : RECAP_ICON;
    for (int i = 0; i < 3; i++) make_notice_row(g.notice_list, ic[i], txt[i]);
}

static void refresh_dont_show(void) {
    lv_label_set_text(g.dont_box, g.st->skip_confirm ? LV_SYMBOL_OK : LV_SYMBOL_DUMMY);
    lv_obj_set_style_text_color(g.dont_box, g.st->skip_confirm ? COL_BRAND : COL_FOOT, 0);
    lv_obj_set_style_text_color(g.dont_lbl, g.st->skip_confirm ? COL_FOOT_ON : COL_FOOT, 0);
}

/* ── events ──────────────────────────────────────────────────────────────── */
static void on_idle_start(lv_event_t *e) { (void)e; show_page(g.page_modes); }

static void on_tile_click(lv_event_t *e) {
    lv_obj_t *t = lv_event_get_target(e);
    g.st->selected = (t == g.tile[1]) ? ATOM_MODE_RECORD_RECAP : ATOM_MODE_LIVE_COACH;
    refresh_tiles();
}

static void on_modes_start(lv_event_t *e) {
    (void)e;
    if (g.st->skip_confirm) {
        if (g.on_start) g.on_start(g.st->selected, g.user);
        return;
    }
    build_notice();
    refresh_dont_show();
    show_page(g.page_confirm);
}

static void on_confirm_start(lv_event_t *e) {
    (void)e;
    if (g.on_start) g.on_start(g.st->selected, g.user);
}

static void on_dont_toggle(lv_event_t *e) {
    (void)e;
    g.st->skip_confirm = !g.st->skip_confirm;
    refresh_dont_show();
}

/* ── page builders ───────────────────────────────────────────────────────── */
static lv_obj_t *build_idle(lv_obj_t *parent) {
    const atom_strings_t *s = S();
    lv_obj_t *p = lv_obj_create(parent);
    style_page(p);
    lv_obj_set_flex_flow(p, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_flex_align(p, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    lv_obj_set_style_pad_hor(p, SAFE_PAD, 0);
    lv_obj_set_style_pad_row(p, 8, 0);

    lv_obj_t *k = make_label(p, s->kicker, FONT_BODY, COL_BRAND);
    (void)k;
    make_label(p, g.st->course_name ? g.st->course_name : "Back & Legs", FONT_BIG, COL_TEXT);
    make_label(p, g.st->course_meta ? g.st->course_meta : "32 min - Strength", FONT_BODY, COL_SUB);
    lv_obj_t *b = make_button(p, s->start_workout, on_idle_start);
    lv_obj_set_style_margin_top(b, 14, 0);
    return p;
}

static lv_obj_t *build_tile(lv_obj_t *parent, int idx, const char *name, const char *sub) {
    lv_obj_t *t = lv_obj_create(parent);
    lv_obj_set_width(t, TILE_W);
    lv_obj_set_height(t, LV_SIZE_CONTENT);
    lv_obj_set_style_bg_color(t, COL_CARD, 0);
    lv_obj_set_style_bg_opa(t, LV_OPA_COVER, 0);
    lv_obj_set_style_radius(t, 17, 0);
    lv_obj_set_style_border_width(t, 2, 0);
    lv_obj_set_style_border_color(t, COL_CARD_LINE, 0);
    lv_obj_set_style_pad_hor(t, 16, 0);
    lv_obj_set_style_pad_ver(t, 13, 0);
    lv_obj_clear_flag(t, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_add_flag(t, LV_OBJ_FLAG_CLICKABLE);
    lv_obj_add_event_cb(t, on_tile_click, LV_EVENT_CLICKED, NULL);

    /* text column (name + sub) on the left, check on the right */
    lv_obj_set_flex_flow(t, LV_FLEX_FLOW_ROW);
    lv_obj_set_flex_align(t, LV_FLEX_ALIGN_START, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);

    lv_obj_t *col = lv_obj_create(t);
    lv_obj_set_height(col, LV_SIZE_CONTENT);
    lv_obj_set_flex_grow(col, 1);
    lv_obj_set_style_bg_opa(col, LV_OPA_TRANSP, 0);
    lv_obj_set_style_border_width(col, 0, 0);
    lv_obj_set_style_pad_all(col, 0, 0);
    lv_obj_clear_flag(col, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_set_flex_flow(col, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_style_pad_row(col, 3, 0);
    make_label(col, name, FONT_NAME, COL_TEXT);
    g.tile_sub[idx] = make_label(col, sub, FONT_BODY, COL_SUB);

    g.tile_check[idx] = make_label(t, LV_SYMBOL_OK, FONT_BODY, COL_BRAND);
    return t;
}

static lv_obj_t *build_modes(lv_obj_t *parent) {
    const atom_strings_t *s = S();
    lv_obj_t *p = lv_obj_create(parent);
    style_page(p);
    lv_obj_set_flex_flow(p, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_flex_align(p, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    lv_obj_set_style_pad_row(p, 12, 0);

    make_label(p, s->modes_title, FONT_TITLE, COL_TEXT);
    g.tile[0] = build_tile(p, 0, s->coach_name, s->coach_sub);
    g.tile[1] = build_tile(p, 1, s->recap_name, s->recap_sub);
    lv_obj_t *b = make_button(p, s->start, on_modes_start);
    lv_obj_set_style_margin_top(b, 6, 0);
    refresh_tiles();
    return p;
}

static lv_obj_t *build_confirm(lv_obj_t *parent) {
    const atom_strings_t *s = S();
    lv_obj_t *p = lv_obj_create(parent);
    style_page(p);
    lv_obj_set_flex_flow(p, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_flex_align(p, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    lv_obj_set_style_pad_hor(p, SAFE_PAD, 0);
    lv_obj_set_style_pad_row(p, 14, 0);

    make_label(p, s->confirm_title, FONT_TITLE, COL_TEXT);

    /* icon-led notice list (repopulated per mode in build_notice) */
    g.notice_list = lv_obj_create(p);
    lv_obj_set_width(g.notice_list, TILE_W);
    lv_obj_set_height(g.notice_list, LV_SIZE_CONTENT);
    lv_obj_set_style_bg_opa(g.notice_list, LV_OPA_TRANSP, 0);
    lv_obj_set_style_border_width(g.notice_list, 0, 0);
    lv_obj_set_style_pad_all(g.notice_list, 0, 0);
    lv_obj_clear_flag(g.notice_list, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_set_flex_flow(g.notice_list, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_style_pad_row(g.notice_list, 12, 0);

    lv_obj_t *b = make_button(p, s->start, on_confirm_start);
    lv_obj_set_style_margin_top(b, 4, 0);

    /* "don't show again" — demoted to a small footnote under Start */
    lv_obj_t *foot = lv_obj_create(p);
    lv_obj_set_height(foot, LV_SIZE_CONTENT);
    lv_obj_set_style_bg_opa(foot, LV_OPA_TRANSP, 0);
    lv_obj_set_style_border_width(foot, 0, 0);
    lv_obj_set_style_pad_all(foot, 0, 0);
    lv_obj_clear_flag(foot, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_add_flag(foot, LV_OBJ_FLAG_CLICKABLE);
    lv_obj_add_event_cb(foot, on_dont_toggle, LV_EVENT_CLICKED, NULL);
    lv_obj_set_flex_flow(foot, LV_FLEX_FLOW_ROW);
    lv_obj_set_flex_align(foot, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    lv_obj_set_style_pad_column(foot, 7, 0);
    g.dont_box = make_label(foot, LV_SYMBOL_DUMMY, FONT_BODY, COL_FOOT);
    g.dont_lbl = make_label(foot, s->dont_show, FONT_BODY, COL_FOOT);
    return p;
}

/* ── public ──────────────────────────────────────────────────────────────── */
void atom_ui_create(lv_obj_t *parent, atom_ui_state_t *state,
                    atom_start_cb_t on_start, void *user) {
    g.st = state;
    g.on_start = on_start;
    g.user = user;

    lv_obj_set_style_bg_color(parent, COL_BG, 0);
    lv_obj_set_style_bg_opa(parent, LV_OPA_COVER, 0);

    g.page_idle    = build_idle(parent);
    g.page_modes   = build_modes(parent);
    g.page_confirm = build_confirm(parent);

    show_page(g.page_idle); /* idle first */
}
