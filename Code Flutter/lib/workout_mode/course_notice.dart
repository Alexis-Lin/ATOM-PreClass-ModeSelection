import 'package:flutter/material.dart';

import 'controller.dart';
import 'models.dart';
import 'shared.dart';
import 'strings.dart';
import 'tokens.dart';

/// Pre-start course notice, presented as a **height-adaptive bottom sheet**.
///
/// Positive-only framing guidance. Live Coach shows a coach mental model +
/// a short "do" checklist + a link to the Framing tips page (the don'ts live
/// there). Record & Recap sets report / algorithm expectations. The data-save
/// choice is a subtle line under the content; when global saving is off it
/// flips to an invite to allow saving for this workout.
///
/// ── INTEGRATION (front-end) ────────────────────────────────────────────────
/// • Present it with [showCourseNoticeSheet] from the mode-select CTA, only for
///   AI modes and only when the user hasn't opted out — the call site already
///   guards on `mode.isAi && !controller.skipNotice` (see phone_sheet.dart).
/// • [onStart] is the ONLY forward exit — your host hook that actually begins
///   the session (navigate to the live-coaching / recording screen, tell the
///   ATOM device to start, etc.). The sheet closes itself first, then calls
///   `onStart(mode)`. Wire this to real navigation / a BLoC/Riverpod event.
/// • Dismissing (✕ button, drag-down, or scrim tap) just closes the sheet and
///   returns to mode select — NOTHING starts. This is the "防呆" back-out.
/// • "Change" opens the data-destination sheet (`showDataChoiceSheet`); "See
///   framing tips" pushes [FramingTipsPage] as a full page. Both compose fine
///   on top of this sheet.
///
/// ── COPY & ASSETS (for UX writing / design) ────────────────────────────────
/// • All strings come from [L] (strings.dart) — no copy is hard-coded here, so
///   wording/localization changes live in that one file.
/// • The framing diagram is [FramingIllustration], a placeholder — swap its
///   body for the final art (Image.asset / SVG) without touching this file.
/// • Height cap is 90% of the screen (`_kMaxSheetFraction`); short content
///   stays short, taller content scrolls internally with the CTA pinned.

/// Fraction of screen height the notice sheet may occupy before it scrolls.
const double _kMaxSheetFraction = 0.9;

/// Show the pre-start notice. Returns when the sheet is dismissed OR after the
/// user taps "I'm ready" (which also fires [onStart]).
Future<void> showCourseNoticeSheet(
  BuildContext context, {
  required WorkoutModeController controller,
  required WorkoutMode mode,
  required ModeCallback onStart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true, // let the sheet grow past the default ~50% cap
    backgroundColor: Colors.transparent, // our own rounded container paints the bg
    barrierColor: const Color(0x57181A18), // dimmed course backdrop behind
    builder: (sheetContext) => _CourseNoticeSheet(
      controller: controller,
      mode: mode,
      onStart: onStart,
    ),
  );
}

class _CourseNoticeSheet extends StatelessWidget {
  const _CourseNoticeSheet({
    required this.controller,
    required this.mode,
    required this.onStart,
  });

