import 'package:flutter/material.dart';
import 'controls.dart';
import 'motion.dart';
import 'theme.dart';

/// Visual-only component specimens. No input devices, platform channels,
/// services, keyboard listeners, HUD overlays or mapping execution.
class FlAdditionalControls extends StatelessWidget {
  const FlAdditionalControls({super.key});
  @override Widget build(BuildContext context) => const Column(
    crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      FlSection(title:'外观预览',icon:Icons.style_outlined),
      FlPreviewStyle(),
      FlSection(title:'进度与状态',icon:Icons.data_usage_outlined),
      FlPreviewProgress(),
      SizedBox(height:12),
      FlPreviewChips(),
    ],
  );
}

class FlPreviewStyle extends StatefulWidget {
  const FlPreviewStyle({super.key});
  @override State<FlPreviewStyle> createState()=>_FlPreviewStyleState();
}
class _FlPreviewStyleState extends State<FlPreviewStyle>{
  double radius=18,opacity=86,border=2;
  bool gradient=true;
  int selected=0;
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    final first=cs.primary.withValues(alpha:opacity/100);
    final corners=BorderRadius.circular(radius);
    return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const Text('按键样式',style:TextStyle(fontSize:17,fontWeight:FontWeight.w600)),
      const SizedBox(height:14),
      Center(child:FlPressScale(pressedScale:.95,child:AnimatedContainer(
        key:const ValueKey('preview-key-style'),
        duration:FlMotion.effective(context,FlMotion.regular),
        curve:FlMotion.curve,
        width:136,height:74,alignment:Alignment.center,
        decoration:BoxDecoration(
          borderRadius:corners,
          gradient:gradient?LinearGradient(colors:[
            first,cs.tertiary.withValues(alpha:opacity/100)]):null,
          color:gradient?null:first,
          border:Border.all(color:cs.outlineVariant,width:border)),
        child:Text(const ['按键','圆角','描边'][selected],
          style:TextStyle(fontSize:17,fontWeight:FontWeight.w700,
            color:cs.onPrimary)),
      ))),
      const SizedBox(height:16),
      FlSegmented<int>(values:const [0,1,2],value:selected,
        label:(i)=>const ['默认','圆角','描边'][i],
        onChanged:(i)=>setState(()=>selected=i)),
      const SizedBox(height:13),
      _LabeledSlider(title:'圆角',value:radius,min:6,max:36,
        onChanged:(v)=>setState(()=>radius=v)),
      _LabeledSlider(title:'透明度',value:opacity,min:35,max:100,
        onChanged:(v)=>setState(()=>opacity=v)),
      _LabeledSlider(title:'边框',value:border,min:0,max:5,
        onChanged:(v)=>setState(()=>border=v)),
      SwitchListTile.adaptive(
        contentPadding:EdgeInsets.zero,title:const Text('渐变'),
        value:gradient,onChanged:(v)=>setState(()=>gradient=v)),
    ]));
  }
}
class _LabeledSlider extends StatelessWidget{
  const _LabeledSlider({required this.title,required this.value,
    required this.min,required this.max,required this.onChanged});
  final String title;
  final double value,min,max;
  final ValueChanged<double> onChanged;
  @override Widget build(BuildContext context)=>Column(children:[
    Row(children:[
      Expanded(child:Text(title)),
      Text('${value.round()}',style:TextStyle(color:flMuted(context))),
    ]),
    Slider(value:value,min:min,max:max,onChanged:onChanged),
  ]);
}

class FlPreviewProgress extends StatefulWidget{
  const FlPreviewProgress({super.key});
  @override State<FlPreviewProgress> createState()=>_FlPreviewProgressState();
}
class _FlPreviewProgressState extends State<FlPreviewProgress>{
  double value=.45;
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Row(children:[
        const Expanded(child:Text('进度',
          style:TextStyle(fontSize:17,fontWeight:FontWeight.w600))),
        Text('${(value*100).round()}%',
          style:TextStyle(fontWeight:FontWeight.w700,color:cs.primary)),
      ]),
      const SizedBox(height:15),
      TweenAnimationBuilder<double>(
        tween:Tween<double>(end:value),
        duration:FlMotion.effective(context,FlMotion.regular),
        curve:FlMotion.curve,
        builder:(context,v,_)=>LinearProgressIndicator(
          value:v,minHeight:9,borderRadius:BorderRadius.circular(9))),
      const SizedBox(height:7),
      Slider(key:const ValueKey('preview-progress-slider'),
        value:value,onChanged:(v)=>setState(()=>value=v)),
      Row(children:[
        Expanded(child:Text('圆环',style:TextStyle(color:flMuted(context)))),
        TweenAnimationBuilder<double>(
          tween:Tween<double>(end:value),
          duration:FlMotion.effective(context,FlMotion.regular),
          curve:FlMotion.curve,
          builder:(context,v,_)=>SizedBox(width:50,height:50,
            child:CircularProgressIndicator(value:v,strokeWidth:5.5))),
      ]),
    ]));
  }
}

class FlPreviewChips extends StatefulWidget {
  const FlPreviewChips({super.key});
  @override State<FlPreviewChips> createState()=>_FlPreviewChipsState();
}
class _FlPreviewChipsState extends State<FlPreviewChips>{
  final Set<String> selected={'Ctrl','A'};
  @override Widget build(BuildContext context)=>FlPanel(
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('组合标签',style:TextStyle(fontSize:17,fontWeight:FontWeight.w600)),
      const SizedBox(height:12),
      Wrap(spacing:8,runSpacing:7,children:[
        for(final name in const ['Ctrl','Shift','Alt','A','B','Space'])
          FilterChip(
            key:ValueKey('preview-chip-$name'),
            label:Text(name),selected:selected.contains(name),
            onSelected:(v)=>setState(() {
              if(v){selected.add(name);} else {selected.remove(name);}
            }),
          ),
      ]),
      const SizedBox(height:8),
      AnimatedSwitcher(
        duration:FlMotion.effective(context,FlMotion.short),
        child:Text(selected.isEmpty?'未选择':selected.join(' + '),
          key:ValueKey(selected.join(',')),
          style:TextStyle(color:Theme.of(context).colorScheme.primary)),
      ),
    ]),
  );
}
