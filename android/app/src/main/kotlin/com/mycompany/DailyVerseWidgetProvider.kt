package com.mycompany.sanctuaryflow

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class DailyVerseWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Widget is added to home screen
    }

    override fun onDisabled(context: Context) {
        // Widget is removed from home screen
    }

    companion object {
        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.daily_verse_widget)

            // Get verse data from shared preferences
            val verse = widgetData.getString("widget_verse", "Trust in the Lord with all your heart")
            val reference = widgetData.getString("widget_reference", "Proverbs 3:5-6")

            // Update the widget UI
            views.setTextViewText(R.id.widget_verse_text, verse)
            views.setTextViewText(R.id.widget_verse_reference, reference)

            // Set up click listener to open the app
            val intent = Intent(context, MainActivity::class.java)
            intent.putExtra("navigate_to", "verse")
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_verse_container, pendingIntent)

            // Set up refresh button
            val refreshIntent = HomeWidgetPlugin.getRunnableIntent(
                context,
                "sanctuaryflow://refresh_verse"
            )
            views.setOnClickPendingIntent(R.id.widget_refresh_button, refreshIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

