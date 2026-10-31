import 'package:flutter/material.dart';
import 'controls.dart';
import 'motion.dart';

/// UI-only samples mapped to Axon-Input source declarations.
/// This library does not request Android permissions or dispatch device input.
enum AxonStudioKind { gamepad, touch, custom, media, shortcuts, workspace }

class FlAxonSourceStudio extends StatelessWidget {
  const FlAxonSourceStudio({super.key,required this.kind});
  final AxonStudioKind kind;
  @override Widget build(BuildContext context)=>switch(kind){
    AxonStudioKind.gamepad=>const FlAxonGamepadStudio(),
    AxonStudioKind.touch=>const FlAxonTouchStudio(),
    AxonStudioKind.custom=>const FlAxonCustomStudio(),
    AxonStudioKind.media=>const FlAxonMediaStudio(),
    AxonStudioKind.shortcuts=>const FlAxonShortcutStudio(),
    AxonStudioKind.workspace=>const FlAxonWorkspaceStudio(),
  };
}
class _Caption extends StatelessWidget {
  const _Caption(this.title,this.source);
  final String title,source;
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return Padding(padding:const EdgeInsets.only(bottom:12),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:TextStyle(fontSize:17,
          fontWeight:FontWeight.w700,color:cs.onSurface)),
        const SizedBox(height:5),
        Text('来源: '+source+' · 本地 UI 模拟',style:TextStyle(
          fontSize:11,color:cs.onSurfaceVariant)),
      ]));
  }
}
class _ValueSlider extends StatelessWidget {
  const _ValueSlider({required this.name,required this.value,
    required this.min,required this.max,required this.onChanged,this.unit=''});
  final String name,unit;
  final double value,min,max;
  final ValueChanged<double> onChanged;
  @override Widget build(BuildContext context)=>Column(children:[
    Row(children:[
      Expanded(child:Text(name,style:const TextStyle(fontSize:13))),
      Text(value.round().toString()+unit,
        style:TextStyle(color:Theme.of(context).colorScheme.primary,
          fontWeight:FontWeight.w700)),
    ]),
    Slider(value:value,min:min,max:max,onChanged:onChanged),
  ]);
}

/// GamepadSettingsStore.java: COMPAT_AUTO/LOOSE/ANDROID/EVDEV
/// and independent swap settings.
class FlAxonGamepadStudio extends StatefulWidget {
  const FlAxonGamepadStudio({super.key});
  @override State<FlAxonGamepadStudio> createState()=>_GamepadState();
}
class _GamepadState extends State<FlAxonGamepadStudio> {
  int compatibility=0;
  final swaps={'A / B':false,'X / Y':false,'左右摇杆':false,'LT / RT':false};
  bool custom=false;
  String from='A',to='X';
  static const modes=['自动','宽松','Android','Evdev'];
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const _Caption('兼容模式与按键交换','GamepadSettingsStore.java'),
      FlPanel(child:Column(children:[
        DropdownButton<int>(
          key:const ValueKey('axon-gamepad-mode'),isExpanded:true,
          value:compatibility,
          items:[for(var i=0;i<modes.length;i++)
            DropdownMenuItem(value:i,child:Text(modes[i]))],
          onChanged:(v){if(v!=null)setState(()=>compatibility=v);}),
        for(final entry in swaps.entries)
          SwitchListTile.adaptive(
            key:ValueKey('axon-swap-'+entry.key),
            dense:true,contentPadding:EdgeInsets.zero,
            title:Text('交换 '+entry.key),value:entry.value,
            onChanged:(v)=>setState(()=>swaps[entry.key]=v)),
      ])),
      const SizedBox(height:12),
      FlPanel(child:Column(children:[
        SwitchListTile.adaptive(
          key:const ValueKey('axon-custom-swap'),
          contentPadding:EdgeInsets.zero,title:const Text('自定义交换'),
          value:custom,onChanged:(v)=>setState(()=>custom=v)),
        Row(children:[
          Expanded(child:_keyPicker(from,0)),
          const Padding(padding:EdgeInsets.symmetric(horizontal:8),
            child:Icon(Icons.swap_horiz_rounded)),
          Expanded(child:_keyPicker(to,1)),
        ]),
        if(custom&&from==to)Text('交换的两端不能相同',
          style:TextStyle(color:cs.error)),
      ])),
      const SizedBox(height:12),
      FlPanel(child:Column(children:[
        Text('当前模式：'+modes[compatibility]),
        const SizedBox(height:10),
        Wrap(spacing:8,children:[
          for(final name in const ['Y','X','B','A'])
            CircleAvatar(
              backgroundColor:cs.primaryContainer,
              child:Text(name,style:TextStyle(
                color:cs.onPrimaryContainer,fontWeight:FontWeight.w700))),
        ]),
      ])),
    ]);
  }
  Widget _keyPicker(String value,int side)=>DropdownButton<String>(
    key:ValueKey('axon-gamepad-bind-'+side.toString()),
    isExpanded:true,value:value,
    items:[for(final key in const ['A','B','X','Y','L1','R1'])
      DropdownMenuItem(value:key,child:Text(key))],
    onChanged:(v){if(v!=null)setState((){
      if(side==0){from=v;}else{to=v;}
    });},
  );
}

