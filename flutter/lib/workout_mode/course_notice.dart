import 'package:flutter/material.dart';

import 'controller.dart';
import 'models.dart';
import 'shared.dart';
import 'strings.dart';
import 'tokens.dart';

/// Full-screen pre-start course notice.
///
/// Positive-only framing guidance. Live Coach shows a coach mental model +
/// a short "do" checklist + a link to the Framing tips page (the don'ts live
/// there). Record & Recap sets report / algorithm expectations. The data-save
/// choice is a subtle bottom line; when global saving is off it flips to an
/// invite to allow saving for this workout.
class CourseNoticePage extends StatelessWidget {
  const CourseNoticePage({
    super.key,
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
        return Scaffold(
          backgroundColor: Wm.sheet,
          appBar: _bar(context, l.noticeTitle),
          body: SafeArea(
            top: false,
            child: Column(children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  children: [
                    Text(mode == WorkoutMode.recordRecap ? l.recapSub : l.coachSub,
                        style: const TextStyle(fontSize: 14.5, height: 1.5, color: Wm.ink2)),
                    const SizedBox(height: 14),
                    const FramingIllustration(),
                    const SizedBox(height: 16),
                    ..._body(context, l),
                  ],
                ),
              ),
              _Footer(controller: controller, mode: mode, onStart: onStart),
            ]),
          ),
        );
      },
    );
  }

  List<Widget> _body(BuildContext context, L l) {
    if (mode == WorkoutMode.recordRecap) {
      if (!controller.saving) {
        return [
          _InfoBox(icon: Icons.description_outlined, header: l.reportHeader, body: l.recapNoSave),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            _CoachCallout(text: l.coachLine),
            const SizedBox(height: 14),
            Row(children: [
              const Icon(Icons.check, size: 15, color: Wm.brandInk),
              const SizedBox(width: 7),
              Text(l.setupLabel.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: Wm.brandInk, letterSpacing: 0.5)),
            ]),
            const SizedBox(height: 8),
            const FramingIllustration(),
            const SizedBox(height: 14),
            _InfoBox(icon: Icons.groups_outlined, header: l.crowdHeader, body: l.crowd),
            const SizedBox(height: 10),
            _InfoBox(icon: Icons.camera_outdoor_outlined, header: l.tripodHeader, body: l.tripod),
            const SizedBox(height: 16),
            Text(l.avoidHeader.toUpperCase(),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: Wm.warn, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            CheckList(items: l.coachAvoid, tone: CheckTone.bad),
            const SizedBox(height: 16),
            _InfoBox(icon: Icons.info_outline, header: l.perExHeader, body: l.perEx),
          ],
        ),
      ),
    );
  }
}

class _CoachCallout extends StatelessWidget {
  const _CoachCallout({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: Wm.brandTint,
          border: Border.all(color: const Color(0xFFD6ECB3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.visibility_outlined, size: 18, color: Wm.brandInk),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5, color: Wm.brandInk)),
          ),
        ]),
      );
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

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.header, required this.body});
  final IconData icon;
  final String header;
  final String body;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(color: Wm.iconBg, borderRadius: BorderRadius.circular(12)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: Wm.ink2),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(header,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Wm.ink)),
              const SizedBox(height: 3),
              Text(body, style: const TextStyle(fontSize: 12, height: 1.45, color: Wm.ink2)),
            ]),
          ),
        ]),
      );
}

/// Placeholder framing diagram.
/// ⚠️ DESIGNER: replace with the "correct vs wrong" framing illustration.
class FramingIllustration extends StatelessWidget {
  const FramingIllustration({super.key});
  @override
  Widget build(BuildContext context) => Container(
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0EC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Wm.line),
        ),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.accessibility_new, size: 54, color: Wm.brandInk),
            SizedBox(height: 6),
            Icon(Icons.crop_free, size: 22, color: Wm.ink3),
          ]),
        ),
      );
}

// ---------------------------------------------------------------------------
class _Footer extends StatelessWidget {
  const _Footer({required this.controller, required this.mode, required this.onStart});
  final WorkoutModeController controller;
  final WorkoutMode mode;
  final ModeCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = L(controller.lang);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: const BoxDecoration(
        color: Wm.sheet,
        border: Border(top: BorderSide(color: Wm.hair)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _DataSaveLine(controller: controller),
        const SizedBox(height: 12),
        PillButton(label: l.ready, onTap: () => onStart(mode)),
        const SizedBox(height: 6),
        _DontShowRow(controller: controller),
      ]),
    );
  }
}

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
    final noSd = controller.dataChoice == DataChoice.local && !controller.hasSdCard;
    final label = controller.dataChoice == DataChoice.cloud
        ? l.drCloud
        : (noSd ? l.drNoSd : l.drLocal);
    final color = noSd ? Wm.warn : Wm.ink3;
    return GestureDetector(
      onTap: () => showDataChoiceSheet(context, controller),
      behavior: HitTestBehavior.opaque,
      child: Row(children: [
        Icon(noSd ? Icons.warning_amber_rounded : Icons.cloud_outlined, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label,
              style: TextStyle(fontSize: 11.5, height: 1.4, color: color),
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
  return showAppSheet(
    context,
    scrollable: true,
    child: StatefulBuilder(
      builder: (context, setSheetState) {
        void pick(DataChoice c) {
          if (invite) {
            controller.setDataChoice(c);
            controller.setSessionSave(true);
            Navigator.pop(context);
          } else {
            controller.setDataChoice(c);
            setSheetState(() {});
          }
        }

        final noSd = controller.dataChoice == DataChoice.local && !controller.hasSdCard;
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
              selected: !invite && controller.dataChoice == DataChoice.cloud,
              onTap: () => pick(DataChoice.cloud),
            ),
            const SizedBox(height: 10),
            _DataOption(
              icon: Icons.sd_card_outlined,
              name: l.dLocalName,
              tag: l.dNeedsSd,
              tagGood: false,
              benefits: l.dLocalBenefits,
              selected: !invite && controller.dataChoice == DataChoice.local,
              onTap: () => pick(DataChoice.local),
            ),
            if (!invite && noSd) ...[
              const SizedBox(height: 12),
              BetaCaution(text: l.noSdWarn),
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
            SheetButton(
              label: invite ? l.saveNotNow : l.dDone,
              primary: !invite,
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
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
          color: good ? Wm.brandTint : Wm.plusBg,
          border: Border.all(color: good ? const Color(0xFFD6ECB3) : Wm.plusLine),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: good ? Wm.brandInk : Wm.plus)),
      );
}
