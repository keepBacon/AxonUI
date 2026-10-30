import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'controls.dart';
import 'color_debug.dart';
import 'theme.dart';

/// Animation preview only. The ticker is active exclusively while "播放" runs.
class FlAnimationDebug extends StatefulWidget {
  const FlAnimationDebug({super.key});
  @override State<FlAnimationDebug> createState()=>_FlAnimationDebugState();
}
class _FlAnimationDebugState extends State<FlAnimationDebug>
    with SingleTickerProviderStateMixin {
  double durationMs=480;
  double translation=24, scale=.78, rotation=12, fromOpacity=.35;
  int easing=0;
  late final AnimationController controller;

  static const curves=[
    Curves.easeOutCubic,Curves.easeInOutCubic,
    Curves.easeOutBack,Curves.elasticOut,Curves.linear,
  ];
  static const names=['柔和','平滑','回弹','弹性','线性'];

  @override void initState(){
    super.initState();
    controller=AnimationController(
      vsync:this,duration:Duration(milliseconds:durationMs.round()),
      value:1,
    );
  }
  @override void dispose(){controller.dispose();super.dispose();}
  void play(){
    if(MediaQuery.disableAnimationsOf(context)){
      controller.value=1;
      return;
    }
    controller.duration=Duration(milliseconds:durationMs.round());
    controller.forward(from:0);
  }

  @override Widget build(BuildContext context) {
    final scheme=Theme.of(context).colorScheme;
    return FlPanel(child:Column(
      crossAxisAlignment:CrossAxisAlignment.stretch,
      children:[
        const Text('动画调试',style:TextStyle(
          fontSize:18,fontWeight:FontWeight.w700)),
        const SizedBox(height:12),
        SizedBox(height:142,child:DecoratedBox(
          decoration:BoxDecoration(
            color:scheme.surfaceContainerHigh,
            borderRadius:BorderRadius.circular(22)),
          child:AnimatedBuilder(
            animation:controller,
            builder:(context,child){
              final raw=curves[easing].transform(controller.value);
              final t=raw.clamp(0.0,1.15).toDouble();
              final opacity=(fromOpacity+(1-fromOpacity)*t).clamp(0.0,1.0);
              final zoom=(scale+(1-scale)*t).clamp(.1,2.0);
              return Center(child:Transform.translate(
                offset:Offset(translation*(1-t),0),
                child:Transform.rotate(
                  angle:rotation*(1-t)*math.pi/180,
                  child:Transform.scale(scale:zoom,
                    child:Opacity(
                      key:const ValueKey('animation-debug-opacity'),
                      opacity:opacity,
                      child:child))))),
              );
            },
            child:Container(width:122,height:62,alignment:Alignment.center,
              decoration:BoxDecoration(
                color:scheme.primary,borderRadius:BorderRadius.circular(20)),
              child:Text('预览',style:TextStyle(
                fontWeight:FontWeight.w700,fontSize:17,
                color:scheme.onPrimary))),
          ),
        )),
        const SizedBox(height:12),
        FlSegmented<int>(values:const [0,1,2,3,4],value:easing,
          label:(v)=>names[v],
          onChanged:(v)=>setState(()=>easing=v)),
        const SizedBox(height:11),
        FlDebugSlider(label:'动画时长',value:durationMs,
          min:120,max:1400,suffix:'ms',
          onChanged:(v)=>setState(() {
            durationMs=v;
            controller.duration=Duration(milliseconds:v.round());
          })),
        FlDebugSlider(label:'位移',value:translation,
          min:0,max:80,suffix:'px',
          onChanged:(v)=>setState(()=>translation=v)),
        FlDebugSlider(label:'初始缩放',value:scale*100,
          min:50,max:100,suffix:'%',
          onChanged:(v)=>setState(()=>scale=v/100)),
        FlDebugSlider(label:'旋转角度',value:rotation,
          min:0,max:45,suffix:'°',
          onChanged:(v)=>setState(()=>rotation=v)),
        FlDebugSlider(label:'初始透明度',value:fromOpacity*100,
          min:0,max:100,suffix:'%',
          onChanged:(v)=>setState(()=>fromOpacity=v/100)),
        const SizedBox(height:8),
        Row(children:[
          Expanded(child:FilledButton.icon(
            key:const ValueKey('animation-debug-play'),
            onPressed:play,
            icon:const Icon(Icons.play_arrow_rounded),
            label:const Text('播放动画'),
          )),
          const SizedBox(width:8),
          OutlinedButton.icon(
            key:const ValueKey('animation-debug-reset'),
            onPressed:()=>controller.value=1,
            icon:const Icon(Icons.replay_rounded),label:const Text('复位'),
          ),
        ]),
      ],
    ));
  }
}