  final WorkoutModeController controller;
  final WorkoutMode mode;
  final ModeCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final l = L(controller.lang);
        final media = MediaQuery.of(context);
        // Record & Recap's output IS the saved video + recap → saving is required.
        final recapNeedsSave = mode == WorkoutMode.recordRecap && !controller.saving;
        return Container(
          constraints: BoxConstraints(maxHeight: media.size.height * _kMaxSheetFraction),
          decoration: const BoxDecoration(
            color: Wm.sheet,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // hug content → height-adaptive
            children: [
              const _Grab(),
              // Title + ✕ close (防呆: an explicit back-out besides scrim/drag).
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 12, 10),
                child: Row(children: [
                  Expanded(
                    child: Text(l.noticeTitle,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Wm.ink)),
                  ),
                  _CloseButton(onTap: () => Navigator.of(context).maybePop()),
                ]),
              ),
              // Scrollable body — image → text → content → save line (matches the
              // prototype's image-first rhythm). Scrolls only if it exceeds the cap.
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  children: [
                    FramingIllustration(knee: l.frKnee, dist: l.frDist),
                    const SizedBox(height: 14),
                    Text(mode == WorkoutMode.recordRecap ? l.recapSub : l.coachSub,
                        style: const TextStyle(fontSize: 14.5, height: 1.5, color: Wm.ink2)),
                    const SizedBox(height: 16),
                    ..._body(context, l),
                    const SizedBox(height: 16),
                    _DataSaveLine(controller: controller), // "Change" stays with the content
                  ],
                ),
              ),
              // Action zone (hairline-separated from content): don't-show + CTA.
              Container(
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: Wm.hair))),
                padding: EdgeInsets.fromLTRB(20, 12, 20, 14 + media.viewPadding.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DontShowRow(controller: controller),
                    const SizedBox(height: 12),
                    // Recap without saving can't proceed → CTA opens the enable flow instead.
                    PillButton(
                      label: recapNeedsSave ? l.recapTurnOnCta : l.ready,
                      onTap: recapNeedsSave
                          ? () => showDataChoiceSheet(context, controller)
                          : () {
                              Navigator.of(context).maybePop(); // close the sheet first…
                              onStart(mode); // …then start the workout (host hook)
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _body(BuildContext context, L l) {
    if (mode == WorkoutMode.recordRecap) {
      if (!controller.saving) {
        return [
          _InfoBox(
              icon: Icons.warning_amber_rounded,
              header: l.recapNeedHeader,
              body: l.recapNeed,
              warn: true), // hard requirement, not just "no report"
        ];
      }
      return [
        _InfoBox(icon: Icons.auto_awesome_outlined, header: l.reportHeader, body: l.report),
        const SizedBox(height: 10),
        _InfoBox(icon: Icons.shield_outlined, header: l.algoHeader, body: l.algo),
      ];
    }
    return [
      CheckList(items: l.coachDo, tone: CheckTone.good),
      const SizedBox(height: 14),
      _TipsLink(
        text: l.tipsLink,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FramingTipsPage(controller: controller),
        )),
      ),
      const SizedBox(height: 14),
      BetaCaution(text: l.beta),
    ];
  }
}

/// Drag handle at the top of the sheet.
class _Grab extends StatelessWidget {
  const _Grab();
  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 5,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFD7DAD3),
          borderRadius: BorderRadius.circular(99),
        ),
      );
}

/// Round ✕ close button (top-right of the sheet).
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(color: Wm.iconBg, shape: BoxShape.circle),
          child: const Icon(Icons.close, size: 17, color: Wm.ink2),
        ),
      );
}

AppBar _bar(BuildContext context, String title) => AppBar(
      backgroundColor: Wm.sheet,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Wm.ink),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Wm.ink)),
      centerTitle: false,
    );

// ---------------------------------------------------------------------------
// Framing tips page (extra reading, opened from the notice)
// ---------------------------------------------------------------------------
class FramingTipsPage extends StatelessWidget {
  const FramingTipsPage({super.key, required this.controller});
  final WorkoutModeController controller;

  @override
  Widget build(BuildContext context) {
    final l = L(controller.lang);
    return Scaffold(
      backgroundColor: Wm.sheet,
      appBar: _bar(context, l.tipsTitle),
      body: SafeArea(
        top: false,
        // Rhythm: ① image → ② plain lead text → ③ plain sections (no boxes) → ✗ list.
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            FramingIllustration(knee: l.frKnee, dist: l.frDist),
            const SizedBox(height: 14),
            Text(l.coachLine,
                style: const TextStyle(fontSize: 14, height: 1.55, color: Wm.ink2)),
            _PlainSec(icon: Icons.groups_outlined, header: l.crowdHeader, body: l.crowd),
            _PlainSec(icon: Icons.camera_outdoor_outlined, header: l.tripodHeader, body: l.tripod),
            const SizedBox(height: 16),
            Text(l.avoidHeader.toUpperCase(),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: Wm.warn, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            CheckList(items: l.coachAvoid, tone: CheckTone.bad),
          ],
        ),
      ),
      // Pinned "Got it" dismisses the tips and returns to the notice sheet.
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Wm.sheet,
          border: Border(top: BorderSide(color: Wm.hair)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: SheetButton(
              label: l.tipsOk,
              primary: true,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TipsLink extends StatelessWidget {
  const _TipsLink({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Wm.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Icon(Icons.visibility_outlined, size: 20, color: Wm.ink2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Wm.ink)),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Wm.ink3),
          ]),
        ),
      );
}

// ---------------------------------------------------------------------------
enum CheckTone { good, bad }

