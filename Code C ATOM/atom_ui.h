/*
 * atom_ui.h — Pre-workout UI for the ATOM 466×466 round device (embedded C).
 *
 * Reference implementation of the device-side screens that mirror the Flutter
 * `Code Flutter/lib/workout_mode/atom_screens.dart`:
 *
 *     idle (today's workout)  →  mode list (Live Coach / Record & Recap)
 *                             →  "before you start" confirm  →  onStart()
 *
 * Built on LVGL (https://lvgl.io), which is the usual choice for small round
 * MCU displays. Tested against the LVGL v8/v9 public API. No other deps.
 *
 * This file is UI only. Entitlement (Plus / AI quota), pairing and the actual
 * workout session are the firmware's job — see `on_start` and `online` below.
 */
#ifndef ATOM_UI_H
#define ATOM_UI_H

#include "lvgl.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* The two AI modes shown on the device (Manual Log stays on the phone). */
typedef enum {
    ATOM_MODE_LIVE_COACH = 0,
    ATOM_MODE_RECORD_RECAP = 1,
} atom_mode_t;

typedef enum {
    ATOM_LANG_EN = 0,
    ATOM_LANG_ZH = 1, /* needs a CJK font compiled into LVGL — see README */
} atom_lang_t;

/*
 * Mutable UI state. The caller owns this struct; keep it alive for the UI's
 * lifetime. `selected` / `skip_confirm` are written back as the user interacts,
 * so firmware can persist them (e.g. "don't show again").
 */
typedef struct {
    atom_mode_t selected;     /* highlighted tile; defaults to Live Coach */
    bool        skip_confirm; /* "don't show again" — start without the confirm */
    atom_lang_t lang;         /* EN by default */
    bool        online;       /* synced from account/phone; see note on on_start */
    const char *course_name;  /* placeholder, e.g. "Back & Legs" */
    const char *course_meta;  /* placeholder, e.g. "32 min · Strength" */
} atom_ui_state_t;

/*
 * Called when the user confirms Start. Begin the session here (start capture,
 * switch to the in-workout screen, etc.). `mode` is the chosen mode; `user` is
 * the opaque pointer you passed to atom_ui_create().
 *
 * NOTE: this reference does not hard-gate Start on `online`/entitlement — the
 * phone is the gatekeeper and the device is normally only reachable here when
 * usable. If you want the device to self-gate, check `state->online` (and your
 * account entitlement) inside this callback or before calling Start.
 */
typedef void (*atom_start_cb_t)(atom_mode_t mode, void *user);

/*
 * Build the UI onto `parent` (usually lv_scr_act()). Sized for a 466×466 round
 * panel; content is kept within a safe centered area so nothing clips on the
 * circle. Shows the idle screen first.
 */
void atom_ui_create(lv_obj_t *parent,
                    atom_ui_state_t *state,
                    atom_start_cb_t on_start,
                    void *user);

#ifdef __cplusplus
}
#endif

#endif /* ATOM_UI_H */
