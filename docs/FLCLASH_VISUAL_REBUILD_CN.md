# FlClash 视觉重构 v4（纯 UI）

参考用户提供的 FlClash「主题」页面截图，以及 FlClash 源码 `lib/views/theme.dart` 和 `lib/views/theme_preview.dart` 的视觉与交互结构。实现为独立 Dart/Flutter Widget，不依赖 FlClash 的代理服务、Riverpod 或 Rust/Mihomo。

## 核心组件
- `FlSectionHeader`：带图标的分组标题；灰色背景和留白等级。
- `FlCard`：无描边的大圆角分组容器。
- `FlChoiceGroup<T>`、`FlChoice<T>`：条目式单选分组、细分隔线、动态蓝色勾号、按压反馈。
- `FlMiniScreen`：使用 Canvas 绘制响应式微型界面，而非空白占位图。
- `FlPillSegmented`：蓝色胶囊单选分段控件、文本状态过渡。
- `FlDiscreteScale`：刻度点、进度轨道及可拖动指示器。
- `FlClashThemeGallery`：整页可运行主题设置（底栏、选项卡动画、玻璃、配色、字体、缩放、动态演示）。

页面之间滑动/淡入过渡使用 `PageRouteBuilder` / `AnimatedSwitcher`，选中状态使用 `AnimatedSwitcher`、`AnimatedContainer`、`AnimatedDefaultTextStyle`。遵循系统 `disableAnimations`。

## 使用与限制
默认 APK 首页为 FlClash 风格主题页。右上角「控件」图标进入保留的 Axon 组件全览。所有 Axon 原 UI 组件仍在 `lib/src/`；Flutter/Dart UI 仅编辑演示状态和视觉配置。不包含按键注入、手柄驱动、系统 Hook 等功能。原生设置 Bridge 仅持久化外观参数，不能作为已接入 Axon 主程序 UI 的证明。

运行 GitHub Actions `.github/workflows/build-apk.yml` 即可构建并以 Artifacts 下载 ARM64 APK。
