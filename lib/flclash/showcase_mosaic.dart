import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';
import 'motion.dart';

/// Presentation-only widgets. This file has no platform channel,
/// device listener, plugin runtime or key-event handling.
class FlShowcaseHero extends StatelessWidget {
  const FlShowcaseHero({super.key,required this.features,this.glass=2});
  final int features,glass;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return Container(
      key:const ValueKey('showcase-hero'),
      height:194,padding:const EdgeInsets.fromLTRB(20,19,14,18),
      decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(29),
        gradient:LinearGradient(
          begin:Alignment.topLeft,end:Alignment.bottomRight,
          colors:[cs.primary.withValues(alpha:.18),
            cs.tertiary.withValues(alpha:.095),
            cs.surface.withValues(alpha:.92)]),
        border:Border.all(color:cs.primary.withValues(alpha:.095))),
      child:Row(children:[
        Expanded(flex:5,child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('组件概览',style:TextStyle(
              color:cs.onSurface,fontWeight:FontWeight.w700,fontSize:19)),
            const SizedBox(height:5),
            Text('交互式 UI 展示 · 仅本地状态',style:TextStyle(
              fontSize:11,color:cs.onSurfaceVariant)),
            const Spacer(),
            Row(children:[
              _value(context,'$features','展示项'),
              const SizedBox(width:17),
              _value(context,'4','分类页'),
            ]),
            const SizedBox(height:7),
            Text('当前主题：'+(Theme.of(context).brightness==Brightness.dark?'深色':'浅色'),
              style:TextStyle(fontSize:11,color:cs.onSurfaceVariant)),
            Text('当前材质：'+(glass==0?'普通':glass==1?'标准玻璃':'强玻璃'),
              style:TextStyle(fontSize:11,color:cs.onSurfaceVariant)),
          ])),
        const Expanded(flex:4,child:FlHeroMiniPreview()),
      ]),
    );
  }
  Widget _value(BuildContext context,String v,String caption)=>
    Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(v,style:TextStyle(fontSize:22,fontWeight:FontWeight.w800,
        color:Theme.of(context).colorScheme.primary)),
      Text(caption,style:TextStyle(fontSize:11,
        color:Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
}

class FlShowcaseCategoryTile extends StatelessWidget {
  const FlShowcaseCategoryTile({
    super.key,required this.title,required this.detail,
    required this.icon,required this.onTap,this.highlight=false,
  });
  final String title,detail;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return FlPressScale(pressedScale:.975,child:Material(
      color:highlight ? cs.primary.withValues(alpha:.12) : flSurface(context),
      borderRadius:BorderRadius.circular(25),
      clipBehavior:Clip.antiAlias,
      child:InkWell(
        key:ValueKey('showcase-category-$title'),
        onTap:onTap,
        child:Padding(padding:const EdgeInsets.all(15),
          child:Column(
            crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[
                Icon(icon,size:25,color:cs.primary),
                const Spacer(),
                FlCategoryMiniature(kind:title),
                const SizedBox(width:4),
                Icon(Icons.arrow_outward_rounded,size:16,
                  color:cs.onSurfaceVariant),
              ]),
              const Spacer(),
              Text(title,maxLines:1,style:TextStyle(
                color:cs.onSurface,fontSize:17,fontWeight:FontWeight.w700)),
              const SizedBox(height:4),
              Text(detail,maxLines:1,overflow:TextOverflow.ellipsis,
                style:TextStyle(color:cs.onSurfaceVariant,fontSize:11)),
            ])),
      ),
    ));
  }
}

