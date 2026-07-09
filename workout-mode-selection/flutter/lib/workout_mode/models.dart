/// Domain models for the pre-workout mode selection flow.
/// Pure data types — no Flutter/UI dependency.
library;

/// The three named modes (direction F). Ordered by "AI involvement".
enum WorkoutMode { liveCoach, recordRecap, manualLog }

extension WorkoutModeX on WorkoutMode {
  bool get requiresDevice => this != WorkoutMode.manualLog;
  bool get requiresPlus => this != WorkoutMode.manualLog;
  bool get isAi => this != WorkoutMode.manualLog;
}

/// Connection health the phone can observe (it cannot sense distance —
/// no "not nearby" state).
enum AtomConnState { online, noNetwork }

class AtomDevice {
  final String id;
  final String name;
  final AtomConnState state;
  const AtomDevice({required this.id, required this.name, this.state = AtomConnState.online});
  bool get isOnline => state == AtomConnState.online;
  AtomDevice copyWith({String? name, AtomConnState? state}) =>
      AtomDevice(id: id, name: name ?? this.name, state: state ?? this.state);
}

enum AppLang { en, zh }

/// Why an AI mode is locked (drives the gate sheet).
enum GateReason { needDevice, needPlus }

/// Where the recorded video / report is kept.
/// - cloud: uploaded, report available (report needs cloud).
/// - local: kept on the ATOM's SD card, not uploaded, no cloud report.
enum DataChoice { cloud, local }
