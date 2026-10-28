# GitHub Actions → Artifacts 构建 APK（适合手机操作）

## 一、完整源码上传（推荐）

将 `axon_flclash_flutter/` **内部文件**上传到 GitHub 仓库根目录，确保仓库顶层有：

- `pubspec.yaml`
- `lib/main.dart`
- `scripts/prepare_android.sh`
- `.github/workflows/build-apk.yml`

进入 GitHub → Actions → **Axon FlClash Flutter APK** → **Run workflow**。

## 二、只有 ZIP 文件时（更适合 GitHub 网页上传）

1. 把 `Axon_FlClash_Flutter_UI_GitHub_Artifacts_v2.zip` 原封不动上传到仓库根目录。注意仓库根目录尽量只留这一个 `Axon_FlClash_*.zip`。
2. 在仓库创建 `.github/workflows/build-apk.yml`，内容复制本包中的同名工作流（也会额外单独提供该文件）。
3. 在 GitHub Actions 里点击 `Axon FlClash Flutter APK`，选择 `Run workflow`。
4. 待 Workflow 完成后，进入本次运行详情页的 **Artifacts**，下载 `Axon-FlClash-UI-Android-ARM64-<序号>`，解压后获得 `Axon-FlClash-UI-arm64-v2.apk` 和 `SHA256SUMS.txt`。

**无需在 Android 手机上安装 Flutter。** ZIP 原样上传方式需要额外提供一份 `.github/workflows/build-apk.yml`，因为 GitHub 不会自动执行压缩包内部的 Workflow 文件。

## 构建说明

- Flutter：固定稳定版本 `3.47.7`；Java：Temurin 17；构建系统由 Flutter SDK 在 CI 自动生成。
- 默认仅构建 **Android ARM64**，适配主流 64 位 Android 手机。`release` 不等同 Play Store 正式签名发布。
- APK 是独立的 **Axon UI 控件演示程序**，不是已经集成完整输入引擎的 Axon 主程序。
- `MainActivity.kt` 仅将 UI 演示版设置保存在独立命名空间 `axon_flclash_ui_demo`；不会修改 Axon 正式配置。
- 工作流会执行 Flutter analyze / widget tests，若失败则停止构建并尽可能上传日志；未在当前环境真实运行 CI。
- `flclash_original_ui_reference/` 仅用于研究，**不参与编译**；它是受 GNU GPL v3 约束的上游源码快照。

## 常见故障

- `No Flutter pubspec.yaml`：ZIP 打包层级异常或放错位置。
- `More than one Axon_FlClash_*.zip`：删除旧包，只保留一个源码包。
- `flutter analyze` / `flutter test` 失败：在该次 Actions 页面下载 `Axon-FlClash-build-logs` 并检查具体报错。
- `No artifacts`：只要编译没完成就没有 APK；先打开运行详情查看红色步骤。
- `Java/Gradle` 问题：不要手工替换生成的 Gradle 文件；保留 Workflows 固定的 Flutter 与 Java 版本。
