import 'models.dart';

/// Bilingual copy — the SINGLE place to refine titles / wording / length.
/// Construct with the current [AppLang] and read strings.
///
/// ⚠️ COPY: product/localization to finalize. Keep lines short; prefer no
/// wrapping. Show info only where necessary.
class L {
  final AppLang lang;
  const L(this.lang);

  bool get zh => lang == AppLang.zh;
  String _t(String en, String cn) => zh ? cn : en;

  // ---- mode sheet chrome ----
  String get title => _t('Select workout mode', '选择上课模式');
  String get flexNote => _t(
      'Not sure? You can switch modes anytime — even mid-workout. Just pick one.',
      '不确定？三种模式课中随时能切换，先随便选一个就好。');
  String get bestLabel => _t('Best for', '适合');
  String get plusTag => 'Plus';

  // ---- device row ----
  String get connected => _t('Connected', '已连接');
  String get noNetwork => _t('No network', '无网络');
  String get noDevice => _t('No device', '未连接');
  String get addDevice => _t('Add device', '添加设备');

  // ---- blocking warning + CTA ----
  String get warnNoNetwork => _t(
      "Can't start AI modes — ATOM is offline. Make sure it's connected to the internet.",
      '无法启动 AI 模式——ATOM 未联网，请确保它已连接网络。');
  String get switchHint => _t(' Or switch to an online device.', ' 也可切换到在线的设备。');
  String get ctaBlocked => _t('Ensure ATOM is online', '请确保 ATOM 在线');

  // ---- gate sheet (locked mode tapped) ----
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

  // ---- device picker ----
  String get pickTitle => _t('Which ATOM?', '使用哪一台 ATOM？');
  String get pickHint => _t('Pick the device that’s next to you.', '请选择在你身边的设备。');

  // ---- per-mode copy ----
  String modeName(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t('Live Coach', '实时教练'),
        WorkoutMode.recordRecap => _t('Record & Recap', '录制复盘'),
        WorkoutMode.manualLog => _t('Manual Log', '手动记录'),
      };
  String modeDesc(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach =>
          _t('Real-time counting and form cues while you move.', '训练时实时计数并给出动作提示。'),
        WorkoutMode.recordRecap =>
          _t('Records quietly, then reports back after (cloud).', '全程安静记录，练完给一份详细报告（云端）。'),
        WorkoutMode.manualLog =>
          _t('Enter your sets, reps and weight yourself.', '自己手动记录组数、次数与重量。'),
      };
  String modeBest(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach =>
          _t('anyone who wants to be coached through every rep.', '想在每一下都被带着练、需要即时反馈的人。'),
        WorkoutMode.recordRecap =>
          _t('experienced users who want the video, data and a report.', '想要影像、数据与报告，又不想被打扰的进阶用户。'),
        WorkoutMode.manualLog =>
          _t('quick manual tracking when you don’t need the camera.', '不需要摄像头、想快速手动记录的时候。'),
      };
  String modeCta(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t('Start Coaching', '开始指导'),
        WorkoutMode.recordRecap => _t('Start Recording', '开始录制'),
        WorkoutMode.manualLog => _t('Start Logging', '开始记录'),
      };

  // ---- course notice (full page) ----
  String get noticeTitle => _t('Get set up', '课前须知');
  String get ready => _t("I'm ready", '准备好了');

  // Live Coach
  String get coachSub => _t('Good framing keeps tracking accurate.', '画面摆好，识别才准。');
  String get doHeader => _t('Set up', '这样摆');
  List<String> get coachDo => zh
      ? const ['全身入框，动作最大幅度也不出框', '手机稳定，约胸口高、镜头水平', '光线均匀，画面里只有你']
      : const [
          'Whole body in frame, even at full range',
          'Phone stable, ~chest height and level',
          'Even light; just you in a clear space',
        ];
  String get avoidHeader => _t('These hurt accuracy', '这些会让识别变不准');
  List<String> get coachAvoid => zh
      ? const ['肢体被裁切或遮挡', '太近、太远或角度不正', '逆光/过暗，或有他人入镜']
      : const ['Body cut off or blocked', 'Too close, too far or bad angle', 'Backlit, too dark or others in frame'];
  String get beta => _t(
      'Beta: ATOM is still improving and may miss or miscount some reps — trust your own judgment.',
      'Beta：ATOM 仍在迭代，个别动作可能漏计或误计，请以自身判断为准。');

