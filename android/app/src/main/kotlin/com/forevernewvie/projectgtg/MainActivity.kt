package com.forevernewvie.projectgtg

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private companion object {
        const val BUILD_INFO_CHANNEL = "project_gtg/app_build_info"
        const val GET_BUILD_INFO_METHOD = "getBuildInfo"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.enableEdgeToEdge(window)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BUILD_INFO_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != GET_BUILD_INFO_METHOD) {
                result.notImplemented()
                return@setMethodCallHandler
            }

            try {
                val packageInfo = packageManager.getPackageInfo(packageName, 0)
                result.success(
                    mapOf(
                        "versionName" to (packageInfo.versionName ?: ""),
                        "versionCode" to packageInfo.longVersionCode.toInt(),
                        "packageName" to packageName,
                    ),
                )
            } catch (error: Exception) {
                result.error(
                    "build_info_error",
                    error.message,
                    null,
                )
            }
        }
    }
}