/// Each tile renders a different small visual instead of a repeated icon.
class FlShowcaseSpecimenTile extends StatelessWidget {
  const FlShowcaseSpecimenTile({
    super.key,required this.title,required this.kind,
    this.onTap,this.caption,
  });
  final String title,kind;
  final String? caption;
  final VoidCallback? onTap;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    final child=Container(
      key:ValueKey('specimen-$title'),
      constraints:const BoxConstraints(minHeight:133),
      padding:const EdgeInsets.fromLTRB(14,13,14,12),
      decoration:BoxDecoration(
        color:flSurface(context),borderRadius:BorderRadius.circular(23)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          Expanded(child:Text(title,maxLines:1,
            overflow:TextOverflow.ellipsis,style:TextStyle(
              fontSize:14,color:cs.onSurface,
              fontWeight:FontWeight.w600))),
          if(onTap!=null)Icon(Icons.chevron_right_rounded,
            size:17,color:cs.onSurfaceVariant),
        ]),
        const SizedBox(height:12),
        SizedBox(height:57,child:Center(child:_specimen(context))),
        if(caption!=null)...[
          const SizedBox(height:8),
          Text(caption!,maxLines:1,overflow:TextOverflow.ellipsis,
            style:TextStyle(fontSize:10,color:cs.onSurfaceVariant)),
        ],
      ]),
    );
    if(onTap==null)return child;
    return FlPressScale(pressedScale:.97,child:Material(
      color:Colors.transparent,
      borderRadius:BorderRadius.circular(23),
      clipBehavior:Clip.antiAlias,
      child:InkWell(onTap:onTap,child:child)));
  }
  Widget _specimen(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    switch(kind){
      case 'keys':
        return Wrap(spacing:3,runSpacing:3,alignment:WrapAlignment.center,
          children:[
            for(final x in ['W','A','S','D'])
              Container(width:24,height:25,alignment:Alignment.center,
                decoration:BoxDecoration(
                  color:x=='W'?cs.primary:cs.surfaceContainerHigh,
                  borderRadius:BorderRadius.circular(7)),
                child:Text(x,style:TextStyle(fontSize:10,
                  fontWeight:FontWeight.w700,
                  color:x=='W'?cs.onPrimary:cs.onSurface))),
          ]);
      case 'gamepad':
        return Icon(Icons.sports_esports_outlined,
          size:55,color:cs.primary);
      case 'color':
        return Row(mainAxisAlignment:MainAxisAlignment.center,children:[
          for(final c in [cs.primary,cs.tertiary,cs.secondary])
            Container(width:24,height:35,margin:const EdgeInsets.symmetric(horizontal:2),
              decoration:BoxDecoration(color:c,
                borderRadius:BorderRadius.circular(10))),
        ]);
      case 'switch':
        return DecoratedBox(decoration:BoxDecoration(
          color:cs.primary.withValues(alpha:.13),
          borderRadius:BorderRadius.circular(25)),
          child:Padding(padding:const EdgeInsets.all(7),
            child:Icon(Icons.toggle_on_rounded,color:cs.primary,size:44)));
      case 'slider':
        return SizedBox(width:116,child:Stack(alignment:Alignment.center,children:[
          Container(height:6,decoration:BoxDecoration(
            color:cs.outlineVariant,borderRadius:BorderRadius.circular(9))),
          Align(alignment:Alignment.centerLeft,child:Container(
            width:77,height:6,decoration:BoxDecoration(
              color:cs.primary,borderRadius:BorderRadius.circular(9)))),
          Align(alignment:const Alignment(.25,0),child:CircleAvatar(
            radius:8,backgroundColor:cs.primary)),
        ]));
      case 'text':
        return Text('Aa',style:TextStyle(
          fontSize:36,fontWeight:FontWeight.w800,color:cs.primary));
      case 'glass':
        return Container(width:90,height:48,
          alignment:Alignment.center,
          decoration:BoxDecoration(
            gradient:LinearGradient(colors:[
              cs.primary.withValues(alpha:.26),
              cs.surface.withValues(alpha:.83)]),
            border:Border.all(color:cs.onSurface.withValues(alpha:.13)),
            borderRadius:BorderRadius.circular(19)),
          child:Icon(Icons.blur_on_rounded,color:cs.primary));
      default:
        return Icon(Icons.auto_awesome_motion_outlined,
          size:43,color:cs.primary);
    }
  }
}

