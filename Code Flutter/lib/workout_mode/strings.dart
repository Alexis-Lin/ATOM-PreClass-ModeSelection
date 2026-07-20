import 'models.dart';

/// Bilingual copy — the SINGLE place to refine titles / wording / length.
/// Mirrors the prototype's `T` object. Construct with the current [AppLang].
///
/// ⚠️ COPY: product/localization to finalize. Items marked "placeholder"
/// (course data, tripod accessory, privacy link) await real content.
class L {
  final AppLang lang;
  const L(this.lang);

  bool get zh => lang == AppLang.zh;
  String _t(String en, String cn) => zh ? cn : en;

  // ---- mode sheet chrome ----
  String get title => _t('Select workout mode', '选择上课模式');
  String get flexNote => _t(
      'Not sure? Switch modes anytime, even mid-workout.',
      '不确定？课中随时能切换，先选一个。');
  String get plusTag => 'Plus';

  // ---- device row ----
  String get connected => _t('Connected', '已连接');
  String get noNetwork => _t('No network', '无网络');
  String get noDevice => _t('ATOM', 'ATOM');
  String get addDevice => _t('Add device', '添加设备');

  // ---- blocking warning + CTA ----
  String get warnNoNetwork =>
      _t('ATOM is offline — connect it to start AI modes.', 'ATOM 未联网，连网后才能启动 AI 模式。');
  String get switchHint => _t(' Or switch to an online device.', ' 也可切换到在线的设备。');
  String get ctaBlocked => _t('ATOM must be online', 'ATOM 需在线');

  // ---- gate sheet (locked mode tapped) ----
  String gateTitle(WorkoutMode m, GateReason r) => switch (r) {
        GateReason.needDevice => _t('${modeName(m)} runs on ATOM', '${modeName(m)} 需要 ATOM'),
        GateReason.needPlus => _t('${modeName(m)} needs Plus', '${modeName(m)} 需要 Plus 会员'),
        GateReason.overQuota => _t('${modeName(m)} — AI limit reached', '${modeName(m)}：AI 额度已用尽'),
      };
  String gateBody(GateReason r) => switch (r) {
        GateReason.needDevice =>
          _t('Pair a nearby ATOM to unlock AI modes.', '连接身边的 ATOM，解锁 AI 模式。'),
        GateReason.needPlus => _t('Get Plus to unlock AI modes.', '开通 Plus，解锁 AI 模式。'),
        GateReason.overQuota => _t(
            'You’ve used up this cycle’s Plus AI sessions — upgrade to Pro for more. Manual Log still works.',
            '本期 Plus 的 AI 次数已用完——升级 Pro 可获得更多。手动记录仍可使用。'),
      };
  String gateButton(GateReason r) => switch (r) {
        GateReason.needDevice => addDevice,
        GateReason.needPlus => _t('Get Plus', '开通 Plus'),
        // Quota exhausted → upsell to Pro. (Exact Pro pricing/limits TBD by business.)
        GateReason.overQuota => _t('Upgrade to Pro', '升级 Pro'),
      };
  String get notNow => _t('Not now', '以后再说');

  // ---- device picker ----
  String get pickTitle => _t('Which ATOM?', '使用哪一台 ATOM？');
  String get pickHint => _t('Pick the one next to you.', '选择你身边的那台。');

  // ---- per-mode copy ----
  String modeName(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t('Live Coach', '实时教练'),
        WorkoutMode.recordRecap => _t('Record & Recap', '录制复盘'),
        WorkoutMode.manualLog => _t('Manual Log', '手动记录'),
      };
  String modeDesc(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach =>
          _t('Live counting & form cues — plus a recap after.', '实时计数与动作提示，练后同样有复盘。'),
        WorkoutMode.recordRecap =>
          _t('Records quietly, recap after — no live form cues.', '安静录制、无实时动作提示，练后出复盘。'),
        WorkoutMode.manualLog =>
          _t('Log sets & reps yourself. No camera.', '自己记录，不开摄像头。'),
      };
  String modeCta(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t('Start Coaching', '开始指导'),
        WorkoutMode.recordRecap => _t('Start Recording', '开始录制'),
        WorkoutMode.manualLog => _t('Start Logging', '开始记录'),
      };

  // ---- course notice (full page) ----
  String get noticeTitle => _t('Get set up', '课前须知');
  String get ready => _t("I'm ready", '准备好了');
  String get dontShow => _t('Don’t show this again', '下次不再提示');