class CheckList extends StatelessWidget {
  const CheckList({super.key, required this.items, required this.tone});
  final List<String> items;
  final CheckTone tone;
  @override
  Widget build(BuildContext context) {
    final good = tone == CheckTone.good;
    final color = good ? Wm.brandInk : Wm.warn;
    final icon = good ? Icons.check : Icons.close;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item, style: const TextStyle(fontSize: 14, height: 1.4, color: Wm.ink)),
            ),
          ]),
        ),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.header, required this.body, this.warn = false});
  final IconData icon;
  final String header;
  final String body;
  final bool warn;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: warn ? Wm.caution : Wm.ink2),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(header,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800, color: warn ? Wm.caution : Wm.ink)),
              const SizedBox(height: 3),
              Text(body,
                  style: TextStyle(fontSize: 12, height: 1.45, color: warn ? Wm.caution : Wm.ink2)),
            ]),
          ),
        ]),
      );
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.header, required this.body, this.warn = false});
  final IconData icon;
  final String header;
  final String body;
  final bool warn;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: warn ? Wm.cautionBg : Wm.iconBg,
          border: warn ? Border.all(color: Wm.cautionLine) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _InfoRow(icon: icon, header: header, body: body, warn: warn),
      );
}

/// Plain (box-free) icon-header + body section — keeps the framing-tips page
/// light instead of a stack of little boxes.
class _PlainSec extends StatelessWidget {
  const _PlainSec({required this.icon, required this.header, required this.body});
  final IconData icon;
  final String header;
  final String body;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, left: 2, right: 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 15, color: Wm.ink2),
            const SizedBox(width: 7),
            Text(header,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Wm.ink)),
          ]),
          const SizedBox(height: 3),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.5, color: Wm.ink2)),
        ]),
      );
}

/// Framing illustration — Concept B "side setup scene": ATOM low on the floor
/// (≈ knee), tilted up; a view cone; the person standing back 0.5–1 m with the
/// whole body inside the view. Teaches the actual setup (low + stand back).
///
/// ⚠️ DESIGNER: placeholder vector — swap for the final art. Labels come in via
/// [knee] / [dist] so they localize. (Cone lines drawn solid here; the real
/// asset can dash them.)
class FramingIllustration extends StatelessWidget {
  const FramingIllustration({super.key, required this.knee, required this.dist});
  final String knee;
  final String dist;
  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 360 / 236,
        child: CustomPaint(painter: _FramingPainter(knee: knee, dist: dist)),
      );
}

class _FramingPainter extends CustomPainter {
  _FramingPainter({required this.knee, required this.dist});
  final String knee;
  final String dist;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 360.0); // author in a 360×236 space

    final bg = RRect.fromRectAndRadius(const Rect.fromLTWH(1, 1, 358, 234), const Radius.circular(16));
    canvas.drawRRect(bg, Paint()..color = const Color(0xFFF6F7F4));
    canvas.drawRRect(
        bg, Paint()..color = const Color(0xFFE6E8E2)..style = PaintingStyle.stroke..strokeWidth = 2);

    canvas.drawLine(const Offset(26, 196), const Offset(334, 196),
        Paint()..color = const Color(0xFFB7BBB0)..strokeWidth = 3..strokeCap = StrokeCap.round);

    final cone = Path()..moveTo(66, 186)..lineTo(300, 36)..lineTo(300, 194)..close();
    canvas.drawPath(cone, Paint()..color = const Color(0xFF4F7D05).withOpacity(0.06));
    final coneLine = Paint()
      ..color = const Color(0xFF9BBF63)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(68, 184), const Offset(300, 38), coneLine);
    canvas.drawLine(const Offset(68, 188), const Offset(300, 192), coneLine);

    // ATOM puck (low, tilted up)
    canvas.save();
    canvas.translate(58, 186);
    canvas.rotate(-20 * 3.1415926535 / 180);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-17, -13, 34, 22), const Radius.circular(6)),
        Paint()..color = const Color(0xFF2B2D2C));
    canvas.drawCircle(const Offset(12, -2.5), 5,
        Paint()..color = const Color(0xFFC9EC8F)..style = PaintingStyle.stroke..strokeWidth = 2.6);
    canvas.restore();

    // figure (whole body inside the cone)
    final green = Paint()
      ..color = const Color(0xFF4F7D05)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(const Offset(252, 98), 15, Paint()..color = const Color(0xFFC9EC8F));
    canvas.drawCircle(const Offset(252, 98), 15, green);
    canvas.drawLine(const Offset(252, 113), const Offset(252, 162), green);
    canvas.drawLine(const Offset(252, 126), const Offset(232, 149), green);
    canvas.drawLine(const Offset(252, 126), const Offset(272, 149), green);
    canvas.drawLine(const Offset(252, 162), const Offset(236, 194), green);
    canvas.drawLine(const Offset(252, 162), const Offset(268, 194), green);

    // distance bracket
    final br = Paint()..color = const Color(0xFF8A8F86)..strokeWidth = 1.6;
    canvas.drawLine(const Offset(66, 214), const Offset(252, 214), br);
    canvas.drawLine(const Offset(66, 209), const Offset(66, 219), br);
    canvas.drawLine(const Offset(252, 209), const Offset(252, 219), br);

    _label(canvas, knee, const Offset(52, 166));
    _label(canvas, dist, const Offset(159, 224));
  }

  void _label(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(color: Color(0xFF6A6F74), fontSize: 13, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_FramingPainter old) => old.knee != knee || old.dist != dist;
}

