# 源码包检查记录

检查范围：`lib/**/*.dart`、`test/**/*.dart`、提取的 FlClash 原版 UI Dart 文件、项目目录结构、Flutter import 引用与 GPL 许可证。

- 从用户上传的 FlClash ZIP 原样提取 UI 相关原始 Dart 文件共 **203** 个。
- 独立可运行区 `lib/` 仅导入 Flutter SDK 或包内 Dart 源文件；没有运行时引用 `package:fl_clash/` 或第三方代理依赖。
- 独立实现基础控件、主题、自定义 UI、JSON 配置表单与 Android 桥接接口，含启动 demo 与 widget 测试代码。
- 已完成静态检查：源文件存在性、本地 import 解析、括号与字符串结构配对、参考文件原始字节比对、ZIP 完整性。
- **尚未完成**：Flutter analyze/test/真机构建；当前生成环境没有 `flutter`/`dart` 命令，不能保证编译时无 SDK API 或渲染兼容问题。
- Java 示例依赖 Flutter Embedding，**不能在原生 Axon 源码里直接 javac 编译**；必须先调整 Android build 链。

---

## v2 GitHub Artifacts build additions (2026-10-27)

- GitHub Actions workflow `.github/workflows/build-apk.yml` provisions Java 17 and pinned Flutter 3.47.7, creates Android host, invokes analyzer and tests, builds Android ARM64 APK, verifies nonempty output and uploads Artifacts.
- Workflow accepts either extracted Flutter project or an `Axon_FlClash_*.zip` uploaded to repo root.
- Source reference snapshot excluded from Flutter analyzer to prevent unresolved FlClash-only dependencies.
- Added standalone Kotlin `MainActivity.kt` storing gallery settings via MethodChannel in separate SharedPreferences namespace; this is not the Axon main engine.
- Replaced Flutter deprecations in this codebase (ThemeData InputDecorationThemeData, Color.withValues/toARGB32, DropdownButtonFormField.initialValue).
- Added MethodChannel serialization test. Project Android scaffold will be generated on runner.
- **Not performed here:** Flutter compilation, Android Gradle build, full Axon host integration, Android device test. Those are CI/host verification tasks.