class FlShowcaseSpecimenGrid extends StatelessWidget {
  const FlShowcaseSpecimenGrid({super.key,required this.children});
  final List<Widget> children;
  @override Widget build(BuildContext context)=>LayoutBuilder(
    builder:(context,bounds){
      final width=(bounds.maxWidth-10)/2;
      return Wrap(spacing:10,runSpacing:10,
        children:[for(final child in children)
          SizedBox(width:width,child:child)]);
    },
  );
}

/// Visual keyboard sample; the toggle is local to the demo.
class FlKeyboardShowcaseSample extends StatefulWidget {
  const FlKeyboardShowcaseSample({super.key});
  @override State<FlKeyboardShowcaseSample> createState()=>
    _FlKeyboardShowcaseSampleState();
}
class _FlKeyboardShowcaseSampleState
    extends State<FlKeyboardShowcaseSample> {
  bool highlighted=true;
  int presses=8;
  String lastKey='W';
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return FlPanel(padding:const EdgeInsets.all(17),child:Column(
      crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[
          Expanded(child:Text('按键样式预览',
            style:TextStyle(fontSize:16,fontWeight:FontWeight.w700,
              color:cs.onSurface))),
          Switch.adaptive(
            key:const ValueKey('keyboard-demo-switch'),
            value:highlighted,onChanged:(v)=>setState(()=>highlighted=v)),
        ]),
        Container(height:113,alignment:Alignment.center,
          decoration:BoxDecoration(
            color:cs.surfaceContainerHigh,
            borderRadius:BorderRadius.circular(19)),
          child:FittedBox(fit:BoxFit.scaleDown,child:Column(
            mainAxisSize:MainAxisSize.min,children:[
              Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                for(final key in ['Q','W','E','R','T','Y'])
                  _key(cs,key,highlighted&&key==lastKey),
              ]),
              Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                for(final key in ['A','S','D','F','G'])
                  _key(cs,key,highlighted&&key==lastKey),
              ]),
              Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                _key(cs,'CTRL',false,w:44),
                _key(cs,'SPACE',highlighted&&lastKey=='SPACE',w:115),
                _key(cs,'ALT',false,w:43),
              ]),
            ],
          ))),
        const SizedBox(height:10),
        Row(children:[
          _mouseButton(cs,'LMB',highlighted),
          const SizedBox(width:6),
          _mouseButton(cs,'RMB',false),
          const Spacer(),
          Text('CPS 示例 ${highlighted?presses:0}',
            key:const ValueKey('keyboard-demo-cps'),
            style:TextStyle(color:cs.primary,fontWeight:FontWeight.w700,
              fontSize:12)),
        ]),
        const SizedBox(height:8),
        Text('点击键帽可模拟反馈 · 不读取设备输入',
          style:TextStyle(fontSize:11,color:cs.onSurfaceVariant)),
      ],
    ));
  }
  Widget _key(ColorScheme cs,String label,bool active,{double w=34})=>
    GestureDetector(
      key:ValueKey('keyboard-key-$label'),
      behavior:HitTestBehavior.opaque,
      onTap:()=>setState((){lastKey=label;presses++;highlighted=true;}),
      child:AnimatedContainer(
        duration:FlMotion.effective(context,FlMotion.short),
        width:w,height:25,margin:const EdgeInsets.all(2),
        alignment:Alignment.center,
        decoration:BoxDecoration(
          color:active?cs.primary:cs.surface,
          borderRadius:BorderRadius.circular(7)),
        child:Text(label,style:TextStyle(
          fontWeight:FontWeight.w700,fontSize:10,
          color:active?cs.onPrimary:cs.onSurfaceVariant)),
      ),
    );
  Widget _mouseButton(ColorScheme cs,String label,bool active)=>
    InkWell(
      key:ValueKey('keyboard-mouse-$label'),
      borderRadius:BorderRadius.circular(9),
      onTap:()=>setState((){lastKey=label;presses++;highlighted=true;}),
      child:Container(
        padding:const EdgeInsets.symmetric(horizontal:11,vertical:7),
        decoration:BoxDecoration(
          color:active?cs.primary.withValues(alpha:.16):cs.surfaceContainerHigh,
          borderRadius:BorderRadius.circular(9)),
        child:Text(label,style:TextStyle(
          fontSize:11,fontWeight:FontWeight.w700,color:cs.onSurface)),
      ),
    );
}

