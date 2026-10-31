import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';
import 'feature_catalog.dart';
import 'color_debug.dart';
import 'animation_debug.dart';
import 'material_debug.dart';
import 'effect_debug.dart';
import 'sequence_debug.dart';
import 'showcase_components.dart';
import 'source_feature_stage.dart';

/// Top-level preview navigation: four tabs, no device or network backend.
class FlPreviewHomeScreen extends StatelessWidget {
  const FlPreviewHomeScreen({super.key, required this.onSelect});
  final ValueChanged<int> onSelect;

  @override Widget build(BuildContext context) => ListView(
    key:const PageStorageKey('preview-home'),
    padding:const EdgeInsets.fromLTRB(22,18,22,128),
    children:[
      const FlShowcaseHeader(title:'主页'),
      const FlShowcaseSection(title:'组件目录',icon:Icons.grid_view_rounded),
      FlGroup(radius:26,dividerInset:70,children:[
        FlShowcaseEntry(title:'键显',icon:Icons.keyboard_alt_outlined,
          subtitle:'键鼠 · 手柄 · 自定义',onTap:()=>onSelect(1),height:67),
        FlShowcaseEntry(title:'插件',icon:Icons.extension_outlined,
          subtitle:'插件配置与控件',onTap:()=>onSelect(2),height:67),
        FlShowcaseEntry(title:'其他',icon:Icons.tune_outlined,
          subtitle:'主题 · 外观 · 模型',onTap:()=>onSelect(3),height:67),
      ]),
      const FlShowcaseSection(title:'控件效果',icon:Icons.auto_awesome_motion_rounded),
      const FlShowcaseInteractionPreview(),
    ],
  );
}

class FlKeyDisplayScreen extends StatelessWidget {
  const FlKeyDisplayScreen({super.key});

  @override Widget build(BuildContext context) => ListView(
    key:const PageStorageKey('keydisplay-list'),
    padding:const EdgeInsets.fromLTRB(22,18,22,128),
    children:[
      const FlShowcaseHeader(title:'键显'),
      const FlShowcaseSection(title:'分类',icon:Icons.widgets_outlined),
      FlGroup(radius:26,dividerInset:72,children:[
        _entry(context,'键鼠',Icons.keyboard_alt_outlined,
          PreviewCatalog.keyboard,'键盘与鼠标'),
        _entry(context,'手柄',Icons.sports_esports_outlined,
          PreviewCatalog.gamepad,'按键与布局'),
        _entry(context,'自定义',Icons.dashboard_customize_outlined,
          PreviewCatalog.custom,'外观与动效'),
      ]),
     ],
  );

  Widget _entry(BuildContext context,String title,IconData icon,
      List<PreviewGroup> groups,String subtitle) => FlShowcaseEntry(
    title:title,icon:icon,subtitle:subtitle,height:72,
    arrowKey:ValueKey('entry-arrow-$title'),
    onTap:()=>openPreviewFeatures(context,title,groups),
  );
}

class FlPluginShowcaseScreen extends StatelessWidget {
  const FlPluginShowcaseScreen({super.key});
  @override Widget build(BuildContext context)=>FlFeatureGroupsScreen(
    title:'插件',groups:PreviewCatalog.plugins,isRoot:true);
}

class FlOtherShowcaseScreen extends StatelessWidget {
  const FlOtherShowcaseScreen({super.key,required this.openTheme});
  final VoidCallback openTheme;
  @override Widget build(BuildContext context) => FlFeatureGroupsScreen(
    title:'其他',groups:PreviewCatalog.others,isRoot:true,
    leadingWidgets:[
      const FlShowcaseSection(title:'主题',icon:Icons.palette_outlined),
      FlGroup(radius:26,dividerInset:72,children:[
        FlShowcaseEntry(title:'主题设置',icon:Icons.color_lens_outlined,
          arrowKey:const ValueKey('entry-arrow-theme'),
          onTap:openTheme),
      ]),
    ],
  );
}

