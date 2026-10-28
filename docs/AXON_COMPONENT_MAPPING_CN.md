# Axon 现有控件与 Flutter 改造映射

核对基准：`Axon_BuildFix190_FlClashStyle_NativeUI_FullSource.zip` 内的 `app/src/main/java/com/axon/input/AxonFlClashKit.java`、`FlClashControlGalleryActivity.java`。Axon 原生 UI 仍保留，Flutter 组件是**并行实现**。

| 现有 Axon UI / 方法 | 新 Dart Widget | 实现状态 |
|---|---|---|
| `card` / `shape` / `touchBg` | `AxonCard` | 已实现：M3 表面、状态描边、水波纹 |
| `section` | `AxonSectionHeader` | 已实现：标题、描述、操作插槽 |
| `settingRow` | `AxonSettingTile` | 已实现：图标、标题、摘要、尾部控件 |
| `toggle` | `AxonSwitchTile` | 已实现：适配式开关 |
| `segments` | `AxonSegmentedControl` | 已实现：单选段控件 |
| `chip` | `AxonChipSelector` / `AxonTag` | 已实现：多选 Chips 与状态标签 |
| `slider` | `AxonSliderTile` | 已实现：数值、单位、离散刻度 |
| `button` | `AxonActionRow` | 已实现：主/次按钮 |
| `input` | `AxonTextInput` | 已实现：文本输入 |
| `metric` | `AxonMetricCard` | 已实现：数值指标 |
| `progress` | `AxonProgressCard` | 已实现：进度条与数值 |
| Axon 设置页的分组展开 | `AxonExpandableCard` | 已实现：动画展开 |
| Axon 配置与操作选择 | `showAxonSheet` | 已实现：底部弹层 |
| Axon 浮窗透明度参数 | `AxonOpacityTile` | 已实现：状态 UI；未连接真实浮窗 |
| Axon UI 系统主题 | `AxonColorModePicker` | 已实现：浅色/深色/系统 |
| Axon 主题配置 | `AxonColorGrid` | 已实现：主题种子色选择 |

## 新增的 FlClash 风格 Axon 专用控件

- `AxonKeyBindField`：实体键盘焦点内按键采集与键位名称展示；**不提供全局键盘监听或键盘猫模型控制**。
- `AxonVirtualPad`：触控方向键，回调留给 Axon 输入层。
- `AxonMappingCard`：触控、手柄、键鼠映射条目卡片。
- `AxonResponseCurve`：归一化控制点曲线的可视编辑器。
- `AxonReorderList`：拖拽重新排序的控件清单。
- `AxonNumberField`：数值加减步进器。
- `AxonDropdown`、`AxonSearchInput`：选项和搜索。
- `AxonModeCard`：大尺寸模式选择卡片。
- `AxonDynamicForm`、`AxonControlSpec`：基于 JSON 数据定义自动生成控件。
- `AxonMethodChannelStore`：为 Java 宿主准备的 MethodChannel 协议。

## 设计规则

- 默认统一 16–22 dp 圆角，避免多层重叠的厚重背景。
- Material 3 ColorScheme 根据主色生成亮暗主题，系统开启减少动画时禁用自定义动画。
- 在 780 dp 以上使用侧面 `NavigationRail`，以下使用底部导航。
- 关键交互控件保持接近或超过 44–48 dp 的触摸目标。
- 不自行读取 Axon 内核、注入器、OverlayState 私有字段，实际状态更新必须由宿主接口完成。
