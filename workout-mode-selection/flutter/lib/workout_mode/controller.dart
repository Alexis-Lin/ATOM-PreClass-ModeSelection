import 'package:flutter/foundation.dart';
import 'models.dart';

/// Holds all pre-workout selection state and the rules around it.
///
/// Pure logic — no widgets. UI listens via [ChangeNotifier]. Swap this for
/// your own state solution and keep the same predicates ([isLocked],
/// [canStart], [missing]) as the single source of truth.
class WorkoutModeController extends ChangeNotifier {
  WorkoutModeController({
    List<AtomDevice> devices = const [],
    bool isPlus = false,
    AppLang lang = AppLang.en,
    this.skipAtomConfirm = false,
  })  : _devices = List.of(devices),
        _isPlus = isPlus,
        _lang = lang {
    _selected = _defaultSelection();
  }

  // ---- state ----
  List<AtomDevice> _devices;
  int _activeIndex = 0;
  bool _isPlus;
  AppLang _lang;
  late WorkoutMode _selected;

  /// When true, the ATOM round-screen start confirmation is skipped
  /// ("Don't show again"). Persist this per user in real code.
  bool skipAtomConfirm;

  // ---- reads ----
  List<AtomDevice> get devices => List.unmodifiable(_devices);
  bool get isPaired => _devices.isNotEmpty;
  bool get hasMultipleDevices => _devices.length > 1;
  int get activeIndex => _activeIndex.clamp(0, _devices.isEmpty ? 0 : _devices.length - 1);
  AtomDevice? get activeDevice => isPaired ? _devices[activeIndex] : null;
  bool get isOnline => activeDevice?.isOnline ?? false;
  bool get isPlus => _isPlus;
  AppLang get lang => _lang;
  WorkoutMode get selected => _selected;

  /// A mode is locked (greyed, tap → gate sheet) when a prerequisite is
  /// missing entirely — no device paired, or no Plus membership.
  bool isLocked(WorkoutMode m) =>
      m.requiresDevice && (!isPaired || (m.requiresPlus && !_isPlus));

  /// What's missing for a locked mode. Device is surfaced first.
  List<GateReason> missing(WorkoutMode m) {
    final out = <GateReason>[];
    if (m.requiresDevice && !isPaired) out.add(GateReason.needDevice);
    if (m.requiresPlus && !_isPlus) out.add(GateReason.needPlus);
    return out;
  }

  /// Whether the currently selected mode can actually start now.
  /// AI modes additionally require the active ATOM to be ONLINE — it can't
  /// provide vision offline, so we block the start (not just warn).
  bool get canStartSelected => canStart(_selected);
  bool canStart(WorkoutMode m) {
    if (!m.isAi) return true; // Manual Log always works.
    return !isLocked(m) && isOnline;
  }

  /// Show the blocking "ATOM offline" warning strip.
  bool get showOfflineWarning => isPaired && !isOnline;

  // ---- writes ----
  void selectMode(WorkoutMode m) {
    if (isLocked(m)) return; // caller should open the gate sheet instead.
    if (_selected == m) return;
    _selected = m;
    notifyListeners();
  }

  void setDevices(List<AtomDevice> devices, {int activeIndex = 0}) {
    _devices = List.of(devices);
    _activeIndex = devices.isEmpty ? 0 : activeIndex.clamp(0, devices.length - 1);
    _reconcileSelection();
    notifyListeners();
  }

  void setActiveIndex(int index) {
    if (_devices.isEmpty) return;
    _activeIndex = index.clamp(0, _devices.length - 1);
    _reconcileSelection();
    notifyListeners();
  }

  void setPlus(bool value) {
    if (_isPlus == value) return;
    _isPlus = value;
    _reconcileSelection();
    notifyListeners();
  }

  void setLang(AppLang value) {
    if (_lang == value) return;
    _lang = value;
    notifyListeners();
  }

  void setSkipAtomConfirm(bool value) {
    skipAtomConfirm = value;
    notifyListeners();
  }

  // ---- helpers ----
  WorkoutMode _defaultSelection() {
    for (final m in WorkoutMode.values) {
      if (!isLocked(m)) return m; // prefers Live Coach, then Record & Recap, then Manual Log
    }
    return WorkoutMode.manualLog;
  }

  /// Keep the selection valid: only re-pick if the current one became locked.
  /// (An AI mode that's merely offline stays selected — the CTA blocks it.)
  void _reconcileSelection() {
    if (isLocked(_selected)) _selected = _defaultSelection();
  }
}
