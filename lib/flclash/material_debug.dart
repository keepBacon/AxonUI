import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'controls.dart';
import 'color_debug.dart';
import 'theme.dart';

class FlMaterialDebug extends StatefulWidget {
  const FlMaterialDebug({super.key});
  @override State<FlMaterialDebug> createState()=>_FlMaterialDebugState();
}
class _FlMaterialDebugState extends State<FlMaterialDebug> {
  double radius=24, sigma=10, shadow=18, border=1.5, tint=.56;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,
      children:[
        const Text('材质调试',style:TextStyle(
          fontSize:18,fontWeight:FontWeight.w700)),
        const SizedBox(height:12),
        SizedBox(height:132,child:Stack(children:[
          Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(22),
            gradient:LinearGradient(colors:[
              cs.primary.withValues(alpha:.36),
              cs.tertiary.withValues(alpha:.35)])))),
          Positioned(left:6,top:-27,
            child:Icon(Icons.blur_circular_rounded,size:170,
              color:cs.onSurface.withValues(alpha:.19))),
          Positioned(right:-12,bottom:-38,
            child:Icon(Icons.filter_vintage_rounded,size:168,
              color:cs.onSurface.withValues(alpha:.16))),
          Center(child:AnimatedContainer(
            key:const ValueKey('material-debug-preview'),
            duration:FlMotion.effective(context,FlMotion.regular),
            curve:FlMotion.curve,
            width:220,height:84,
            decoration:BoxDecoration(
              borderRadius:BorderRadius.circular(radius),
              boxShadow:[
                BoxShadow(color:cs.shadow.withValues(alpha:.19),
                  blurRadius:shadow,offset:const Offset(0,6))],
            ),
            child:ClipRRect(
              borderRadius:BorderRadius.circular(radius),
              child:BackdropFilter(
                filter:ImageFilter.blur(sigmaX:sigma,sigmaY:sigma),
                child:DecoratedBox(decoration:BoxDecoration(
                  color:cs.surface.withValues(alpha:tint),
                  borderRadius:BorderRadius.circular(radius),
                  border:Border.all(color:cs.onSurface.withValues(alpha:.22),
                    width:border)),
                  child:Center(child:Text('材质预览',style:TextStyle(
                    fontWeight:FontWeight.w700,color:cs.onSurface))),
                ),
              ),
            ),
          )),
        ])),
        const SizedBox(height:15),
        FlDebugSlider(label:'圆角',value:radius,min:4,max:40,suffix:'dp',
          onChanged:(v)=>setState(()=>radius=v)),
        FlDebugSlider(label:'高斯模糊',value:sigma,min:0,max:26,suffix:'σ',
          onChanged:(v)=>setState(()=>sigma=v)),
        FlDebugSlider(label:'阴影',value:shadow,min:0,max:40,
          onChanged:(v)=>setState(()=>shadow=v)),
        FlDebugSlider(label:'边框宽度',value:border,min:0,max:5,
          onChanged:(v)=>setState(()=>border=v)),
        FlDebugSlider(label:'材质透明度',value:tint*100,min:10,max:100,
          suffix:'%',onChanged:(v)=>setState(()=>tint=v/100)),
      ],
    ));
  }
}

class FlTypographyDebug extends StatefulWidget {
  const FlTypographyDebug({super.key});
  @override State<FlTypographyDebug> createState()=>_FlTypographyDebugState();
}
class _FlTypographyDebugState extends State<FlTypographyDebug> {
  double fontSize=22, letterSpacing=.5, lineHeight=1.25;
  int weight=500;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,
      children:[
        const Text('排版调试',style:TextStyle(
          fontWeight:FontWeight.w700,fontSize:18)),
        const SizedBox(height:12),
        AnimatedContainer(
          duration:FlMotion.effective(context,FlMotion.short),
          height:105,padding:const EdgeInsets.all(14),
          decoration:BoxDecoration(color:cs.surfaceContainerHigh,
            borderRadius:BorderRadius.circular(18)),
          child:Center(child:Text('Typography Aa 字体样式',
            key:const ValueKey('typography-debug-preview'),
            textAlign:TextAlign.center,
            maxLines:2,overflow:TextOverflow.ellipsis,
            style:TextStyle(fontSize:fontSize,letterSpacing:letterSpacing,
              height:lineHeight,fontWeight:FontWeight.values[(weight~/100)-1],
              color:cs.onSurface)))),
        const SizedBox(height:13),
        FlSegmented<int>(values:const [400,500,600,700],
          label:(v)=>'$v',value:weight,
          onChanged:(v)=>setState(()=>weight=v)),
        const SizedBox(height:8),
        FlDebugSlider(label:'字号',value:fontSize,min:12,max:36,suffix:'sp',
          onChanged:(v)=>setState(()=>fontSize=v)),
        FlDebugSlider(label:'字间距',value:letterSpacing,min:0,max:5,
          suffix:'px',onChanged:(v)=>setState(()=>letterSpacing=v)),
        FlDebugSlider(label:'行高',value:lineHeight*100,min:100,max:200,
          suffix:'%',onChanged:(v)=>setState(()=>lineHeight=v/100)),
      ],
    ));
  }
}

class FlSpacingDebug extends StatefulWidget {
  const FlSpacingDebug({super.key});
  @override State<FlSpacingDebug> createState()=>_FlSpacingDebugState();
}
class _FlSpacingDebugState extends State<FlSpacingDebug> {
  double padding=16,gap=12;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,
      children:[
        const Text('间距调试',style:TextStyle(
          fontWeight:FontWeight.w700,fontSize:18)),
        const SizedBox(height:12),
        AnimatedPadding(
          key:const ValueKey('spacing-debug-preview'),
          duration:FlMotion.effective(context,FlMotion.regular),
          curve:FlMotion.curve,
          padding:EdgeInsets.all(padding),
          child:DecoratedBox(
            decoration:BoxDecoration(color:cs.surfaceContainerHigh,
              borderRadius:BorderRadius.circular(19)),
            child:Padding(padding:const EdgeInsets.all(13),
              child:Row(children:[
                Expanded(child:_SpacingTile(color:cs.primary)),
                SizedBox(width:gap),
                Expanded(child:_SpacingTile(color:cs.tertiary)),
              ])),
          ),
        ),
        FlDebugSlider(label:'内边距',value:padding,min:0,max:40,
          suffix:'dp',onChanged:(v)=>setState(()=>padding=v)),
        FlDebugSlider(label:'组件间距',value:gap,min:0,max:40,
          suffix:'dp',onChanged:(v)=>setState(()=>gap=v)),
      ],
    ));
  }
}
class _SpacingTile extends StatelessWidget {
  const _SpacingTile({required this.color});
  final Color color;
  @override Widget build(BuildContext context)=>Container(
    height:52,decoration:BoxDecoration(
      color:color.withValues(alpha:.75),
      borderRadius:BorderRadius.circular(14)));
}
