package com.forevernewvie.projectgtg

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class GtgWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_gtg).apply {
                // Fetch data saved by Flutter's WidgetSyncService
                val todayTotal = widgetData.getInt("gtg_today_total", 0)
                val primaryExercise = widgetData.getString("gtg_primary_exercise", "pushUp")

                // Update Widget UI texts
                setTextViewText(R.id.tv_title, "GTG " + primaryExercise?.uppercase())
                setTextViewText(R.id.tv_reps, "$todayTotal")

                // Button click intent to trigger Flutter background isolate
                val uriStr = "gtgwidget://log?type=$primaryExercise&reps=1"
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse(uriStr)
                )
                setOnClickPendingIntent(R.id.btn_log, backgroundIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