// ---------------------------------------------------------------------------
/// Subtle data-destination line. When global saving is off, it flips to a
/// green invite ("Video saving is off — this workout won't be saved · Turn on").
class _DataSaveLine extends StatelessWidget {
  const _DataSaveLine({required this.controller});
  final WorkoutModeController controller;

  @override
  Widget build(BuildContext context) {
    final l = L(controller.lang);
    if (!controller.saving) {
      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => showDataChoiceSheet(context, controller),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            color: Wm.brandTint,
            border: Border.all(color: const Color(0xFFD6ECB3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Expanded(
              child: Text(l.drSaveOff,
                  style: const TextStyle(fontSize: 11.5, height: 1.4, color: Wm.brandInk)),
            ),
            const SizedBox(width: 8),
            Text(l.drTurnOn,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Wm.brandInk,
                    decoration: TextDecoration.underline)),
          ]),
        ),
      );
    }
    // App can't verify the SD card → no "no card" state here; just the choice.
    final label = controller.dataChoice == DataChoice.cloud ? l.drCloud : l.drLocal;
    return GestureDetector(
      onTap: () => showDataChoiceSheet(context, controller),
      behavior: HitTestBehavior.opaque,
      child: Row(children: [
        const Icon(Icons.cloud_outlined, size: 14, color: Wm.ink3),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 11.5, height: 1.4, color: Wm.ink3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 6),
        Text(l.drChange,
            style: const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: Wm.ink, decoration: TextDecoration.underline)),
      ]),
    );
  }
}