/// TouchDisplayStore.java: joystick/LMB/RMB/space rectangular regions.
/// Dragging only updates in-memory normalized coordinates.
class FlAxonTouchStudio extends StatefulWidget {
  const FlAxonTouchStudio({super.key});
  @override State<FlAxonTouchStudio> createState()=>_TouchState();
}
class _TouchState extends State<FlAxonTouchStudio> {
  int mode=0,selected=0;
  double size=1;
  final positions=[
    const Offset(.12,.43),const Offset(.60,.32),
    const Offset(.67,.66),const Offset(.29,.72)];
  static const labels=['摇杆','鼠标左键','鼠标右键','空格'];
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const _Caption('触控区域布局','TouchDisplayStore.java'),
      FlPanel(child:Column(children:[
        FlSegmented<int>(values:const [0,1,2],value:mode,
          label:(x)=>const ['键鼠','手柄','触控'][x],
          onChanged:(x)=>setState(()=>mode=x)),
        const SizedBox(height:12),
        Wrap(spacing:5,runSpacing:5,children:[
          for(var i=0;i<labels.length;i++)
            ChoiceChip(key:ValueKey('axon-region-select-'+i.toString()),
              label:Text(labels[i]),selected:selected==i,
              onSelected:(_)=>setState(()=>selected=i)),
        ]),
      ])),
      const SizedBox(height:12),
      LayoutBuilder(builder:(context,box){
        const h=210.0;
        final w=box.maxWidth, rw=72.0*size,rh=45.0*size;
        final dx=(w-rw).clamp(1.0,double.infinity);
        final dy=(h-rh).clamp(1.0,double.infinity);
        return Container(
          key:const ValueKey('axon-touch-canvas'),width:w,height:h,
          clipBehavior:Clip.hardEdge,
          decoration:BoxDecoration(color:cs.surfaceContainerHigh,
            borderRadius:BorderRadius.circular(18)),
          child:Stack(children:[
            for(var i=0;i<labels.length;i++)
              Positioned(left:positions[i].dx*dx,top:positions[i].dy*dy,
                child:GestureDetector(
                  key:ValueKey('axon-region-'+i.toString()),
                  onTap:()=>setState(()=>selected=i),
                  onPanUpdate:(d)=>setState((){
                    selected=i;
                    positions[i]=Offset(
                      (positions[i].dx+d.delta.dx/dx).clamp(0.0,1.0),
                      (positions[i].dy+d.delta.dy/dy).clamp(0.0,1.0));
                  }),
                  child:Container(width:rw,height:rh,
                    alignment:Alignment.center,
                    decoration:BoxDecoration(
                      color:i==selected?cs.primary.withValues(alpha:.25):
                        cs.surface.withValues(alpha:.9),
                      borderRadius:BorderRadius.circular(10),
                      border:Border.all(
                        color:i==selected?cs.primary:cs.outline,width:1.5)),
                    child:Text(labels[i],style:TextStyle(fontSize:10,
                      color:cs.onSurface,fontWeight:FontWeight.w700))),
                )),
          ]),
        );
      }),
      const SizedBox(height:12),
      FlPanel(child:Column(children:[
        _ValueSlider(name:'区域尺寸',value:size*100,min:70,max:140,
          unit:'%',onChanged:(x)=>setState(()=>size=x/100)),
        Text('X '+(positions[selected].dx*100).round().toString()+
          '%  ·  Y '+(positions[selected].dy*100).round().toString()+'%',
          key:const ValueKey('axon-region-position'),
          style:TextStyle(color:cs.onSurfaceVariant)),
      ])),
    ]);
  }
}

