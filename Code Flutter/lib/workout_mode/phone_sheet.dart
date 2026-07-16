import 'package:flutter/material.dart';

import 'controller.dart';
import 'course_notice.dart';
import 'models.dart';
import 'shared.dart';
import 'strings.dart';
import 'tokens.dart';

/// The pre-workout "Select workout mode" bottom sheet (direction F: named
/// 3-choice + a "you can switch anytime" note).
class WorkoutModeSheet extends StatelessWidget {
  const WorkoutModeSheet({
    super.key,
    required this.controller,
    required this.onStart,
    this.onAddDevice,
    this.onGetPlus,
  });

  final WorkoutModeController controller;
  final ModeCallback onStart;
  final VoidCallback? onAddDevice;
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
                      color: const Color(0xFFD7DAD3), borderRadius: BorderRadius.circular(99)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
                child: Text(l.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Wm.ink)),
              ),
              _DeviceRow(controller: controller, onAddDevice: onAddDevice),
              if (controller.showOfflineWarning) ...[
                const SizedBox(height: 8),
                _WarningStrip(text: _offlineWarn(controller, l)),
              ],
              const SizedBox(height: 10),
              for (final m in WorkoutMode.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ModeCard(
                    controller: controller,
                    mode: m,
                    onTap: () => _onModeTap(context, m),
                  ),
                ),
              // "Switch anytime" note: plain green text, below the cards.
              // Shown only when the AI modes are actually usable (device +
              // Plus + online); otherwise only Manual works and it'd mislead.
              if (controller.aiUsable) _FlexNote(text: l.flexNote),
              const SizedBox(height: 2),
              _cta(context, l),
            ],
          ),
        );
      },
    );
  }

  Widget _cta(BuildContext context, L l) {
    final m = controller.selected;
    final canStart = controller.canStartSelected;
    return PillButton(
      label: canStart ? l.modeCta(m) : l.ctaBlocked,
      enabled: canStart,
      onTap: () {
        if (m.isAi && !controller.skipNotice) {
          // Height-adaptive bottom sheet; it calls onStart(m) itself on "I'm ready".
          showCourseNoticeSheet(context, controller: controller, mode: m, onStart: onStart);
        } else {
          onStart(m);
        }
      },
    );
  }

  String _offlineWarn(WorkoutModeController c, L l) {
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
}

// ---------------------------------------------------------------------------
class _FlexNote extends StatelessWidget {
  const _FlexNote({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 2),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.45, color: Wm.brandInk)),
      );
}

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
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Wm.hair))),
      child: Row(children: [
        if (controller.hasMultipleDevices)
          Padding(
            padding: const EdgeInsets.only(right: 9),
            child: _SquareIconButton(
                icon: Icons.swap_horiz, onTap: () => showDevicePicker(context, controller)),
          ),
        _HwBadge(active: paired),
        const SizedBox(width: 9),
        if (paired) ...[
          // Ellipsize a long device name instead of overflowing the row.
          Flexible(
            child: Text(controller.activeDevice!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Wm.ink)),
          ),
          const SizedBox(width: 8),
          _StatusChip(online: controller.isOnline, l: l),
          const Spacer(),
        ] else ...[
          Text(l.noDevice,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Wm.ink2)),
          const Spacer(),
          _AddDeviceButton(label: l.addDevice, onTap: onAddDevice),
        ],
      ]),
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
            borderRadius: BorderRadius.circular(8)),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: const ShapeDecoration(color: Wm.cta, shape: StadiumBorder()),
          child: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
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

