# 与 Axon Android Java 项目对接

## A. 建议先完成独立验收

在独立 Flutter 项目目录运行 `flutter create --platforms=android .` 和 `flutter run`。体验页面：总览 / 基础控件 / 输入映射 / 外观与布局。此路径没有任何 Axon 原生运行时依赖。

## B. Android 嵌入注意事项

Axon 当前源代码是 Java Android 应用，不是 Flutter 应用，且采用自身构建方式。**仅复制 `lib/` 不会覆盖 Axon 的原生界面**；需要接入 Flutter Engine、Android Embedding 和 Gradle/构建依赖，检查 App 的启动与内存占用，然后才能将部分设置页切换到 Flutter。

可参考 Flutter 官方 Add-to-App（Android）的 Module 集成文档：<https://docs.flutter.dev/add-to-app/android/project-setup>。

高层步骤：

1. 用 Flutter CLI 创建 `--template module` 项目，并将本包 `lib/`、`pubspec.yaml`、`analysis_options.yaml` 以及测试文件复制到 Module；运行 `flutter pub get`。不要复制 `flclash_original_ui_reference/` 到 `lib/`。
2. 调整 Axon 的 Android 构建系统，引入 Flutter Module AAR/源码模块的嵌入依赖。若项目没有兼容的 Gradle 流程，先升级构建流程；不能指望单纯 javac 就能打包 Flutter Engine。
3. 只有在 Flutter Embedding 已就位后，才把 `android_integration/AxonFlutterGalleryActivity.java` 放入 `app/src/main/java/com/axon/input/` 并合并 Manifest Activity 条目。
4. 从 Axon 需要的新入口启动该 Activity，例如 `startActivity(new Intent(this, AxonFlutterGalleryActivity.class));`。
5. Dart 端使用 `AxonDemoApp(store: const AxonMethodChannelStore())` 而非默认内存存储；Java 端演示实现使用独立 SharedPreferences，仅作通信演示，不会修改 Axon 真正的设置。
6. 将 Java `load` / `set` 手动映射到 Axon 合法设置接口，按 key 白名单、类型、范围完成校验；保留原生输入执行层及资源销毁流程。

## MethodChannel 协议

```
Channel: com.axon.input/flutter_ui

load() -> Map<String, dynamic>  // 读取设置
set({key: String, value: primitive}) -> void // 单项修改
```

Java 宿主完整演示代码在 `android_integration/AxonFlutterGalleryActivity.java`。它只存取独立 demo 配置，提供构建接入后的双向通道样例。实时事件回传、原生重启、插件设置与输入设备捕获都需要后续专门接入，不应宣称当前已完成。

## JSON 驱动的控件示例

```dart
final specs = <AxonControlSpec>[
  AxonControlSpec(id: 'touch', label: '触控映射', type: 'toggle'),
  AxonControlSpec(id: 'pointer_speed', label: '鼠标速度',
    type: 'slider', min: 0, max: 100),
  AxonControlSpec(id: 'mode', label: '输入模式',
    type: 'choice', options: ['普通', '兼容', '性能']),
  AxonControlSpec(id: 'profile_name', label: '配置名称', type: 'text'),
];

AxonDynamicForm(
  controls: specs,
  values: stateValues,
  onChanged: (id, newValue) {
    setState(() => stateValues[id] = newValue);
    store.setValue(id, newValue);
  },
);
```

## 性能与维护

- 在同一个 Java Activity 中运行 Flutter Engine 会增加启动时间与内存占用；不要把 Flutter 页面放进所有全局悬浮覆盖窗口。
- Flutter 构建平台代码必须使用官方 SDK 生成，不能直接与现有 Java 编译链混合而声称可编译。
- 优先迁移配置页、控件库与编辑器；保持时间敏感的键鼠、游戏手柄绘制与事件注入在当前原生层。
