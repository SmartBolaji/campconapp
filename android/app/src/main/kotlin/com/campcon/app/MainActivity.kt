package com.campcon.app

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.campcon.app/android_version"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        .setMethodCallHandler { call, result ->
          when (call.method) {
            "getSdkVersion" -> {
              result.success(Build.VERSION.SDK_INT)
            }
            else -> {
              result.notImplemented()
            }
          }
        }
  }
}