class _WarningStrip extends StatelessWidget {
  const _WarningStrip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: Wm.warnBg,
          border: Border.all(color: Wm.warnLine),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: Wm.warn),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 11.5, height: 1.45, color: Wm.warn))),
        ]),
      );
}

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
        borderRadius: BorderRadius.circular(9),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(children: [
              _ModeIcon(mode: mode, selected: selected, dim: locked),
              const SizedBox(width: 13),
              Expanded(
                // Unselected = title only; the one-line description lives in
                // the expand (shown once selected).
                child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 7, runSpacing: 4, children: [
                  Text(l.modeName(mode),
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: locked ? Wm.ink3 : Wm.ink)),
                  if (mode.requiresPlus) PlusTag(label: l.plusTag),
                ]),
              ),
              const SizedBox(width: 10),
              locked
                  ? const Icon(Icons.lock_outline, size: 20, color: Wm.ink3)
                  : WmRadio(selected: selected),
            ]),
          ),
        ),
        AnimatedSize(
          duration: WmMotion.base,
          curve: WmMotion.expand,
          alignment: Alignment.topCenter,
          child: selected ? _ModeDetail(mode: mode, l: l) : const SizedBox(width: double.infinity),
        ),
      ]),
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
              color: selected ? Wm.brandTint : Wm.iconBg, borderRadius: BorderRadius.circular(9)),
          child: Icon(iconFor(mode), size: 23, color: selected ? Wm.brandInk : const Color(0xFF2C2F31)),
        ),
      );
}

class _ModeDetail extends StatelessWidget {
  const _ModeDetail({required this.mode, required this.l});
  final WorkoutMode mode;
  final L l;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(68, 0, 14, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.modeDesc(mode),
              style: const TextStyle(fontSize: 14, height: 1.5, color: Wm.ink2)),
          if (mode == WorkoutMode.liveCoach) ...[
            const SizedBox(height: 8),
            BetaCaution(text: l.beta),
          ],
        ]),
      );
}

// ---------------------------------------------------------------------------
// Secondary sheets
// ---------------------------------------------------------------------------
Future<void> showGateSheet(
  BuildContext context,
  WorkoutModeController controller,
  WorkoutMode mode, {
  VoidCallback? onAddDevice,
  VoidCallback? onGetPlus,
}) {
  final l = L(controller.lang);
  final reasons = controller.missing(mode);
  if (reasons.isEmpty) return Future<void>.value(); // defensive: gate opens only for locked modes
  final reason = reasons.first;
  return showAppSheet(
    context,
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: Wm.iconBg, borderRadius: BorderRadius.circular(13)),
        child: Icon(reason == GateReason.needDevice ? kAtomIcon : kPlusIcon,
            size: 23, color: reason == GateReason.needDevice ? Wm.ink : Wm.plus),
      ),
      const SizedBox(height: 9),
      Text(l.gateTitle(mode, reason),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Wm.ink)),
      const SizedBox(height: 4),
      Text(l.gateBody(reason), style: const TextStyle(fontSize: 13, height: 1.5, color: Wm.ink2)),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: SheetButton(label: l.notNow, onTap: () => Navigator.pop(context))),
        const SizedBox(width: 9),
        Expanded(
          child: SheetButton(
            label: l.gateButton(reason),
            primary: true,
            onTap: () {
              Navigator.pop(context);
              if (reason == GateReason.needDevice) {
                onAddDevice?.call();
              } else if (reason == GateReason.needPlus) {
                onGetPlus?.call();
              }
              // GateReason.overQuota: PLACEHOLDER — wire to buy-credits / upgrade
              // once the business model is set.
            },
          ),
        ),
      ]),
    ]),
  );
}

Future<void> showDevicePicker(BuildContext context, WorkoutModeController controller) {
  final l = L(controller.lang);
  return showAppSheet(
    context,
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.pickTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Wm.ink)),
      const SizedBox(height: 4),
      Text(l.pickHint, style: const TextStyle(fontSize: 12.5, color: Wm.ink2)),
      const SizedBox(height: 12),
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
      SheetButton(label: l.notNow, onTap: () => Navigator.pop(context)),
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
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: active ? Wm.ink : Wm.line, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          _HwBadge(active: true),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(device.name,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Wm.ink)),
              const SizedBox(height: 2),
              Text(online ? l.connected : l.noNetwork,
                  style: TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.w600, color: online ? Wm.brandInk : Wm.warn)),
            ]),
          ),
          WmRadio(selected: active),
        ]),
      ),
    );
  }
}
