import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';
import 'motion.dart';

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
    this.icon,this.subtitle,this.height=62,this.arrowKey,
  });
  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final String? subtitle;
  final double height;
  final Key? arrowKey;

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
              if(icon!=null)...[
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
            scale:motion=='缩放'?.92:1,
            child:AnimatedOpacity(
              duration:FlMotion.effective(context,FlMotion.regular),
              opacity:motion=='淡入'?.66:1,
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