void openPreviewFeatures(BuildContext context,String title,List<PreviewGroup> groups) {
  Navigator.of(context).push(_route(context,
    FlFeatureGroupsScreen(title:title,groups:groups)));
}

Route<void> _route(BuildContext context,Widget page) =>
  PageRouteBuilder<void>(
    transitionDuration:FlMotion.effective(context,FlMotion.page),
    reverseTransitionDuration:FlMotion.effective(context,FlMotion.release),
    pageBuilder:(context,animation,secondary)=>
      FlShowcasePageSurface(child:page),
    transitionsBuilder:(context,animation,secondary,child){
      final fade=CurvedAnimation(parent:animation,curve:Curves.easeOutCubic);
      return FadeTransition(opacity:fade,child:SlideTransition(
        position:Tween<Offset>(
          begin:const Offset(.035,0),end:Offset.zero).animate(fade),
        child:child));
    },
  );

/// Group screens contain only names and left-hand navigation arrows.
/// Compact FlClash group screen; debug controls belong ONLY to detail pages.
class FlFeatureGroupsScreen extends StatelessWidget {
  const FlFeatureGroupsScreen({super.key,required this.title,
    required this.groups,this.isRoot=false,this.leadingWidgets=const []});
  final String title;
  final List<PreviewGroup> groups;
  final bool isRoot;
  final List<Widget> leadingWidgets;
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor:Colors.transparent,
    body:SafeArea(child:ListView(
      key:PageStorageKey('feature-groups-$title'),
      padding:EdgeInsets.fromLTRB(22,isRoot?18:7,22,isRoot?128:30),
      children:[
        FlShowcaseHeader(title:title,
          onBack:isRoot?null:()=>Navigator.of(context).pop()),
        ...leadingWidgets,
        for(final group in groups)...[
          FlShowcaseGroupHeading(
            title:group.title,icon:group.icon,count:group.features.length),
          FlGroup(radius:24,dividerInset:71,children:[
            for(final feature in group.features)
              FlShowcaseEntry(
                title:feature.title,
                height:64,
                visual:FlFeatureThumbnail(kind:feature.kind,title:feature.title),
                arrowKey:ValueKey('debug-arrow-${feature.title}'),
                onTap:()=>_openFeature(context,feature),
              ),
          ]),
        ],
      ],
    )),
  );

  void _openFeature(BuildContext context,PreviewFeature feature) {
    Navigator.of(context).push(
      _route(context,FlFeatureDebugScreen(feature:feature)));
  }
}

/// Actual control panels are mounted only after the user enters a detail view.
class FlFeatureDebugScreen extends StatelessWidget {
  const FlFeatureDebugScreen({super.key,required this.feature});
  final PreviewFeature feature;
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor:Colors.transparent,
    body:SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(17,12,20,6),
        child:Row(children:[
          IconButton(
            key:const ValueKey('debug-back'),
            icon:Icon(Icons.arrow_back_rounded,
              color:Theme.of(context).colorScheme.onSurface),
            onPressed:()=>Navigator.of(context).pop()),
          const SizedBox(width:9),
          Expanded(child:Text(feature.title,maxLines:1,
            overflow:TextOverflow.ellipsis,
            style:TextStyle(fontSize:23,fontWeight:FontWeight.w700,
              color:Theme.of(context).colorScheme.onSurface))),
        ])),
      Expanded(child:ListView(
        padding:const EdgeInsets.fromLTRB(24,8,24,38),
        children:[_panel(feature.kind,feature.title)],
      )),
    ])),
  );

  Widget _panel(PreviewKind kind,String title) => switch(kind) {
    PreviewKind.color=>const FlColorDebug(),
    PreviewKind.animation=>const FlAnimationDebug(),
    PreviewKind.gradient=>const FlGradientDebug(),
    PreviewKind.material=>const FlMaterialDebug(),
    PreviewKind.typography=>const FlTypographyDebug(),
    PreviewKind.spacing=>const FlSpacingDebug(),
    PreviewKind.press=>const FlPressDebug(),
    PreviewKind.layers=>const FlLayerColorDebug(),
    PreviewKind.sequence=>const FlColorSequenceDebug(),
    PreviewKind.textEffects=>const FlTextEffectsDebug(),
    PreviewKind.controls=>const _LocalControlSample(),
    PreviewKind.slider=>_LocalSliderSample(title:title),
    PreviewKind.settings=>_LocalSettingsSample(title:title),
    PreviewKind.options=>_LocalOptionsSample(title:title),
    PreviewKind.listEditor=>_LocalListSample(title:title),
    PreviewKind.layout=>const FlSpacingDebug(),
    PreviewKind.media=>_LocalMediaSample(title:title),
    PreviewKind.plugin=>_LocalSettingsSample(title:title),
    PreviewKind.source=>FlSourceFeatureSample(title:title),
  };
}

