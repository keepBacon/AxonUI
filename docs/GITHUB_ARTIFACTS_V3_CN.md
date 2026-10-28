# GitHub Artifacts：Axon UI-only v3 Android APK

不需要在安卓端安装 Flutter 或 Android Studio。

## 方式 A：上传 v3 源码 ZIP（最便捷）

1. 在 GitHub 仓库根目录上传 `Axon_FlClash_Flutter_UI_Only_v3.zip`，**不能只上传旧版 v2**。
2. 在仓库 `.github/workflows/build-apk.yml` 新建或覆盖构建工作流（工作流文件单独提供）。
3. 打开 GitHub 仓库 Actions → `Axon FlClash UI-only APK` → `Run workflow`。
4. 构建后在该次运行的 **Artifacts** 下载 `Axon-FlClash-UI-only-ARM64-<run_number>`。
5. 解压获得 `Axon-FlClash-UI-only-arm64-v3.apk` 和 `SHA256SUMS.txt`。

## 方式 B：上传解压后的工程

把 ZIP 内的 `axon_flclash_flutter` 整个文件夹放在仓库根目录；工作流会自动寻找该目录。亦可把其内部文件直接放在仓库根目录。

## 编译流程

- Ubuntu Runner / Java 17 / Flutter 3.47.7 stable。
- `flutter create --platforms=android` 自动生成 Android 工程。
- `scripts/prepare_android.sh` 仅为独立演示 APK 加入历史版本的**本地设置保存**（不控制任何真实输入）。
- `flutter analyze --no-fatal-infos`、`flutter test`、`flutter build apk --release --target-platform android-arm64`。
- 成功后上传 GitHub Artifacts；失败则上传运行日志。

## 说明

- 本 APK 是独立 UI Gallery，不是替换 Axon 主程序的安装包。
- UI 动态控件与 FlClash 原始参考源码是分开的；参考源码没有接入 Flutter 编译依赖。
- 如需实际覆盖 Axon 主程序 UI，要进行另外的 Java/Flutter 混合集成，这不属于本轮范围。
