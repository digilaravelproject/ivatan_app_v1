
import 'package:flutter/material.dart';

class TextOverlay {
  String text;
  Color color;
  String style;
  String shape;
  String font;
  Offset position;
  double scale;
  double rotation;

  TextOverlay({
    required this.text,
    required this.color,
    this.style = 'Classic',
    this.shape = 'None',
    this.font = 'Default',
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class StickerOverlay {
  String emoji;
  Offset position;
  double scale;
  double rotation;

  StickerOverlay({
    required this.emoji,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class DrawingStroke {
  List<Offset> points;
  Color color;
  double strokeWidth;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length > 1) {
        for (int i = 0; i < stroke.points.length - 1; i++) {
          canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
        }
      } else if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points[0], stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
