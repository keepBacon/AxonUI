import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';

/// Illustrative, read-only visual specimens. No hardware listeners,
/// game mapping, input events, plug-in execution or platform channels.
class FlSourceFeatureStage extends StatelessWidget {
  const FlSourceFeatureStage({
    super.key,required this.title,
    this.enabled=false,this.level=.5,
  });
  final String title;
  final bool enabled;
  final double level;

  bool get _gamepad => title.contains('手柄')||title.contains('摇杆')||
    title.contains('ABXY')||title.contains('肩键')||
    title.contains('十字键')||title.contains('背键');
  bool get _keyboard => title.contains('键盘')||title.contains('按显')||
    title.contains('按键')||title.contains('CPS')||title.contains('键鼠');
  bool get _mouse => title.contains('鼠标')||title.contains('指针')||
    title.contains('轨迹');
  bool get _text => title.contains('文本')||title.contains('字体')||
    title.contains('文字');
  bool get _plugin => title.contains('插件')||title.contains('功能')||
    title.contains('开关')||title.contains('列表');

  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return FlPanel(padding:const EdgeInsets.all(16),child:Column(
      crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[
          Icon(Icons.auto_awesome_motion_outlined,
            color:cs.primary,size:18),
          const SizedBox(width:8),
          Expanded(child:Text('效果预览',
            style:TextStyle(fontSize:14,fontWeight:FontWeight.w700,
              color:cs.onSurface))),
          Container(
            padding:const EdgeInsets.symmetric(horizontal:9,vertical:4),
            decoration:BoxDecoration(
              color:cs.primary.withValues(alpha:.09),
              borderRadius:BorderRadius.circular(12)),
            child:Text('UI',style:TextStyle(color:cs.primary,
              fontSize:11,fontWeight:FontWeight.w800))),
        ]),
        const SizedBox(height:12),
        Container(
          key:const ValueKey('source-feature-stage'),
          height:148,
          decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(19),
            gradient:LinearGradient(
              begin:Alignment.topLeft,end:Alignment.bottomRight,
              colors:[cs.primary.withValues(alpha:.10),
                cs.tertiary.withValues(alpha:.08),
                cs.surfaceContainerHigh.withValues(alpha:.7)],
            )),
          child:AnimatedScale(
            duration:FlMotion.effective(context,FlMotion.short),
            curve:FlMotion.curve,
            scale:.9+level.clamp(0.0,1.0)*.1,
            child:Center(
              child:_gamepad ? _pad(context) :
                _mouse ? _mouseVisual(context) :
                _text ? _textVisual(context) :
                _plugin ? _pluginVisual(context) :
                _keyboard ? _keys(context) : _generic(context),
            ),
          ),
        ),
        const SizedBox(height:10),
        Row(children:[
          Icon(Icons.layers_outlined,size:14,color:cs.onSurfaceVariant),
          const SizedBox(width:6),
          Expanded(child:Text(title,maxLines:1,
            overflow:TextOverflow.ellipsis,
            style:TextStyle(fontSize:12,color:cs.onSurfaceVariant))),
          Text('展示状态',style:TextStyle(fontSize:11,
            color:enabled?cs.primary:cs.onSurfaceVariant)),
        ]),
      ],
    ));
  }

  Widget _key(BuildContext context,String label,{bool highlighted=false,
      double width=27}) {
    final cs=Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration:FlMotion.effective(context,FlMotion.short),
      width:width,height:25,
      alignment:Alignment.center,
      margin:const EdgeInsets.symmetric(horizontal:2,vertical:2),
      decoration:BoxDecoration(
        color:highlighted?cs.primary:cs.surface,
        border:Border.all(
          color:highlighted?cs.primary:cs.outlineVariant.withValues(alpha:.55)),
        borderRadius:BorderRadius.circular(6),
        boxShadow:[BoxShadow(
          color:cs.shadow.withValues(alpha:.055),
          blurRadius:3,offset:const Offset(0,2))],
      ),
      child:Text(label,style:TextStyle(fontSize:9,
        fontWeight:FontWeight.w700,
        color:highlighted?cs.onPrimary:cs.onSurfaceVariant)),
    );
  }

  Widget _keys(BuildContext context) => Column(
    mainAxisSize:MainAxisSize.min,children:[
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        for(final (i,c) in ['Q','W','E','R','T','Y','U','I'].indexed)
          _key(context,c,highlighted:i==2&&enabled),
      ]),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        for(final (i,c) in ['A','S','D','F','G','H','J'].indexed)
          _key(context,c,highlighted:i==1&&enabled),
      ]),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        _key(context,'CTRL',width:40),
        _key(context,'SPACE',width:115,highlighted:enabled),
        _key(context,'ALT',width:36),
      ]),
    ],
  );

  Widget _pad(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    Widget circle(String letter,Color color)=>Container(
      width:29,height:29,alignment:Alignment.center,
      margin:const EdgeInsets.all(2),
      decoration:BoxDecoration(color:color,shape:BoxShape.circle),
      child:Text(letter,style:TextStyle(
        color:cs.onPrimary,fontSize:12,fontWeight:FontWeight.w700)));
    return Container(
      width:246,height:116,
      padding:const EdgeInsets.symmetric(horizontal:15,vertical:8),
      decoration:BoxDecoration(
        color:cs.surface.withValues(alpha:.85),
        borderRadius:BorderRadius.circular(35),
        border:Border.all(color:cs.outlineVariant.withValues(alpha:.5))),
      child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        Column(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[
          Container(width:43,height:16,decoration:BoxDecoration(
            color:cs.primary.withValues(alpha:.25),
            borderRadius:BorderRadius.circular(9))),
          Icon(Icons.album_rounded,size:37,color:cs.primary),
        ]),
        Icon(Icons.add_rounded,size:22,color:cs.onSurfaceVariant),
        Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          circle('Y',cs.tertiary),
          Row(children:[circle('X',cs.secondary),circle('B',cs.primary)]),
          circle('A',cs.primary.withValues(alpha:.8)),
        ]),
      ]),
    );
  }

  Widget _mouseVisual(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Row(mainAxisAlignment:MainAxisAlignment.center,children:[
      Icon(Icons.mouse_outlined,color:cs.primary,size:67),
      const SizedBox(width:16),
      Column(mainAxisAlignment:MainAxisAlignment.center,
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          for(final (i,n) in ['左键','中键','右键'].indexed)
            Container(
              width:99,margin:const EdgeInsets.only(bottom:5),
              padding:const EdgeInsets.symmetric(horizontal:11,vertical:5),
              decoration:BoxDecoration(
                color:i==0&&enabled?cs.primary:cs.surface,
                borderRadius:BorderRadius.circular(9)),
              child:Text(n,style:TextStyle(fontSize:11,
                color:i==0&&enabled?cs.onPrimary:cs.onSurfaceVariant)),
            ),
        ]),
    ]);
  }

  Widget _textVisual(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return Column(mainAxisSize:MainAxisSize.min,children:[
      Text('Aa',style:TextStyle(fontSize:40,fontWeight:FontWeight.w800,
        color:cs.primary)),
      Text('文字样式预览',style:TextStyle(
        fontSize:13,color:cs.onSurfaceVariant,letterSpacing:.5)),
    ]);
  }
  Widget _pluginVisual(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return Container(width:230,padding:const EdgeInsets.all(12),
      decoration:BoxDecoration(
        color:cs.surface,borderRadius:BorderRadius.circular(17)),
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        Row(children:[
          Icon(Icons.extension_outlined,size:19,color:cs.primary),
          const SizedBox(width:8),
          Expanded(child:Container(height:7,decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(5),
            color:cs.onSurfaceVariant.withValues(alpha:.19)))),
          const SizedBox(width:8),
          Icon(Icons.toggle_on_rounded,color:cs.primary),
        ]),
        const SizedBox(height:10),
        Row(children:[
          Expanded(child:Container(height:7,decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(5),
            color:cs.primary.withValues(alpha:.27)))),
          const SizedBox(width:8),
          Container(width:40,height:17,decoration:BoxDecoration(
            color:cs.primary.withValues(alpha:.17),
            borderRadius:BorderRadius.circular(9))),
        ]),
      ]),
    );
  }
  Widget _generic(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return Icon(Icons.tune_rounded,size:57,color:cs.primary);
  }
}
