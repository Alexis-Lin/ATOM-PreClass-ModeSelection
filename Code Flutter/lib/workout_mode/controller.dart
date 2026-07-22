import 'package:flutter/foundation.dart';
import 'models.dart';

/// All pre-workout state and the rules around it. Pure logic (no widgets).
/// The predicates [isLocked] / [missing] / [canStart] are the single source
/// of truth; keep them if you swap in your own state solution.
class WorkoutModeController extends ChangeNotifier {
  WorkoutModeController({
    List<AtomDevice> devices = const [],
    bool isPlus = false,
    AppLang lang = AppLang.en,
    this.hasAiQuota = true,
    this.saveVideosOn = true,
    this.skipNotice = false,
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

  // NOTE: the App does NOT know the ATOM's SD-card status (not synced). Local SD
  // recording is the ATOM's own setting (decoupled) — not modelled here.

  /// Has Plus, but this billing cycle's AI sessions may be used up. When false
  /// (and the user has Plus), AI modes lock with GateReason.overQuota.
  bool hasAiQuota;

  /// Global "Video storage" (privacy) setting. Default on. The smart modes must
  /// upload video to the cloud for their report, so there is NO per-session or
  /// per-destination choice on the pre-class page — just a cloud notice. When a
  /// user turns this OFF, the AI modes gray out (GateReason.storageOff).
  bool saveVideosOn;

  /// "Don't show again" for the phone course-notice page.
  bool skipNotice;

  /// "Don't show again" for the ATOM round-screen confirm.
  bool skipAtomConfirm;

  // ---- reads ----
  List<AtomDevice> get devices => List.unmodifiable(_devices);
  bool get isPaired => _devices.isNotEmpty;
  bool get hasMultipleDevices => _devices.length > 1;
  int get activeIndex => _devices.isEmpty ? 0 : _activeIndex.clamp(0, _devices.length - 1);
  AtomDevice? get activeDevice => isPaired ? _devices[activeIndex] : null;
  bool get isOnline => activeDevice?.isOnline ?? false;
  bool get isPlus => _isPlus;
  AppLang get lang => _lang;
  WorkoutMode get selected => _selected;

  bool isLocked(WorkoutMode m) {
    if (!m.isAi) return false;
    return !isPaired || !_isPlus || !hasAiQuota || !saveVideosOn;
  }

  /// Gate reasons for a locked AI mode, in display priority order.
  List<GateReason> missing(WorkoutMode m) {
    if (!m.isAi) return const [];
    final out = <GateReason>[];
    if (!isPaired) out.add(GateReason.needDevice);
    if (!_isPlus) {
      out.add(GateReason.needPlus);
    } else if (!hasAiQuota) {
      out.add(GateReason.overQuota); // has Plus but AI credits used up
    }
    if (!saveVideosOn) out.add(GateReason.storageOff); // video storage turned off
    return out;
  }

  /// AI modes additionally need the active ATOM online (it can't provide
  /// vision offline) — block the start, don't just warn.
  bool get canStartSelected => canStart(_selected);
  bool canStart(WorkoutMode m) => m.isAi ? (!isLocked(m) && isOnline) : true;

  bool get showOfflineWarning => isPaired && !isOnline;

  /// AI modes are fully usable (device + Plus + online). Drives whether the
  /// "switch anytime" note is shown — it's misleading when only Manual works.
  bool get aiUsable => isPaired && isPlus && hasAiQuota && isOnline && saveVideosOn;

  // ---- writes ----
  void selectMode(WorkoutMode m) {
    if (isLocked(m) || _selected == m) return;
    _selected = m;
    notifyListeners();
  }

  void setDevices(List<AtomDevice> devices, {int activeIndex = 0}) {
    _devices = List.of(devices);
    _activeIndex = devices.isEmpty ? 0 : activeIndex.clamp(0, devices.length - 1);
    _reconcile();
    notifyListeners();
  }

  void setActiveIndex(int index) {
    if (_devices.isEmpty) return;
    _activeIndex = index.clamp(0, _devices.length - 1);
    _reconcile();
    notifyListeners();
  }

  void setPlus(bool v) { if (_isPlus != v) { _isPlus = v; _reconcile(); notifyListeners(); } }
  void setLang(AppLang v) { if (_lang != v) { _lang = v; notifyListeners(); } }
  void setHasAiQuota(bool v) { if (hasAiQuota != v) { hasAiQuota = v; _reconcile(); notifyListeners(); } }
  void setSaveVideosOn(bool v) { if (saveVideosOn != v) { saveVideosOn = v; _reconcile(); notifyListeners(); } }
  void setSkipNotice(bool v) { skipNotice = v; notifyListeners(); }
  void setSkipAtomConfirm(bool v) { skipAtomConfirm = v; notifyListeners(); }

  // ---- helpers ----
  WorkoutMode _defaultSelection() {
    for (final m in WorkoutMode.values) {
      if (!isLocked(m)) return m;
    }
    return WorkoutMode.manualLog;
  }

  void _reconcile() {
    if (isLocked(_selected)) _selected = _defaultSelection();
  }
}
