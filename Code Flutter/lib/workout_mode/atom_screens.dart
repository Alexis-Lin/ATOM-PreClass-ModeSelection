import 'package:flutter/material.dart';

import 'controller.dart';
import 'models.dart';
import 'shared.dart' show iconFor, ModeCallback;
import 'strings.dart';
import 'tokens.dart';

/// The ATOM 466×466 round device screen: pick Live Coach or Record & Recap.
///
/// Only the two AI modes appear here (Manual Log stays on the phone). The
/// Start action opens a full-screen confirmation unless the user chose
/// "Don't show again".
class AtomRoundScreen extends StatefulWidget {
  const AtomRoundScreen({
    super.key,
    required this.controller,
    required this.onStart,
    this.diameter = 330,
  });

  final WorkoutModeController controller;
  final ModeCallback onStart;
  final double diameter;

  @override
  State<AtomRoundScreen> createState() => _AtomRoundScreenState();
}

class _AtomRoundScreenState extends State<AtomRoundScreen> {
  WorkoutMode _sel = WorkoutMode.liveCoach;
  bool _showConfirm = false;

  static const _modes = [WorkoutMode.liveCoach, WorkoutMode.recordRecap];

  void _startPressed() {
    if (widget.controller.skipAtomConfirm) {
      widget.onStart(_sel);
    } else {
      setState(() => _showConfirm = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final l = L(widget.controller.lang);
        final d = widget.diameter;
        return SizedBox(
          width: d,
          height: d,
          child: ClipOval(
            child: Container(
              color: Wm.deviceBg,
              child: Stack(
                children: [
                  _face(l, d),
                  // Confirm appears with a fade + gentle settle-in (standard
                  // modal-appear motion), not a hard swap.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1.03, end: 1.0).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _showConfirm
                        ? KeyedSubtree(key: const ValueKey('confirm'), child: _confirm(l))
                        : const SizedBox.shrink(key: ValueKey('none')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _face(L l, double d) {
    return Stack(
      children: [
        Positioned(
          top: d * 0.15,
          left: 0,
          right: 0,
          child: Center(
            child: Text(l.atomTitle,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: Wm.deviceText)),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final m in _modes) ...[
                _AtomTile(
                  mode: m,
                  selected: _sel == m,
                  width: d * 0.76,
                  l: l,
                  onTap: () => setState(() => _sel = m),
                ),
                if (m != _modes.last) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        Positioned(
          bottom: d * 0.09,
          left: 0,
          right: 0,
          child: Center(child: _StartPill(label: l.atomStart, onTap: _startPressed)),
        ),
      ],
    );
  }

  Widget _confirm(L l) {
    final skip = widget.controller.skipAtomConfirm;
    return Container(
      color: Wm.deviceBg, // fully opaque — a complete screen, not a scrim
      padding: const EdgeInsets.fromLTRB(42, 38, 42, 34),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l.atomConfirmTitle,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: Wm.deviceText)),
          const SizedBox(height: 16),
          // Icon-led notice — the round screen is too small for an illustration.
          SizedBox(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final row in _noticeRows(l)) ...[
                  _NoticeRow(icon: row.$1, text: row.$2),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 3),
          _DontShowAgain(
            label: l.dontShowAgain,
            value: skip,
            onTap: () => widget.controller.setSkipAtomConfirm(!skip),
          ),
          const SizedBox(height: 14),
          _StartPill(
            label: l.atomStart,
            onTap: () {
              setState(() => _showConfirm = false);
              widget.onStart(_sel);
            },
          ),
        ],
      ),
    );
  }

  // Pair each terse notice line with an icon. Order matches L.atomBullets.
  List<(IconData, String)> _noticeRows(L l) {
    final icons = _sel == WorkoutMode.recordRecap
        ? const [Icons.person_outline, Icons.light_mode_outlined, Icons.info_outline]
        : const [Icons.person_outline, Icons.height, Icons.warning_amber_rounded];
    final lines = l.atomBullets(_sel);
    return [
      for (var i = 0; i < lines.length; i++)
        (icons[i < icons.length ? i : icons.length - 1], lines[i]),
    ];
  }
}

/// Icon-chip + text row for the ATOM "before you start" notice.
class _NoticeRow extends StatelessWidget {
  const _NoticeRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: const Color(0xFF1C1F18), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 17, color: Wm.brand),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 14, height: 1.32, color: Color(0xFFC4CABD))),
          ),
        ],
      );
}

class _AtomTile extends StatelessWidget {
  const _AtomTile({
    required this.mode,
    required this.selected,
    required this.width,
    required this.l,
    required this.onTap,
  });
  final WorkoutMode mode;
  final bool selected;
  final double width;
  final L l;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A1D15) : Wm.deviceCard,
          border: Border.all(
              color: selected ? Wm.brand : Wm.deviceCardLine, width: 1.5),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconFor(mode), size: 24, color: selected ? Wm.brand : Wm.deviceText),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.modeName(mode),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700, color: Wm.deviceText)),
                  // Only the SELECTED tile shows its explanation.
                  if (selected) ...[
                    const SizedBox(height: 3),
                    Text(l.atomSub(mode),
                        style: const TextStyle(
                            fontSize: 12.5, height: 1.35, color: Color(0xFF939A91))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            _DeviceRadio(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _DeviceRadio extends StatelessWidget {
  const _DeviceRadio({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
        width: 21,
        height: 21,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Wm.brand : Colors.transparent,
          border: Border.all(color: selected ? Wm.brand : const Color(0xFF3A3D38), width: 2),
        ),
        child: selected ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
      );
}

class _StartPill extends StatelessWidget {
  const _StartPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          decoration: BoxDecoration(color: Wm.brand, borderRadius: BorderRadius.circular(99)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F1408))),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right, size: 17, color: Color(0xFF0F1408)),
          ]),
        ),
      );
}

class _DontShowAgain extends StatelessWidget {
  const _DontShowAgain({required this.label, required this.value, required this.onTap});
  final String label;
  final bool value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value ? Wm.brand : Colors.transparent,
              border: Border.all(color: value ? Wm.brand : const Color(0xFF4A4E46), width: 1.5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: value ? const Icon(Icons.check, size: 11, color: Colors.black) : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFFC9CDC4))),
        ]),
      );
}
