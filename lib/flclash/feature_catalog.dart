import 'package:flutter/material.dart';

/// Read-only feature catalogue transcribed from the source UI declarations:
/// MainActivity.java, SuperCustomControlSpec.java, GamepadSettingsStore.java,
/// PressAnimationConfig.java and PluginUiSpec.java (BuildFix190).
/// No original Java/C++ implementation is included in this Flutter preview.
enum PreviewKind {
  controls, slider, color, animation, gradient, material,
  typography, spacing, press, layers, sequence, textEffects,
  settings, options, listEditor, layout, media, plugin, source,
}
class PreviewFeature {
  const PreviewFeature(this.title, this.kind);
  final String title;
  final PreviewKind kind;
}
class PreviewGroup {
  const PreviewGroup(this.title, this.icon, this.features);
  final String title;
  final IconData icon;
  final List<PreviewFeature> features;
}
List<PreviewFeature> _f(String value) => value.split(';').map((entry) {
  final a=entry.trim().split('|');
  return PreviewFeature(a[0], PreviewKind.values.byName(a[1]));
}).toList(growable:false);
PreviewGroup _g(String title, IconData icon, String items)=>
  PreviewGroup(title,icon,_f(items));

abstract final class PreviewCatalog {
  static final keyboard=<PreviewGroup>[
    _g('键盘与鼠标',Icons.keyboard_outlined,
      '常规按显|source;输入时显示全键盘|source;鼠标按显|source;键盘猫显示|source;最近按键|source;鼠标轨迹|source;自定义鼠标指针|source'),
    _g('外观调试',Icons.palette_outlined,
      '颜色调试|color;透明度调试|layers;按压动画调试|press;键位间距|spacing;键盘猫模型调试|source'),
  ];
  static final gamepad=<PreviewGroup>[
    _g('游戏手柄',Icons.sports_esports_outlined,
      '左摇杆|source;右摇杆|source;ABXY 按键|source;十字键显示|source;左肩键|source;右肩键|source;背键显示|source'),
    _g('手柄设置',Icons.tune_outlined,
      '兼容模式|source;独立按键交换|source'),
  ];
  static final custom=<PreviewGroup>[
    _g('超级自定义按显',Icons.dashboard_customize_outlined,
      '自定义控件|source;按键控件|source;文本控件|source;摇杆控件|source'),
    _g('颜色与材质',Icons.palette_outlined,
      '颜色调试|color;图层颜色调试|layers;多色序列调试|sequence;渐变调试|gradient;文字描边调试|textEffects;透明度调试|material'),
    _g('动画与布局',Icons.animation_outlined,
      '按压动画调试|press;控件位置与尺寸|source;排版调试|typography;圆角与边框|material'),
  ];
  static final plugins=<PreviewGroup>[
    _g('插件管理',Icons.extension_outlined,
      '插件列表|source;插件详情|source;插件 UI 配置|source'),
    _g('功能入口',Icons.widgets_outlined,
      '功能开关|source;功能按钮|source'),
    _g('调试字段',Icons.tune_outlined,
      '滑块|source;颜色|source;单选|source;数值|source;文本|source;键位|source;开关|source;列表|source;绑定|source'),
  ];
  static final others=<PreviewGroup>[
    _g('显示行为',Icons.settings_outlined,
      'CPS 显示|source;自由拖动悬浮组件|source;隐藏按显快捷键|source;自动隐藏|source;修改字体|source'),
    _g('输入增强 · 参数展示',Icons.tune_outlined,
      '灵敏度倍率|source;同时点击|source;强制长按|source'),
    _g('模型与插件显示',Icons.view_in_ar_outlined,
      'Live2D|source;Live2D 模型调试|source;Web 插件显示|source'),
    _g('外观',Icons.palette_outlined,
      '颜色调试|color;动画调试|animation;材质调试|material;文字效果调试|textEffects'),
  ];
}
