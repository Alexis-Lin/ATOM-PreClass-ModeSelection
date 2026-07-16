import 'package:flutter/material.dart';

import 'workout_mode/atom_screens.dart';
import 'workout_mode/controller.dart';
import 'workout_mode/models.dart';
import 'workout_mode/preview_settings.dart';
import 'workout_mode/tokens.dart';

/// Demo harness — NOT production. It wires the reusable pieces together and
/// adds preview controls so an engineer can drive every state:
/// pairing (none/one/two), ATOM status (online/no-network), Plus, language.
///
/// Reusable parts live in `lib/workout_mode/`. In a real app you'd:
///   showModalBottomSheet(context, builder: (_) => WorkoutModeSheet(...))
/// and push AtomRoundScreen on the device build.
void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Workout Mode Selection',
        theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFE9EAE6)),
        home: const DemoPage(),
      );
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final controller = WorkoutModeController(
    devices: const [AtomDevice(id: 'a1', name: 'ATOM 449C')],
    isPlus: true,
  );

  int _count = 1; // 0=none, 1=one, 2=two
  AtomConnState _status = AtomConnState.online;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _applyDevices() {
    final list = <AtomDevice>[
      if (_count >= 1) AtomDevice(id: 'a1', name: 'ATOM 449C', state: _status),
      if (_count >= 2) const AtomDevice(id: 'a2', name: 'ATOM 40CE'),
    ];
    controller.setDevices(list);
  }

  void _start(WorkoutMode m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('▶  Start ${m.name}'), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Mode Selection'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _controls(),
              const SizedBox(height: 20),
              _sectionLabel('iPhone · course preview → modal'),
              const SizedBox(height: 10),
              _phoneFrame(),
              const SizedBox(height: 28),
              _sectionLabel('ATOM device · round screen'),
              const SizedBox(height: 10),
              Center(
                child: AtomRoundScreen(controller: controller, onStart: _start),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String s) => Text(s.toUpperCase(),
      style: const TextStyle(
          fontSize: 12, letterSpacing: 1.1, fontWeight: FontWeight.w700, color: Wm.ink2));

  Widget _controls() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E2DC)),
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _group('Paired', [
              _chip('None', _count == 0, () { _count = 0; _applyDevices(); }),
              _chip('One', _count == 1, () { _count = 1; _applyDevices(); }),
              _chip('Two', _count == 2, () { _count = 2; _applyDevices(); }),
            ]),
            _group('ATOM', [
              _chip('Online', _status == AtomConnState.online, () {
                _status = AtomConnState.online;
                _applyDevices();
              }),
              _chip('No network', _status == AtomConnState.noNetwork, () {
                _status = AtomConnState.noNetwork;
                _applyDevices();
              }),
            ]),
            _group('Plus', [
              _chip('On', controller.isPlus, () => controller.setPlus(true)),
              _chip('Off', !controller.isPlus, () => controller.setPlus(false)),
            ]),
            _group('AI quota', [
              _chip('OK', controller.hasAiQuota, () => controller.setHasAiQuota(true)),
              _chip('Used up', !controller.hasAiQuota, () => controller.setHasAiQuota(false)),
            ]),
            _group('Save video (Settings)', [
              _chip('On', controller.saveVideosOn, () => controller.setSaveVideosOn(true)),
              _chip('Off', !controller.saveVideosOn, () => controller.setSaveVideosOn(false)),
            ]),
            _group('Lang', [
              _chip('EN', controller.lang == AppLang.en, () => controller.setLang(AppLang.en)),
              _chip('中文', controller.lang == AppLang.zh, () => controller.setLang(AppLang.zh)),
            ]),
          ],
        ),
      );

  Widget _group(String label, List<Widget> chips) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Wm.ink3)),
          const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: chips),
        ],
      );

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => setState(onTap),
          showCheckmark: false,
          labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Wm.ink2),
          selectedColor: Wm.cta,
          backgroundColor: const Color(0xFFF2F3EF),
          side: BorderSide.none,
        ),
      );

  Widget _phoneFrame() => Center(
        child: Container(
          width: 402, // iPhone 17 logical width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0x14000000)),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 30, offset: Offset(0, 12))],
          ),
          clipBehavior: Clip.antiAlias,
          child: CoursePreviewPage(
            controller: controller,
            onStart: _start,
            onAddDevice: () { _count = 1; _status = AtomConnState.online; _applyDevices(); },
            onGetPlus: () => controller.setPlus(true),
          ),
        ),
      );
}
