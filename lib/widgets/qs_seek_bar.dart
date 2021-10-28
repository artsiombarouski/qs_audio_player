import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QsSeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final bool showTimers;

  QsSeekBar({
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
    this.showTimers = true,
  });

  @override
  _QsSeekBarState createState() => _QsSeekBarState();
}

class _QsSeekBarState extends State<QsSeekBar> {
  static final _timeRegex = RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$');

  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = widget.duration.inMilliseconds.toDouble();
    final value = min(max, widget.bufferedPosition.inMilliseconds.toDouble());
    List<Widget>? timerWidgets;
    if (widget.showTimers) {
      timerWidgets = [
        const SizedBox(height: 44.0),
        Positioned(
          left: 16.0,
          bottom: 0.0,
          child: Text(
              _timeRegex.firstMatch("$_left")?.group(1) ?? '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              _timeRegex.firstMatch("$_remaining")?.group(1) ?? '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
      ];
    }
    return Stack(
      fit: StackFit.loose,
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            overlayShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8.0, pressedThumbRadius: 12.0),
            activeTrackColor: theme.primaryColor.withOpacity(0.2),
            inactiveTrackColor: Colors.black.withOpacity(0.05),
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: max,
              value: value,
              onChanged: _handleChange,
              onChangeEnd: _handleChangeEnd,
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8.0, pressedThumbRadius: 12.0),
            overlayShape: HiddenThumbComponentShape(),
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(
              _dragValue ?? widget.position.inMilliseconds.toDouble(),
              widget.duration.inMilliseconds.toDouble(),
            ),
            onChanged: _handleChange,
            onChangeEnd: _handleChangeEnd,
          ),
        ),
        if (timerWidgets != null) ...timerWidgets
      ],
    );
  }

  void _handleChange(double value) {
    setState(() {
      _dragValue = value;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(Duration(milliseconds: value.round()));
    }
  }

  void _handleChangeEnd(double value) {
    if (widget.onChangeEnd != null) {
      widget.onChangeEnd!(Duration(milliseconds: value.round()));
    }
    _dragValue = null;
  }

  Duration get _left => widget.position;

  Duration get _remaining => widget.duration - widget.position;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class RoundSliderThumbShape extends SliderComponentShape {
  const RoundSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.pressedThumbRadius,
    this.disabledThumbRadius,
    this.elevation = 1.0,
    this.pressedElevation = 6.0,
  });

  final double enabledThumbRadius;

  final double? pressedThumbRadius;

  double get _pressedThumnRadius => pressedThumbRadius ?? enabledThumbRadius;

  final double? disabledThumbRadius;

  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  final double elevation;

  final double pressedElevation;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled == true ? _pressedThumnRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    assert(context != null);
    assert(center != null);
    assert(enableAnimation != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    final Tween<double> pressedRadiusTween = Tween<double>(
      begin: enabledThumbRadius,
      end: _pressedThumnRadius,
    );
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    final Color color = colorTween.evaluate(enableAnimation)!;
    final double radius = math.max(
      pressedRadiusTween.evaluate(activationAnimation),
      radiusTween.evaluate(enableAnimation),
    );

    final Tween<double> elevationTween = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    );

    final double evaluatedElevation =
        elevationTween.evaluate(activationAnimation);
    final Path path = Path()
      ..addArc(
          Rect.fromCenter(
              center: center, width: 2 * radius, height: 2 * radius),
          0,
          math.pi * 2);
    canvas.drawShadow(path, Colors.black, evaluatedElevation, true);

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = color,
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;

  PositionData(this.position, this.bufferedPosition);
}