  // Live Coach — positive only; the don'ts live on the Framing tips page.
  String get coachSub => _t(
      'ATOM watches like a coach — set it up so it can see you clearly.',
      'ATOM 就像教练的眼睛——摆好位置，让它看清你。');
  // Angle is per-exercise and prompted in-workout, so it's intentionally not a
  // fixed rule here — 4 essentials keep the checklist scannable.
  List<String> get coachDo => zh
      ? const ['全身入框，站在画面中央', 'ATOM 约膝盖高，或放地上', '离 ATOM 0.5–1 米', '周围留空，别被器械挡住']
      : const [
          'Whole body in frame, centered',
          'ATOM at knee height, or the floor',
          'Stand 0.5–1 m back',
          'Clear space — nothing blocking you',
        ];
  String get tipsLink => _t('See framing tips', '查看拍摄技巧');
  String get beta => _t(
      'Beta — AI may miss or miscount reps. Use your judgment.',
      'Beta——AI 可能漏计或误计，请自行判断。');

  // Framing illustration labels (baked into the drawing but localized).
  String get frKnee => _t('≈ knee', '≈ 膝盖高');
  String get frDist => _t('0.5–1 m', '0.5–1 米');

  // Record & Recap
  String get recapSub => _t(
      'Stay in frame at any angle — just keep the light good.',
      '全程在画面里，角度随意，光线充足就好。');
  String get reportHeader => _t('Your report', '关于报告');
  String get report => _t(
      'Deeper recaps coming via OTA. Today’s is basic.', '更深复盘将随 OTA 上线，当前报告较简单。');
  String get algoHeader => _t('Nothing is lost', '不用担心');
  String get algo =>
      _t('Video is saved — future upgrades re-analyze it.', '视频留存，日后升级可重新分析。');
  String get recapNoSave => _t(
      'This workout won’t be saved, so there’s no recap report.', '本次不保存，将没有复盘报告。');
  // Record & Recap hard-requires saving (its output IS the saved video + recap).
  String get recapNeedHeader => _t('Saving required', '需开启保存');
  String get recapNeed => _t(
      'Record & Recap keeps the video to build your recap — turn on saving to start.',
      '录制复盘要保存视频才能生成复盘——开启保存即可开始。');
  String get recapTurnOnCta => _t('Turn on saving to continue', '开启保存以继续');

  // ---- framing tips (extra reading) ----
  String get tipsTitle => _t('Framing tips', '拍摄技巧');
  String get tipsOk => _t('Got it', '知道了');
  String get coachLine => _t(
      'Think of ATOM as your coach’s eyes: if a coach standing there could see your form, so can ATOM.',
      '把 ATOM 想成教练的眼睛：教练站那儿能看清你的动作，ATOM 就能看清。');
  String get crowdHeader => _t('Crowd is fine', '背景有人没关系');
  String get crowd => _t(
      'ATOM tracks the largest person in view, so people in the background won’t throw it off — just be centred and close enough that you’re the biggest.',
      'ATOM 只认画面里最大的那个人，背景有人也不影响——你居中、离得够近，是画面里最大的主体就行。');
  String get tripodHeader => _t('Steady placement', '稳定摆放');
  String get tripod => _t(
      'The ATOM tripod is the easy way to get it level at about knee height — recommended. A stand or box works too.',
      '推荐用配套的 ATOM 三脚架，最省事地把它平稳架到约膝盖高度；用支架或垫高也行。');
  String get avoidHeader => _t('These hurt accuracy', '这些会影响识别');
  // "Cut off" and "blocked by gear" merged — both mean "not fully visible".
  List<String> get coachAvoid => zh
      ? const ['身体被裁切、偏到一边，或被器械挡住', '太近或太远——0.5–1 米最好', 'ATOM 过度仰角对着你', '逆光、过暗，或阴影很重']
      : const [
          'Body cut off, off-center, or blocked by gear',
          'Too close or too far — aim for 0.5–1 m',
          'ATOM tilted steeply up at you',
          'Backlit, too dark, or heavy shadows',
        ];

  // ---- data-save (bottom line) ----
  String get drCloud => _t('Saved to your cloud', '视频同步到云端');
  String get drLocal => _t('Saved on ATOM (SD card)', '视频存于 ATOM（SD 卡）');
  String get drSaveOff =>
      _t('Video saving is off — this workout won’t be saved.', '视频保存已关闭，本次不会保存。');
  String get drTurnOn => _t('Turn on', '开启保存');
  String get drChange => _t('Change', '更改');

