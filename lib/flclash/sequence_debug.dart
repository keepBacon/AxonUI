import 'package:flutter/material.dart';
import 'controls.dart';
import 'color_debug.dart';
import 'theme.dart';

/// Editable multi-stop gradient preview inspired by an eight-color palette.
class FlColorSequenceDebug extends StatefulWidget {
  const FlColorSequenceDebug({super.key});
  @override State<FlColorSequenceDebug> createState()=>_FlColorSequenceDebugState();
}
class _FlColorSequenceDebugState extends State<FlColorSequenceDebug> {
  final stops=<Color>[
    const Color(0xFF468CF0),const Color(0xFF7C73DA),
    const Color(0xFFD98FC5),
  ];
  int active=0;
  double angle=0;
  static const palette=<Color>[
    Color(0xFF468CF0),Color(0xFF7C73DA),Color(0xFFD98FC5),
    Color(0xFFED9878),Color(0xFF50B7A7),Color(0xFF25334C),
    Color(0xFFF3CA6B),Color(0xFFFFFFFF),
  ];
  void swap(int target) {
    if(target<0||target>=stops.length)return;
    setState(() {
      final color=stops.removeAt(active);
      stops.insert(target,color);
      active=target;
    });
  }
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const Text('多色序列调试',style:TextStyle(fontSize:18,fontWeight:FontWeight.w700)),
      const SizedBox(height:12),
      AnimatedContainer(
        key:const ValueKey('color-sequence-preview'),
        height:96,
        duration:FlMotion.effective(context,FlMotion.regular),
        curve:FlMotion.curve,
        decoration:BoxDecoration(
          borderRadius:BorderRadius.circular(22),
          gradient:LinearGradient(
            colors:stops,
            transform:GradientRotation(angle*3.141592653589793/180)),
        )),
      const SizedBox(height:13),
      SizedBox(height:60,child:ListView(
        scrollDirection:Axis.horizontal,
        children:[
          for(var i=0;i<stops.length;i++)
            Padding(padding:const EdgeInsets.only(right:9),
              child:InkWell(
                key:ValueKey('color-stop-$i'),
                onTap:()=>setState(()=>active=i),
                borderRadius:BorderRadius.circular(16),
                child:AnimatedContainer(
                  duration:FlMotion.effective(context,FlMotion.short),
                  width:54,
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(16),
                    border:Border.all(
                      color:i==active?cs.primary:cs.outlineVariant,
                      width:i==active?3:1),
                    color:stops[i]),
                  child:Center(child:Text('${i+1}',
                    style:TextStyle(fontWeight:FontWeight.w700,
                      color:ThemeData.estimateBrightnessForColor(stops[i])
                        ==Brightness.dark?Colors.white:Colors.black))),
                )),
              ),
        ])),
      const SizedBox(height:7),
      Wrap(spacing:6,children:[
        IconButton.filledTonal(
          tooltip:'增加色标',key:const ValueKey('color-stop-add'),
          onPressed:stops.length>=8?null:()=>setState((){
            stops.add(stops[active]);active=stops.length-1;
          }),
          icon:const Icon(Icons.add_rounded)),
        IconButton.filledTonal(
          tooltip:'删除色标',
          onPressed:stops.length<=2?null:()=>setState((){
            stops.removeAt(active);
            active=active.clamp(0,stops.length-1);
          }),
          icon:const Icon(Icons.remove_rounded)),
        IconButton.filledTonal(tooltip:'左移色标',
          onPressed:active<=0?null:()=>swap(active-1),
          icon:const Icon(Icons.arrow_back_rounded)),
        IconButton.filledTonal(tooltip:'右移色标',
          onPressed:active>=stops.length-1?null:()=>swap(active+1),
          icon:const Icon(Icons.arrow_forward_rounded)),
      ]),
      const SizedBox(height:9),
      FlColorSwatches(colors:palette,value:stops[active],
        onChanged:(value)=>setState(()=>stops[active]=value)),
      FlDebugSlider(label:'序列角度',value:angle,min:0,max:360,suffix:'°',
        onChanged:(v)=>setState(()=>angle=v)),
    ]));
  }
}

class FlTextEffectsDebug extends StatefulWidget {
  const FlTextEffectsDebug({super.key});
  @override State<FlTextEffectsDebug> createState()=>_FlTextEffectsDebugState();
}
class _FlTextEffectsDebugState extends State<FlTextEffectsDebug> {
  double strokeWidth=1.4,shadowBlur=5,shadowOffset=3;
  Color fill=const Color(0xFFFFFFFF),stroke=const Color(0xFF29477F);
  bool outlined=true;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const Text('文字效果调试',style:TextStyle(fontSize:18,fontWeight:FontWeight.w700)),
      const SizedBox(height:12),
      DecoratedBox(decoration:BoxDecoration(color:cs.primary,
        borderRadius:BorderRadius.circular(19)),
        child:SizedBox(height:112,
          child:Center(child:Stack(alignment:Alignment.center,children:[
            if(outlined)
              Text('效果预览',key:const ValueKey('text-stroke-preview'),
                style:TextStyle(fontSize:30,fontWeight:FontWeight.w700,
                  foreground:Paint()
                    ..style=PaintingStyle.stroke
                    ..strokeWidth=strokeWidth
                    ..color=stroke)),
            Text('效果预览',style:TextStyle(
              fontSize:30,fontWeight:FontWeight.w700,color:fill,
              shadows:[Shadow(color:Colors.black.withValues(alpha:.36),
                blurRadius:shadowBlur,offset:Offset(0,shadowOffset))])),
          ]))),
      ),
      const SizedBox(height:12),
      SwitchListTile.adaptive(
        contentPadding:EdgeInsets.zero,title:const Text('文字描边'),
        value:outlined,onChanged:(v)=>setState(()=>outlined=v)),
      FlDebugSlider(label:'描边宽度',value:strokeWidth,
        min:0,max:7,suffix:'px',onChanged:(v)=>setState(()=>strokeWidth=v)),
      FlDebugSlider(label:'文字阴影',value:shadowBlur,min:0,max:26,
        onChanged:(v)=>setState(()=>shadowBlur=v)),
      FlDebugSlider(label:'阴影偏移',value:shadowOffset,min:0,max:14,
        onChanged:(v)=>setState(()=>shadowOffset=v)),
      const SizedBox(height:8),
      FlSegmented<int>(values:const [0,1],value:fill==Colors.white?0:1,
        label:(v)=>v==0?'浅色文字':'深色文字',
        onChanged:(v)=>setState(() {
          fill=v==0?Colors.white:const Color(0xFF22314D);
          stroke=v==0?const Color(0xFF29477F):Colors.white;
        })),
    ]));
  }
}
