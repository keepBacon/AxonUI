import 'package:flutter/material.dart';
import 'controls.dart';
import 'motion.dart';
import 'theme.dart';

/// Visual-only component specimens. No input devices, platform channels,
/// services, keyboard listeners, HUD overlays or mapping execution.
class FlAdditionalControls extends StatelessWidget {
  const FlAdditionalControls({super.key});
  @override Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      FlSection(title:'摇杆与方向', icon:Icons.sports_esports_outlined),
      FlPanel(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text('双摇杆',style:TextStyle(fontSize:17,fontWeight:FontWeight.w600)),
        SizedBox(height:14),
        Wrap(spacing:16,runSpacing:12,alignment:WrapAlignment.center,children:[
          FlPreviewJoystick(title:'左摇杆'),
          FlPreviewJoystick(title:'右摇杆'),
        ]),
      ])),
      SizedBox(height:12),
      FlPanel(child:FlPreviewDpad()),
      FlSection(title:'触控区域',icon:Icons.touch_app_outlined),
      FlPanel(child:FlPreviewTrackpad()),
      FlSection(title:'外观参数',icon:Icons.style_outlined),
      FlPreviewStyle(),
      FlSection(title:'进度与状态',icon:Icons.data_usage_outlined),
      FlPreviewProgress(),
      SizedBox(height:12),
      FlPreviewChips(),
    ],
  );
}

class FlPreviewJoystick extends StatefulWidget {
  const FlPreviewJoystick({super.key,required this.title});
  final String title;
  @override State<FlPreviewJoystick> createState()=>_FlPreviewJoystickState();
}
class _FlPreviewJoystickState extends State<FlPreviewJoystick>{
  Offset value=Offset.zero;
  bool active=false;
  void change(Offset local) {
    var p=local-const Offset(64,64);
    if(p.distance>39) p=p*(39/p.distance);
    setState(() {value=p;active=true;});
  }
  void release()=>setState(() {value=Offset.zero;active=false;});
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return SizedBox(width:128,child:Column(children:[
      GestureDetector(
        key:ValueKey('preview-stick-${widget.title}'),
        behavior:HitTestBehavior.opaque,
        onPanStart:(d)=>change(d.localPosition),
        onPanUpdate:(d)=>change(d.localPosition),
        onPanEnd:(_)=>release(), onPanCancel:release,
        child:SizedBox(width:128,height:128,child:Stack(
          alignment:Alignment.center,children:[
            DecoratedBox(decoration:BoxDecoration(
              shape:BoxShape.circle,color:cs.surfaceContainerHigh,
              border:Border.all(color:cs.outlineVariant)),
              child:const SizedBox(width:128,height:128)),
            DecoratedBox(decoration:BoxDecoration(shape:BoxShape.circle,
              border:Border.all(color:cs.primary.withValues(alpha:.17),width:2)),
              child:const SizedBox(width:87,height:87)),
            AnimatedAlign(
              duration:FlMotion.effective(context,
                active?Duration.zero:FlMotion.release),
              curve:Curves.easeOutCubic,
              alignment:Alignment(value.dx/39*.68,value.dy/39*.68),
              child:Container(width:48,height:48,decoration:BoxDecoration(
                color:cs.primary,shape:BoxShape.circle,
                boxShadow:[BoxShadow(
                  color:cs.primary.withValues(alpha:.20),
                  blurRadius:13,offset:const Offset(0,4))])),
            ),
          ])),
      ),
      const SizedBox(height:8),
      Text(widget.title,style:const TextStyle(fontWeight:FontWeight.w600)),
    ]));
  }
}

class FlPreviewDpad extends StatefulWidget {
  const FlPreviewDpad({super.key});
  @override State<FlPreviewDpad> createState()=>_FlPreviewDpadState();
}
class _FlPreviewDpadState extends State<FlPreviewDpad>{
  String selected='';
  Widget button(String id,IconData glyph){
    final cs=Theme.of(context).colorScheme;
    final isSelected=id==selected;
    return FlPressScale(pressedScale:.91,child:AnimatedContainer(
      duration:FlMotion.effective(context,FlMotion.short),
      decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(16),
        color:isSelected?cs.primary:cs.surfaceContainerHigh),
      child:Material(type:MaterialType.transparency,child:InkWell(
        key:ValueKey('preview-direction-$id'),
        borderRadius:BorderRadius.circular(16),
        onTap:()=>setState(()=>selected=id),
        child:SizedBox(width:53,height:53,child:Icon(glyph,size:28,
          color:isSelected?cs.onPrimary:cs.onSurface)),
      )),
    ));
  }
  @override Widget build(BuildContext context)=>Column(children:[
    const Align(alignment:Alignment.centerLeft,child:Text(
      '十字方向键',style:TextStyle(fontWeight:FontWeight.w600,fontSize:17))),
    const SizedBox(height:12),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:[
      button('上',Icons.keyboard_arrow_up_rounded)]),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:[
      button('左',Icons.keyboard_arrow_left_rounded),
      const SizedBox(width:53,height:53),
      button('右',Icons.keyboard_arrow_right_rounded)]),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:[
      button('下',Icons.keyboard_arrow_down_rounded)]),
    const SizedBox(height:8),
    Text(selected.isEmpty?'方向':selected,
      style:TextStyle(color:flMuted(context))),
  ]);
}

class FlPreviewTrackpad extends StatefulWidget {
  const FlPreviewTrackpad({super.key});
  @override State<FlPreviewTrackpad> createState()=>_FlPreviewTrackpadState();
}
class _FlPreviewTrackpadState extends State<FlPreviewTrackpad>{
  Offset point=const Offset(.5,.5);
  bool active=false;
  String selected='左';
  void move(Offset local,Size size)=>setState(() {
    active=true;
    point=Offset(
      (local.dx/size.width).clamp(0.0,1.0),
      (local.dy/size.height).clamp(0.0,1.0));
  });
  void release()=>setState(() {active=false;point=const Offset(.5,.5);});
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('触控板',style:TextStyle(fontSize:17,fontWeight:FontWeight.w600)),
      const SizedBox(height:12),
      SizedBox(height:139,child:LayoutBuilder(builder:(context,c){
        final size=c.biggest;
        return GestureDetector(
          key:const ValueKey('preview-trackpad'),
          behavior:HitTestBehavior.opaque,
          onPanStart:(d)=>move(d.localPosition,size),
          onPanUpdate:(d)=>move(d.localPosition,size),
          onPanEnd:(_)=>release(),onPanCancel:release,
          child:Stack(children:[
            Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(
              color:cs.surfaceContainerHigh,
              borderRadius:BorderRadius.circular(19)))),
            Positioned.fill(child:Center(child:Icon(
              Icons.touch_app_outlined,size:44,
              color:cs.onSurfaceVariant.withValues(alpha:.16)))),
            AnimatedPositioned(
              duration:FlMotion.effective(context,
                active?Duration.zero:FlMotion.release),
              curve:Curves.easeOutCubic,
              left:(size.width-22)*point.dx,
              top:(size.height-22)*point.dy,
              child:IgnorePointer(child:Container(width:22,height:22,
                decoration:BoxDecoration(
                  color:cs.primary.withValues(alpha:.86),
                  shape:BoxShape.circle,
                  border:Border.all(color:cs.onPrimary,width:2)))),
            ),
          ]),
        );
      })),
      const SizedBox(height:11),
      FlSegmented<String>(values:const ['左','中','右'],
        value:selected,label:(v)=>'${v}键',
        onChanged:(v)=>setState(()=>selected=v)),
    ]);
  }
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
