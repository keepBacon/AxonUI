# AxonUI v5 · FlClash 风格控件完全重构

## 目标与边界

- 删除旧 `lib/src/*` UI 控件、旧 Demo 和旧式动态表单。
- 所有界面重新基于统一的 `Fl*` 控件系统：圆角分组面板、行内选项预览图、蓝色勾选、胶囊分段控件、统一底部弹窗、动态配色和过渡动画。
- 样式参考 FlClash 源码 `lib/views/theme.dart`、`lib/views/theme_preview.dart`、`lib/ui/theme.dart`，并结合用户提供截图重新实现。
- 纯 UI 层，不添加执行器、游戏逻辑、真实按键/手柄、触控注入或后台输入检测。

## 控件覆盖映射

| 旧 UI 元素 | v5 新 UI 组件 |
|---|---|
| AxonCard / SettingTile | FlPanel / FlGroup / FlSettingRow |
| AxonSwitchTile | FlToggleRow |
| AxonSegmentedControl | FlSegmented |
| AxonSliderTile / PrecisionSlider | FlSliderPanel / FlDiscreteScale |
| AxonDropdown / Search | flPick / TextField 搜索|
| AxonColorGrid | FlColorSwatches |
| AxonReorderList | FlReorderPanel |
| AxonPluginSchemaUi | FlSchemaPanel（仅界面状态）|
| 旧主题页 | FlThemeScreen |
| 旧控件画廊 | FlControlsScreen、FlProfilesScreen |
| 旧底栏 | FlNavigationShell（模糊、动效、浮动胶囊） |

## 动画

- 配色与主题切换：`AnimatedContainer` + `MaterialApp` 主题渐变。
- 选中状态：`AnimatedSwitcher` 的透明度和缩放变化。
- 分段控件：圆角高亮底色渐变，`easeOutCubic` 270ms。
- 页面过渡：水平轻滑 + 淡入/淡出；实时预览可切换滑动或淡入。
- 动画降低：尊重 `MediaQuery.disableAnimationsOf`。

## 构建验收

由 GitHub Actions 执行静态分析、Widget 测试和 Android ARM64 Release 打包。成功运行后提供 APK 和 SHA256 清单。CI 结果不得从文件存在推断为实际编译通过。

## 2026-10-31 · 四分页展示层补充

- 主页总览卡接收当前材质级别并显示主题亮度和真实分类/展示项计数；迷你预览可点击切换色彩状态。
- 分类入口增加按类别变化的小型键帽、手柄、开关、色板，而非重复右侧图标。
- 键显保留三级分类与原详情页，增加可点击键帽、模拟鼠标状态与 CPS 示例；不会监听真实设备按键。
- 插件页在操作台后加入本地多选、排序与模拟绑定操作，区分功能控件、调试缩略图及功能映射列表。
- 主页使用横向预览带、两列卡片与大面积交互卡形成不同尺寸的卡片节奏。
- 增加交互测试，修复 FlPressScale 导入和 public barrel 导出缺失。
- 本展示 APK 不等于 Axon-Input 的 UI 已被原地替换；仍需单独完成 Java/Flutter 宿主集成方案。

## 2026-10-31 Axon 源码映射 UI 扩展

映射源：keepBacon/Axon-Input 的 app/src/main/java/com/axon/input/，新增的控件仅为 Flutter UI。

| 源码 | 新组件 | 对应 UI 状态 |
|---|---|---|
| GamepadSettingsStore.java | FlAxonGamepadStudio | 四种兼容模式、AB/XY/摇杆/扳机交换、自定义交换 |
| TouchDisplayStore.java | FlAxonTouchStudio | 键鼠/手柄/触控模式、摇杆/LMB/RMB/空格四区域拖拽、尺寸 |
| SuperCustomControlSpec.java + KeyAppearance.java | FlAxonCustomStudio | 按键/文本/摇杆、形状、颜色、宽度、透明度、圆角 |
| FloatingMediaStore.java + FloatingVideoOverlayView.java | FlAxonMediaStudio | 多素材列表、循环/单次、色键抠像、透明度 |
| FeatureShortcutStore.java | FlAxonShortcutStudio | 快捷键配置和冲突提示 |
| SuperCustomConfigStore.java | FlAxonWorkspaceStudio | 5 个配置槽位、模拟保存/复制/清空 |

源码位于 lib/flclash/axon_source_studios.dart；由 lib/flclash_ui.dart 导出。页面入口在主页、键显和其他分页。没有修改 Android 输入、无障碍、鼠标/手柄注入、视频播放或用户原始配置，所有数据为内存演示。