/// SuperCustomControlSpec / KeyAppearance: key, text and joystick.
/// Appearance controls only modify local canvas data.
class FlAxonCustomStudio extends StatefulWidget {
  const FlAxonCustomStudio({super.key});
  @override State<FlAxonCustomStudio> createState()=>_CustomState();
}
class _CustomState extends State<FlAxonCustomStudio>{
  int type=0,shape=0,shade=0;
  double width=92,opacity=94,corner=14;
  String label='CPS: 8';
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    final colors=[cs.primary,cs.tertiary,cs.secondary,
      const Color(0xFF55AFA1)];
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const _Caption('超级自定义控件','SuperCustomControlSpec.java / KeyAppearance.java'),
      FlPanel(child:Column(children:[
        FlSegmented<int>(values:const [0,1,2],value:type,
          label:(x)=>const ['按键','文本','摇杆'][x],
          onChanged:(x)=>setState(()=>type=x)),
        const SizedBox(height:14),
        Container(key:const ValueKey('axon-custom-stage'),
          height:150,width:double.infinity,alignment:Alignment.center,
          decoration:BoxDecoration(color:cs.surfaceContainerHigh,
            borderRadius:BorderRadius.circular(19)),
          child:AnimatedOpacity(
            duration:FlMotion.effective(context,FlMotion.regular),
            opacity:opacity/100,
            child:AnimatedContainer(
              duration:FlMotion.effective(context,FlMotion.regular),
              width:type==1?width*1.45:width,height:type==1?56:width*.7,
              alignment:Alignment.center,
              decoration:BoxDecoration(
                color:colors[shade].withValues(alpha:.23),
                border:Border.all(color:colors[shade],width:1.5),
                borderRadius:BorderRadius.circular(
                  shape==1?2:shape==2?100:corner)),
              child:type==2
                ?Icon(Icons.radio_button_checked_rounded,color:colors[shade],
                  size:34)
                :Text(type==1?label:'SPACE',maxLines:2,
                  overflow:TextOverflow.ellipsis,
                  style:TextStyle(color:cs.onSurface,
                    fontWeight:FontWeight.w700)),
            ),
          )),
        const SizedBox(height:11),
        Wrap(spacing:6,runSpacing:6,children:[
          for(var i=0;i<3;i++)
            ChoiceChip(key:ValueKey('axon-shape-'+i.toString()),
              label:Text(const ['圆角','方形','圆形'][i]),
              selected:shape==i,
              onSelected:(_)=>setState(()=>shape=i)),
        ]),
        const SizedBox(height:10),
        Wrap(spacing:8,children:[
          for(var i=0;i<colors.length;i++)
            InkWell(key:ValueKey('axon-color-'+i.toString()),
              customBorder:const CircleBorder(),
              onTap:()=>setState(()=>shade=i),
              child:CircleAvatar(radius:16,backgroundColor:colors[i],
                child:i==shade?const Icon(Icons.check_rounded,
                  color:Colors.white,size:16):null)),
        ]),
      ])),
      const SizedBox(height:12),
      FlPanel(child:Column(children:[
        if(type==1)TextField(
          key:const ValueKey('axon-custom-label'),
          decoration:const InputDecoration(labelText:'文本内容'),
          onChanged:(x)=>setState(()=>label=x)),
        _ValueSlider(name:'宽度',value:width,min:55,max:180,unit:' dp',
          onChanged:(x)=>setState(()=>width=x)),
        _ValueSlider(name:'透明度',value:opacity,min:20,max:100,unit:'%',
          onChanged:(x)=>setState(()=>opacity=x)),
        _ValueSlider(name:'圆角',value:corner,min:0,max:40,unit:' dp',
          onChanged:(x)=>setState(()=>corner=x)),
      ])),
    ]);
  }
}

