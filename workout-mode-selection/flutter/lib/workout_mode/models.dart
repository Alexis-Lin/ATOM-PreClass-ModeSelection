/// Domain models for the pre-workout mode selection flow.
///
/// These are pure data types — no Flutter/UI dependency — so they can be
/// reused by the engineer's own state layer (Bloc / Riverpod / etc.).
library;

/// The three workout modes, ordered by "AI involvement":
/// real-time coaching → automatic recording → fully manual.
enum WorkoutMode { liveCoach, recordRecap, manualLog }

extension WorkoutModeX on WorkoutMode {
  /// AI modes need the ATOM hardware.
  bool get requiresDevice => this != WorkoutMode.manualLog;

  /// AI modes need a Plus membership.
  bool get requiresPlus => this != WorkoutMode.manualLog;

  /// True for the two camera/AI modes; false for Manual Log.
  bool get isAi => this != WorkoutMode.manualLog;
}

/// Connection health the phone can actually observe for a paired ATOM.
///
/// NOTE: the phone can only tell whether the ATOM is on the network — it
/// cannot sense distance, so there is deliberately no "not nearby" state.
enum AtomConnState { online, noNetwork }

/// A single paired ATOM device. A phone may pair several (like one iPhone
/// pairing multiple Apple Watches).
class AtomDevice {
  final String id;
  final String name;
  final AtomConnState state;

  const AtomDevice({
    required this.id,
    required this.name,
    this.state = AtomConnState.online,
  });

  bool get isOnline => state == AtomConnState.online;

  AtomDevice copyWith({String? name, AtomConnState? state}) => AtomDevice(
        id: id,
        name: name ?? this.name,
        state: state ?? this.state,
      );
}

/// UI language.
enum AppLang { en, zh }

/// Why an AI mode is currently unavailable (used to drive the gate sheet).
enum GateReason { needDevice, needPlus }
