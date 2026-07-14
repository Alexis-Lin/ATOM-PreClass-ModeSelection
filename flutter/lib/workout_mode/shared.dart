import 'package:flutter/material.dart';

import 'models.dart';
import 'tokens.dart';

typedef ModeCallback = void Function(WorkoutMode mode);

/// Material icon stand-ins.
/// ⚠️ DESIGNER: replace with the design's line icons (speaker / camcorder /
/// hand+pen).
IconData iconFor(WorkoutMode m) => switch (m) {
      WorkoutMode.liveCoach => Icons.campaign_outlined,
      WorkoutMode.recordRecap => Icons.videocam_outlined,
      WorkoutMode.manualLog => Icons.edit_note,
    };

const IconData kAtomIcon = Icons.adjust; // ATOM puck
const IconData kPlusIcon = Icons.diamond_outlined; // premium gem

/// Selection radio (brand-filled with a check when selected).
class WmRadio extends StatelessWidget {
  const WmRadio({super.key, required this.selected, this.size = 24});
  final bool selected;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Wm.brand : Colors.transparent,
          border: Border.all(color: selected ? Wm.brand : const Color(0xFFD2D5CE), width: 2),
        ),
        child: selected ? Icon(Icons.check, size: size * 0.55, color: Colors.white) : null,
      );
}

/// Small "Plus" (or other) membership tag.
class PlusTag extends StatelessWidget {
  const PlusTag({super.key, this.label = 'Plus'});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(4, 1, 5, 1),
        decoration: BoxDecoration(
          color: Wm.plusBg,
          border: Border.all(color: Wm.plusLine),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(kPlusIcon, size: 10, color: Wm.plus),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 9.5, fontWeight: FontWeight.w700, color: Wm.plus, letterSpacing: 0.2)),
        ]),
      );
}

/// Muted amber Beta caution.
class BetaCaution extends StatelessWidget {
  const BetaCaution({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: Wm.cautionBg,
          border: Border.all(color: Wm.cautionLine),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.warning_amber_rounded, size: 15, color: Wm.caution),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 11.5, height: 1.45, color: Wm.caution)),
          ),
        ]),
      );
}

/// A pill / capsule action button (Action buttons are capsule per spec).
class PillButton extends StatelessWidget {
  const PillButton({super.key, required this.label, this.onTap, this.enabled = true});
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Material(
          color: enabled ? Wm.cta : Wm.ctaOff,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      );
}

/// A secondary sheet button (capsule).
class SheetButton extends StatelessWidget {
  const SheetButton({super.key, required this.label, required this.onTap, this.primary = false});
  final String label;
  final VoidCallback onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) => Material(
        color: primary ? Wm.cta : Colors.white,
        shape: StadiumBorder(side: primary ? BorderSide.none : const BorderSide(color: Wm.line, width: 1.5)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: primary ? Colors.white : Wm.ink)),
            ),
          ),
        ),
      );
}

/// Rounded-top modal bottom sheet used for gate / picker / data choice.
Future<void> showAppSheet(BuildContext context,
    {required Widget child, bool scrollable = false}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: scrollable,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: SafeArea(top: false, child: child),
    ),
  );
}