  // ---- data-save sheet (normal + invite-to-save) ----
  String get dataSheetTitle => _t('Where to save your video?', '视频保存在哪里？');
  String get saveOnTitle => _t('Save this workout’s video?', '保存这次的视频？');
  String get saveOnBody => _t(
      'Saving is off in your settings. Turn it on for this workout to get your recap.',
      '你已在设置中关闭保存。为本次开启即可获得复盘。');
  String get saveNotNow => _t('Not this time', '这次不用');
  String get dEnableCta => _t('Turn on saving', '开启保存');
  // Scope of the per-session enable: unchecked = this session only; checked = flip the global setting.
  String get dSaveAlways => _t('Keep saving on from now on', '以后一直开启保存（可在设置关闭）');
  String get dCloudName => _t('Cloud', '云端');
  String get dLocalName => _t('Keep on ATOM', '仅存 ATOM');
  String get dRecommended => _t('Recommended', '推荐');
  String get dNeedsSd => _t('Needs SD card', '需 SD 卡');
  // App can't verify the ATOM's SD card → a reminder, not a detected state.
  String get dLocalReminder => _t(
      'The app can’t check ATOM’s SD card from here — make sure one’s inserted, or this session won’t be saved.',
      'App 端无法确认 ATOM 的 SD 卡状态——请自行确保已插卡，否则本次不会保存。');
  String get dDone => _t('Done', '完成');
  List<String> get dCloudBenefits => zh
      ? const ['无需 SD 卡', '算法升级后自动重分析']
      : const ['No SD card needed', 'Auto re-analyzed as AI improves'];
  List<String> get dLocalBenefits => zh
      ? const ['存 SD 卡，随时自取', '不上传云端']
      : const ['On the SD card — copy off anytime', 'Not uploaded'];
  // Privacy: "just enough" — no strong promise (don't over-commit / invite worry),
  // just a light pointer to the policy.
  String get privacyNote => _t('See our', '详见');
  String get privacyLink => _t('Privacy Policy', '隐私协议');

  // ---- Settings (global video-saving toggle) ----
  String get settingsTitle => _t('Settings', '设置');
  String get setSaveTitle => _t('Save workout videos', '保存训练视频');
  String get setSaveBody => _t(
      'On by default. Turn off and no video is recorded or uploaded — your reps and stats are still logged, and you’ll be asked each time whether to allow saving.',
      '默认开启。关闭后不再录制或上传任何视频——组数、数据仍会记录；每次训练会询问是否允许保存。');

  // ---- course preview (placeholders) ----
  String get pvKicker => _t('TODAY’S WORKOUT', '今日训练');
  String get courseName => _t('Back & Legs', '背部与腿部力量');
  String get pvMeta => _t('32 min · Strength · Intermediate', '32 分钟 · 力量 · 进阶');
  String get pvMetaShort => _t('32 min · Strength', '32 分钟 · 力量');
  String get pvDesc => _t(
      'A lower-body strength session — squats, hinges and lunges for stronger legs and back.',
      '下肢力量训练——深蹲、髋铰链与弓步，练强腿部和背部。');
  String get pvStatMin => _t('min', '分钟');
  String get pvStatEx => _t('exercises', '个动作');
  String get pvStatKcal => _t('kcal', '千卡');
  String get pvIncludes => _t('In this session', '本节包含');
  List<String> get pvExercises => zh
      ? const ['高脚杯深蹲', '罗马尼亚硬拉', '行走弓步', '背部伸展']
      : const ['Goblet squat', 'Romanian deadlift', 'Walking lunge', 'Back extension'];
  String get pvStart => _t('Start workout', '开始训练');

  // ---- ATOM round device ----
  String get atomTitle => _t('Workout mode', '上课模式');
  String get atomStart => _t('Start', '开始');
  String get atomConfirmTitle => _t('Before you start', '开始前请确认');
  // Round screen is small → these render as icon-led rows (see _confirm), not
  // an illustration. Keep each line terse. Order matches the icon list there.
  List<String> atomBullets(WorkoutMode m) => m == WorkoutMode.recordRecap
      ? (zh
          ? const ['全程在画面里，正对侧对都行', '光线充足，画面里只有你', '更深复盘随 OTA 上线']
          : const [
              'Stay in frame — front or side both fine',
              'Good light, just you in view',
              'Deeper recaps coming via OTA',
            ])
      : (zh
          ? const ['全身入框', 'ATOM 约膝盖高，或放地上', 'Beta——请自行判断']
          : const [
              'Whole body in frame',
              'ATOM at knee height or on the floor',
              'Beta — use your own judgment',
            ]);
  String get dontShowAgain => _t("Don’t show again", '不再显示');
  String atomSub(WorkoutMode m) => switch (m) {
        WorkoutMode.liveCoach => _t('Live counting and form cues.', '实时计数、动作提示。'),
        WorkoutMode.recordRecap => _t('Records quietly, reports after.', '安静录制，练后出报告。'),
        WorkoutMode.manualLog => '',
      };
}
