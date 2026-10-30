import 'package:flutter/material.dart';
import 'controls.dart';
import 'dock.dart';
import 'preview.dart';
import 'schema.dart';
import 'store.dart';
import 'theme.dart';

class FlThemeScreen extends StatefulWidget {
  const FlThemeScreen({super.key, required this.onBack, required this.mode,
    required this.seed, required this.onMode, required this.onSeed,
    required this.glass, required this.onGlass, required this.store});
  final VoidCallback onBack;
  final ThemeMode mode;
  final Color seed;
  final int glass;
  final ValueChanged<int> onGlass;
  final ValueChanged<ThemeMode> onMode;
  final ValueChanged<Color> onSeed;
  final FlUiStore store;
  @override
  State<FlThemeScreen> createState()=>_FlThemeScreenState();
}
class _FlThemeScreenState extends State<FlThemeScreen>{
  bool _floating=true,_slide=true,_custom=false;
  int _colorStyle=0;
  int get _glass => widget.glass;
  double _scale=1;
  String _font='跟随系统';
  final _colors=<Color>[
    FlTokens.blue,const Color(0xFFA9B5D6),const Color(0xFFE3B0E3),
    const Color(0xFFF0B7CB),const Color(0xFFF0D1AE),
    const Color(0xFFB8DCC8),const Color(0xFF777C95),
  ];
  @override
  void initState(){super.initState();_load();}
  Future<void> _load()async{
    try{final data=await widget.store.load();if(!mounted)return;
      setState((){
        _floating=data['floating'] is bool?data['floating'] as bool:_floating;
        _slide=data['slide'] is bool?data['slide'] as bool:_slide;
        _custom=data['custom_scale'] is bool?data['custom_scale'] as bool:_custom;
        _colorStyle=data['color_style'] is int?data['color_style'] as int:_colorStyle;
        _scale=data['text_scale'] is num?(data['text_scale'] as num).toDouble():_scale;
        _font=data['font']?.toString()??_font;
      });
    }catch(_){/* Host persistence is optional in UI-only previews. */}
  }
  void _save(String key,Object? value){widget.store.save(key,value).catchError((Object _){});}
  @override
  Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    final dark=Theme.of(context).brightness==Brightness.dark;
    return Scaffold(body:SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(22,12,24,8),
        child:Row(children:[
          Material(color:flSurface(context),shape:const CircleBorder(),
            child:InkWell(key:const ValueKey('theme-back'),
              customBorder:const CircleBorder(),onTap:widget.onBack,
              child:const SizedBox(width:55,height:55,
                child:Icon(Icons.arrow_back_rounded,size:28)))),
          const SizedBox(width:18),
          const Expanded(child:Text('主题',style:TextStyle(fontSize:23,
            fontWeight:FontWeight.w700))),
          IconButton.filledTonal(tooltip:'重置主题',onPressed:(){
            widget.onMode(ThemeMode.system);widget.onSeed(FlTokens.blue);
            widget.onGlass(2);
            setState((){_floating=true;_slide=true;_custom=false;
              _colorStyle=0;_scale=1;_font='跟随系统';});
          },icon:const Icon(Icons.restart_alt_rounded)),
        ])),
      Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(24,4,24,35),children:[
        const FlSection(title:'外观模式',icon:Icons.dark_mode_outlined),
        FlChoiceGroup<ThemeMode>(value:widget.mode,choices:const [
          FlChoice(ThemeMode.system,'跟随系统',preview:FlScreenThumb()),
          FlChoice(ThemeMode.light,'浅色',preview:FlScreenThumb()),
          FlChoice(ThemeMode.dark,'深色',preview:FlScreenThumb(dark:true)),
        ],onChanged:widget.onMode),
        const FlSection(title:'主题色',icon:Icons.palette_outlined),
        FlPanel(child:FlColorSwatches(colors:_colors,value:widget.seed,
          onChanged:widget.onSeed)),
        const SizedBox(height:10),
        FlGroup(children:[FlSettingRow(title:'配色风格',
          subtitle:const ['鲜明','柔和','自然'][0],
          trailing:Row(mainAxisSize:MainAxisSize.min,children:[
            Text(['鲜明','柔和','自然'][_colorStyle],style:TextStyle(color:flMuted(context))),
            const Icon(Icons.unfold_more_rounded)]),
          onTap:()async{
            final v=await flPick<int>(context,title:'配色风格',values:[0,1,2],
              label:(x)=>['鲜明','柔和','自然'][x],selected:_colorStyle);
            if(v!=null){setState(()=>_colorStyle=v);_save('color_style',v);}
          })]),
        const FlSection(title:'底栏',icon:Icons.layers_outlined),
        FlChoiceGroup<bool>(value:_floating,choices:[
          FlChoice(true,'悬浮',preview:FlScreenThumb(accent:widget.seed,glass:_glass)),
          FlChoice(false,'固定',preview:FlScreenThumb(accent:widget.seed,floating:false)),
        ],onChanged:(v){setState(()=>_floating=v);_save('floating',v);}),
        const FlSection(title:'选项卡动画',icon:Icons.motion_photos_on_outlined),
        FlChoiceGroup<bool>(value:_slide,choices:[
          FlChoice(true,'滑动',preview:FlScreenThumb(accent:widget.seed)),
          FlChoice(false,'淡入',preview:FlScreenThumb(accent:widget.seed,slide:false)),
        ],onChanged:(v){setState(()=>_slide=v);_save('slide',v);}),
        const FlSection(title:'液态玻璃',icon:Icons.water_drop_outlined),
        FlChoiceGroup<int>(value:_glass,choices:[
          FlChoice(0,'无',preview:FlScreenThumb(accent:widget.seed,glass:0)),
          FlChoice(1,'标准',preview:FlScreenThumb(accent:widget.seed,glass:1)),
          FlChoice(2,'极致',preview:FlScreenThumb(accent:widget.seed,glass:2)),
        ],onChanged:widget.onGlass),
        const SizedBox(height:14),
        FlGlassMaterialPreview(level:_glass),
        Padding(padding:const EdgeInsets.only(top:8),child:Text(
          '光学液态玻璃：官方 Shader 与背景捕获系统应用于悬浮导航。',
          style:TextStyle(fontSize:12,color:flMuted(context)))),
        const FlSection(title:'字体',icon:Icons.font_download_outlined),
        FlGroup(children:[FlSettingRow(title:_font,leading:const Text('Aa',
          style:TextStyle(fontWeight:FontWeight.bold,fontSize:23)),
          trailing:const Icon(Icons.chevron_right_rounded),
          onTap:()async{
            final v=await flPick<String>(context,title:'选择字体',
              values:['跟随系统','Roboto','monospace','serif'],label:(s)=>s,selected:_font);
            if(v!=null){setState(()=>_font=v);_save('font',v);}
          })]),
        const FlSection(title:'文本缩放',icon:Icons.text_fields_outlined),
        FlSegmented<bool>(values:const [false,true],
          label:(v)=>v?'自定义':'跟随系统',value:_custom,
          onChanged:(v){setState(()=>_custom=v);_save('custom_scale',v);}),
        const SizedBox(height:12),
        FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Row(children:[
            Text('Aa',style:TextStyle(fontSize:22*_scale,
              fontFamily:_font=='跟随系统'?null:_font)),
            const Spacer(),
            DecoratedBox(decoration:BoxDecoration(
              color:cs.surfaceContainerHigh,borderRadius:BorderRadius.circular(22)),
              child:Padding(padding:const EdgeInsets.symmetric(horizontal:14,vertical:6),
                child:Text('${(_scale*100).round()}%',style:const TextStyle(fontSize:15)))),
          ]),
          const SizedBox(height:10),
          Text('应用内的文字将以这个大小显示',style:TextStyle(
            fontSize:14*_scale,color:flMuted(context))),
          const SizedBox(height:12),
          Opacity(opacity:_custom?1:.55,child:IgnorePointer(ignoring:!_custom,
            child:FlDiscreteScale(value:_scale,onChanged:(v){
              setState(()=>_scale=v);_save('text_scale',v);
            }))),
        ])),
        const FlSection(title:'交互预览',icon:Icons.ondemand_video_outlined),
        FlPanel(child:Column(children:[
          const Align(alignment:Alignment.centerLeft,child:Text('实时主题预览',
            style:TextStyle(fontWeight:FontWeight.w600,fontSize:15))),
          const SizedBox(height:12),
          SizedBox(height:234,child:FlLivePreview(accent:widget.seed,
            floating:_floating,slide:_slide,glass:_glass,dark:dark)),
          const SizedBox(height:5),
          Text('点击预览底栏图标体验切换效果',
            style:TextStyle(color:flMuted(context),fontSize:12)),
        ])),
        const SizedBox(height:22),
        Padding(padding:const EdgeInsets.only(bottom:12),child:Center(
          child:Text('基于 FlClash 视觉体系重构 · 仅 UI 层',
            style:TextStyle(fontSize:12,color:flMuted(context))))),
      ])),
    ])));
  }
}