/// FloatingMediaStore: multi-item UI, loop/once, chroma and opacity.
/// No file I/O, playback, or video decoding is performed.
class FlAxonMediaStudio extends StatefulWidget {
  const FlAxonMediaStudio({super.key});
  @override State<FlAxonMediaStudio> createState()=>_MediaState();
}
class _MediaState extends State<FlAxonMediaStudio>{
  final items=['演示素材 01','演示素材 02'];
  int selected=0,playback=0;
  bool enabled=true,chroma=false;
  double opacity=100,strength=36;
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const _Caption('悬浮视频视觉编辑器',
        'FloatingMediaStore.java / FloatingVideoOverlayView.java'),
      FlPanel(child:Column(children:[
        Row(children:[
          Expanded(child:Text('素材列表 · '+items.length.toString(),
            style:const TextStyle(fontWeight:FontWeight.w700))),
          IconButton(key:const ValueKey('axon-media-add'),
            tooltip:'增加演示项',
            onPressed:()=>setState((){
              items.add('演示素材 '+(items.length+1).toString());
              selected=items.length-1;
            }),icon:const Icon(Icons.add_circle_outline_rounded)),
        ]),
        for(var i=0;i<items.length;i++)
          ListTile(key:ValueKey('axon-media-item-'+i.toString()),
            dense:true,selected:i==selected,
            contentPadding:EdgeInsets.zero,
            leading:Icon(Icons.movie_outlined,color:cs.primary),
            title:Text(items[i]),
            subtitle:const Text('仅显示占位画面'),
            onTap:()=>setState(()=>selected=i),
            trailing:IconButton(
              icon:const Icon(Icons.close_rounded),
              tooltip:'删除演示项',
              onPressed:()=>setState((){
                items.removeAt(i);
                selected=items.isEmpty?0:selected.clamp(0,items.length-1);
              }))),
      ])),
      const SizedBox(height:12),
      FlPanel(child:Column(children:[
        Container(key:const ValueKey('axon-media-preview'),
          height:125,width:double.infinity,
          decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(20),
            gradient:LinearGradient(colors:[
              cs.primary.withValues(alpha:.18),
              cs.tertiary.withValues(alpha:.21)])),
          child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
            Icon(enabled?Icons.play_circle_outline_rounded:
              Icons.pause_circle_outline_rounded,size:39,color:cs.primary),
            Text(items.isEmpty?'空素材':items[selected],
              style:TextStyle(color:cs.onSurface)),
          ])),
        SwitchListTile.adaptive(
          key:const ValueKey('axon-media-enabled'),
          contentPadding:EdgeInsets.zero,title:const Text('显示状态'),
          value:enabled,onChanged:(x)=>setState(()=>enabled=x)),
        FlSegmented<int>(values:const [0,1],value:playback,
          label:(x)=>const ['循环','播放一次'][x],
          onChanged:(x)=>setState(()=>playback=x)),
        SwitchListTile.adaptive(
          key:const ValueKey('axon-media-chroma'),
          contentPadding:EdgeInsets.zero,title:const Text('色键透明'),
          value:chroma,onChanged:(x)=>setState(()=>chroma=x)),
        if(chroma)_ValueSlider(name:'抠像强度',value:strength,min:0,max:300,
          onChanged:(x)=>setState(()=>strength=x)),
        _ValueSlider(name:'透明度',value:opacity,min:0,max:100,unit:'%',
          onChanged:(x)=>setState(()=>opacity=x)),
      ])),
    ]);
  }
}

