import 'dart:ui' as ui;

import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum BulsaSceneMood { steady, paydaySoon, celebration, warning }

/// A deliberately non-interactive Flame layer. Game choices and all important
/// information remain Flutter widgets so they stay readable and accessible.
class BulsaMoodScene extends StatelessWidget {
  const BulsaMoodScene({
    super.key,
    required this.mood,
    required this.reducedMotion,
  });

  final BulsaSceneMood mood;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) => Semantics(
    label: _semanticLabel(mood),
    image: true,
    child: IgnorePointer(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 96,
          child: GameWidget.controlled(
            gameFactory: () =>
                BulsaMoodGame(mood: mood, reducedMotion: reducedMotion),
          ),
        ),
      ),
    ),
  );
}

class BulsaMoodGame extends FlameGame {
  BulsaMoodGame({required this.mood, required this.reducedMotion});

  final BulsaSceneMood mood;
  final bool reducedMotion;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!reducedMotion) _elapsed += dt;
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    final width = size.x;
    final height = size.y;
    if (width <= 0 || height <= 0) return;

    final phase = reducedMotion ? 0.0 : _elapsed;
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width, height),
      ui.Paint()..color = BulsaColors.background,
    );
    final primary = ui.Paint()
      ..color = BulsaColors.primary.withValues(alpha: 0.18);
    final softPrimary = ui.Paint()
      ..color = BulsaColors.primary.withValues(alpha: 0.08);
    final outline = ui.Paint()
      ..color = BulsaColors.black.withValues(alpha: 0.12)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(ui.Offset(width * .16, height * .55), 34, softPrimary);
    canvas.drawCircle(ui.Offset(width * .84, height * .45), 42, softPrimary);

    switch (mood) {
      case BulsaSceneMood.steady:
        _drawCoin(
          canvas,
          ui.Offset(width * .5, height * .5),
          20 + (reducedMotion ? 0 : 2 * _wave(phase)),
          primary,
          outline,
        );
      case BulsaSceneMood.paydaySoon:
        for (var index = 0; index < 3; index++) {
          final delay = phase + index * .8;
          _drawCoin(
            canvas,
            ui.Offset(width * (.42 + index * .08), height * .5),
            12 + (reducedMotion ? 0 : _wave(delay)),
            primary,
            outline,
          );
        }
      case BulsaSceneMood.celebration:
        for (var index = 0; index < 5; index++) {
          final x = width * (.32 + index * .09);
          final y =
              height * (.5 + (reducedMotion ? 0 : .14 * _wave(phase + index)));
          _drawCoin(canvas, ui.Offset(x, y), 10, primary, outline);
        }
      case BulsaSceneMood.warning:
        final center = ui.Offset(width * .5, height * .5);
        final path = ui.Path()
          ..moveTo(center.dx, center.dy - 24)
          ..lineTo(center.dx + 24, center.dy)
          ..lineTo(center.dx, center.dy + 24)
          ..lineTo(center.dx - 24, center.dy)
          ..close();
        canvas.drawPath(path, softPrimary);
        canvas.drawPath(path, outline);
    }
  }

  void _drawCoin(
    ui.Canvas canvas,
    ui.Offset center,
    double radius,
    ui.Paint fill,
    ui.Paint outline,
  ) {
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, outline);
  }

  double _wave(double value) => (value % 2 < 1 ? value % 1 : 1 - value % 1);
}

String _semanticLabel(BulsaSceneMood mood) => switch (mood) {
  BulsaSceneMood.steady => 'Decorative cycle progress scene',
  BulsaSceneMood.paydaySoon => 'Decorative payday-soon scene',
  BulsaSceneMood.celebration => 'Decorative completed-cycle celebration',
  BulsaSceneMood.warning => 'Decorative debt-limit warning',
};
