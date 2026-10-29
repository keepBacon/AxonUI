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
