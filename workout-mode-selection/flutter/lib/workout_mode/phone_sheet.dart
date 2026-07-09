import 'package:flutter/material.dart';

import 'controller.dart';
import 'models.dart';
import 'strings.dart';
import 'tokens.dart';

typedef ModeCallback = void Function(WorkoutMode mode);

/// Material icon stand-ins.
/// ⚠️ DESIGNER: replace with the line icons from the design (speaker,
/// camcorder, hand+pen). These are approximations only.
IconData iconFor(WorkoutMode m) => switch (m) {
      WorkoutMode.liveCoach => Icons.campaign_outlined,
      WorkoutMode.recordRecap => Icons.videocam_outlined,
      WorkoutMode.manualLog => Icons.edit_note,
    };

const IconData kAtomIcon = Icons.adjust; // the ATOM puck
const IconData kPlusIcon = Icons.diamond_outlined;

/// The pre-workout "Select workout mode" bottom sheet content.
///
/// Drop it into a `showModalBottomSheet` or embed it anywhere. It listens to
/// [controller] and rebuilds itself.
class WorkoutModeSheet extends StatelessWidget {
  const WorkoutModeSheet({
    super.key,
    required this.controller,
    required this.onStart,
    this.onAddDevice,
    this.onGetPlus,
  });

  final WorkoutModeController controller;

  /// Called once all confirmations pass and the workout should begin.
  final ModeCallback onStart;

  /// Open the real pairing flow. In the demo this adds a device.
  final VoidCallback? onAddDevice;

  /// Open the real membership flow. In the demo this flips Plus on.
  final VoidCallback? onGetPlus;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final l = L(controller.lang);
        return Container(
          decoration: const BoxDecoration(
            color: Wm.sheet,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Wm.radiusSheet)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DAD3),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 2, 6),
                child: Text(l.title,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w800, color: Wm.ink)),
              ),
              _DeviceRow(controller: controller, onAddDevice: onAddDevice),
              if (controller.showOfflineWarning) ...[
                const SizedBox(height: 8),
                _WarningStrip(text: _offlineWarningText(controller, l)),
              ],
              const SizedBox(height: 8),
              for (final m in WorkoutMode.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ModeCard(
                    controller: controller,
                    mode: m,
                    onTap: () => _onModeTap(context, m),
                  ),
                ),
              const SizedBox(height: 2),
              _Cta(controller: controller, onStart: (m) => _onStart(context, m)),
            ],
          ),
        );
      },
    );
  }

  String _offlineWarningText(WorkoutModeController c, L l) {
    var msg = l.warnNoNetwork;
    final otherOnline = c.hasMultipleDevices &&
        c.devices.asMap().entries.any((e) => e.key != c.activeIndex && e.value.isOnline);
    if (otherOnline) msg += l.switchHint;
    return msg;
  }

  void _onModeTap(BuildContext context, WorkoutMode m) {
    if (controller.isLocked(m)) {
      showGateSheet(context, controller, m, onAddDevice: onAddDevice, onGetPlus: onGetPlus);
    } else {
      controller.selectMode(m);
    }
  }

  void _onStart(BuildContext context, WorkoutMode m) {
    if (m.isAi) {
      showPreStartSheet(context, controller, onConfirm: () => onStart(m));
    } else {
      onStart(m);
    }
  }
}

// ---------------------------------------------------------------------------
// Device row
// ---------------------------------------------------------------------------
class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.controller, this.onAddDevice});
  final WorkoutModeController controller;
  final VoidCallback? onAddDevice;

  @override
  Widget build(BuildContext context) {
    final l = L(controller.lang);
    final paired = controller.isPaired;
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Wm.hair)),
      ),
      child: Row(
        children: [
          if (controller.hasMultipleDevices)
            Padding(
              padding: const EdgeInsets.only(right: 9),
              child: _SquareIconButton(
                icon: Icons.swap_horiz,
                onTap: () => showDevicePicker(context, controller),
              ),
            ),
          _HwBadge(active: paired),
          const SizedBox(width: 9),
          if (paired) ...[
            Text(controller.activeDevice!.name,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: Wm.ink)),
            const SizedBox(width: 8),
            _StatusChip(online: controller.isOnline, l: l),
            const Spacer(),
          ] else ...[
            Text(l.noDevice,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: Wm.ink2)),
            const Spacer(),
            _AddDeviceButton(label: l.addDevice, onTap: onAddDevice),
          ],
        ],
      ),
    );
  }
}

class _HwBadge extends StatelessWidget {
  const _HwBadge({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: active ? Wm.brandTint : const Color(0xFFF1F2EE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(kAtomIcon, size: 16, color: active ? Wm.brandInk : Wm.ink3),
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.online, required this.l});
  final bool online;
  final L l;
  @override
  Widget build(BuildContext context) {
    final color = online ? Wm.brandInk : Wm.warn;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(online ? Icons.wifi : Icons.wifi_off, size: 15, color: color),
      const SizedBox(width: 5),
      Text(online ? l.connected : l.noNetwork,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
    ]);
  }
}

