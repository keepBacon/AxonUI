import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';
import 'motion.dart';
import 'feature_catalog.dart';

/// A route-local background matching the FlClash-inspired shell.
class FlShowcasePageSurface extends StatelessWidget {
  const FlShowcasePageSurface({super.key,required this.child});
  final Widget child;
  @override Widget build(BuildContext context) {
    final scheme=Theme.of(context).colorScheme;
    final dark=Theme.of(context).brightness==Brightness.dark;
    final base=dark?const Color(0xFF151720):FlTokens.backgroundLight;
    return DecoratedBox(
      decoration:BoxDecoration(gradient:LinearGradient(
        begin:Alignment.topLeft,end:Alignment.bottomRight,
        colors:[Color.lerp(base,scheme.primary,.08)!,base],
      )),
      child:child,
    );
  }
}

/// Compact row: one left arrow, readable title and optional right icon.
class FlShowcaseEntry extends StatelessWidget {
  const FlShowcaseEntry({
    super.key,required this.title,required this.onTap,
    this.icon,this.subtitle,this.height=62,this.arrowKey,this.visual,
  });
  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final String? subtitle;
  final double height;
  final Key? arrowKey;
  final Widget? visual;

  @override Widget build(BuildContext context) {
    final scheme=Theme.of(context).colorScheme;
    return FlPressScale(
      pressedScale:.99,
      child:InkWell(
        key:ValueKey('showcase-entry-$title'),
        onTap:onTap,
        child:ConstrainedBox(
          constraints:BoxConstraints(minHeight:height),
          child:Padding(
            padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),
            child:Row(children:[
              SizedBox(width:40,height:40,child:IconButton(
                key:arrowKey??ValueKey('showcase-arrow-$title'),
                onPressed:onTap,tooltip:'打开$title',
                padding:EdgeInsets.zero,
                icon:Icon(Icons.chevron_right_rounded,
                  size:23,color:scheme.onSurfaceVariant),
              )),
              const SizedBox(width:9),
              Expanded(child:Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                mainAxisAlignment:MainAxisAlignment.center,
                children:[
                  Text(title,maxLines:1,overflow:TextOverflow.ellipsis,
                    style:TextStyle(fontSize:16,fontWeight:FontWeight.w600,
                      color:scheme.onSurface)),
                  if(subtitle!=null)...[
                    const SizedBox(height:3),
                    Text(subtitle!,maxLines:1,overflow:TextOverflow.ellipsis,
                      style:TextStyle(fontSize:12,
                        color:scheme.onSurfaceVariant)),
                  ],
                ],
              )),
              if(visual!=null)...[
                const SizedBox(width:8),
                visual!,
              ] else if(icon!=null)...[
                const SizedBox(width:8),
                Container(width:37,height:37,alignment:Alignment.center,
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(13),
                    color:scheme.primary.withValues(alpha:.09)),
                  child:Icon(icon,size:20,color:scheme.primary)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class FlShowcaseSection extends StatelessWidget {
  const FlShowcaseSection({super.key,required this.title,required this.icon});
  final String title;
  final IconData icon;
  @override Widget build(BuildContext context) {
    final scheme=Theme.of(context).colorScheme;
    return Padding(
      padding:const EdgeInsets.fromLTRB(5,19,5,10),
      child:Row(children:[
        Icon(icon,size:21,color:scheme.onSurfaceVariant),
        const SizedBox(width:11),
        Expanded(child:Text(title,
          style:TextStyle(fontSize:15,fontWeight:FontWeight.w700,
            color:scheme.onSurfaceVariant))),
      ]),
    );
  }
}

class FlShowcaseHeader extends StatelessWidget {
  const FlShowcaseHeader({
    super.key,required this.title,this.onBack,this.trailing,
  });
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  @override Widget build(BuildContext context) {
    final scheme=Theme.of(context).colorScheme;
    return Padding(
      padding:EdgeInsets.fromLTRB(onBack==null?5:0,4,4,9),
      child:Row(children:[
        if(onBack!=null)...[
          IconButton(
            key:const ValueKey('feature-back'),
            onPressed:onBack,
            icon:Icon(Icons.arrow_back_rounded,color:scheme.onSurface),
          ),
          const SizedBox(width:6),
        ],
        Expanded(child:Text(title,maxLines:1,
          overflow:TextOverflow.ellipsis,
          style:TextStyle(
            fontSize:onBack==null?28:24,
            fontWeight:FontWeight.w700,
            color:scheme.onSurface))),
        if(trailing!=null)trailing!,
      ]),
    );
  }
}

/// Previously successful segmented pill + live interaction / scale animation.
/// All state is local to this preview card.
class FlShowcaseInteractionPreview extends StatefulWidget {
  const FlShowcaseInteractionPreview({super.key});
  @override State<FlShowcaseInteractionPreview> createState()=>
    _FlShowcaseInteractionPreviewState();
}
class _FlShowcaseInteractionPreviewState
    extends State<FlShowcaseInteractionPreview> {
  String motion='滑动';
  double value=64;
  bool active=true;

  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return FlPanel(padding:const EdgeInsets.all(17),child:Column(
      crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        FlSegmented<String>(
          values:const ['滑动','淡入','缩放'],
          label:(v)=>v,value:motion,
          onChanged:(v)=>setState(()=>motion=v),
        ),
        const SizedBox(height:14),
        Container(
          height:66,alignment:Alignment.center,
          decoration:BoxDecoration(
            color:cs.surfaceContainerHigh,
            borderRadius:BorderRadius.circular(18)),
          child:AnimatedScale(
            duration:FlMotion.effective(context,FlMotion.selection),
            curve:FlMotion.curve,
            scale:motion == '缩放' ? .92 : 1,
            child:AnimatedOpacity(
              duration:FlMotion.effective(context,FlMotion.regular),
              key: const ValueKey('showcase-preview-opacity'),
              opacity:(motion == '淡入' ? .66 : 1) * value / 100,
              child:FlPressScale(pressedScale:.94,
                child:FilledButton.tonal(
                  key:const ValueKey('showcase-preview-button'),
                  onPressed:()=>setState(()=>active=!active),
                  child:Text(active?'控件预览':'已切换'),
                )),
            ),
          ),
        ),
        const SizedBox(height:13),
        Row(children:[
          const Expanded(child:Text('透明度',
            style:TextStyle(fontSize:14,fontWeight:FontWeight.w500))),
          Text('${value.round()}%',
            style:TextStyle(fontSize:13,color:cs.onSurfaceVariant)),
        ]),
        Slider(
          key:const ValueKey('showcase-preview-slider'),
          value:value,min:0,max:100,
          onChanged:(v)=>setState(()=>value=v),
        ),
      ],
    ));
  }
}


/// Tiny, non-interactive design specimens distinguish feature types without
/// putting debug sliders or feature execution on the catalogue screen.
class FlFeatureThumbnail extends StatelessWidget {
  const FlFeatureThumbnail({super.key,required this.kind,required this.title});
  final PreviewKind kind;
  final String title;

  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    final primary=cs.primary;
    final muted=cs.onSurfaceVariant;
    Widget content;
    switch(kind) {
      case PreviewKind.color:
      case PreviewKind.gradient:
      case PreviewKind.sequence:
      case PreviewKind.layers:
        content=Row(mainAxisAlignment:MainAxisAlignment.center,children:[
          for(final c in [primary,cs.tertiary,cs.secondary])
            Container(
              margin:const EdgeInsets.symmetric(horizontal:1),
              width:8,height:21,
              decoration:BoxDecoration(color:c,borderRadius:BorderRadius.circular(5)),
            ),
        ]);
      case PreviewKind.slider:
      case PreviewKind.spacing:
      case PreviewKind.layout:
        content=Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          Container(width:26,height:4,decoration:BoxDecoration(
            color:muted.withValues(alpha:.18),borderRadius:BorderRadius.circular(5)),
            child:Align(alignment:Alignment.centerLeft,child:Container(
              width:17,decoration:BoxDecoration(
                color:primary,borderRadius:BorderRadius.circular(5)),
            )),
          ),
          const SizedBox(height:5),
          Row(mainAxisAlignment:MainAxisAlignment.center,children:[
            for(var i=0;i<3;i++)
              Container(width:5,height:5,margin:const EdgeInsets.symmetric(horizontal:2),
                decoration:BoxDecoration(color:primary.withValues(alpha:.32+i*.2),
                  shape:BoxShape.circle)),
          ]),
        ]);
      case PreviewKind.animation:
      case PreviewKind.press:
        content=Stack(alignment:Alignment.center,children:[
          Container(width:27,height:27,decoration:BoxDecoration(
            border:Border.all(color:primary.withValues(alpha:.28),width:2),
            shape:BoxShape.circle)),
          Icon(Icons.play_arrow_rounded,size:19,color:primary),
        ]);
      case PreviewKind.source:
        if(title.contains('摇杆')||title.contains('手柄')) {
          content=Icon(Icons.sports_esports_outlined,size:21,color:primary);
        } else if(title.contains('键')||title.contains('鼠标')||title.contains('CPS')){
          content=Icon(Icons.keyboard_outlined,size:21,color:primary);
        } else if(title.contains('动画')||title.contains('Live2D')){
          content=Icon(Icons.auto_awesome_motion_rounded,size:21,color:primary);
        } else {
          content=Icon(Icons.tune_rounded,size:20,color:primary);
        }
      case PreviewKind.typography:
      case PreviewKind.textEffects:
        content=Text('Aa',style:TextStyle(
          color:primary,fontSize:17,fontWeight:FontWeight.w800));
      case PreviewKind.material:
        content=Icon(Icons.blur_on_outlined,size:22,color:primary);
      case PreviewKind.plugin:
      case PreviewKind.listEditor:
        content=Icon(Icons.view_list_rounded,size:21,color:primary);
      case PreviewKind.options:
      case PreviewKind.settings:
        content=Icon(Icons.tune_rounded,size:21,color:primary);
      case PreviewKind.controls:
        content=Icon(Icons.smart_button_outlined,size:22,color:primary);
      case PreviewKind.media:
        content=Icon(Icons.image_outlined,size:21,color:primary);
    }
    return Container(
      key:ValueKey('feature-thumbnail-$title'),
      width:44,height:38,alignment:Alignment.center,
      decoration:BoxDecoration(
        color:primary.withValues(alpha:.07),
        borderRadius:BorderRadius.circular(13),
        border:Border.all(color:primary.withValues(alpha:.07))),
      child:content,
    );
  }
}

/// A single compact section accent introduces a visual hierarchy without
/// repeating wide banners or adding new navigation entries.
class FlShowcaseGroupHeading extends StatelessWidget {
  const FlShowcaseGroupHeading({
    super.key,required this.title,required this.icon,required this.count,
  });
  final String title;
  final IconData icon;
  final int count;

  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return Padding(
      padding:const EdgeInsets.fromLTRB(4,23,4,10),
      child:Row(children:[
        Container(width:34,height:34,alignment:Alignment.center,
          decoration:BoxDecoration(
            color:cs.primary.withValues(alpha:.10),
            borderRadius:BorderRadius.circular(12)),
          child:Icon(icon,size:18,color:cs.primary)),
        const SizedBox(width:11),
        Expanded(child:Text(title,style:TextStyle(
          fontWeight:FontWeight.w700,fontSize:16,color:cs.onSurface))),
        DecoratedBox(
          decoration:BoxDecoration(
            color:cs.surfaceContainerHighest.withValues(alpha:.65),
            borderRadius:BorderRadius.circular(16)),
          child:Padding(padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),
            child:Text('$count',style:TextStyle(
              fontSize:12,fontWeight:FontWeight.w600,
              color:cs.onSurfaceVariant))),
        ),
      ]),
    );
  }
}