class _DontShowRow extends StatelessWidget {
  const _DontShowRow({required this.controller});
  final WorkoutModeController controller;
  @override
  Widget build(BuildContext context) {
    final l = L(controller.lang);
    return InkWell(
      onTap: () => controller.setSkipNotice(!controller.skipNotice),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(controller.skipNotice ? Icons.check_box : Icons.check_box_outline_blank,
              size: 17, color: controller.skipNotice ? Wm.ink : Wm.ink3),
          const SizedBox(width: 7),
          Text(l.dontShow, style: const TextStyle(fontSize: 12.5, color: Wm.ink2)),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data-choice secondary sheet (normal "where to save" vs invite-to-save)
// ---------------------------------------------------------------------------
Future<void> showDataChoiceSheet(BuildContext context, WorkoutModeController controller) {
  final l = L(controller.lang);
  final invite = !controller.saving; // saving globally off → guide to allow
  var alwaysOn = false; // invite scope: false = this session only; true = flip global setting
  return showAppSheet(
    context,
    scrollable: true,
    child: StatefulBuilder(
      builder: (context, setSheetState) {
        // Selecting a card just highlights it now; the commit is the button below.
        void pick(DataChoice c) {
          controller.setDataChoice(c);
          setSheetState(() {});
        }

        final remind = controller.dataChoice == DataChoice.local; // SD reminder (app can't verify)
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(invite ? l.saveOnTitle : l.dataSheetTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Wm.ink)),
            if (invite) ...[
              const SizedBox(height: 4),
              Text(l.saveOnBody, style: const TextStyle(fontSize: 12.5, height: 1.5, color: Wm.ink2)),
            ],
            const SizedBox(height: 12),
            _DataOption(
              icon: Icons.cloud_outlined,
              name: l.dCloudName,
              tag: l.dRecommended,
              tagGood: true,
              benefits: l.dCloudBenefits,
              selected: controller.dataChoice == DataChoice.cloud,
              onTap: () => pick(DataChoice.cloud),
            ),
            const SizedBox(height: 10),
            _DataOption(
              icon: Icons.sd_card_outlined,
              name: l.dLocalName,
              tag: l.dNeedsSd,
              tagGood: false,
              benefits: l.dLocalBenefits,
              selected: controller.dataChoice == DataChoice.local,
              onTap: () => pick(DataChoice.local),
            ),
            if (remind) ...[
              const SizedBox(height: 10),
              _SdReminder(text: l.dLocalReminder),
            ],
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lock_outline, size: 14, color: Wm.ink3),
              const SizedBox(width: 7),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '${l.privacyNote} ',
                      style: const TextStyle(fontSize: 11.5, height: 1.5, color: Wm.ink3)),
                  TextSpan(
                      text: l.privacyLink,
                      style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.5,
                          color: Wm.ink2,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline)),
                ])),
              ),
            ]),
            const SizedBox(height: 16),
            if (invite) ...[
              // Scope of the enable: this session only (default) vs flip the global setting.
              _ScopeCheck(
                value: alwaysOn,
                label: l.dSaveAlways,
                onTap: () => setSheetState(() => alwaysOn = !alwaysOn),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: SheetButton(label: l.saveNotNow, onTap: () => Navigator.pop(context))),
                const SizedBox(width: 9),
                Expanded(
                  child: SheetButton(
                    label: l.dEnableCta,
                    primary: true,
                    onTap: () {
                      if (alwaysOn) {
                        controller.setSaveVideosOn(true); // "keep on" → global setting
                      } else {
                        controller.setSessionSave(true); // just this session
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ]),
            ] else
              SheetButton(label: l.dDone, primary: true, onTap: () => Navigator.pop(context)),
          ],
        );
      },
    ),
  );
}

/// Neutral SD reminder for "Keep on ATOM" (the app can't verify the card).
class _SdReminder extends StatelessWidget {
  const _SdReminder({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(color: Wm.iconBg, borderRadius: BorderRadius.circular(8)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline, size: 15, color: Wm.ink3),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, height: 1.45, color: Wm.ink2)),
          ),
        ]),
      );
}

/// Checkbox row for the "keep saving on from now on" scope choice.
class _ScopeCheck extends StatelessWidget {
  const _ScopeCheck({required this.value, required this.label, required this.onTap});
  final bool value;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Icon(value ? Icons.check_box : Icons.check_box_outline_blank,
                size: 19, color: value ? Wm.brandInk : Wm.ink3),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5, color: Wm.ink2))),
          ]),
        ),
      );
}

class _DataOption extends StatelessWidget {
  const _DataOption({
    required this.icon,
    required this.name,
    required this.tag,
    required this.tagGood,
    required this.benefits,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String name;
  final String tag;
  final bool tagGood;
  final List<String> benefits;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? Wm.brandTint : Wm.card,
            border: Border.all(color: selected ? Wm.brandInk : Wm.line, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, size: 20, color: selected ? Wm.brandInk : Wm.ink2),
              const SizedBox(width: 10),
              Text(name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Wm.ink)),
              const SizedBox(width: 8),
              _DataTag(text: tag, good: tagGood),
              const Spacer(),
              WmRadio(selected: selected, size: 22),
            ]),
            const SizedBox(height: 9),
            for (final b in benefits)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 30),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check, size: 13, color: Wm.ink3),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(b, style: const TextStyle(fontSize: 12, height: 1.4, color: Wm.ink2)),
                  ),
                ]),
              ),
          ]),
        ),
      );
}

class _DataTag extends StatelessWidget {
  const _DataTag({required this.text, required this.good});
  final String text;
  final bool good;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          // "Recommended" = brand green; "Needs SD card" = neutral gray (not a
          // premium/positive signal).
          color: good ? Wm.brandTint : const Color(0xFFF1F2EE),
          border: Border.all(color: good ? const Color(0xFFD6ECB3) : Wm.line),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: good ? Wm.brandInk : Wm.ink2)),
      );
}