class FlPluginWorkbench extends StatefulWidget {
  const FlPluginWorkbench({super.key});
  @override State<FlPluginWorkbench> createState()=>_FlPluginWorkbenchState();
}
class _FlPluginWorkbenchState extends State<FlPluginWorkbench> {
  bool enabled=true;
  double level=42;
  int choice=0;
  int shade=0;
  final samples=<Color>[
    const Color(0xFF4886E0),const Color(0xFF63BBAA),
    const Color(0xFFB789CB),const Color(0xFFF0A775)];
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      FlPanel(padding:const EdgeInsets.fromLTRB(17,12,17,12),
        child:Row(children:[
          Icon(Icons.extension_outlined,size:22,color:cs.primary),
          const SizedBox(width:12),
          const Expanded(child:Column(
            crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('功能开关',style:TextStyle(fontSize:16,
                fontWeight:FontWeight.w700)),
              SizedBox(height:2),
              Text('本地预览',style:TextStyle(fontSize:11)),
            ],
          )),
          Switch.adaptive(
            key:const ValueKey('plugin-demo-switch'),
            value:enabled,onChanged:(v)=>setState(()=>enabled=v)),
        ])),
      const SizedBox(height:10),
      FlPanel(padding:const EdgeInsets.fromLTRB(15,15,15,12),child:Column(
        crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          FlSegmented<int>(values:const [0,1,2],
            label:(v)=>const ['默认','选项一','选项二'][v],
            value:choice,onChanged:(v)=>setState(()=>choice=v)),
          const SizedBox(height:11),
          Row(children:[
            const Expanded(child:Text('数值滑块')),
            Text('${level.round()}',
              style:TextStyle(fontWeight:FontWeight.w700,
                color:cs.primary)),
          ]),
          Slider(
            key:const ValueKey('plugin-demo-slider'),
            value:level,min:0,max:100,
            onChanged:(v)=>setState(()=>level=v)),
        ])),
      const SizedBox(height:10),
      FlShowcaseSpecimenGrid(children:[
        FlPanel(padding:const EdgeInsets.all(12),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('颜色选择',style:TextStyle(fontSize:13,
              fontWeight:FontWeight.w700)),
            const SizedBox(height:11),
            Wrap(spacing:7,runSpacing:7,children:[
              for(var i=0;i<samples.length;i++)
                GestureDetector(
                  onTap:()=>setState(()=>shade=i),
                  child:AnimatedContainer(
                    key:ValueKey('plugin-swatch-$i'),
                    duration:FlMotion.effective(context,FlMotion.short),
                    width:27,height:27,
                    decoration:BoxDecoration(
                      color:samples[i],shape:BoxShape.circle,
                      border:Border.all(
                        color:i==shade?cs.onSurface:Colors.transparent,
                        width:2.2)),
                    child:i==shade?const Icon(Icons.check,
                      size:14,color:Colors.white):null),
                ),
            ]),
            const SizedBox(height:9),
            Text('色板',style:TextStyle(
              fontSize:11,color:cs.onSurfaceVariant)),
          ],
        )),
        FlPanel(padding:const EdgeInsets.all(12),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('文本输入',style:TextStyle(fontSize:13,
              fontWeight:FontWeight.w700)),
            const SizedBox(height:8),
            TextField(
              key:const ValueKey('plugin-demo-text'),
              decoration:InputDecoration(
                isDense:true,hintText:'请输入文本',
                contentPadding:const EdgeInsets.symmetric(
                  horizontal:10,vertical:12)),
            ),
            const SizedBox(height:8),
            Text('UI 状态独立',style:TextStyle(
              fontSize:11,color:cs.onSurfaceVariant)),
          ],
        )),
      ]),
    ]);
  }
}