class _AddDeviceButton extends StatelessWidget {
  const _AddDeviceButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: Wm.cta, borderRadius: BorderRadius.circular(9)),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ),
      );
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: Wm.iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: Wm.ink2),
        ),
      );
}

// ---------------------------------------------------------------------------
// Warning strip (blocking, offline)
// ---------------------------------------------------------------------------
class _WarningStrip extends StatelessWidget {
  const _WarningStrip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: Wm.warnBg,
          border: Border.all(color: Wm.warnLine),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: Wm.warn),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 11.5, height: 1.45, color: Wm.warn)),
          ),
        ]),
      );
}

// ---------------------------------------------------------------------------
// Mode card
// ---------------------------------------------------------------------------
class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.controller, required this.mode, required this.onTap});
  final WorkoutModeController controller;
  final WorkoutMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L(controller.lang);
    final locked = controller.isLocked(mode);
    final selected = controller.selected == mode && !locked;

    return Container(
      decoration: BoxDecoration(
        color: locked ? Wm.lockedBg : Wm.card,
        border: Border.all(color: selected ? Wm.ink : Wm.line, width: 1.5),
        borderRadius: BorderRadius.circular(Wm.radiusCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  _ModeIcon(mode: mode, selected: selected, dim: locked),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(
                            child: Text(l.modeName(mode),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: locked ? Wm.ink3 : Wm.ink)),
                          ),
                          if (mode.requiresPlus) ...[
                            const SizedBox(width: 7),
                            const _PlusTag(),
                          ],
                        ]),
                        const SizedBox(height: 3),
                        Opacity(
                          opacity: locked ? 0.5 : 1,
                          child: Text(l.modeDesc(mode),
                              style: const TextStyle(
                                  fontSize: 12.5, height: 1.45, color: Wm.ink2)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  locked ? const _LockTrailing() : _Radio(selected: selected),
                ],
              ),
            ),
          ),
          // Detail — dynamic height, revealed on selection.
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: selected
                ? _ModeDetail(mode: mode, l: l)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ModeIcon extends StatelessWidget {
  const _ModeIcon({required this.mode, required this.selected, required this.dim});
  final WorkoutMode mode;
  final bool selected;
  final bool dim;
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: dim ? 0.5 : 1,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: selected ? Wm.brandTint : Wm.iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconFor(mode),
              size: 23, color: selected ? Wm.brandInk : const Color(0xFF2C2F31)),
        ),
      );
}

class _ModeDetail extends StatelessWidget {
  const _ModeDetail({required this.mode, required this.l});
  final WorkoutMode mode;
  final L l;
  @override
  Widget build(BuildContext context) {
    return Padding(
      // full width — intentionally NOT indented under the icon
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: '${l.bestLabel} ',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: Wm.ink)),
              TextSpan(
                  text: l.modeBest(mode),
                  style: const TextStyle(
                      fontSize: 12, height: 1.45, color: Wm.ink2, fontWeight: FontWeight.w500)),
            ]),
          ),
          if (mode == WorkoutMode.liveCoach) ...[
            const SizedBox(height: 8),
            _BetaCaution(text: l.beta),
          ],
        ],
      ),
    );
  }
}

class _BetaCaution extends StatelessWidget {
  const _BetaCaution({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: Wm.cautionBg,
          border: Border.all(color: Wm.cautionLine),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.warning_amber_rounded, size: 15, color: Wm.caution),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 11.5, height: 1.45, color: Wm.caution)),
          ),
        ]),
      );
}

class _PlusTag extends StatelessWidget {
  const _PlusTag();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(4, 1, 5, 1),
        decoration: BoxDecoration(
          color: Wm.plusBg,
          border: Border.all(color: Wm.plusLine),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(kPlusIcon, size: 10, color: Wm.plus),
          SizedBox(width: 3),
          Text('Plus',
              style: TextStyle(
                  fontSize: 9.5, fontWeight: FontWeight.w700, color: Wm.plus, letterSpacing: 0.2)),
        ]),
      );
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Wm.brand : Colors.transparent,
          border: Border.all(color: selected ? Wm.brand : const Color(0xFFD2D5CE), width: 2),
        ),
        child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
      );
}

class _LockTrailing extends StatelessWidget {
  const _LockTrailing();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.lock_outline, size: 20, color: Wm.ink3);
}

