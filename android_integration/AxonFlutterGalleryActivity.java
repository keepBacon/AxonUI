package com.axon.input;

import android.content.SharedPreferences;
import android.os.Bundle;
import androidx.annotation.NonNull;
import java.util.HashMap;
import java.util.Map;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * OPTIONAL Flutter-host example for Axon. This class requires the Flutter
 * embedding runtime to be included in Axon's Android build first.
 *
 * It stores only a separate demo namespace. Connect Axon settings explicitly
 * and with type/key validation before shipping this page as a real editor.
 */
public final class AxonFlutterGalleryActivity extends FlutterActivity {
    private static final String CHANNEL = "com.axon.input/flutter_ui";
    private static final String PREFS = "axon_flutter_ui_demo";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine engine) {
        super.configureFlutterEngine(engine);
        SharedPreferences prefs = getSharedPreferences(PREFS, MODE_PRIVATE);
        new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if ("load".equals(call.method)) {
                        result.success(new HashMap<>(prefs.getAll()));
                        return;
                    }
                    if (!"set".equals(call.method)) {
                        result.notImplemented();
                        return;
                    }
                    String key = call.argument("key");
                    Object value = call.argument("value");
                    if (key == null || !key.matches("[a-zA-Z0-9_.-]{1,64}")) {
                        result.error("BAD_KEY", "Invalid setting key", null);
                        return;
                    }
                    SharedPreferences.Editor editor = prefs.edit();
                    if (value == null) {
                        editor.remove(key);
                    } else if (value instanceof Boolean) {
                        editor.putBoolean(key, (Boolean) value);
                    } else if (value instanceof Integer) {
                        editor.putInt(key, (Integer) value);
                    } else if (value instanceof Long) {
                        editor.putLong(key, (Long) value);
                    } else if (value instanceof Double) {
                        editor.putFloat(key, ((Double) value).floatValue());
                    } else if (value instanceof String) {
                        editor.putString(key, (String) value);
                    } else {
                        result.error("BAD_VALUE", "Unsupported value type", null);
                        return;
                    }
                    editor.apply();
                    result.success(null);
                });
    }
}
