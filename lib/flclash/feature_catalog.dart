import 'package:flutter/material.dart';

/// Only UI metadata extracted from the reference application's feature families.
/// This preview neither reads hardware nor imports runtime implementations.
enum PreviewKind {
  controls, slider, color, animation, gradient, material,
  typography, spacing, press, layers, sequence, textEffects,
  settings, options, listEditor, layout, media, plugin,
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
List<PreviewFeature> _f(String values) => values.split(';').map((entry) {
  final pair = entry.trim().split('|');
  return PreviewFeature(pair[0], PreviewKind.values.byName(pair[1]));
}).toList(growable:false);
PreviewGroup _g(String name, IconData icon, String entries) =>
  PreviewGroup(name, icon, _f(entries));

abstract final class PreviewCatalog {
  static final keyboard = <PreviewGroup>[
    _g('键盘显示', Icons.keyboard_outlined,
      '全键盘布局|layout;单键外观|material;键帽颜色|layers;按下颜色|layers;按键透明度|slider;按键状态动画|press;键帽间距|spacing;布局排列|layout;按键显示统计|settings;CPS 显示样式|typography'),
    _g('鼠标显示', Icons.mouse_outlined,
      '鼠标按键|controls;鼠标轨迹|animation;鼠标光标|media;光标主题|color;鼠标灵敏度|slider;轨迹颜色|sequence;轨迹长度|slider;鼠标按键动画|press'),
    _g('动画模型', Icons.pets_outlined,
      '键盘猫外观|media;手部动作预览|animation;模型布局|layout;模型透明度|slider;模型背景|media;模型动画速度|animation;Live2D 模型|media;Live2D 物理效果|animation'),
  ];
  static final gamepad = <PreviewGroup>[
    _g('手柄外观', Icons.sports_esports_outlined,
      '手柄主题|color;手柄布局|layout;按键外观|material;按键颜色|layers;按钮按压动画|press;摇杆显示样式|material;摇杆回弹动画|animation;扳机进度样式|slider;肩键显示效果|controls;状态信息卡|settings'),
    _g('布局与配置', Icons.tune_outlined,
      '兼容模式|options;AB 按键交换|options;XY 按键交换|options;左右摇杆交换|options;扳机交换|options;自定义按钮顺序|listEditor;手柄灵敏度|slider;按键显示统计|settings'),
  ];
  static final custom = <PreviewGroup>[
    _g('控件构成', Icons.dashboard_customize_outlined,
      '自定义控件列表|listEditor;按键控件|controls;文本控件|typography;摇杆控件外观|material;控件位置与大小|layout;图层顺序|listEditor;复制与删除|listEditor;对齐与间距|spacing'),
    _g('颜色与材质', Icons.palette_outlined,
      '颜色调试|color;图层颜色调试|layers;渐变调试|gradient;多色序列调试|sequence;背景渐变|gradient;文字渐变|gradient;边框渐变|gradient;材质调试|material;透明度与模糊|material'),
    _g('动画与文字', Icons.animation_outlined,
      '动画调试|animation;按压反馈调试|press;文字效果调试|textEffects;排版调试|typography;间距调试|spacing;图片字体|media;CPS 文本占位符|typography;控件动画曲线|animation'),
  ];
  static final plugins = <PreviewGroup>[
    _g('插件管理', Icons.extension_outlined,
      '插件列表|listEditor;插件详情|plugin;插件开关|settings;插件权限|options;插件分组|listEditor;插件版本|plugin;运行状态卡|settings;插件日志界面|listEditor'),
    _g('插件配置控件', Icons.tune_outlined,
      '开关|settings;按钮|controls;数值滑块|slider;颜色选择|color;单选列表|options;数值步进|controls;文本输入|typography;键位字段|settings;动态列表|listEditor;组合绑定字段|settings'),
    _g('插件界面', Icons.web_asset_outlined,
      '卡片布局|layout;悬浮窗口外观|material;面板透明度|slider;排序动画|animation;自定义图标|media;状态统计展示|settings'),
  ];
  static final others = <PreviewGroup>[
    _g('外观与动效', Icons.palette_outlined,
      '主题预览|color;液态玻璃|material;动画调试|animation;颜色调试|color;多色序列|sequence;文字样式|typography;描边与阴影|textEffects;间距调试|spacing;字体库|typography'),
    _g('模型与媒体', Icons.perm_media_outlined,
      '模型预览|media;Live2D 物理参数|animation;背景图片|media;视频背景|media;媒体卡片|layout;图像字体|media'),
    _g('其他界面', Icons.settings_outlined,
      '配置方案|listEditor;更新提示|settings;云端资源列表|listEditor;信息面板|plugin;设置项搜索|settings;界面布局参数|layout'),
  ];
}