// ---------------------------------------------------------------------------
// CTA
// ---------------------------------------------------------------------------
class _Cta extends StatelessWidget {
  const _Cta({required this.controller, required this.onStart});
  final WorkoutModeController controller;
  final ModeCallback onStart;
  @override
  Widget build(BuildContext context) {
    final l = L(controller.lang);
    final m = controller.selected;
    final enabled = controller.canStartSelected;
    final label = enabled ? l.modeCta(m) : l.ctaBlocked;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: enabled ? Wm.cta : Wm.ctaOff,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: enabled ? () => onStart(m) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Secondary sheets
// ---------------------------------------------------------------------------

/// Locked-mode gate: explains what's missing and offers the action.
Future<void> showGateSheet(
  BuildContext context,
  WorkoutModeController controller,
  WorkoutMode mode, {
  VoidCallback? onAddDevice,
  VoidCallback? onGetPlus,
}) {
  final l = L(controller.lang);
  final reason = controller.missing(mode).first;
  return _showSheet(
    context,
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: Wm.iconBg, borderRadius: BorderRadius.circular(13)),
        child: Icon(reason == GateReason.needDevice ? kAtomIcon : kPlusIcon,
            size: 23, color: reason == GateReason.needDevice ? Wm.ink : Wm.plus),
      ),
      const SizedBox(height: 9),
      Text(l.gateTitle(mode, reason),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Wm.ink)),
      const SizedBox(height: 4),
      Text(l.gateBody(reason),
          style: const TextStyle(fontSize: 13, height: 1.5, color: Wm.ink2)),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _SheetButton(label: l.notNow, onTap: () => Navigator.pop(context))),
        const SizedBox(width: 9),
        Expanded(
          child: _SheetButton(
            label: l.gateButton(reason),
            primary: true,
            onTap: () {
              Navigator.pop(context);
              (reason == GateReason.needDevice ? onAddDevice : onGetPlus)?.call();
            },
          ),
        ),
      ]),
    ]),
  );
}

/// Pre-start setup / framing guidance for AI modes.
/// Scrollable: framing diagram + do-list + accuracy-hurting conditions + beta.
Future<void> showPreStartSheet(
  BuildContext context,
  WorkoutModeController controller, {
  required VoidCallback onConfirm,
}) {
  final l = L(controller.lang);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) {
      final maxH = MediaQuery.of(context).size.height * 0.85;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.prestartTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Wm.ink)),
                const SizedBox(height: 5),
                Text(l.prestartSub,
                    style: const TextStyle(fontSize: 12.5, height: 1.45, color: Wm.ink2)),
                const SizedBox(height: 12),
                const _FramingBox(),
                const SizedBox(height: 14),
                _SectionLabel(text: l.prestartDoHeader),
                for (final s in l.prestartDo) _GuideItem(text: s),
                const SizedBox(height: 6),
                _SectionLabel(text: l.prestartAvoidHeader, warn: true),
                for (final s in l.prestartAvoid) _GuideItem(text: s, avoid: true),
                const SizedBox(height: 12),
                _BetaCaution(text: l.prestartBeta),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _SheetButton(label: l.prestartCancel, onTap: () => Navigator.pop(context))),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _SheetButton(
                      label: l.prestartStart,
                      primary: true,
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, this.warn = false});
  final String text;
  final bool warn;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: warn ? Wm.warn : Wm.ink3)),
      );
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({required this.text, this.avoid = false});
  final String text;
  final bool avoid;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(avoid ? Icons.close : Icons.check,
              size: 16, color: avoid ? Wm.warn : Wm.brandInk),
          const SizedBox(width: 9),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4, color: Wm.ink2)),
          ),
        ]),
      );
}

/// Framing illustration — a figure fully inside the camera frame.
/// ⚠️ DESIGNER: placeholder. Replace with a proper "correct vs wrong"
/// framing illustration (or a short demo clip).
class _FramingBox extends StatelessWidget {
  const _FramingBox();
  @override
  Widget build(BuildContext context) => Container(
        height: 132,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0EC),
          border: Border.all(color: const Color(0xFFC9CCC3), width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFB7BBB0)),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const Icon(Icons.accessibility_new, size: 56, color: Wm.brandInk),
          ],
        ),
      );
}

/// Multi-device secondary selection.
Future<void> showDevicePicker(BuildContext context, WorkoutModeController controller) {
  final l = L(controller.lang);
  return _showSheet(
    context,
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.pickTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Wm.ink)),
      const SizedBox(height: 10),
      for (var i = 0; i < controller.devices.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _DevicePickRow(
            device: controller.devices[i],
            active: i == controller.activeIndex,
            l: l,
            onTap: () {
              controller.setActiveIndex(i);
              Navigator.pop(context);
            },
          ),
        ),
      const SizedBox(height: 2),
      _SheetButton(label: l.notNow, onTap: () => Navigator.pop(context)),
    ]),
  );
}

class _DevicePickRow extends StatelessWidget {
  const _DevicePickRow({required this.device, required this.active, required this.l, required this.onTap});
  final AtomDevice device;
  final bool active;
  final L l;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final online = device.isOnline;
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: active ? Wm.ink : Wm.line, width: 1.5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(children: [
          const _HwBadge(active: true),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(device.name,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Wm.ink)),
              const SizedBox(height: 2),
              Text(online ? l.connected : l.noNetwork,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: online ? Wm.brandInk : Wm.warn)),
            ]),
          ),
          _Radio(selected: active),
        ]),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({required this.label, required this.onTap, this.primary = false});
  final String label;
  final VoidCallback onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) => Material(
        color: primary ? Wm.cta : Colors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: primary ? null : Border.all(color: Wm.line, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primary ? Colors.white : Wm.ink)),
            ),
          ),
        ),
      );
}

Future<void> _showSheet(BuildContext context, {required Widget child}) {
  return showModalBottomSheet(
    context: context,
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
