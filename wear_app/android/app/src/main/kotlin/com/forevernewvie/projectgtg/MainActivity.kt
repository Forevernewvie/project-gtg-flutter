package com.forevernewvie.projectgtg

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var isFlutterUiDisplayed = false

    override fun onCreate(savedInstanceState: Bundle?) {
        // Handle the splash screen transition and keep it visible with the 48x48dp icon
        // until Flutter actually renders its first frame on screen.
        val splashScreen = installSplashScreen()
        splashScreen.setKeepOnScreenCondition {
            !isFlutterUiDisplayed
        }
        super.onCreate(savedInstanceState)
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        isFlutterUiDisplayed = true
    }
}
