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
    this.hasSdCard = true,
    this.hasAiQuota = true,
    this.dataChoice = DataChoice.cloud,
    this.saveVideosOn = true,
    this.sessionSave = false,
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

  /// Where recorded video/report is kept (remembered preference).
  DataChoice dataChoice;

  /// NOTE: the App does NOT actually know the ATOM's SD-card status (not synced),
  /// so this no longer gates anything — "Keep on ATOM" is surfaced as a REMINDER,
  /// not a verified state. Kept for API compatibility; safe to remove.
  bool hasSdCard;

  /// Has Plus, but this billing cycle's AI sessions may be used up. When false
  /// (and the user has Plus), AI modes lock with GateReason.overQuota.
  bool hasAiQuota;

  /// Global "Save workout videos" setting (Settings). Default on — we do NOT
  /// nudge users away from saving. When off, each session invites them to
  /// allow saving instead.
  bool saveVideosOn;

  /// Per-session opt-in to save when [saveVideosOn] is off.
  bool sessionSave;

  /// Whether this workout's video is being saved (destination applies only
  /// when true). Report/recap needs this.
  bool get saving => saveVideosOn || sessionSave;

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

  bool isLocked(WorkoutMode m) =>
      m.requiresDevice && (!isPaired || (m.requiresPlus && (!_isPlus || !hasAiQuota)));

  List<GateReason> missing(WorkoutMode m) {
    final out = <GateReason>[];
    if (m.requiresDevice && !isPaired) out.add(GateReason.needDevice);
    if (m.requiresPlus && !_isPlus) {
      out.add(GateReason.needPlus);
    } else if (m.requiresPlus && !hasAiQuota) {
      out.add(GateReason.overQuota); // has Plus but AI credits used up
    }
    return out;
  }

  /// AI modes additionally need the active ATOM online (it can't provide
  /// vision offline) — block the start, don't just warn.
  bool get canStartSelected => canStart(_selected);
  bool canStart(WorkoutMode m) => m.isAi ? (!isLocked(m) && isOnline) : true;

  bool get showOfflineWarning => isPaired && !isOnline;

  /// AI modes are fully usable (device + Plus + online). Drives whether the
  /// "switch anytime" note is shown — it's misleading when only Manual works.
  bool get aiUsable => isPaired && isPlus && hasAiQuota && isOnline;

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
  void setHasSdCard(bool v) { if (hasSdCard != v) { hasSdCard = v; notifyListeners(); } }
  void setHasAiQuota(bool v) { if (hasAiQuota != v) { hasAiQuota = v; _reconcile(); notifyListeners(); } }
  void setDataChoice(DataChoice v) { if (dataChoice != v) { dataChoice = v; notifyListeners(); } }
  void setSaveVideosOn(bool v) { saveVideosOn = v; sessionSave = false; notifyListeners(); }
  void setSessionSave(bool v) { sessionSave = v; notifyListeners(); }
  /// Reset per-session opt-in (call when starting a fresh pre-workout flow).
  void resetSession() { sessionSave = false; notifyListeners(); }
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
