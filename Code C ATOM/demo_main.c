/*
 * demo_main.c — minimal wiring example for atom_ui on an LVGL simulator.
 *
 * This is illustrative, not part of the firmware. It shows the two things a
 * firmware engineer must provide: (1) an atom_ui_state_t, (2) an on_start
 * callback that actually begins the session. Display/tick/input init is
 * board-specific and omitted (see the LVGL porting guide).
 */
#include "atom_ui.h"
#include <stdio.h>

/* Your host hook: the user confirmed Start on the device. */
static void on_start(atom_mode_t mode, void *user)
{
    (void)user;
    /* Begin capture, switch to the in-workout screen, notify the phone, etc.
     * Optionally self-gate here on entitlement / state->online. */
    printf("START mode=%s\n", mode == ATOM_MODE_LIVE_COACH ? "LiveCoach" : "RecordRecap");
}

/* Call once after lv_init() + your display/input driver are up. */
void atom_demo_init(void)
{
    static atom_ui_state_t state = {
        .selected     = ATOM_MODE_LIVE_COACH,
        .skip_confirm = false,
        .lang         = ATOM_LANG_EN,
        .online       = true,
        .course_name  = "Back & Legs",
        .course_meta  = "32 min - Strength",
    };
    atom_ui_create(lv_scr_act(), &state, on_start, NULL);
}
