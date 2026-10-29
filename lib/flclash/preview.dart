import 'package:flutter/material.dart';
import 'theme.dart';

/// Custom-painted mini phone thumbnails inspired by FlClash's MiniScreen.
/// No external bitmap dependencies or fixed-screen captures.
class FlScreenThumb extends StatelessWidget {
  const FlScreenThumb({super.key, this.dark = false, this.floating = true,
    this.slide = true, this.glass = 0, this.accent = FlTokens.blue});
  final bool dark, floating, slide;
  final int glass;
  final Color accent;
  @override
  Widget build(BuildContext context) => SizedBox(width: 52, height: 38,
    child: ClipRRect(borderRadius: BorderRadius.circular(7),
      child: CustomPaint(painter: _ThumbPainter(
        dark: dark, floating: floating, slide: slide, glass: glass, accent: accent))));
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter({required this.dark, required this.floating, required this.slide,
    required this.glass, required this.accent});
  final bool dark, floating, slide;
  final int glass;
  final Color accent;
  @override
  void paint(Canvas canvas, Size s) {
    final bg = dark ? const Color(0xFF222631) : const Color(0xFFEDF1F6);
    final card = dark ? const Color(0xFF353947) : Colors.white;
    final ink = dark ? const Color(0xFFD4D8E1) : const Color(0xFF8B9AAA);
    canvas.drawRect(Offset.zero & s, Paint()..color = bg);
    void box(double x, double y, double w, double h, Color c, [double r = 3]) =>
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h),
          Radius.circular(r)), Paint()..color = c);
    box(5, 4, 20, 3, ink.withValues(alpha: .45), 2);
    box(5, 10, 42, 14, card);
    box(8, 13, 14, 4, accent.withValues(alpha: .8), 2);
    box(8, 20, 34, 1.5, ink.withValues(alpha: .30), 1);
    box(5, 26, 42, 5, card, 2);
    for (var i=0;i<4;i++) { box(9+i*9.5, 27.5, 5, 2, i==1 ? accent : ink.withValues(alpha:.35),1); }
    if (floating) { box(9, 32, 34, 5, glass>0 ? accent.withValues(alpha:.28):card, 3); }
    else { box(0, 32, s.width, 6, card, 0); }
    if (slide) { box(22, 32.8, 7, 3.7, accent.withValues(alpha:.6),3); }
    else { box(24, 33, 4, 4, accent,3); }
    if (glass==2) box(11, 32.4, 30, 1, Colors.white.withValues(alpha:.5),1);
  }
  @override
  bool shouldRepaint(covariant _ThumbPainter old) =>
    dark!=old.dark || floating!=old.floating || slide!=old.slide ||
    glass!=old.glass || accent!=old.accent;
}

/// Animated interactive phone used to preview the real tab transition.
class FlLivePreview extends StatefulWidget {
  const FlLivePreview({super.key, required this.accent,
    required this.floating, required this.slide, required this.glass,
    required this.dark});
  final Color accent;
  final bool floating, slide, dark;
  final int glass;
  @override
  State<FlLivePreview> createState() => _FlLivePreviewState();
}
class _FlLivePreviewState extends State<FlLivePreview> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final fg = widget.dark ? Colors.white : const Color(0xFF253042);
    final bg = widget.dark ? const Color(0xFF20242E) : const Color(0xFFF0F1F6);
    final card = widget.dark ? const Color(0xFF343844) : Colors.white;
    final label = ['总览', '控件', '配置', '主题'][selected];
    // Lay out the miniature screen at its design size, then scale as a whole.
    // This keeps animated content within 234px preview panels on small phones
    // and avoids RenderFlex overflows during AnimatedSwitcher transitions.
    return Center(child: FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(width: 175, height: 300,
      child: AnimatedContainer(duration: FlMotion.effective(context),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:.12), blurRadius: 20)]),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
          child: Column(children: [
            Row(children: [Container(width: 48, height: 6,
              decoration: BoxDecoration(color: fg.withValues(alpha:.20),
                borderRadius: BorderRadius.circular(9))), const Spacer(),
              Icon(Icons.more_horiz, size: 12, color: fg)]),
            const SizedBox(height: 12),
            Expanded(child: ClipRect(child: AnimatedSwitcher(
              duration: FlMotion.effective(context, const Duration(milliseconds: 340)),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                if (!widget.slide) return FadeTransition(opacity: animation, child: child);
                return SlideTransition(position: Tween(begin: const Offset(.16, 0),
                  end: Offset.zero).animate(animation), child: FadeTransition(
                    opacity: animation, child: child));
              },
              child: Column(key: ValueKey(selected),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: fg,fontSize:16,fontWeight:FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(height: 52, decoration: BoxDecoration(color: card,
                    borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size:18, color:widget.accent),
                        const SizedBox(width:6), Text('Axon UI', style:TextStyle(fontSize:11,color:fg)),
                      ]))),
                  const SizedBox(height: 6),
                  for (var i=0;i<3;i++) Padding(padding: const EdgeInsets.only(bottom:6),
                    child: Container(height: 24, decoration: BoxDecoration(color:card,
                      borderRadius:BorderRadius.circular(9)),
                      child: Row(children:[const SizedBox(width:8),CircleAvatar(
                        radius:6,backgroundColor: widget.accent.withValues(alpha:.55)),
                        const SizedBox(width:8),Container(height:4,width:52,
                          decoration:BoxDecoration(color:fg.withValues(alpha:.16),
                            borderRadius:BorderRadius.circular(3)))]))),
                ]),
            ))),
            const SizedBox(height: 10),
            AnimatedContainer(duration: FlMotion.effective(context),
              height: 34, margin: EdgeInsets.symmetric(horizontal:widget.floating?8:0),
              decoration: BoxDecoration(color:widget.glass==0?card:
                card.withValues(alpha:widget.glass == 1 ? 0.78 : 0.55),
                borderRadius:BorderRadius.circular(widget.floating?20:5)),
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: InkWell(
                        key: ValueKey('preview-tab-$i'),
                        onTap: () => setState(() => selected = i),
                        child: Center(
                          child: AnimatedContainer(
                            duration: FlMotion.effective(context),
                            width: i == selected ? 26 : 18,
                            height: 22,
                            decoration: BoxDecoration(
                              color: i == selected
                                  ? widget.accent.withValues(alpha: .22)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              [
                                Icons.dashboard_outlined,
                                Icons.tune_rounded,
                                Icons.layers_outlined,
                                Icons.palette_outlined,
                              ][i],
                              size: 13,
                              color: i == selected
                                  ? widget.accent
                                  : fg.withValues(alpha: .4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ])),
      ),
    )));
  }
}
