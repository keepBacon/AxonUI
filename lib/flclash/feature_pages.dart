import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';
import 'motion.dart';
import 'feature_catalog.dart';
import 'advanced_controls.dart';
import 'color_debug.dart';
import 'animation_debug.dart';
import 'material_debug.dart';
import 'effect_debug.dart';
import 'sequence_debug.dart';

/// Top-level preview navigation: four tabs, no device or network backend.
class FlPreviewHomeScreen extends StatelessWidget {
  const FlPreviewHomeScreen({super.key, required this.onSelect});
  final ValueChanged<int> onSelect;
  @override Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('preview-home'),
    padding: const EdgeInsets.fromLTRB(24,18,24,140),
    children: [
      const Text('主页', style: TextStyle(
        fontSize:29,fontWeight:FontWeight.w700)),
      const SizedBox(height:10),
      const FlSection(title:'展示目录',icon:Icons.grid_view_rounded),
      FlGroup(children: [
        FlSettingRow(title:'键显',
          leading:const Icon(Icons.keyboard_alt_outlined),
          trailing:const Icon(Icons.chevron_right_rounded),
          onTap:()=>onSelect(1)),
        FlSettingRow(title:'插件',
          leading:const Icon(Icons.extension_outlined),
          trailing:const Icon(Icons.chevron_right_rounded),
          onTap:()=>onSelect(2)),
        FlSettingRow(title:'其他',
          leading:const Icon(Icons.tune_outlined),
          trailing:const Icon(Icons.chevron_right_rounded),
          onTap:()=>onSelect(3)),
      ]),
      const FlSection(title:'组件分类',icon:Icons.layers_outlined),
      const FlPanel(child: Wrap(spacing:8,runSpacing:8,children: [
        Chip(label:Text('键盘')),
        Chip(label:Text('鼠标')),
        Chip(label:Text('手柄')),
        Chip(label:Text('自定义')),
        Chip(label:Text('颜色')),
        Chip(label:Text('动画')),
        Chip(label:Text('材质')),
        Chip(label:Text('插件')),
      ])),
    ],
  );
}

class FlKeyDisplayScreen extends StatelessWidget {
  const FlKeyDisplayScreen({super.key});
  @override Widget build(BuildContext context) => ListView(
    key:const PageStorageKey('keydisplay-list'),
    padding:const EdgeInsets.fromLTRB(24,18,24,140),
    children: [
      const Text('键显',style:TextStyle(fontSize:29,fontWeight:FontWeight.w700)),
      const FlSection(title:'分类',icon:Icons.widgets_outlined),
      FlGroup(children: [
        _entry(context,'键鼠',Icons.keyboard_alt_outlined,PreviewCatalog.keyboard),
        _entry(context,'手柄',Icons.sports_esports_outlined,PreviewCatalog.gamepad),
        _entry(context,'自定义',Icons.dashboard_customize_outlined,PreviewCatalog.custom),
      ]),
    ],
  );

  Widget _entry(BuildContext context,String title,IconData icon,
      List<PreviewGroup> groups) => FlSettingRow(
    title:title,
    leading:IconButton(
      key:ValueKey('entry-arrow-$title'),
      tooltip:'进入$title', icon:const Icon(Icons.chevron_right_rounded),
      onPressed:()=>openPreviewFeatures(context,title,groups)),
    trailing:Icon(icon,color:Theme.of(context).colorScheme.primary),
    onTap:()=>openPreviewFeatures(context,title,groups));
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
    title:'其他', groups:PreviewCatalog.others,isRoot:true,
    leadingWidgets: [
      const FlSection(title:'主题',icon:Icons.palette_outlined),
      FlGroup(children:[
        FlSettingRow(
          title:'主题设置',
          leading:IconButton(
            key:const ValueKey('entry-arrow-theme'),
            onPressed:openTheme,
            icon:const Icon(Icons.chevron_right_rounded)),
          onTap:openTheme),
      ]),
    ]);
}

void openPreviewFeatures(BuildContext context,String title,List<PreviewGroup> groups) {
  Navigator.of(context).push(_route(context,
    FlFeatureGroupsScreen(title:title,groups:groups)));
}

Route<void> _route(BuildContext context,Widget page) =>
  PageRouteBuilder<void>(
    transitionDuration:FlMotion.effective(context,FlMotion.page),
    reverseTransitionDuration:FlMotion.effective(context,FlMotion.release),
    pageBuilder:(context,animation,secondary)=>page,
    transitionsBuilder:(context,animation,secondary,child){
      final fade=CurvedAnimation(parent:animation,curve:Curves.easeOutCubic);
      return FadeTransition(opacity:fade,child:SlideTransition(
        position:Tween<Offset>(
          begin:const Offset(.035,0),end:Offset.zero).animate(fade),
        child:child));
    },
  );

/// Group screens contain only names and left-hand navigation arrows.
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
      padding:EdgeInsets.fromLTRB(24,isRoot?18:8,24,isRoot?140:38),
      children:[
        if(!isRoot) Row(children:[
          IconButton(
            key:const ValueKey('feature-back'),
            onPressed:()=>Navigator.of(context).pop(),
            icon:const Icon(Icons.arrow_back_rounded)),
          const SizedBox(width:10),
          Expanded(child:Text(title,style:const TextStyle(
            fontSize:25,fontWeight:FontWeight.w700))),
        ]) else
          Text(title,style:const TextStyle(
            fontSize:29,fontWeight:FontWeight.w700)),
        ...leadingWidgets,
        for(final group in groups)...[
          FlSection(title:group.title,icon:group.icon),
          FlGroup(children:[
            for(final feature in group.features)
              FlSettingRow(
                title:feature.title,
                leading:IconButton(
                  key:ValueKey('debug-arrow-${feature.title}'),
                  tooltip:'打开${feature.title}',
                  icon:const Icon(Icons.chevron_right_rounded),
                  onPressed:()=>_openFeature(context,feature)),
                onTap:()=>_openFeature(context,feature),
              ),
          ]),
        ],
      ],
    )),
  );

  void _openFeature(BuildContext context,PreviewFeature feature) {
    Navigator.of(context).push(_route(context,FlFeatureDebugScreen(feature:feature)));
  }
}

/// Actual control panels are mounted only after the user enters a detail view.
class FlFeatureDebugScreen extends StatelessWidget {
  const FlFeatureDebugScreen({super.key,required this.feature});
  final PreviewFeature feature;
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor:Theme.of(context).scaffoldBackgroundColor,
    body:SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(17,12,24,6),child:Row(children:[
        IconButton(
          key:const ValueKey('debug-back'),
          icon:const Icon(Icons.arrow_back_rounded),
          onPressed:()=>Navigator.of(context).pop()),
        const SizedBox(width:9),
        Expanded(child:Text(feature.title,maxLines:1,
          overflow:TextOverflow.ellipsis,
          style:const TextStyle(fontSize:23,fontWeight:FontWeight.w700))),
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