/// FeatureShortcutStore: local keyboard/mouse/gamepad key names and
/// duplicate binding validation; never registers a shortcut.
class FlAxonShortcutStudio extends StatefulWidget {
  const FlAxonShortcutStudio({super.key});
  @override State<FlAxonShortcutStudio> createState()=>_ShortcutState();
}
class _ShortcutState extends State<FlAxonShortcutStudio>{
  final bindings=<String,String>{
    '常规按显':'F1','全键盘':'F2',
    '鼠标轨迹':'未绑定','键盘猫':'未绑定'};
  String? conflict;
  static const keys=['未绑定','F1','F2','F3','Space','Mouse4','Gamepad A'];
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const _Caption('快捷键绑定矩阵','FeatureShortcutStore.java'),
      FlPanel(child:Column(children:[
        for(final name in bindings.keys)
          Padding(padding:const EdgeInsets.only(bottom:9),
            child:Row(children:[
              Expanded(child:Text(name,
                style:const TextStyle(fontWeight:FontWeight.w600))),
              SizedBox(width:137,child:DropdownButton<String>(
                key:ValueKey('axon-binding-'+name),
                isExpanded:true,value:bindings[name],
                items:[for(final k in keys)
                  DropdownMenuItem(value:k,child:Text(k))],
                onChanged:(key){if(key==null)return;setState((){
                  if(key!='未绑定'&&bindings.entries.any(
                    (e)=>e.key!=name&&e.value==key)){
                    conflict='快捷键冲突：'+key;
                  }else{bindings[name]=key;conflict=null;}
                });},
              )),
            ])),
        if(conflict!=null)Text(conflict!,
          key:const ValueKey('axon-binding-conflict'),
          style:TextStyle(color:cs.error)),
        Text('UI 模拟，不会注册或触发按键',
          style:TextStyle(color:cs.onSurfaceVariant,fontSize:11)),
      ])),
    ]);
  }
}

/// SuperCustomConfigStore.SLOT_COUNT = 5; only local sample data.
class FlAxonWorkspaceStudio extends StatefulWidget {
  const FlAxonWorkspaceStudio({super.key});
  @override State<FlAxonWorkspaceStudio> createState()=>_WorkspaceState();
}
class _WorkspaceState extends State<FlAxonWorkspaceStudio>{
  int selected=0;
  final occupied=<int>{0,2};
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const _Caption('五槽位配置管理','SuperCustomConfigStore.java'),
      FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Wrap(spacing:8,runSpacing:8,children:[
          for(var i=0;i<5;i++)
            ChoiceChip(key:ValueKey('axon-workspace-'+i.toString()),
              label:Text('槽位 '+(i+1).toString()),selected:selected==i,
              onSelected:(_)=>setState(()=>selected=i)),
        ]),
        const SizedBox(height:15),
        Container(padding:const EdgeInsets.all(16),
          decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(17),
            color:cs.primary.withValues(alpha:.08)),
          child:Text('槽位 '+(selected+1).toString()+
            (occupied.contains(selected)?' · 已保存演示':' · 空'),
            key:const ValueKey('axon-workspace-state'))),
        const SizedBox(height:12),
        Wrap(spacing:7,runSpacing:6,children:[
          FilledButton.tonal(
            key:const ValueKey('axon-workspace-save'),
            onPressed:()=>setState(()=>occupied.add(selected)),
            child:const Text('模拟保存')),
          OutlinedButton(
            key:const ValueKey('axon-workspace-clear'),
            onPressed:()=>setState(()=>occupied.remove(selected)),
            child:const Text('清空')),
          OutlinedButton(
            key:const ValueKey('axon-workspace-copy'),
            onPressed:()=>setState((){
              if(occupied.contains(selected)){
                occupied.add((selected+1)%5);
              }
            }),
            child:const Text('复制到下一槽')),
        ]),
      ])),
    ]);
  }
}
