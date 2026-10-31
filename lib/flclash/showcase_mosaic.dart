import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';

/// Presentation-only widgets. This file has no platform channel,
/// device listener, plugin runtime or key-event handling.
class FlShowcaseHero extends StatelessWidget {
  const FlShowcaseHero({super.key,required this.features});
  final int features;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return Container(
      key:const ValueKey('showcase-hero'),
      height:178,padding:const EdgeInsets.fromLTRB(20,19,14,18),
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
            Text('预览与交互',style:TextStyle(
              fontSize:12,color:cs.onSurfaceVariant)),
            const Spacer(),
            Row(children:[
              _value(context,'$features','展示项'),
              const SizedBox(width:17),
              _value(context,'4','分类页'),
            ]),
          ])),
        Expanded(flex:4,child:LayoutBuilder(builder:(context,box)=>
          Stack(alignment:Alignment.center,children:[
            Positioned(right:3,top:2,child:Transform.rotate(
              angle:.12,child:_tile(cs.tertiary.withValues(alpha:.20),
                Icons.palette_outlined,cs.primary,65))),
            Positioned(left:0,top:30,child:Transform.rotate(
              angle:-.13,child:_tile(cs.surface.withValues(alpha:.88),
                Icons.tune_rounded,cs.onSurface,74))),
            Positioned(right:16,bottom:5,child:_tile(
              cs.primary.withValues(alpha:.92),
              Icons.auto_awesome_motion_rounded,cs.onPrimary,64)),
          ]))),
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
  Widget _tile(Color bg,IconData icon,Color fg,double size)=>
    Container(width:size,height:size,alignment:Alignment.center,
      decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(20),
        boxShadow:const [BoxShadow(
          color:Color(0x13000000),blurRadius:13,offset:Offset(0,4))]),
      child:Icon(icon,size:28,color:fg));
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
                Icon(Icons.arrow_outward_rounded,size:18,
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
                  _key(cs,key,highlighted&&key=='W'),
              ]),
              Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                for(final key in ['A','S','D','F','G'])
                  _key(cs,key,highlighted&&key=='A'),
              ]),
              Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                _key(cs,'CTRL',false,w:44),
                _key(cs,'SPACE',highlighted,w:115),
                _key(cs,'ALT',false,w:43),
              ]),
            ],
          ))),
        const SizedBox(height:10),
        Text('模拟视觉反馈 · 不读取设备输入',
          style:TextStyle(fontSize:11,color:cs.onSurfaceVariant)),
      ],
    ));
  }
  Widget _key(ColorScheme cs,String label,bool active,{double w=34})=>
    AnimatedContainer(
      duration:FlMotion.effective(context,FlMotion.short),
      width:w,height:25,margin:const EdgeInsets.all(2),
      alignment:Alignment.center,
      decoration:BoxDecoration(
        color:active?cs.primary:cs.surface,
        borderRadius:BorderRadius.circular(7)),
      child:Text(label,style:TextStyle(
        fontWeight:FontWeight.w700,fontSize:10,
        color:active?cs.onPrimary:cs.onSurfaceVariant)),
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
