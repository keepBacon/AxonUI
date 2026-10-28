# Axon × FlClash · 纯 Flutter/Dart UI 控件库 v3

**本轮仅扩充 UI：不增加真实按键、手柄、触控注入、驱动或原生输入逻辑。**

主要资料：
- `docs/UI_ONLY_CONTROL_COVERAGE_CN.md`：Axon 本地源码的控件覆盖矩阵。
- `docs/GITHUB_ARTIFACTS_V3_CN.md`：Github Actions/Artifacts 构建与下载。
- `lib/src/ui_extras.dart`：v3 的通用 UI-only 控件。
- `lib/src/coverage_gallery.dart`：插件协议、外观、映射 UI、配置与通用控件实验室。
- `lib/src/ui_extras_gallery.dart`：新增 UI 控件的实际交互预览。

## 使用方式

```sh
flutter create --platforms=android --project-name axon_flclash_flutter .
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release --target-platform android-arm64
```

Android 平台目录由 CI 生成。完整工作流在 `.github/workflows/build-apk.yml`。

**不要把独立 UI Gallery 当作已经替换 Axon Input 的安装包。** GitHub Artifacts 上传的是本项目的演示 APK。

---

> GitHub Actions / Artifacts 打包：请先阅读 [`docs/GITHUB_ARTIFACTS_CN.md`](docs/GITHUB_ARTIFACTS_CN.md)。本版支持源码或压缩包方式触发构建，并新增 Android 原生持久化桥接。

# Axon × FlClash UI — Flutter / Dart 源码包

基于用户提供的 `FlClash-main.zip` 进行 UI 源码分离，并根据 Axon 当前的原生 Java 控件结构，独立开发了可使用的 Flutter Material 3 UI 控件库与交互式演示程序。

**交付的是 Dart/Flutter 源码和 GitHub Artifacts APK 构建工作流，不是 HTML 页面，也不是已经替换 Axon APK UI 的补丁。** 当前 Axon 主要采用 Java 原生 UI，Flutter 的 Android Embedding 需要新增引擎依赖和 Activity 才能接入。此项目可单独运行，可以作为未来 Axon Flutter 化 UI 的基础；键盘猫、真实手柄输入、驱动、Shizuku、覆盖层均未做未经验证的移植。

## 目录

```
axon_flclash_flutter/
├── lib/
│   ├── main.dart                 # 可交互演示 app
│   ├── axon_flclash_ui.dart      # 公共导出入口
│   └── src/
│       ├── theme.dart            # Material 3、亮暗主题、动效时长
│       ├── common.dart           # 通用卡片、指标、分组、展开面板
│       ├── controls.dart         # Axon 现有基础控件的 Dart 实现
│       ├── axon_controls.dart    # Axon 场景特色控件
│       ├── bridge.dart           # 状态模型与 Java MethodChannel 协议
│       └── dynamic_form.dart     # 按 JSON 描述动态生成表单
├── test/widget_test.dart
├── android_integration/        # 独立的 Java Host Activity 示例，不自动合并
├── flclash_original_ui_reference/
│   ├── lib/ui/                 # 原始 FlClash UI 实现（参考）
│   ├── lib/widgets/            # 原始 FlClash 控件实现（参考）
│   ├── lib/features/form/      # 原始 FlClash 表单实现（参考）
│   ├── lib/views/              # 原始 FlClash 视图（参考）
│   ├── lib/pages/              # 原始 FlClash 页面（参考）
│   └── LICENSE                 # FlClash GPL-3.0 原文
└── docs/
    ├── AXON_COMPONENT_MAPPING_CN.md
    ├── INTEGRATION_CN.md
    └── EXTRACTION_MANIFEST.md
```

## 单独运行（推荐先演示验收）

环境：安装 Flutter stable（建议 Flutter 3.29+）与 Android SDK，确保 `flutter doctor` 没有 Android 相关错误。

```sh
cd axon_flclash_flutter
flutter create --platforms=android --project-name axon_flclash_flutter .
flutter pub get
flutter analyze
flutter test
flutter run
```

`flutter create` 会自动生成平台构建脚手架（此压缩包不带 SDK 生成的 `android/` 目录）。如果要构建 APK：

```sh
flutter build apk --release
```

APK 一般生成于 `build/app/outputs/flutter-apk/app-release.apk`。

> 本环境未安装 Flutter/Dart SDK，未执行真实 `flutter analyze`、`flutter test` 或 APK 构建；请在 Flutter 环境中执行上述命令。源文件已执行基本静态结构与引用检查。不要将静态检查误认为编译通过。

## 为什么原始 UI 不直接放入可执行 lib？

上传的 FlClash 是 GPL-3.0 项目，它的 UI 源码不只依赖 Flutter，还引用 FlClash 内部状态管理、`material_ui`、`fl_clash/*`、图标体系及构建生成文件；整个 `lib/ui/` 复制到 Axon 里**不能独立运行**。

因此交付采用两层：

1. **源码提取层**：`flclash_original_ui_reference/` 保留上传版本的原始 Dart 文件，方便对照 `theme.dart`、`card.dart`、`segmented_control.dart`、`sheet.dart`、`motion.dart` 等结构。未经改动的原始内容遵循上游 GPL-3.0。
2. **独立实现层**：`lib/` 是新编写的 Flutter 控件库，只依赖 Flutter SDK，不依赖 VPN 核心 / FlClash 全局变量 / 原生代理服务。

## 使用范例

```dart
import 'package:flutter/material.dart';
import 'package:axon_flclash_flutter/axon_flclash_ui.dart';

// 例如在 StatefulWidget.build 中：
AxonCard(child: Column(children: [
  AxonSwitchTile(title: '触控映射', value: enabled,
    onChanged: (v) => setState(() => enabled = v)),
  AxonSliderTile(title: '灵敏度', value: sensitivity,
    min: 0, max: 100, suffix: '%',
    onChanged: (v) => setState(() => sensitivity = v)),
]));
```

表单可以通过 `AxonControlSpec.fromJson` 将 Axon 端的控件描述转换成 Flutter Widgets，具体见 `docs/INTEGRATION_CN.md`。

## License / Attribution

- 原始代码与来源：FlClash <https://github.com/chen08209/FlClash>，用户提供的源代码快照；上传文件 `FlClash-main.zip`。
- `flclash_original_ui_reference/**` 包含 FlClash 的部分原始源码，在原项目 GNU GPL v3 条款下分发。
- 为避免混合项目造成授权混淆，本次整个发布包统一提供 GNU GPL v3 许可证文本（项目根目录 `LICENSE`）。请保留上游版权声明与源码提供义务。
- `Axon` 来源为用户此前上传的 Axon 源码，参考了 `AxonFlClashKit.java` 的组件类别及项目 UI 结构；本次包中没有复制 Axon 的 Java 实现。
- UI 演示中的状态 / 延迟 / 完成度都是演示数据，不能用来证明实际输入性能。

## v2 — GitHub Artifacts APK

- Workflow: `.github/workflows/build-apk.yml`
- Android native preview bridge: `scripts/MainActivity.kt` + `scripts/prepare_android.sh`
- Android UI settings survive gallery relaunch via SharedPreferences (standalone package namespace).
- No real input injection is executed by the preview app.
- Supported test target: Android ARM64 (Flutter 3.47.7, Java 17).
