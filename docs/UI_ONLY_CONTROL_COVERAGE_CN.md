# Axon Input / FlClash Flutter UI 控件覆盖表（v3）

## 范围（重要）

**本工程仅构建 UI 组件及独立演示 APK**。不会修改 Axon Input 主程序，不增加输入注入、真实按键响应、键盘猫模型渲染、手柄事件采集、系统浮窗或 C++ 底层控制。所有键位、手柄、触控、输入映射、响应曲线均为**界面表单或预览**。Flutter 的设置演示数据与实际输入引擎状态不是同一个数据源。

## 基于真实 Axon 源码的核对范围

核对归档：`Axon_BuildFix190_FlClashStyle_NativeUI_FullSource.zip`。

### 1. AxonFlClashKit.java：原生 UI 工具集

| Java UI API | Flutter UI 对应 | 覆盖情况 |
|---|---|---|
| `dp`、`lp` | `MediaQuery`、`Padding`、`BoxConstraints` | Flutter 等效布局基础能力 |
| `shape`、`touchBg` | `AxonCard` + `Material`/`InkWell`/`BoxDecoration` | 已实现等效样式 |
| `column`、`row`、`text` | Flutter `Column`、`Row`、`Text` | Flutter 内置等效 |
| `section` | `AxonSectionHeader` | 已实现 |
| `card` | `AxonCard` | 已实现 |
| `settingRow` | `AxonSettingTile` | 已实现 |
| `divider` | Flutter `Divider` | 内置等效 |
| `toggle` | `AxonSwitchTile` | 已实现 |
| `segments` | `AxonSegmentedControl` | 已实现 |
| `chip` | `AxonTag`、`AxonChipSelector` | 已实现 |
| `slider` | `AxonSliderTile`、`AxonPrecisionSlider` | 已实现 |
| `button` | `AxonActionRow`、`AxonLoadingAction` | 已实现 |
| `input` | `AxonTextInput` | 已实现 |
| `metric` | `AxonMetricCard` | 已实现 |
| `progress` | `AxonProgressCard` | 已实现 |

### 2. PluginUiSpec.java：UI schema 协议

| 原生声明类型 | Flutter 动态控件 | 覆盖情况 |
|---|---|---|
| `feature.toggle` | `AxonPluginSchemaUi` / `AxonSwitchTile` | UI 实现 |
| `feature.button` | `AxonPluginSchemaUi` / `FilledButton` | UI 回调，不执行原生动作 |
| `debug.slider` | `AxonPrecisionSlider` | UI 实现 |
| `debug.number` | `AxonPrecisionSlider`（数字输入+步进） | UI 实现 |
| `debug.color` | `AxonArgbEditor` | UI 实现 |
| `debug.select` | `AxonDropdown` | UI 实现 |
| `debug.text` | `TextFormField` | UI 实现 |
| `debug.key` | `AxonKeyCodeInput` | 仅输入码编辑 UI |
| `debug.toggle` | `AxonSwitchTile` | UI 实现 |
| `debug.list` | `AxonPluginListEditor` | 嵌套编辑、增删、拖拽 |
| `debug.binding` | `AxonBindingEditor` | 仅映射参数/区域编辑 UI |

### 3. 新增通用 UI 组件（v3）

- `AxonCheckboxTile`：复选框设置行。
- `AxonRadioChoiceGroup<T>`：单选设置组。
- `AxonStepperField`：整数步进器。
- `AxonOptionGrid<T>`：响应式网格单选。
- `AxonSearchPicker<T>`：带搜索的底部弹出选择器。
- `AxonMultiSelectChips<T>`：多选项 Chips。
- `AxonInfoBanner`：信息、成功、警告、错误状态条。
- `AxonEmptyState`：空状态/无结果占位。
- `AxonAnimatedTabStrip`：可横向滚动的动画选项卡。
- `AxonLoadingAction`：显示忙碌状态的操作按钮。
- `AxonLabeledValue`：参数名称/值展示。
- `AxonUiExtrasGallery`：上述控件的可交互演示页面。

### 4. 其他已实现的 UI 层控件

- 输入映射参数面板、虚拟方向键图形按钮、触控区域拖拽编辑器、响应曲线编辑器。
- ARGB 多颜色/渐变编辑、范围滑块、日志区域、重排列表、预设卡片、状态标签、折线图。
- Material 3 亮暗主题、种子色、卡片、弹出菜单、折叠项与适配窄屏布局。

## 结论与未覆盖项

**已覆盖：** `AxonFlClashKit.java` 所列 UI API 的控件类型或 Flutter 等效布局，以及 `PluginUiSpec.java` 的 2 种 feature 和 9 种 debug 字段类型。各组件可在 APK 页面独立预览。

**不能宣称覆盖：** Axon Input 所有 Activity 的真实业务流程、所有 Java/C++ 内核接口、实机输入事件、第三方插件所有视觉组合、实际悬浮键盘猫/手柄模型。要替换 Axon 主程序 UI，需要进行宿主集成和实机验收；本轮明确不进行此类工作。

**验证状态：** 代码目录、导入关系、语法括号结构、工作流与 ZIP 完整性可在当前环境检查；Flutter SDK 未安装，真实编译 / 渲染 / APK 测试必须由 GitHub Actions 执行。CI 已配置 `flutter analyze`、`flutter test`，只有成功才会构建并上传 APK。