class _LocalSliderSample extends StatefulWidget {
  const _LocalSliderSample({required this.title});
  final String title;
  @override State<_LocalSliderSample> createState()=>_LocalSliderSampleState();
}
class _LocalSliderSampleState extends State<_LocalSliderSample> {
  double value=50;
  @override Widget build(BuildContext context)=>FlSliderPanel(
    title:widget.title,value:value,
    onChanged:(v)=>setState(()=>value=v));
}

class _LocalSettingsSample extends StatefulWidget {
  const _LocalSettingsSample({required this.title});
  final String title;
  @override State<_LocalSettingsSample> createState()=>_LocalSettingsSampleState();
}
class _LocalSettingsSampleState extends State<_LocalSettingsSample> {
  bool enabled=true;
  double value=70;
  @override Widget build(BuildContext context)=>Column(children:[
    FlGroup(children:[
      FlToggleRow(title:widget.title,
        icon:Icons.toggle_on_outlined,value:enabled,
        onChanged:(v)=>setState(()=>enabled=v)),
    ]),
    const SizedBox(height:12),
    FlSliderPanel(title:'显示比例',value:value,
      onChanged:(v)=>setState(()=>value=v)),
  ]);
}

class _LocalOptionsSample extends StatefulWidget {
  const _LocalOptionsSample({required this.title});
  final String title;
  @override State<_LocalOptionsSample> createState()=>_LocalOptionsSampleState();
}
class _LocalOptionsSampleState extends State<_LocalOptionsSample> {
  String choice='自动';
  @override Widget build(BuildContext context) {
    const choices=['自动','标准','自定义'];
    return Column(children:[
      const SizedBox(height:8),
      FlSegmented<String>(values:choices,label:(s)=>s,
        value:choice,onChanged:(s)=>setState(()=>choice=s)),
      const SizedBox(height:12),
      FlPanel(child:Text(widget.title)),
    ]);
  }
}

class _LocalControlSample extends StatefulWidget {
  const _LocalControlSample();
  @override State<_LocalControlSample> createState()=>_LocalControlSampleState();
}
class _LocalControlSampleState extends State<_LocalControlSample> {
  bool selected=false;
  int count=1;
  @override Widget build(BuildContext context)=>FlGroup(children:[
    FlSettingRow(title:'按钮',
      leading:const Icon(Icons.smart_button_outlined),
      trailing:FilledButton.tonal(
        key:const ValueKey('preview-button'),
        onPressed:()=>setState(()=>selected=!selected),
        child:Text(selected?'已选中':'点击'))),
    FlSettingRow(title:'数值',
      trailing:FlStepCounter(value:count,min:0,max:12,
        onChanged:(v)=>setState(()=>count=v))),
  ]);
}