/// Compact stateful specimen in the hero; taps change only this preview.
class FlHeroMiniPreview extends StatefulWidget {
  const FlHeroMiniPreview({super.key});
  @override State<FlHeroMiniPreview> createState()=>_FlHeroMiniPreviewState();
}
class _FlHeroMiniPreviewState extends State<FlHeroMiniPreview> {
  int sample=0;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    final shades=[cs.primary,cs.tertiary,cs.secondary];
    final color=shades[sample];
    return InkWell(
      key:const ValueKey('hero-live-preview'),
      onTap:()=>setState(()=>sample=(sample+1)%shades.length),
      borderRadius:BorderRadius.circular(23),
      child:AnimatedContainer(
        duration:FlMotion.effective(context,FlMotion.regular),
        curve:Curves.easeOutCubic,
        padding:const EdgeInsets.all(10),
        decoration:BoxDecoration(
          color:color.withValues(alpha:.14),
          borderRadius:BorderRadius.circular(23),
          border:Border.all(color:color.withValues(alpha:.22))),
        child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          Text('动态小样',style:TextStyle(fontSize:10,
            color:cs.onSurfaceVariant)),
          const SizedBox(height:9),
          AnimatedContainer(
            duration:FlMotion.effective(context,FlMotion.regular),
            width:48,height:48,
            decoration:BoxDecoration(color:color,shape:BoxShape.circle),
            child:Icon(Icons.auto_awesome_rounded,color:cs.onPrimary,size:24)),
          const SizedBox(height:10),
          Row(mainAxisAlignment:MainAxisAlignment.center,children:[
            for(var i=0;i<shades.length;i++)
              Container(width:i==sample?15:6,height:6,
                margin:const EdgeInsets.symmetric(horizontal:2),
                decoration:BoxDecoration(
                  color:i==sample?color:cs.outlineVariant,
                  borderRadius:BorderRadius.circular(5))),
          ]),
          const SizedBox(height:5),
          Text('轻触切换',style:TextStyle(fontSize:9,
            color:cs.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

/// Meaningful category illustrations instead of identical right-side icons.
class FlCategoryMiniature extends StatelessWidget {
  const FlCategoryMiniature({super.key,required this.kind});
  final String kind;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    Widget child;
    if(kind=='键显'||kind=='键鼠'){
      child=Wrap(spacing:2,children:[
        for(final k in ['W','A','S','D'])
          Container(width:13,height:16,alignment:Alignment.center,
            decoration:BoxDecoration(
              color:k=='W'?cs.primary:cs.surfaceContainerHighest,
              borderRadius:BorderRadius.circular(4)),
            child:Text(k,style:TextStyle(fontSize:8,
              color:k=='W'?cs.onPrimary:cs.onSurface))),
      ]);
    }else if(kind=='插件'){
      child=Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        Icon(Icons.toggle_on_rounded,size:27,color:cs.primary),
        const SizedBox(width:3),
        Container(width:19,height:5,decoration:BoxDecoration(
          color:cs.tertiary,borderRadius:BorderRadius.circular(5))),
      ]);
    }else if(kind=='手柄'){
      child=Icon(Icons.sports_esports_rounded,size:29,color:cs.primary);
    }else{
      child=Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        for(final c in [cs.primary,cs.tertiary,cs.secondary])
          Container(width:13,height:19,margin:const EdgeInsets.all(2),
            decoration:BoxDecoration(color:c,
              borderRadius:BorderRadius.circular(6))),
      ]);
    }
    return SizedBox(key:ValueKey('category-thumb-$kind'),
      width:73,height:26,child:Center(child:child));
  }
}

