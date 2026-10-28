import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'bridge.dart';

// A standalone visual interpretation of the FlClash Theme screen.
// All state changes here are presentation-only: no Axon input engine calls.
abstract final class FlMotion {
  static Duration duration(BuildContext context, [int ms = 270]) =>
      MediaQuery.maybeOf(context)?.disableAnimations == true
          ? Duration.zero : Duration(milliseconds: ms);
  static const curve = Curves.easeOutCubic;
}

class FlClashPalette {
  static const canvas = Color(0xFFF0EEF1);
  static const card = Color(0xFFFFFBFC);
  static const ink = Color(0xFF171B22);
  static const muted = Color(0xFF606775);
  static const blue = Color(0xFF0087F8);
  static const line = Color(0xFFDDDCE0);
}

class FlChoice<T> {
  const FlChoice(this.value, this.title, {this.preview, this.subtitle});
  final T value;
  final String title;
  final Widget? preview;
  final String? subtitle;
}

class FlSectionHeader extends StatelessWidget {
  const FlSectionHeader({super.key, required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 32, 2, 15),
    child: Row(children: [
      Icon(icon, size: 23, color: FlClashPalette.muted),
      const SizedBox(width: 13),
      Text(title, style: const TextStyle(fontSize: 18,
        fontWeight: FontWeight.w600, color: FlClashPalette.muted)),
    ]),
  );
}

class FlCard extends StatelessWidget {
  const FlCard({super.key, required this.child, this.padding, this.radius = 26});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : FlClashPalette.card,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: child,
  );
}

class FlChoiceGroup<T> extends StatelessWidget {
  const FlChoiceGroup({super.key, required this.title, required this.icon,
    required this.value, required this.options, required this.onChanged});
  final String title;
  final IconData icon;
  final T value;
  final List<FlChoice<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      FlSectionHeader(icon: icon, title: title),
      FlCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (int i = 0; i < options.length; i++) ...[
          _FlChoiceRow<T>(choice: options[i], selected: options[i].value == value,
              onTap: () => onChanged(options[i].value)),
          if (i != options.length - 1)
            const Padding(padding: EdgeInsets.only(left: 76, right: 11),
              child: Divider(height: 1, thickness: .7, color: FlClashPalette.line)),
        ],
      ])),
    ],
  );
}

class _FlChoiceRow<T> extends StatefulWidget {
  const _FlChoiceRow({required this.choice, required this.selected, required this.onTap});
  final FlChoice<T> choice;
  final bool selected;
  final VoidCallback onTap;
  @override
  State<_FlChoiceRow<T>> createState() => _FlChoiceRowState<T>();
}

class _FlChoiceRowState<T> extends State<_FlChoiceRow<T>> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true, selected: widget.selected, label: widget.choice.title,
    child: GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: FlMotion.duration(context, 160),
        curve: FlMotion.curve,
        color: _pressed ? FlClashPalette.blue.withValues(alpha: .055) : Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 66),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              if (widget.choice.preview != null)
                SizedBox(width: 52, height: 39, child: Center(child: widget.choice.preview)),
              if (widget.choice.preview != null) const SizedBox(width: 13),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.choice.title, style: const TextStyle(fontSize: 17.5,
                    fontWeight: FontWeight.w400)),
                  if (widget.choice.subtitle != null)
                    Text(widget.choice.subtitle!, style: const TextStyle(fontSize: 11.5,
                      color: FlClashPalette.muted)),
                ],
              )),
              AnimatedSwitcher(duration: FlMotion.duration(context, 210),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween<double>(begin: .55, end: 1).animate(
                    CurvedAnimation(parent: animation, curve: FlMotion.curve)),
                  child: FadeTransition(opacity: animation, child: child)),
                child: widget.selected
                  ? const Icon(Icons.check_rounded, key: ValueKey('checked'),
                      color: FlClashPalette.blue, size: 27)
                  : const SizedBox(key: ValueKey('unchecked'), width: 27, height: 27)),
            ]),
          ),
        ),
      ),
    ),
  );
}

/// Vector preview art, not a static screenshot. It responds to selected modes.
class FlMiniScreen extends StatelessWidget {
  const FlMiniScreen({super.key, this.floating = true, this.slide = true,
    this.glass = 0, this.dark = false, this.accent = FlClashPalette.blue});
  final bool floating, slide, dark;
  final int glass;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    width: 47, height: 34,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6), color: Colors.white,
      border: Border.all(color: const Color(0xFFE1E2E8), width: .6),
    ),
    clipBehavior: Clip.antiAlias,
    child: CustomPaint(painter: _FlScreenPainter(
      floating: floating, slide: slide, glass: glass, dark: dark, accent: accent)),
  );
}