class _LocalListSample extends StatefulWidget {
  const _LocalListSample({required this.title});
  final String title;
  @override State<_LocalListSample> createState()=>_LocalListSampleState();
}
class _LocalListSampleState extends State<_LocalListSample> {
  final List<String> items=['条目一','条目二','条目三'];
  @override Widget build(BuildContext context) => FlPanel(child:Column(
    crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text(widget.title,style:const TextStyle(
        fontSize:17,fontWeight:FontWeight.w600)),
      const SizedBox(height:12),
      for(final (index,item) in items.indexed)
        ListTile(
          key:ValueKey('sample-item-$index'),
          dense:true,title:Text(item),
          leading:const Icon(Icons.drag_indicator_rounded),
          trailing:IconButton(icon:const Icon(Icons.close_rounded),
            onPressed:()=>setState(()=>items.removeAt(index))),
        ),
      Align(alignment:Alignment.centerRight,child:TextButton.icon(
        onPressed:()=>setState(()=>items.add('条目${items.length+1}')),
        icon:const Icon(Icons.add_rounded),label:const Text('添加'))),
    ]));
}

class _LocalMediaSample extends StatefulWidget {
  const _LocalMediaSample({required this.title});
  final String title;
  @override State<_LocalMediaSample> createState()=>_LocalMediaSampleState();
}
class _LocalMediaSampleState extends State<_LocalMediaSample> {
  double scale=1;
  @override Widget build(BuildContext context)=>FlPanel(child:Column(children:[
    SizedBox(height:170,child:Center(child:AnimatedScale(
      duration:FlMotion.effective(context,FlMotion.regular),
      scale:scale,
      child:Container(width:96,height:96,alignment:Alignment.center,
        decoration:BoxDecoration(
          gradient:LinearGradient(colors:[
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary]),
          borderRadius:BorderRadius.circular(24)),
        child:const Icon(Icons.image_outlined,color:Colors.white,size:40)),
    ))),
    Slider(value:scale,min:.5,max:1.5,
      onChanged:(v)=>setState(()=>scale=v)),
  ]));
}