class FlControlsScreen extends StatefulWidget {
  const FlControlsScreen({super.key});
  @override
  State<FlControlsScreen> createState()=>_FlControlsScreenState();
}
class _FlControlsScreenState extends State<FlControlsScreen> {
  bool enabled=true,labels=false,overlay=true;
  double opacity=78,sensitivity=52;
  String preset='均衡';
  int polling=90;
  final options=['舒适','均衡','真实'];
  @override
  Widget build(BuildContext context)=>ListView(
    padding:const EdgeInsets.fromLTRB(24,16,24,130),children:[
      const Text('控件',style:TextStyle(fontSize:29,fontWeight:FontWeight.bold)),
      const SizedBox(height:7),Text('所有值只用于 UI 演示，不连接实际按键或触控逻辑',
        style:TextStyle(color:flMuted(context))),
      const FlSection(title:'显示设置',icon:Icons.visibility_outlined),
      FlGroup(children:[
        FlToggleRow(title:'显示控制组件',icon:Icons.widgets_outlined,value:enabled,
          onChanged:(v)=>setState(()=>enabled=v)),
        FlToggleRow(title:'文本标签',icon:Icons.text_fields_outlined,value:labels,
          onChanged:(v)=>setState(()=>labels=v)),
        FlToggleRow(title:'界面半透明',icon:Icons.layers_outlined,value:overlay,
          onChanged:(v)=>setState(()=>overlay=v)),
      ]),
      const FlSection(title:'控件样式',icon:Icons.style_outlined),
      FlSegmented<String>(values:options,label:(s)=>s,value:preset,
        onChanged:(v)=>setState(()=>preset=v)),
      const SizedBox(height:12),
      FlSliderPanel(title:'透明度',value:opacity,
        onChanged:(v)=>setState(()=>opacity=v)),
      const SizedBox(height:12),
      FlSliderPanel(title:'灵敏度预览',value:sensitivity,
        subtitle:'仅演示参数编辑控件，不修改设备行为',
        onChanged:(v)=>setState(()=>sensitivity=v)),
      const FlSection(title:'数值与选择',icon:Icons.tune_outlined),
      FlGroup(children:[
        FlSettingRow(title:'刷新率预览',subtitle:'本地展示数字，不控制屏幕帧率',
          trailing:FlStepCounter(value:polling,min:30,max:240,step:10,
            onChanged:(v)=>setState(()=>polling=v))),
        FlSettingRow(title:'交互模式',subtitle:preset,
          trailing:const Icon(Icons.chevron_right_rounded),onTap:()async{
            final picked=await flPick<String>(context,title:'选择交互模式',
              values:options,label:(s)=>s,selected:preset);
            if(picked!=null)setState(()=>preset=picked);
          }),
      ]),
    ]);
}

