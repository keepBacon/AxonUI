import 'package:flutter/material.dart';
import 'theme.dart';

/// A lightweight, interruptible pressed-state transform. It never replaces
/// a control's InkWell: taps, ripples and accessibility stay with the child.
class FlPressScale extends StatefulWidget {
  const FlPressScale({
    super.key,
    required this.child,
    this.pressedScale = .97,
  });
  final Widget child;
  final double pressedScale;

  @override
  State<FlPressScale> createState() => _FlPressScaleState();
}

class _FlPressScaleState extends State<FlPressScale> {
  int? _pointer;
  Offset? _origin;
  bool _pressed = false;

  void _begin(PointerDownEvent event) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    _origin = event.position;
    setState(() => _pressed = true);
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer != _pointer || _origin == null) return;
    // Do not keep the pressed visual when the user starts scrolling the page.
    if ((event.position - _origin!).distance > 14) _end(event.pointer);
  }

  void _end(int pointer) {
    if (pointer != _pointer) return;
    _pointer = null;
    _origin = null;
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _begin,
    onPointerMove: _move,
    onPointerUp: (event) => _end(event.pointer),
    onPointerCancel: (event) => _end(event.pointer),
    child: AnimatedScale(
      key: const ValueKey('press-transform'),
      scale: _pressed ? widget.pressedScale : 1,
      duration: FlMotion.effective(context,
        _pressed ? FlMotion.press : FlMotion.release),
      curve: _pressed ? Curves.easeOutCubic : FlMotion.rebound,
      child: widget.child,
    ),
  );
}

class FlFadeThrough extends StatelessWidget {
  const FlFadeThrough({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: FlMotion.effective(context, FlMotion.page),
    layoutBuilder: (current, previous) => Stack(
      fit: StackFit.expand,
      children: [...previous, if (current != null) current],
    ),
    transitionBuilder: (page, animation) => AnimatedBuilder(
      animation: animation,
      child: page,
      builder: (context, page) {
        final leaving = animation.status == AnimationStatus.reverse;
        final t = animation.value.clamp(0.0, 1.0).toDouble();
        final raw = leaving
            ? ((t - .55) / .45).clamp(0.0, 1.0).toDouble()
            : ((t - .40) / .60).clamp(0.0, 1.0).toDouble();
        final opacity = Curves.easeOutCubic.transform(raw);
        return IgnorePointer(
          ignoring: leaving,
          child: ExcludeSemantics(
            excluding: leaving,
            child: Opacity(
              opacity: opacity,
              child: FractionalTranslation(
                translation: Offset(leaving ? 0 : .018 * (1 - opacity), 0),
                child: page,
              ),
            ),
          ),
        );
      },
    ),
    child: child,
  );
}
