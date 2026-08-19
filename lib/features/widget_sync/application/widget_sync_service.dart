import 'package:home_widget/home_widget.dart';
import '../domain/widget_data_model.dart';

/// Service responsible for communicating with iOS/Android native widgets.
class WidgetSyncService {
  /// The App Group ID defined in Xcode for iOS data sharing.
  static const String appGroupId = 'group.com.projectgtg';
  
  /// The names of the native widget classes.
  static const String iOSWidgetName = 'GtgWidget';
  static const String androidWidgetName = 'GtgWidgetProvider';

  /// Initializes the HomeWidget plugin with the App Group ID.
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  /// Pushes the latest data to the native side and triggers a widget update.
  static Future<void> syncData(WidgetDataModel data) async {
    final map = data.toMap();
    
    // Save each data point into the shared preferences/app group
    for (final entry in map.entries) {
      await HomeWidget.saveWidgetData(entry.key, entry.value);
    }
    
    // Tell the OS to refresh the widget UI
    await HomeWidget.updateWidget(
      name: iOSWidgetName,
      androidName: androidWidgetName,
    );
  }
}
