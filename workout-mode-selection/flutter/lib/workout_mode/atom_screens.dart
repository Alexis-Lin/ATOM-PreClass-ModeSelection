import 'package:flutter/material.dart';

import 'controller.dart';
import 'models.dart';
import 'phone_sheet.dart' show iconFor, kPlusIcon, ModeCallback;
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
                  if (_showConfirm) _confirm(l),
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
                    fontSize: 16, fontWeight: FontWeight.w800, color: Wm.deviceText)),
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
                  width: d * 0.73,
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
      padding: const EdgeInsets.fromLTRB(42, 40, 42, 34),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RoundClose(onTap: () => setState(() => _showConfirm = false)),
          const SizedBox(height: 12),
          const _DeviceFrame(),
          const SizedBox(height: 12),
          Text(l.atomConfirmTitle,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: Wm.deviceText)),
          const SizedBox(height: 12),
          _bullet(l.atomConfirm1),
          const SizedBox(height: 10),
          _bullet(l.atomConfirm2),
          const SizedBox(height: 15),
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

  Widget _bullet(String text) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: Wm.brand),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(text,
                style: const TextStyle(fontSize: 11.5, height: 1.4, color: Color(0xFFAEB4A8))),
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
                          fontSize: 15.5, fontWeight: FontWeight.w700, color: Wm.deviceText)),
                  // Only the SELECTED tile shows its explanation.
                  if (selected) ...[
                    const SizedBox(height: 3),
                    Text(l.atomSub(mode),
                        style: const TextStyle(
                            fontSize: 11, height: 1.35, color: Wm.deviceSub)),
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

/// Compact framing hint for the round confirm.
/// ⚠️ DESIGNER: placeholder — replace with the framing illustration.
class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame();
  @override
  Widget build(BuildContext context) => Container(
        width: 122,
        height: 58,
        decoration: BoxDecoration(
          color: Wm.deviceCard,
          border: Border.all(color: Wm.deviceCardLine, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.accessibility_new, size: 30, color: Wm.brand),
      );
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
                    fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F1408))),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFF0F1408)),
          ]),
        ),
      );
}

class _RoundClose extends StatelessWidget {
  const _RoundClose({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1C1F1A),
            border: Border.all(color: const Color(0xFF33362F)),
          ),
          child: const Icon(Icons.close, size: 15, color: Color(0xFFC9CDC4)),
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
          Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFFC9CDC4))),
        ]),
      );
}

// Kept for parity with the phone tag if needed on device.
// ignore: unused_element
Widget atomPlusTag() => const Icon(kPlusIcon, size: 12, color: Wm.plus);