class FlSourceFeatureSample extends StatefulWidget {
  const FlSourceFeatureSample({super.key,required this.title});
  final String title;
  @override State<FlSourceFeatureSample> createState()=>_FlSourceFeatureSampleState();
}
class _FlSourceFeatureSampleState extends State<FlSourceFeatureSample> {
  bool enabled=false;
  final Map<String,double> values={};
  final Map<String,bool> switches={};
  final Map<String,int> options={};
  static const Map<String,List<String>> specs={
    '常规按显':['键盘大小','键盘间距','空格键高度','鼠标按键高度','显示空格键','显示空格键 CPS','空格键内容显示为横杠','左右键显示','左右键与空格位置交换','左右键 CPS 显示'],
    '输入时显示全键盘':['全键盘大小'],
    '鼠标按显':['鼠标按键大小'],
    '键盘猫显示':['模型大小','模型风格','表情选择','方向键变为鼠标','全局反转'],
    '最近按键':['显示大小'],
    '鼠标轨迹':['轨迹大小','轨迹圆点大小','左键按下颜色','右键按下颜色'],
    '自定义鼠标指针':['鼠标指针外观','指针诊断模式'],
    '左摇杆':['摇杆大小','中心圆点大小','圆角强度','描边宽度','中心圆点圆角','颜色调试','透明度调试'],
    '右摇杆':['摇杆大小','中心圆点大小','圆角强度','描边宽度','中心圆点圆角','颜色调试','透明度调试'],
    'ABXY 按键':['按键大小','按键间距','颜色调试','透明度调试','按压动画调试','反转 ABXY 位置','△○□X 图标','显示 Y 键 CPS','显示 X 键 CPS','显示 B 键 CPS','显示 A 键 CPS'],
    '十字键显示':['按键大小','颜色调试','透明度调试','按压动画调试'],
    '左肩键':['按键大小','颜色调试','透明度调试','显示 L2 压力','显示 L1 CPS'],
    '右肩键':['按键大小','颜色调试','透明度调试','显示 R2 压力','显示 R1 CPS'],
    '背键显示':['按键大小','颜色调试','透明度调试'],
    '兼容模式':['兼容模式选项','交换 X / Y','交换 A / B','交换左右摇杆','交换 L2 / R2','按键交换'],
    '独立按键交换':['交换 X / Y','交换 A / B','交换左右摇杆','交换 L2 / R2'],
    '自定义控件':['控件类型','宽度','高度','圆角','背景透明度','边框透明度','文字透明度','按压扩散透明度','文字大小','描边宽度','颜色调试','按压动画调试'],
    '按键控件':['宽度','高度','圆角','按键背景颜色','按下颜色','边框颜色','文字颜色','按压动画调试'],
    '文本控件':['宽度','高度','文字大小','文字描边','文字描边宽度','文字阴影','CPS 文本'],
    '摇杆控件':['左摇杆 / 右摇杆','摇杆大小','圆点尺寸','圆点圆角','背景颜色','透明度'],
    '控件位置与尺寸':['X 位置','Y 位置','宽度','高度'],
    '插件 UI 配置':['功能开关','功能按钮','滑块','颜色','单选','数值','文本','键位','开关','列表','绑定'],
    'Live2D':['模型大小','物理强度','Physics 组','表情调试','参数调试','全套动作捕捉','捕捉鼠标','去水印'],
    'Web 插件显示':['显示方式','布局位置','显示比例'],
    'CPS 显示':['统计目标','显示大小','颜色调试','透明度调试'],
    '修改字体':['字体选择','字体大小'],
    '灵敏度倍率':['倍率'],
    '同时点击':['组合列表'],
    '隐藏按显快捷键':['快捷键外观','目标选择'],
  };
  bool _isToggle(String x)=>x.startsWith('显示')||
    x.startsWith('交换')||x.contains('启用')||x.contains('反转')||
    x.contains('图标')||x.contains('捕捉')||x.contains('去水印')||
    x.contains('诊断模式')||x.contains('显示为横杠')||
    x.contains('左右键显示')||x.contains('方向键变为鼠标')||
    x.contains('全局反转')||x.contains('位置交换')||
    x.contains('文字描边')||x.contains('文字阴影')||
    x.contains('全套动作捕捉')||x.contains('模拟开关');
  bool _isSelection(String x)=>x.contains('模式')||x.contains('类型')||
    x.contains('风格')||x.contains('选择')||x.contains('组')||
    x.contains('左摇杆 /');
  @override Widget build(BuildContext context) {
    final params=specs[widget.title]??const <String>[];
    final cs=Theme.of(context).colorScheme;
    final sourceLevel=values['键盘大小']??values['按键大小']??
      values['摇杆大小']??values['模型大小']??50;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      FlGroup(dividerInset:64,children:[
        FlToggleRow(
          key:const ValueKey('source-feature-toggle'),
          title:widget.title,icon:Icons.tune_rounded,value:enabled,
          onChanged:(v)=>setState(()=>enabled=v)),
      ]),
      const SizedBox(height:13),
      FlSourceFeatureStage(
        title:widget.title,enabled:enabled,level:sourceLevel/100),
      const SizedBox(height:20),
      Row(children:[
        Icon(Icons.tune_rounded,color:cs.primary,size:20),
        const SizedBox(width:9),
        Text('参数调试',style:TextStyle(
          fontSize:16,fontWeight:FontWeight.w700,
          color:cs.onSurface)),
        const Spacer(),
        Text('${params.length} 项',style:TextStyle(
          fontSize:12,color:cs.onSurfaceVariant)),
      ]),
      const SizedBox(height:10),
      if(params.isNotEmpty) FlPanel(
        padding:const EdgeInsets.symmetric(horizontal:17,vertical:10),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          for(final (index,param) in params.indexed)...[
            if(index>0) Divider(
              height:18,thickness:.65,
              color:cs.outlineVariant.withValues(alpha:.6)),
            if(param.contains('调试'))
              _debugLink(context,param)
            else if(param.contains('背景颜色')||
                    param.contains('文字颜色')||
                    param.contains('边框颜色')||
                    param.contains('按下颜色')||
                    param.contains('键盘颜色'))
              _colorRow(param,cs)
            else if(_isToggle(param))
              SwitchListTile.adaptive(
                key:ValueKey('source-toggle-$param'),
                contentPadding:EdgeInsets.zero,
                dense:true,title:Text(param,
                  style:const TextStyle(fontSize:14)),
                value:switches[param]??false,
                onChanged:(v)=>setState(()=>switches[param]=v))
            else if(_isSelection(param))
              _selectRow(param)
            else _sliderRow(param),
          ],
        ]),
      ),
      if(params.isEmpty) FlPanel(child:Column(
        crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Text(widget.title,style:const TextStyle(fontSize:16)),
          const SizedBox(height:14),
          FlSegmented<String>(
            values:const ['默认','选项一','选项二'],
            label:(x)=>x,
            value:['默认','选项一','选项二'][options['generic']??0],
            onChanged:(x)=>setState(()=>options['generic']=
              ['默认','选项一','选项二'].indexOf(x))),
        ])),
    ]);
  }

  Widget _debugLink(BuildContext context,String param) {
    final cs=Theme.of(context).colorScheme;
    final kind=param.contains('动画') ? PreviewKind.press :
      param.contains('透明度') ? PreviewKind.material :
      PreviewKind.color;
    return InkWell(
      key:ValueKey('source-debug-link-$param'),
      borderRadius:BorderRadius.circular(12),
      onTap:()=>Navigator.of(context).push(
        _route(context,FlFeatureDebugScreen(
          feature:PreviewFeature(param,kind)))),
      child:Padding(
        padding:const EdgeInsets.symmetric(vertical:7),
        child:Row(children:[
          Icon(Icons.chevron_right_rounded,size:24,
            color:cs.primary),
          const SizedBox(width:9),
          Expanded(child:Text(param,
            style:const TextStyle(fontSize:14,
              fontWeight:FontWeight.w600))),
          Icon(Icons.tune_rounded,size:18,
            color:cs.onSurfaceVariant),
        ]),
      ),
    );
  }

  Widget _sliderRow(String name) {
    final value=values[name]??50;
    return Padding(padding:const EdgeInsets.symmetric(vertical:4),
      child:Column(children:[
        Row(children:[
          Expanded(child:Text(name,style:const TextStyle(fontSize:14))),
          Container(
            padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),
            decoration:BoxDecoration(
              color:Theme.of(context).colorScheme.surfaceContainerHighest
                .withValues(alpha:.6),
              borderRadius:BorderRadius.circular(12)),
            child:Text('${value.round()}',
              style:const TextStyle(fontSize:12,
                fontWeight:FontWeight.w600)),
          ),
        ]),
        Slider(
          key:ValueKey('source-slider-$name'),
          value:value,min:0,max:100,
          onChanged:(x)=>setState(()=>values[name]=x)),
      ]),
    );
  }
  Widget _selectRow(String name) {
    const choices=['自动','标准','自定义'];
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(name,style:const TextStyle(fontSize:14)),
      const SizedBox(height:10),
      FlSegmented<String>(values:choices,label:(s)=>s,
        value:choices[options[name]??0],
        onChanged:(v)=>setState(()=>options[name]=choices.indexOf(v))),
    ]);
  }
  Widget _colorRow(String name,ColorScheme cs)=>Padding(
    padding:const EdgeInsets.symmetric(vertical:7),
    child:Row(children:[
      Expanded(child:Text(name,style:const TextStyle(fontSize:14))),
      for(final c in [cs.primary,cs.tertiary,cs.secondary]) Padding(
        padding:const EdgeInsets.only(left:9),
        child:InkWell(
          key:ValueKey('source-swatch-$name-${c.toARGB32()}'),
          onTap:()=>setState(()=>options[name]=c.toARGB32()),
          child:AnimatedContainer(
            duration:FlMotion.effective(context,FlMotion.short),
            padding:const EdgeInsets.all(3),
            decoration:BoxDecoration(shape:BoxShape.circle,
              border:Border.all(
                color:options[name]==c.toARGB32()
                  ? cs.primary:Colors.transparent,width:2)),
            child:CircleAvatar(radius:12,backgroundColor:c)))),
    ]),
  );
}
