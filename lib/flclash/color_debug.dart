import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';

/// A labeled design-parameter slider; only its parent preview changes.
class FlDebugSlider extends StatelessWidget {
  const FlDebugSlider({
    super.key, required this.label, required this.value, required this.min,
    required this.max, required this.onChanged, this.suffix = '',
    this.divisions,
  });
  final String label, suffix;
  final double value, min, max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
      Text('${value.round()}$suffix',
        style: TextStyle(fontSize: 13, color: flMuted(context),
          fontFeatures: const [FontFeature.tabularFigures()])),
    ]),
    Slider(
      key: ValueKey('debug-slider-$label'),
      value: value.clamp(min, max).toDouble(),
      min: min, max: max, divisions: divisions, onChanged: onChanged,
    ),
  ]);
}

/// All color values are local, including HEX, HSV and alpha.
class FlColorDebug extends StatefulWidget {
  const FlColorDebug({super.key});
  @override State<FlColorDebug> createState() => _FlColorDebugState();
}
class _FlColorDebugState extends State<FlColorDebug> {
  HSVColor hsv = HSVColor.fromColor(const Color(0xFF508AF2));
  double alpha = 1;
  late final TextEditingController hex = TextEditingController(
    text: _hex(color));

  Color get color => hsv.toColor().withValues(alpha: alpha);
  String _hex(Color value) =>
      value.toARGB32().toRadixString(16).padLeft(8,'0').toUpperCase();

  void change(HSVColor value, [double? newAlpha]) {
    setState(() {
      hsv = value;
      if(newAlpha != null) alpha = newAlpha;
      hex.text = _hex(color);
    });
  }

  void applyHex(String text) {
    final clean=text.trim().replaceAll('#','');
    if(clean.length!=6 && clean.length!=8) return;
    final number=int.tryParse(clean,radix:16);
    if(number==null) return;
    final argb=clean.length==6 ? (0xFF000000 | number) : number;
    final parsed=Color(argb);
    change(HSVColor.fromColor(parsed), parsed.a);
  }

  @override void dispose(){hex.dispose();super.dispose();}
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme;
    return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,
      children:[
        const Text('颜色调试',style:TextStyle(
          fontSize:18,fontWeight:FontWeight.w700)),
        const SizedBox(height:12),
        AnimatedContainer(
          key:const ValueKey('color-debug-preview'),
          duration:FlMotion.effective(context,FlMotion.short),
          height:86,
          decoration:BoxDecoration(color:color,
            borderRadius:BorderRadius.circular(22)),
          alignment:Alignment.center,
          child:Text('#${_hex(color)}',
            style:TextStyle(fontWeight:FontWeight.w700,
              color:hsv.value<.6 ? Colors.white : Colors.black87)),
        ),
        const SizedBox(height:12),
        TextField(
          key:const ValueKey('color-debug-hex'),
          controller:hex,
          textCapitalization:TextCapitalization.characters,
          decoration:InputDecoration(
            labelText:'HEX (AARRGGBB)',prefixText:'#',
            suffixIcon:IconButton(icon:const Icon(Icons.check_rounded),
              onPressed:()=>applyHex(hex.text))),
          onSubmitted:applyHex,
        ),
        const SizedBox(height:10),
        FlDebugSlider(label:'色相',value:hsv.hue,min:0,max:360,
          suffix:'°',onChanged:(v)=>change(hsv.withHue(v))),
        FlDebugSlider(label:'饱和度',value:hsv.saturation*100,min:0,max:100,
          suffix:'%',onChanged:(v)=>change(hsv.withSaturation(v/100))),
        FlDebugSlider(label:'亮度',value:hsv.value*100,min:0,max:100,
          suffix:'%',onChanged:(v)=>change(hsv.withValue(v/100))),
        FlDebugSlider(label:'透明度',value:alpha*100,min:0,max:100,
          suffix:'%',onChanged:(v)=>change(hsv,v/100)),
        const SizedBox(height:7),
        FlColorSwatches(
          colors:const [
            Color(0xFF508AF2),Color(0xFF47BBAA),Color(0xFFE8A05E),
            Color(0xFFC875C9),Color(0xFFF06C84),Color(0xFF242D45)],
          value:hsv.toColor(),
          onChanged:(v)=>change(HSVColor.fromColor(v)),
        ),
        Text('R ${(color.r*255).round()}   G ${(color.g*255).round()}   '
          'B ${(color.b*255).round()}   A ${(alpha*255).round()}',
          style:TextStyle(fontSize:12,color:cs.onSurfaceVariant)),
      ],
    ));
  }
}

class FlGradientDebug extends StatefulWidget {
  const FlGradientDebug({super.key});
  @override State<FlGradientDebug> createState()=>_FlGradientDebugState();
}
class _FlGradientDebugState extends State<FlGradientDebug> {
  Color start=const Color(0xFF4A8CF2);
  Color end=const Color(0xFFA785E8);
  double angle=0;
  int editing=0;
  @override Widget build(BuildContext context) {
    final active=editing==0 ? start:end;
    const swatches=[
      Color(0xFF4A8CF2),Color(0xFF62C8B5),
      Color(0xFFFFAD75),Color(0xFFC78AE9),Color(0xFFF5788B),
      Color(0xFF38415C),
    ];
    return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,
      children:[
        const Text('渐变调试',style:TextStyle(
          fontSize:18,fontWeight:FontWeight.w700)),
        const SizedBox(height:12),
        AnimatedContainer(
          key:const ValueKey('gradient-debug-preview'),
          height:100,
          duration:FlMotion.effective(context,FlMotion.regular),
          curve:FlMotion.curve,
          decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(24),
            gradient:LinearGradient(
              begin:Alignment.centerLeft,end:Alignment.centerRight,
              transform:GradientRotation(angle*3.141592653589793/180),
              colors:[start,end])),
        ),
        const SizedBox(height:14),
        FlSegmented<int>(values:const [0,1],value:editing,
          label:(v)=>v==0?'起始颜色':'结束颜色',
          onChanged:(v)=>setState(()=>editing=v)),
        const SizedBox(height:12),
        FlColorSwatches(colors:swatches,value:active,onChanged:(v)=>setState((){
          if(editing==0){start=v;}else{end=v;}
        })),
        FlDebugSlider(label:'渐变角度',value:angle,min:0,max:360,
          suffix:'°',onChanged:(v)=>setState(()=>angle=v)),
        Align(alignment:Alignment.centerRight,child:TextButton.icon(
          onPressed:()=>setState((){
            final previous=start;start=end;end=previous;}),
          icon:const Icon(Icons.swap_horiz_rounded),
          label:const Text('交换颜色'),
        )),
      ],
    ));
  }
}
