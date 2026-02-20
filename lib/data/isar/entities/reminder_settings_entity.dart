import 'package:isar_community/isar.dart';

import '../../../core/models/reminder_settings.dart';
import '../../persistence/persistence_constants.dart';

part 'reminder_settings_entity.g.dart';

@collection
class ReminderSettingsEntity {
  ReminderSettingsEntity();

  Id id = PersistenceConstants.singletonEntityId;

  bool enabled = ReminderSettings.defaults.enabled;
  int intervalMinutes = ReminderSettings.defaults.intervalMinutes;
  int quietStartMinutes = ReminderSettings.defaults.quietStartMinutes;
  int quietEndMinutes = ReminderSettings.defaults.quietEndMinutes;
  bool skipWeekends = ReminderSettings.defaults.skipWeekends;
  int maxPerDay = ReminderSettings.defaults.maxPerDay;

  /// Converts this persistence entity into the domain model.
  ReminderSettings toModel() {
    return ReminderSettings(
      enabled: enabled,
      intervalMinutes: intervalMinutes,
      quietStartMinutes: quietStartMinutes,
      quietEndMinutes: quietEndMinutes,
      skipWeekends: skipWeekends,
      maxPerDay: maxPerDay,
    );
  }

  /// Creates a singleton Isar entity from the domain settings model.
  static ReminderSettingsEntity fromModel(ReminderSettings model) {
    return ReminderSettingsEntity()
      ..enabled = model.enabled
      ..intervalMinutes = model.intervalMinutes
      ..quietStartMinutes = model.quietStartMinutes
      ..quietEndMinutes = model.quietEndMinutes
      ..skipWeekends = model.skipWeekends
      ..maxPerDay = model.maxPerDay;
  }
}
