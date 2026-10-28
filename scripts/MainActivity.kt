package com.axon.axon_flclash_flutter

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Standalone preview persistence: keys belong to the isolated demo namespace.
 * Does not modify settings or control engine in the real Axon application.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.axon.input/flutter_ui"
    private val prefsName = "axon_flclash_ui_demo"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "load" -> {
                        // StandardMessageCodec accepts Double, but not native Float.
                        val safe = prefs.all.mapValues { (_, v) ->
                            if (v is Float) v.toDouble() else v
                        }
                        result.success(safe)
                    }
                    "set" -> {
                        val key = call.argument<String>("key")
                        if (key.isNullOrEmpty() ||
                            !Regex("[A-Za-z0-9_.-]{1,64}").matches(key)) {
                            result.error("BAD_KEY", "Invalid setting key", null)
                            return@setMethodCallHandler
                        }
                        val value = call.argument<Any?>("value")
                        val edit = prefs.edit()
                        when (value) {
                            null -> edit.remove(key)
                            is Boolean -> edit.putBoolean(key, value)
                            is Int -> edit.putInt(key, value)
                            is Long -> edit.putLong(key, value)
                            is Double -> edit.putFloat(key, value.toFloat())
                            is String -> edit.putString(key, value)
                            else -> {
                                result.error("BAD_VALUE", "Unsupported setting value", null)
                                return@setMethodCallHandler
                            }
                        }
                        edit.apply()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