class _FlScreenPainter extends CustomPainter {
  const _FlScreenPainter({required this.floating, required this.slide,
    required this.glass, required this.dark, required this.accent});
  final bool floating, slide, dark;
  final int glass;
  final Color accent;
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 47;
    canvas.save(); canvas.scale(scale);
    final bg = dark ? const Color(0xFF29303B) : const Color(0xFFF5F7FA);
    final fg = dark ? const Color(0xFFE0E5EE) : const Color(0xFFB1BBC7);
    final faint = dark ? const Color(0xFF5A6372) : const Color(0xFFE4E9F0);
    void rect(double x,double y,double w,double h,Color col,double r) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x,y,w,h),
        Radius.circular(r)),Paint()..color=col);
    }
    rect(0,0,47,34,bg,0);
    rect(3,3,19,3,fg,1.5); rect(24,3,10,3,faint,1.5);
    rect(3,9,18,10,dark ? const Color(0xFF343C4C) : Colors.white,2);
    rect(5,11,11,2,accent.withValues(alpha: .65),1);
    rect(5,15,14,1.8,faint,1);
    rect(24,9,20,10,dark ? const Color(0xFF343C4C) : Colors.white,2);
    rect(26,11,13,2,faint,1);rect(26,15,9,1.7,fg,1);
    if (slide) {rect(3,21,13,1.7,accent,1);rect(18,21,15,1.7,faint,1);}
    else {rect(3,21,10,1.7,faint,1);rect(16,21,18,1.7,accent.withValues(alpha:.43),1);}
    final navBg = glass == 2 ? const Color(0xFFC0E1F9) :
      glass == 1 ? const Color(0xFFE8F0FB) : dark ? const Color(0xFF505A69) : Colors.white;
    rect(floating ? 5 : 0, floating ? 25 : 24,
      floating ? 37 : 47, floating ? 7 : 10,navBg,floating ? 4 : 0);
    for (int i=0;i<4;i++) {
      final x=(floating ? 9.5 : 7)+(i * (floating ? 8.1 : 11.0));
      rect(x, floating?27.1:26.5, 3, 2.2, i==1 ? accent : fg,1);
      if (i==1) rect(x-.5, floating?30:29.5,4, .6, accent, .4);
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _FlScreenPainter o) => floating != o.floating ||
    slide != o.slide || glass != o.glass || dark != o.dark || accent != o.accent;
}

class FlPillSegmented extends StatelessWidget {
  const FlPillSegmented({super.key, required this.values,
    required this.selected, required this.onChanged});
  final List<String> values;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => FlCard(radius: 24,
    padding: const EdgeInsets.all(4),
    child: Row(children: [for (int i=0;i<values.length;i++)
      Expanded(child: GestureDetector(
        onTap: () => onChanged(i),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: FlMotion.duration(context, 285),
          curve: FlMotion.curve,
          height: 39,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected == i ? FlClashPalette.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: AnimatedDefaultTextStyle(
            duration: FlMotion.duration(context, 210),
            style: TextStyle(fontSize: 15.5, fontWeight: selected==i
              ? FontWeight.w600 : FontWeight.w500,
              color: selected==i ? Colors.white : FlClashPalette.muted),
            child: Text(values[i]),
          ),
        ),
      )),
    ]),
  );
}