class FlProfilesScreen extends StatefulWidget {
  const FlProfilesScreen({super.key});
  @override
  State<FlProfilesScreen> createState()=>_FlProfilesScreenState();
}
class _FlProfilesScreenState extends State<FlProfilesScreen>{
  final names=['默认','轻量','沉浸'];
  String chosen='默认',query='';
  final schema=<Map<String,dynamic>>[
    {'id':'visual','name':'界面外观','type':'toggle','default':true,'debug':[
      {'id':'overlay','name':'显示浮窗','type':'toggle','default':true},
      {'id':'opacity','name':'透明度','type':'slider','default':84,'min':0,'max':100,'suffix':'%'},
      {'id':'color','name':'高亮颜色','type':'color'},
      {'id':'mode','name':'动画风格','type':'select','options':['柔和','标准','快速'],'default':'柔和'},
      {'id':'label','name':'配置说明','type':'text','default':'视觉预览'},
    ]},
    {'id':'bind','name':'参数编辑示例','type':'toggle','default':false,'debug':[
      {'id':'key','name':'键码编辑（UI 模拟）','type':'key','default':62},
      {'id':'binding','name':'区域与来源（UI 模拟）','type':'binding'},
      {'id':'list','name':'选项列表','type':'list','fields':[
        {'id':'name','name':'名称','type':'text','default':'新条目'},
        {'id':'action','name':'状态','type':'select','options':['开启','关闭'],'default':'开启'}]},
    ]},
    {'id':'action','name':'演示按钮','type':'button','buttonText':'仅触发 UI 提示'},
  ];
  @override
  Widget build(BuildContext context){
    final filtered=names.where((s)=>s.contains(query)).toList();
    return ListView(padding:const EdgeInsets.fromLTRB(24,16,24,130),children:[
      const Text('配置',style:TextStyle(fontSize:29,fontWeight:FontWeight.bold)),
      const SizedBox(height:14),
      TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search_rounded),
        hintText:'搜索配置'),onChanged:(v)=>setState(()=>query=v)),
      const FlSection(title:'外观方案',icon:Icons.folder_outlined),
      if(filtered.isNotEmpty) FlChoiceGroup<String>(value:chosen,choices:[
        for(final name in filtered) FlChoice(name,name,
          preview:const Icon(Icons.layers_outlined),subtitle:'仅变更本地 UI 选中状态'),
      ],onChanged:(v)=>setState(()=>chosen=v))
      else FlPanel(child:Text('没有匹配的方案',style:TextStyle(color:flMuted(context)))),
      const FlSection(title:'插件 UI 协议预览',icon:Icons.account_tree_outlined),
      const Text('使用全新的 FlClash 分组控件渲染声明式配置；无插件执行权限。',
        style:TextStyle(fontSize:13)),
      FlSchemaPanel(features:schema),
    ]);
  }
}
