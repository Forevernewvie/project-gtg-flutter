class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.intervalMinutes,
    required this.quietStartMinutes,
    required this.quietEndMinutes,
    required this.skipWeekends,
    required this.maxPerDay,
  });

  final bool enabled;
  final int intervalMinutes;
  final int quietStartMinutes;
  final int quietEndMinutes;
  final bool skipWeekends;
  final int maxPerDay;

  static const ReminderSettings defaults = ReminderSettings(
    enabled: false,
    intervalMinutes: 60,
    quietStartMinutes: 23 * 60,
    quietEndMinutes: 7 * 60,
    skipWeekends: false,
    maxPerDay: 24,
  );

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'enabled': enabled,
      'intervalMinutes': intervalMinutes,
      'quietStartMinutes': quietStartMinutes,
      'quietEndMinutes': quietEndMinutes,
      'skipWeekends': skipWeekends,
      'maxPerDay': maxPerDay,
    };
  }

  static ReminderSettings fromJson(Map<String, Object?> json) {
    bool readBool(String key, bool fallback) {
      final v = json[key];
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      if (v is num) return v != 0;
      return fallback;
    }

    int readInt(String key, int fallback) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    return ReminderSettings(
      enabled: readBool('enabled', defaults.enabled),
      intervalMinutes: readInt('intervalMinutes', defaults.intervalMinutes),
      quietStartMinutes: readInt(
        'quietStartMinutes',
        defaults.quietStartMinutes,
      ),
      quietEndMinutes: readInt('quietEndMinutes', defaults.quietEndMinutes),
      skipWeekends: readBool('skipWeekends', defaults.skipWeekends),
      maxPerDay: readInt('maxPerDay', defaults.maxPerDay),
    );
  }

  ReminderSettings copyWith({
    bool? enabled,
    int? intervalMinutes,
    int? quietStartMinutes,
    int? quietEndMinutes,
    bool? skipWeekends,
    int? maxPerDay,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
      quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
      skipWeekends: skipWeekends ?? this.skipWeekends,
      maxPerDay: maxPerDay ?? this.maxPerDay,
    );
  }
}