/// Horizontal strip deliberately breaks up the two-column card rhythm.
class FlShowcasePreviewRibbon extends StatelessWidget {
  const FlShowcasePreviewRibbon({super.key});
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return SingleChildScrollView(
      key:const ValueKey('showcase-ribbon'),
      scrollDirection:Axis.horizontal,
      child:Row(children:[
        _chip(cs,Icons.touch_app_rounded,'按压反馈'),
        _chip(cs,Icons.water_drop_outlined,'液态材质'),
        _chip(cs,Icons.palette_outlined,'动态配色'),
        _chip(cs,Icons.motion_photos_on_rounded,'页面过渡'),
      ]),
    );
  }
  Widget _chip(ColorScheme cs,IconData icon,String label)=>Container(
    margin:const EdgeInsets.only(right:8),
    padding:const EdgeInsets.symmetric(horizontal:13,vertical:11),
    decoration:BoxDecoration(
      color:cs.surfaceContainerLow,borderRadius:BorderRadius.circular(16)),
    child:Row(mainAxisSize:MainAxisSize.min,children:[
      Icon(icon,size:19,color:cs.primary),
      const SizedBox(width:7),
      Text(label,style:TextStyle(fontSize:12,color:cs.onSurface)),
    ]),
  );
}

/// Reorder and binding samples use local state; no plugin executor is involved.
class FlPluginEditorPreview extends StatefulWidget {
  const FlPluginEditorPreview({super.key});
  @override State<FlPluginEditorPreview> createState()=>_FlPluginEditorPreviewState();
}
class _FlPluginEditorPreviewState extends State<FlPluginEditorPreview> {
  final items=['显示层','触控层','动效层'];
  final selected=<String>{'显示层'};
  bool bound=false;
  void _moveUp(int index){
    if(index==0)return;
    setState((){
      final item=items.removeAt(index);
      items.insert(index-1,item);
    });
  }
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return FlPanel(padding:const EdgeInsets.all(15),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[
          Icon(Icons.drag_indicator_rounded,color:cs.primary),
          const SizedBox(width:8),
          Expanded(child:Text('排序与多选',style:TextStyle(
            fontSize:14,fontWeight:FontWeight.w700,color:cs.onSurface))),
          Text('本地状态',style:TextStyle(fontSize:10,
            color:cs.onSurfaceVariant)),
        ]),
        const SizedBox(height:8),
        for(var i=0;i<items.length;i++)
          Padding(padding:const EdgeInsets.only(bottom:4),child:Row(children:[
            Checkbox(
              key:ValueKey('plugin-check-$i'),
              value:selected.contains(items[i]),
              onChanged:(v)=>setState((){
                if(v==true){selected.add(items[i]);}
                else{selected.remove(items[i]);}
              })),
            Expanded(child:Text(items[i],style:TextStyle(color:cs.onSurface))),
            IconButton(
              key:ValueKey('plugin-move-$i'),
              tooltip:'上移'+items[i],
              icon:const Icon(Icons.arrow_upward_rounded,size:19),
              onPressed:i==0?null:()=>_moveUp(i)),
          ])),
        const Divider(height:16),
        Row(children:[
          Icon(Icons.keyboard_rounded,size:19,color:cs.primary),
          const SizedBox(width:8),
          Expanded(child:Text(bound?'快捷键 · Ctrl + K':'快捷键 · 未绑定',
            style:TextStyle(fontSize:12,color:cs.onSurface))),
          TextButton(
            key:const ValueKey('plugin-demo-bind'),
            onPressed:()=>setState(()=>bound=!bound),
            child:Text(bound?'清除':'模拟绑定')),
        ]),
      ]),
    );
  }
}
