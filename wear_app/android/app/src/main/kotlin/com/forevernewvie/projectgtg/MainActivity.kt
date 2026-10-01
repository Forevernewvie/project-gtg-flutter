package com.forevernewvie.projectgtg

import android.os.Bundle
import android.os.SystemClock
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var isFlutterUiDisplayed = false
    private var splashStartTime = 0L

    override fun onCreate(savedInstanceState: Bundle?) {
        // Handle the splash screen transition and keep it visible with the 48x48dp icon
        // until Flutter actually renders its first frame on screen (capped at 4s for ANR safety).
        val splashScreen = installSplashScreen()
        splashStartTime = SystemClock.elapsedRealtime()
        splashScreen.setKeepOnScreenCondition {
            !isFlutterUiDisplayed && (SystemClock.elapsedRealtime() - splashStartTime < 4000L)
        }
        super.onCreate(savedInstanceState)
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        isFlutterUiDisplayed = true
    }
}