class FlDiscreteScale extends StatelessWidget {
  const FlDiscreteScale({super.key, required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Semantics(
    slider: true, value: '${(value*100).round()}%',
    child: LayoutBuilder(builder: (context, constraints) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (d) => onChanged((value + d.delta.dx * .8 /
          (constraints.maxWidth - 44).clamp(1.0, double.infinity)).clamp(.7, 1.5).toDouble()),
      onTapDown: (d) {
        final x = (d.localPosition.dx - 22) /
          (constraints.maxWidth-44).clamp(1,double.infinity);
        onChanged((.7 + x*.8).clamp(.7,1.5).toDouble());
      },
      child: SizedBox(height: 39, child: CustomPaint(
        painter: _FlScalePainter(value), child: const Row(children: [
          SizedBox(width: 22, child: Text('A', style: TextStyle(fontSize: 13,
            color: FlClashPalette.muted))),
          Spacer(), Text('A', style: TextStyle(fontSize: 23,
            color: FlClashPalette.muted)),
        ]),
      )),
    )),
  );
}

class _FlScalePainter extends CustomPainter {
  const _FlScalePainter(this.value);
  final double value;
  @override
  void paint(Canvas c, Size s) {
    final start = 32.0, end = s.width-33, center = s.height/2;
    final track = Rect.fromLTWH(start, center-5, end-start, 10);
    c.drawRRect(RRect.fromRectAndRadius(track, const Radius.circular(9)),
      Paint()..color=const Color(0xFFDCDCE0));
    final f=((value-.7)/.8).clamp(0.0,1.0);
    final px=start+(end-start)*f;
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(start, center-5,
      (px-start).clamp(0.0,end-start).toDouble(),10),const Radius.circular(9)),
      Paint()..color=const Color(0xFFA2A3A9));
    for (int i=0;i<=12;i++) {
      final x=start+(end-start)*i/12;
      c.drawCircle(Offset(x,center),2.1,Paint()..color=x<=px
        ? Colors.white.withValues(alpha:.85):const Color(0xFF262A30));
    }
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px-2.2,center-16,4.4,32),
      const Radius.circular(4)),Paint()..color=const Color(0xFFF8F8F8));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px-1.4,center-16,2.8,32),
      const Radius.circular(3)),Paint()..color=const Color(0xFF979AA1));
  }
  @override
  bool shouldRepaint(covariant _FlScalePainter old) => old.value!=value;
}

/// Theme controls intentionally accept a store only for appearance preferences.
/// The method channel here never dispatches key/mouse/touch input actions.
class FlClashThemeGallery extends StatefulWidget {
  const FlClashThemeGallery({super.key, required this.store, required this.mode,
    required this.seed, required this.onThemeChanged, required this.onSeedChanged,
    required this.onOpenControls});
  final AxonUiStore store;
  final ThemeMode mode;
  final Color seed;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Color> onSeedChanged;
  final VoidCallback onOpenControls;
  @override
  State<FlClashThemeGallery> createState() => _FlClashThemeGalleryState();
}

class _FlClashThemeGalleryState extends State<FlClashThemeGallery> {
  bool _floating = true;
  bool _slide = true;
  int _glass = 2;
  String _font = 'monospace';
  bool _custom = false;
  double _scale = 1;
  int _colorStyle = 0;
  bool _loaded = false;
  int _previewTab = 0;
  final _colors = const [Color(0xFF0087F8), Color(0xFFC889D7),
    Color(0xFFFFA9B9), Color(0xFFFFD0D6), Color(0xFFF4C5A5),
    Color(0xFFF5E1AE), Color(0xFFAFE5C8), Color(0xFFB7BFCE)];

  @override
  void initState() {super.initState(); _load();}
  Future<void> _load() async {
    try {
      final data = await widget.store.load();
      if (!mounted) return;
      setState(() {
        _floating = data['fl_floating'] is bool ? data['fl_floating'] as bool : true;
        _slide = data['fl_slide'] is bool ? data['fl_slide'] as bool : true;
        _glass = (data['fl_glass'] is int ? data['fl_glass'] as int : 2).clamp(0,2).toInt();
        _font = data['fl_font'] is String ? data['fl_font'] as String : 'monospace';
        _custom = data['fl_custom'] == true;
        _colorStyle = data['fl_color_style'] is int ? data['fl_color_style'] as int : 0;
        _scale = (data['fl_scale'] is num ? (data['fl_scale'] as num).toDouble() : 1.0).clamp(.7,1.5).toDouble();
        _loaded = true;
      });
    } catch (_) {if (mounted) setState(() => _loaded = true);}
  }
  void _save(String key, Object value) {
    widget.store.setValue('fl_$key',value).catchError((Object _){});
  }

