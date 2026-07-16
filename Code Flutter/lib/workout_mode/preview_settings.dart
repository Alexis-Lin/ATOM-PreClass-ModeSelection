import 'package:flutter/material.dart';

import 'controller.dart';
import 'models.dart';
import 'phone_sheet.dart';
import 'shared.dart';
import 'strings.dart';
import 'tokens.dart';

/// Course preview (shown first). The bottom button opens the mode-selection
/// sheet — the modal is NOT shown on entry. A gear opens Settings.
///
/// Sized for embedding in a phone frame; course data is placeholder.
class CoursePreviewPage extends StatelessWidget {
  const CoursePreviewPage({
    super.key,
    required this.controller,
    required this.onStart,
    this.onAddDevice,
    this.onGetPlus,
    this.height = 660,
  });

  final WorkoutModeController controller;
  final ModeCallback onStart;
  final VoidCallback? onAddDevice;
  final VoidCallback? onGetPlus;
  final double height;

  void _openSheet(BuildContext context) {
    controller.resetSession();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkoutModeSheet(
        controller: controller,
        onStart: onStart,
        onAddDevice: onAddDevice,
        onGetPlus: onGetPlus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final l = L(controller.lang);
        return SizedBox(
          height: height,
          child: Column(children: [
            _Hero(l: l, onGear: () => _pushSettings(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                children: [
                  Text(l.pvDesc, style: const TextStyle(fontSize: 14, height: 1.6, color: Wm.ink2)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _Stat(value: '32', label: l.pvStatMin),
                    const SizedBox(width: 10),
                    _Stat(value: '12', label: l.pvStatEx),
                    const SizedBox(width: 10),
                    _Stat(value: '~280', label: l.pvStatKcal),
                  ]),
                  const SizedBox(height: 16),
                  Text(l.pvIncludes.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800, color: Wm.ink, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  for (var i = 0; i < l.pvExercises.length; i++)
                    _ExerciseRow(index: i + 1, name: l.pvExercises[i]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: PillButton(label: l.pvStart, onTap: () => _openSheet(context)),
            ),
          ]),
        );
      },
    );
  }

  void _pushSettings(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SettingsPage(controller: controller)),
      );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.l, required this.onGear});
  final L l;
  final VoidCallback onGear;
  @override
  Widget build(BuildContext context) => Container(
        height: 200,
        padding: const EdgeInsets.fromLTRB(18, 14, 14, 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2B302E), Color(0xFF4A5247), Color(0xFF727A68)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('20:33',
                style: TextStyle(color: Color(0xFFF4F5F2), fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            InkWell(
              onTap: onGear,
              customBorder: const CircleBorder(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                child: const Icon(Icons.tune, size: 18, color: Colors.white),
              ),
            ),
          ]),
          const Spacer(),
          Text(l.pvKicker,
              style: const TextStyle(
                  color: Color(0xD9FFFFFF), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
          const SizedBox(height: 7),
          Text(l.courseName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Text(l.pvMeta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 12)),
        ]),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F2),
            border: Border.all(color: Wm.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Wm.ink)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Wm.ink3)),
          ]),
        ),
      );
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.index, required this.name});
  final int index;
  final String name;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Wm.hair))),
        child: Row(children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Wm.iconBg, borderRadius: BorderRadius.circular(7)),
            child: Text('$index',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Wm.ink2)),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Wm.ink)),
        ]),
      );
}

/// Settings — the global "Save workout videos" toggle lives here.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});
  final WorkoutModeController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final l = L(controller.lang);
        return Scaffold(
          backgroundColor: Wm.sheet,
          appBar: AppBar(
            backgroundColor: Wm.sheet,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Wm.ink),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(l.settingsTitle,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Wm.ink)),
            centerTitle: false,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Wm.hair))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.setSaveTitle,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Wm.ink)),
                      const SizedBox(height: 5),
                      Text(l.setSaveBody,
                          style: const TextStyle(fontSize: 12, height: 1.55, color: Wm.ink2)),
                    ]),
                  ),
                  const SizedBox(width: 14),
                  Switch(
                    value: controller.saveVideosOn,
                    activeColor: Wm.brand,
                    onChanged: controller.setSaveVideosOn,
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