  // Record & Recap
  String get recapSub => _t('Just stay in frame the whole time.', '运动时，你全程在画面里就好。');
  String get keepHeader => _t('Keep in mind', '记住这几点');
  List<String> get recapKeep => zh
      ? const ['运动全程待在画面里', '角度不苛刻，正面或侧面都行', '光线别太暗，画面里只有你']
      : const [
          'Stay fully in frame the whole workout',
          'Angle is flexible — front or side is fine',
          'Enough light; just you in frame',
        ];
  String get reportHeader => _t('Your report', '关于报告');
  String get report => _t(
      'Deep recap reports are still evolving — coming soon via OTA. Today’s report is basic for now.',
      '深度复盘报告持续迭代中（Coming soon，留意 OTA 更新），当前报告还比较简单。');
  String get algoHeader => _t('Nothing is lost', '不用担心');
  String get algo => _t(
      'Your video is saved, so every future algorithm upgrade can re-analyze it.',
      '视频会留存，之后每次算法升级都能重新分析这段录像。');

  // ---- data-save (bottom entry + secondary sheet) ----
  String get drCloud => _t('Video syncs to your cloud account', '视频将同步到你的云端账户');
  String get drLocal => _t('Video kept on ATOM (SD card)', '视频存于 ATOM（SD 卡）');
  String get drNoSd => _t("Video won't be saved — no SD card", '视频不会保存 — 无 SD 卡');
  String get drChange => _t('Change', '更改');
  String get dontShow => _t('Don’t show this again', '下次不再提示');

  String get dataSheetTitle => _t('Where to save your video?', '视频保存在哪里？');
  String get dCloudName => _t('Cloud', '云端');
  String get dLocalName => _t('Keep on ATOM', '仅存 ATOM');
  String get dRecommended => _t('Recommended', '推荐');
  String get dNeedsSd => _t('Needs SD card', '需 SD 卡');
  String get dDone => _t('Done', '完成');
  List<String> get dCloudBenefits => zh
      ? const ['无需 SD 卡', '算法升级后自动重新分析']
      : const ['No SD card needed', 'Re-analyzed automatically as our AI improves'];
  List<String> get dLocalBenefits => zh
      ? const ['存在 SD 卡上，随时自己拷走', '不上传云端']
      : const ['Stored on the SD card — copy it off anytime', 'Not uploaded to the cloud'];
  String get noSdWarn => _t(
      "No SD card in your ATOM — this session won't be kept. Insert a card, or upload to cloud.",
      'ATOM 未检测到 SD 卡——本次训练不会被保留。请插入 SD 卡，或改为上传云端。');
  String get privacyNote => _t(
      "We don't proactively access your videos, and won't use your data to train our AI.",
      '我们不会主动查看你的视频，也不会用你的数据来训练 AI。');
  String get privacyLink => _t('Privacy Policy', '隐私协议');

  // ---- ATOM round device ----
  String get atomTitle => _t('Workout mode', '上课模式');
  String get atomStart => _t('Start', '开始');
  String get atomConfirmTitle => _t('Before you start', '开始前请确认');
  List<String> atomBullets(WorkoutMode m) => m == WorkoutMode.recordRecap
      ? (zh
          ? const ['运动全程待在画面里，角度不苛刻。', '深度复盘报告持续迭代中（留意 OTA）。']
          : const [
              'Just stay in frame the whole time — angle is flexible.',
              'Deep recap reports are still improving (watch for OTA).',
            ])
      : (zh
          ? const ['AI 仍在 beta，动作可能漏记或误记。', '让全身完整入框——别遮挡、别逆光。']
          : const [
              'AI is in beta and may miss or miscount reps.',
              'Keep your whole body in frame — no blocking or backlight.',
            ]);
  String get dontShowAgain => _t("Don't show again", '不再显示');
  String atomSub(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t('Real-time counting and cues.', '实时计数与动作提示。'),
        WorkoutMode.recordRecap => _t('Silent recording, report after.', '安静记录，练后出报告。'),
        WorkoutMode.manualLog => '',
      };
}
