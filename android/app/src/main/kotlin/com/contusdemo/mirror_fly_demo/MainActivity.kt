package com.contusdemo.mirror_fly_demo

import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.Build.VERSION.SDK_INT
import android.os.Bundle
import android.util.Log
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister


class MainActivity : FlutterActivity() {
    //protected val stickyService: Intent by lazy { Intent(this, AndroidPlugin::class.java) }
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        // Handle the splash screen transition.
        val splashScreen = installSplashScreen()
//        if (SDK_INT >= Build.VERSION_CODES.S) {
//            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
//        }

        super.onCreate(savedInstanceState)
    }

    @Override
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    }
}
