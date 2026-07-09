import 'models.dart';

/// Bilingual copy. Construct with the current [AppLang] and read strings.
///
/// ⚠️ COPY: final wording should be reviewed by product/localization.
class L {
  final AppLang lang;
  const L(this.lang);

  bool get zh => lang == AppLang.zh;
  String _t(String en, String cn) => zh ? cn : en;

  // Sheet chrome.
  String get title => _t('Select workout mode', '选择上课模式');
  String get bestLabel => _t('Best for', '适合');
  String get plusTag => 'Plus';

  // Device row.
  String get connected => _t('Connected', '已连接');
  String get noNetwork => _t('No network', '无网络');
  String get noDevice => _t('No device', '未连接');
  String get addDevice => _t('Add device', '添加设备');
  String get deviceBrand => 'ATOM';

  // Blocking warning + CTA.
  String get warnNoNetwork => _t(
        "Can't start AI modes — ATOM is offline. Make sure it's connected to the internet.",
        '无法启动 AI 模式——ATOM 未联网，请确保它已连接网络。',
      );
  String get switchHint => _t(' Or switch to an online device.', ' 也可切换到在线的设备。');
  String get ctaBlocked => _t('Ensure ATOM is online', '请确保 ATOM 在线');

  // Gate sheet (locked mode tapped).
  String gateTitle(WorkoutMode m, GateReason r) => r == GateReason.needDevice
      ? _t('${modeName(m)} runs on ATOM', '${modeName(m)} 需要 ATOM')
      : _t('${modeName(m)} needs Plus', '${modeName(m)} 需要 Plus 会员');
  String gateBody(GateReason r) => r == GateReason.needDevice
      ? _t('Pair a nearby ATOM device to unlock live coaching and recorded analysis.',
          '请连接身边的 ATOM 设备，解锁实时指导与录制分析。')
      : _t('Unlock AI coaching and recorded analysis with a Plus membership.',
          '开通 Plus 会员，解锁 AI 实时指导与录制分析。');
  String gateButton(GateReason r) =>
      r == GateReason.needDevice ? addDevice : _t('Get Plus', '开通 Plus');
  String get notNow => _t('Not now', '以后再说');

  // Pre-start confirmation (phone).
  String get prestartTitle => _t('Before you start', '开始前请确认');
  String get prestart1 =>
      _t('AI is in beta — it may miss or miscount some reps.', 'AI 模式仍在 beta 迭代中，动作可能漏记或误记。');
  String get prestart2 =>
      _t('Keep your ATOM online and within reach.', '确保 ATOM 在线并放在手边。');
  String get prestart3 => _t(
      'Stay fully in frame — no obstructions or odd angles.', '保持人物完整入框，不要遮挡或奇怪角度。');
  String get prestartStart => _t('Start', '开始');

  // Device picker.
  String get pickTitle => _t('Which ATOM?', '使用哪一台 ATOM？');

  // Beta caution (Live Coach detail).
  String get beta => _t(
        'Beta: ATOM is still improving and may miss or miscount some reps — trust your own judgment.',
        'Beta：ATOM 仍在迭代，个别动作可能漏计或误计，请以自身判断为准。',
      );

  // ATOM round device.
  String get atomTitle => _t('Workout mode', '上课模式');
  String get atomStart => _t('Start', '开始');
  String get atomConfirmTitle => _t('Before you start', '开始前请确认');
  String get atomConfirm1 =>
      _t('AI is in beta and may miss or miscount reps.', 'AI 仍在 beta，动作可能漏记或误记。');
  String get atomConfirm2 =>
      _t('Stay fully in frame — no obstructions.', '请完整入框，不要遮挡。');
  String get dontShowAgain => _t("Don't show again", '不再显示');

  // Per-mode copy.
  String modeName(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t('Live Coach', '实时教练'),
        WorkoutMode.recordRecap => _t('Record & Recap', '录制复盘'),
        WorkoutMode.manualLog => _t('Manual Log', '手动记录'),
      };

  String modeDesc(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach =>
          _t('Real-time counting and form cues while you move.', '训练时实时计数并给出动作提示。'),
        WorkoutMode.recordRecap =>
          _t('Records your session quietly, then reports back after.', '全程安静记录，练完给你一份详细报告。'),
        WorkoutMode.manualLog =>
          _t('Enter your sets, reps and weight yourself.', '自己手动记录组数、次数与重量。'),
      };

  String modeBest(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t(
            'anyone who wants to be coached through every rep with instant feedback.',
            '想在每一下都被带着练、需要即时反馈的人。'),
        WorkoutMode.recordRecap => _t(
            'experienced users who want the video, the data and a report — without the chatter.',
            '想要影像、数据与报告，又不想被打扰的进阶用户。'),
        WorkoutMode.manualLog =>
          _t("quick manual tracking when you don't need the camera.", '不需要摄像头、想快速手动记录的时候。'),
      };

  String modeCta(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t('Start Coaching', '开始指导'),
        WorkoutMode.recordRecap => _t('Start Recording', '开始录制'),
        WorkoutMode.manualLog => _t('Start Logging', '开始记录'),
      };

  /// Short sub-label used on the ATOM round tiles.
  String atomSub(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t('Real-time counting and cues.', '实时计数与动作提示。'),
        WorkoutMode.recordRecap => _t('Silent recording, report after.', '安静记录，练后出报告。'),
        WorkoutMode.manualLog => '',
      };
}
