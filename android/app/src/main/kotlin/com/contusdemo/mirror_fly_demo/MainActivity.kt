package com.contusdemo.mirror_fly_demo

import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.Build.VERSION.SDK_INT
import android.os.Bundle
import android.util.Log
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister


class MainActivity : FlutterActivity() {
    //protected val stickyService: Intent by lazy { Intent(this, AndroidPlugin::class.java) }
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)

        if (SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }

        super.onCreate(savedInstanceState)
    }

    @Override
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine)
        FlyBaseController(this).init(flutterEngine,intent);
        FlyBaseController(this).onResume()
        //startService(stickyService)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        FlyBaseController(this).onActivityResult(requestCode, resultCode, data)
    }

    override fun onResume() {
        super.onResume()
//        FlyBaseController(this).onResume()
    }
    override fun onDestroy() {
        super.onDestroy()
        FlyBaseController(this).onDestroy()
        //stopService(stickyService)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("newIntent",intent.toString())
        Log.d("newIntent from",intent.getBooleanExtra("from_notification",false).toString())
        Log.d("newIntent jid",intent.getStringExtra("jid").toString())
    }

}
