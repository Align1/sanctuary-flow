package com.mycompany.sanctuaryflow

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class StreakWidgetProvider : AppWidgetProvider() {
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
            val views = RemoteViews(context.packageName, R.layout.streak_widget)

            // Get streak data from shared preferences
            val currentStreak = widgetData.getInt("widget_streak", 0)
            val longestStreak = widgetData.getInt("widget_longest_streak", 0)
            val hasReadToday = widgetData.getBoolean("widget_has_read_today", false)

            // Update the widget UI
            views.setTextViewText(R.id.widget_streak_count, currentStreak.toString())
            views.setTextViewText(R.id.widget_longest_streak, "Best: $longestStreak")
            
            // Update icon based on whether user has read today
            val iconResId = if (hasReadToday) R.drawable.ic_check_circle else R.drawable.ic_book_open
            views.setImageViewResource(R.id.widget_streak_icon, iconResId)

            // Set up click listener to open the app
            val intent = Intent(context, MainActivity::class.java)
            intent.putExtra("navigate_to", "bible_tracker")
            val pendingIntent = PendingIntent.getActivity(
                context,
                1,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_streak_container, pendingIntent)

            // Set up quick action buttons
            val prayerIntent = Intent(context, MainActivity::class.java)
            prayerIntent.putExtra("navigate_to", "prayer")
            val prayerPendingIntent = PendingIntent.getActivity(
                context,
                2,
                prayerIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_prayer_button, prayerPendingIntent)

            val readingIntent = Intent(context, MainActivity::class.java)
            readingIntent.putExtra("navigate_to", "reading_plans")
            val readingPendingIntent = PendingIntent.getActivity(
                context,
                3,
                readingIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_reading_button, readingPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

