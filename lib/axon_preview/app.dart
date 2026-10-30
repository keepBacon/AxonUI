import 'package:flutter/material.dart';
import '../flclash/store.dart';
import '../flclash/glass.dart';
import '../flclash/upstream_liquid_glass.dart';
import 'components.dart';

/// Standalone component gallery: never calls Axon input or FlClash networking.
class AxonPreviewApp extends StatefulWidget {
  const AxonPreviewApp({super.key, this.store});
  final FlUiStore? store;
  @override State<AxonPreviewApp> createState()=>_AxonPreviewAppState();
}
class _AxonPreviewAppState extends State<AxonPreviewApp> {
  int tier=2; bool dark=false; Color accent=AxonLab.blue;
  @override Widget build(BuildContext context) => MaterialApp(
    title:'Axon UI Lab', debugShowCheckedModeBanner:false,
    theme:ThemeData(useMaterial3:true,
      colorScheme:ColorScheme.fromSeed(seedColor:accent,brightness:dark?Brightness.dark:Brightness.light),
      scaffoldBackgroundColor:dark?const Color(0xFF111A29):AxonLab.canvas),
    home:LiquidGlassScope(enabled:tier>0,
      quality:tier==1?LiquidGlassQuality.standard:LiquidGlassQuality.ultra,
      child:LiquidGlassHost(enabled:tier>0,
        child:FlGlassScope(level:tier,child:_Workbench(
          tier:tier,onTier:(v)=>setState(()=>tier=v),
          dark:dark,onDark:(v)=>setState(()=>dark=v),
          onAccent:(v)=>setState(()=>accent=v))))),
  );
}
class _Workbench extends StatefulWidget {
  const _Workbench({required this.tier,required this.onTier,required this.dark,
    required this.onDark,required this.onAccent});
  final int tier; final ValueChanged<int> onTier;
  final bool dark;final ValueChanged<bool> onDark;
  final ValueChanged<Color> onAccent;
  @override State<_Workbench> createState()=>_WorkbenchState();
}
class _WorkbenchState extends State<_Workbench> {
  int tab=0,number=3;bool enabled=true,pressed=false;
  double opacity=75,size=55;String keyName='Space',choice='按下';
  Offset touch=const Offset(.4,.5);
  final items=<String>['键盘','鼠标','手柄','触控','插件','主题'];
  @override Widget build(BuildContext context) => Scaffold(body:SafeArea(
    child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:820),
      child:Column(children:[
        Padding(padding:const EdgeInsets.fromLTRB(18,15,18,12),child:Row(children:[
          Container(width:43,height:43,decoration:BoxDecoration(
            color:Theme.of(context).colorScheme.primary,borderRadius:BorderRadius.circular(14)),
            child:const Icon(Icons.widgets_rounded,color:Colors.white)),
          const SizedBox(width:12),
          const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('AXON / UI LAB',style:TextStyle(fontSize:19,fontWeight:FontWeight.w800)),
            Text('组件库预览 APK · UI ONLY',style:TextStyle(fontSize:11)),
          ])),
          const AxonTag(label:'PREVIEW',active:true),
        ])),
        Padding(padding:const EdgeInsets.symmetric(horizontal:14),child:
          AxonSegmented<int>(options:const [0,1,2,3],value:tab,
          label:(v)=>const ['组件库','Axon 控件','布局编辑','材质动效'][v],
          onChanged:(v)=>setState(()=>tab=v))),
        Expanded(child:ListView(key:ValueKey('lab-$tab'),
          padding:const EdgeInsets.fromLTRB(15,18,15,32),
          children:[if(tab==0)..._home(),if(tab==1)..._controls(),
            if(tab==2)..._editor(),if(tab==3)..._material()])),
      ])))));
  List<Widget> _home()=>[
    const AxonSectionHeading(title:'组件目录',subtitle:'独立的 Axon UI 展示体系'),
    const SizedBox(height:12),
    AxonSurface(color:Theme.of(context).colorScheme.primary.withValues(alpha:.1),
      child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        AxonTag(label:'COMPONENT WORKBENCH',active:true),
        SizedBox(height:14),
        Text('探索可交互的控件。',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800)),
        SizedBox(height:6),
        Text('所有键位、手柄及触控控件仅预览视觉状态，不执行设备操作。'),
      ])),
    const SizedBox(height:12),
    for(final item in items)...[
      AxonSurface(child:AxonSetting(title:item,subtitle:'点击浏览预览控件',
        icon:Icons.extension_outlined,
        trailing:const Icon(Icons.chevron_right),
        onTap:()=>setState(()=>tab=item=='主题'?3:item=='触控'?2:1))),
      const SizedBox(height:8),
    ],
    AxonSurface(child:AxonSetting(title:'状态开关',icon:Icons.toggle_on_rounded,
      trailing:Switch(key:const ValueKey('home-toggle'),value:enabled,
        onChanged:(v)=>setState(()=>enabled=v)))),
  ];
  List<Widget> _controls()=>[
    const AxonSectionHeading(title:'Axon 控件合集',
      subtitle:'对应 Axon 的 UI 控件和插件声明类型'),
    const SizedBox(height:12),
    AxonSurface(child:Column(children:[
      AxonSetting(title:'开关',icon:Icons.toggle_on_outlined,
        trailing:Switch(key:const ValueKey('axon-toggle'),
          value:enabled,onChanged:(v)=>setState(()=>enabled=v))),
      const Divider(),
      AxonSetting(title:'整数步进',icon:Icons.exposure_plus_1,
        trailing:AxonStepper(value:number,min:1,max:20,
          onChanged:(v)=>setState(()=>number=v))),
      const SizedBox(height:12),
      AxonSegmented<String>(options:const ['按下','切换','长按'],
        value:choice,label:(v)=>v,onChanged:(v)=>setState(()=>choice=v)),
      const SizedBox(height:12),
      FilledButton(onPressed:()=>setState(()=>pressed=!pressed),
        child:Text(pressed?'已按下':'按钮视觉预览')),
    ])),
    const SizedBox(height:12),
    AxonSurface(child:Column(children:[
      AxonValueSlider(label:'透明度',value:opacity,
        onChanged:(v)=>setState(()=>opacity=v)),
      AxonValueSlider(label:'控件大小',value:size,min:24,max:96,suffix:'dp',
        onChanged:(v)=>setState(()=>size=v)),
    ])),
    const SizedBox(height:12),
    AxonSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const AxonSectionHeading(title:'虚拟键帽 / 鼠标',subtitle:'只改变本地选中态'),
      const SizedBox(height:12),
      Wrap(spacing:8,runSpacing:8,children:[
        for(final k in const ['W','A','S','D','Space','LMB','RMB','Shift'])
          AxonKeycap(label:k,selected:k==keyName,
            onTap:()=>setState(()=>keyName=k)),
      ]),
    ])),
    const SizedBox(height:12),
    const AxonSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      AxonSectionHeading(title:'插件 UI Schema',subtitle:'2 个入口，9 个调试控件类型'),
      SizedBox(height:12),
      Wrap(spacing:5,runSpacing:6,children:[
        AxonTag(label:'feature.toggle'),AxonTag(label:'feature.button'),
        AxonTag(label:'slider'),AxonTag(label:'number'),AxonTag(label:'select'),
        AxonTag(label:'color'),AxonTag(label:'text'),AxonTag(label:'key'),
        AxonTag(label:'toggle'),AxonTag(label:'list'),AxonTag(label:'binding'),
      ]),
    ])),
  ];
  List<Widget> _editor()=>[
    const AxonSectionHeading(title:'布局编辑',subtitle:'虚拟按键拖拽，绝不发送输入'),
    const SizedBox(height:12),
    AxonSurface(child:AspectRatio(aspectRatio:1.55,
      child:LayoutBuilder(builder:(context,c){
        const buttonWidth=72.0,buttonHeight=52.0;
        final maxX=(c.maxWidth-buttonWidth).clamp(0.0,double.infinity);
        final maxY=(c.maxHeight-buttonHeight).clamp(0.0,double.infinity);
        return Stack(children:[
          Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(
            color:Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius:BorderRadius.circular(17)))),
          Positioned(left:touch.dx*maxX,top:touch.dy*maxY,
            child:GestureDetector(key:const ValueKey('draggable-key'),
              onPanUpdate:(d)=>setState(()=>touch=Offset(
                (touch.dx+(maxX==0?0:d.delta.dx/maxX)).clamp(0,1),
                (touch.dy+(maxY==0?0:d.delta.dy/maxY)).clamp(0,1))),
              child:Container(width:buttonWidth,height:buttonHeight,
                alignment:Alignment.center,
                decoration:BoxDecoration(color:AxonLab.blue,
                  borderRadius:BorderRadius.circular(14)),
                child:const Text('SPACE',
                  style:TextStyle(color:Colors.white,fontWeight:FontWeight.w700))))),
        ]);
      }))),
    const SizedBox(height:12),
    AxonSurface(child:Column(children:[
      const AxonSectionHeading(title:'手柄反馈',subtitle:'仅 UI 状态'),
      const SizedBox(height:12),
      Wrap(spacing:7,children:[
        for(final k in const ['↑','←','↓','→','A','B'])
          AxonKeycap(label:k,selected:keyName==k,
            onTap:()=>setState(()=>keyName=k)),
      ]),
      const SizedBox(height:9),
      const Text('仅视觉状态'),
    ])),
  ];
  List<Widget> _material()=>[
    const AxonSectionHeading(title:'材质与动效',subtitle:'独立 UI Lab，不使用 FlClash 布局'),
    const SizedBox(height:12),
    AxonSurface(child:Column(children:[
      AxonSetting(title:'暗色主题',icon:Icons.dark_mode_outlined,
        trailing:Switch(key:const ValueKey('theme-dark'),value:widget.dark,
          onChanged:widget.onDark)),
      const Divider(),
      AxonSegmented<int>(options:const [0,1,2],value:widget.tier,
        label:(v)=>const ['无玻璃','标准','极致'][v],onChanged:widget.onTier),
    ])),
    const SizedBox(height:12),
    AxonSurface(child:Column(children:[
      const AxonSectionHeading(title:'原生 Shader 材质实验'),
      const SizedBox(height:12),
      SizedBox(height:145,child:Stack(children:[
        Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(
          borderRadius:BorderRadius.circular(18),
          gradient:const LinearGradient(colors:[
            Color(0xFF6C99EE),Color(0xFFA4E5DC)])))),
        Center(child:FlGlassSurface(level:widget.tier,pill:true,radius:20,
          child:const Padding(padding:EdgeInsets.all(20),
            child:Text('AXON GLASS LAB')))),
      ])),
    ])),
    const SizedBox(height:12),
    AxonSurface(child:Column(children:[
      const AxonSectionHeading(title:'主题强调色'),
      const SizedBox(height:12),
      Wrap(spacing:12,children:[
        for(final color in const [AxonLab.blue,Color(0xFF2AB6A2),
          Color(0xFFD28C72),Color(0xFF9A85C8)])
          InkWell(onTap:()=>widget.onAccent(color),
            child:CircleAvatar(backgroundColor:color,radius:19)),
      ]),
    ])),
  ];
}