  Future<void> _pickFont() async {
    final selected = await showModalBottomSheet<String>(
      context: context, showDragHandle: true, isScrollControlled: true,
      backgroundColor: FlClashPalette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(22,8,22,20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Align(alignment: Alignment.centerLeft, child: Text('字体',
            style: TextStyle(fontSize: 23,fontWeight: FontWeight.w600))),
          const SizedBox(height: 12),
          for(final family in const ['系统默认','monospace','sans-serif','serif'])
            ListTile(title: Text(family), leading: const Text('Aa',style: TextStyle(fontSize: 18)),
              trailing: _font==family ? const Icon(Icons.check,color:FlClashPalette.blue):null,
              onTap: () => Navigator.pop(ctx,family)),
        ]),
      )),
    );
    if (selected != null) {setState(() => _font=selected);_save('font',selected);}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF171B23) : FlClashPalette.canvas;
    final foreground = isDark ? Colors.white : FlClashPalette.ink;
    final a = widget.seed;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(13,9,20,8),
          child: Row(children: [
            Material(color: isDark ? const Color(0xFF303744) : FlClashPalette.card,
              shape: const CircleBorder(),
              child: InkWell(customBorder: const CircleBorder(),
                onTap: widget.onOpenControls,
                child: const SizedBox(width: 48,height: 48,
                  child: Icon(Icons.arrow_back_rounded,size: 29)))),
            const SizedBox(width: 17),
            Text('主题',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,
              color: foreground)),
            const Spacer(),
            IconButton(tooltip:'查看所有 Axon UI 控件', onPressed: widget.onOpenControls,
              icon: const Icon(Icons.widgets_outlined)),
          ])),
        Expanded(child: AnimatedOpacity(
          duration: FlMotion.duration(context),opacity: _loaded ? 1 : 0,
          child: ListView(physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14,4,14,40),
            children: [
              FlCard(child: InkWell(borderRadius: BorderRadius.circular(25),
                onTap: () {setState(() => _colorStyle=(_colorStyle+1)%3);
                  _save('color_style',_colorStyle);},
                child: Padding(padding: const EdgeInsets.symmetric(
                  horizontal: 17,vertical: 18),
                  child: Row(children: [const Expanded(child: Text('配色风格',
                    style: TextStyle(fontSize: 17))),
                    Text(const ['鲜明','柔和','自然'][_colorStyle],
                      style: const TextStyle(fontSize: 16,color: FlClashPalette.muted)),
                    const SizedBox(width: 8),const Icon(Icons.unfold_more_rounded,size: 20),
                  ])))),
              const FlSectionHeader(icon: Icons.palette_outlined,title:'主题色'),
              SizedBox(height:54, child: ListView(scrollDirection: Axis.horizontal,
                children:[for(final color in _colors) GestureDetector(
                  onTap: () => widget.onSeedChanged(color),
                  child: Padding(padding:const EdgeInsets.only(right:12),
                    child: AnimatedContainer(duration: FlMotion.duration(context),
                      width: 48,height:48,padding:const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape:BoxShape.circle,
                        border: Border.all(color:a.toARGB32()==color.toARGB32()
                            ? FlClashPalette.blue:Colors.transparent,width:2)),
                      child: DecoratedBox(decoration:BoxDecoration(
                        color:color,shape:BoxShape.circle),
                        child:a.toARGB32()==color.toARGB32()
                          ? const Icon(Icons.check_rounded,color:Colors.white):null)),
                  )) ])),
              FlChoiceGroup<ThemeMode>(title:'主题模式', icon:Icons.brightness_6_outlined,
                value:widget.mode, onChanged:widget.onThemeChanged,
                options:const [
                  FlChoice(ThemeMode.system,'跟随系统',preview:FlMiniScreen()),
                  FlChoice(ThemeMode.light,'浅色',preview:FlMiniScreen()),
                  FlChoice(ThemeMode.dark,'深色',preview:FlMiniScreen(dark:true)),
                ]),
              FlChoiceGroup<bool>(title:'底栏',icon:Icons.layers_outlined,
                value:_floating,options:[
                  FlChoice(true,'悬浮',preview:FlMiniScreen(floating:true,accent:a,glass:_glass)),
                  FlChoice(false,'固定',preview:FlMiniScreen(floating:false,accent:a,glass:_glass)),
                ],onChanged:(v) {setState(() => _floating=v);_save('floating',v);}),
              FlChoiceGroup<bool>(title:'选项卡动画',icon:Icons.motion_photos_on_outlined,
                value:_slide,options:[
                  FlChoice(true,'滑动',preview:FlMiniScreen(slide:true,accent:a)),
                  FlChoice(false,'淡入',preview:FlMiniScreen(slide:false,accent:a)),
                ],onChanged:(v) {setState(() => _slide=v);_save('slide',v);}),
              FlChoiceGroup<int>(title:'液态玻璃',icon:Icons.water_drop_outlined,
                value:_glass,options:[
                  FlChoice(0,'无',preview:FlMiniScreen(glass:0,accent:a)),
                  FlChoice(1,'标准',preview:FlMiniScreen(glass:1,accent:a)),
                  FlChoice(2,'极致',preview:FlMiniScreen(glass:2,accent:a)),
                ],onChanged:(v) {setState(() => _glass=v);_save('glass',v);}),
              const FlSectionHeader(icon:Icons.font_download_outlined,title:'字体'),
              FlCard(child: ListTile(
                contentPadding:const EdgeInsets.symmetric(horizontal:17),
                leading:const Text('Aa',style:TextStyle(fontSize:21,fontWeight:FontWeight.w600)),
                title:Text(_font,style:const TextStyle(fontSize:16)),
                trailing:const Icon(Icons.chevron_right_rounded,color:FlClashPalette.muted),
                onTap:_pickFont)),
              const FlSectionHeader(icon:Icons.text_fields_rounded,title:'文本缩放'),
              FlPillSegmented(values:const ['跟随系统','自定义'],
                selected:_custom?1:0,onChanged:(i){setState(() => _custom=i==1);
                  _save('custom',_custom);}),
              const SizedBox(height:8),
              FlCard(child:Padding(padding:const EdgeInsets.fromLTRB(16,15,16,12),
                child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
                  Row(children:[
                    AnimatedDefaultTextStyle(duration: FlMotion.duration(context),
                      style:TextStyle(fontSize:21*_scale,color:foreground),child:const Text('Aa')),
                    const Spacer(),
                    DecoratedBox(decoration:BoxDecoration(
                      color:isDark?Colors.white12:const Color(0xFFF0EEF1),
                      borderRadius:BorderRadius.circular(30)),
                      child: Padding(padding:const EdgeInsets.symmetric(horizontal:12,vertical:5),
                        child:Text('${(_scale*100).round()}%',style:const TextStyle(
                          fontWeight:FontWeight.w600,fontSize:14)))),
                  ]),
                  const SizedBox(height:3),
                  AnimatedDefaultTextStyle(duration: FlMotion.duration(context),
                    style:TextStyle(fontSize:14.5*_scale,color:FlClashPalette.muted),
                    child:const Text('应用内的文字将以这个大小显示')),
                  const SizedBox(height:10),
                  FlDiscreteScale(value:_scale,onChanged:(v){setState(() {
                    _scale=v;_custom=true;});_save('scale',v);_save('custom',true);}),
                ]))),
              const FlSectionHeader(icon:Icons.animation_rounded,title:'动态效果预览'),
              FlCard(child:Padding(padding:const EdgeInsets.all(16),
                child:Column(children:[
                  Row(children:[const Text('页面切换',style:TextStyle(fontSize:16,
                    fontWeight:FontWeight.w500)),const Spacer(),
                    Text(_slide?'滑动':'淡入',style:const TextStyle(color:FlClashPalette.muted))]),
                  const SizedBox(height:14),
                  FlPillSegmented(values:const ['首页','设置','控件'],
                    selected:_previewTab,onChanged:(v)=>setState(() => _previewTab=v)),
                  const SizedBox(height:12),
                  ClipRRect(borderRadius:BorderRadius.circular(18),
                    child: Stack(children:[
                      AnimatedSwitcher(duration:FlMotion.duration(context,360),
                        switchInCurve:FlMotion.curve,
                        transitionBuilder:(child,animation)=> _slide
                          ? SlideTransition(position:Tween<Offset>(
                              begin:const Offset(.13,0),end:Offset.zero).animate(animation),
                            child:FadeTransition(opacity:animation,child:child))
                          : FadeTransition(opacity:animation,child:child),
                        child:Container(key:ValueKey(_previewTab),height:90,
                          alignment:Alignment.center,
                          color:a.withValues(alpha:.075),
                          child:Text(const ['概览面板','个性化设置','UI 组件预览'][_previewTab],
                            style:TextStyle(fontSize:18,color:a,fontWeight:FontWeight.w600))),
                      ),
                      if(_glass>0) Positioned(right:8,top:8,
                        child:ClipRRect(borderRadius:BorderRadius.circular(12),
                          child:BackdropFilter(filter:ImageFilter.blur(
                            sigmaX:_glass==2?16:6,sigmaY:_glass==2?16:6),
                            child:Container(color:Colors.white.withValues(
                              alpha: _glass == 2 ? 0.38 : 0.70),
                              padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),
                              child:const Text('Glass',style:TextStyle(fontSize:11)))))),
                    ])),
                  const SizedBox(height:8),
                  Align(alignment:Alignment.centerRight,child:TextButton.icon(
                    onPressed:widget.onOpenControls,
                    icon:const Icon(Icons.open_in_new_rounded,size:17),
                    label:const Text('全部 Axon UI 控件'))),
                ]))),
            ],
          ),
        )),
      ])),
    );
  }
}
