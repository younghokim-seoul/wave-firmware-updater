import 'package:flutter/material.dart';

class AlignmentView extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;

    final paintOuter = Paint()..color = Colors.transparent;

    final paintInner = Paint()
      ..color = Colors.red
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height * 0.92);
    const radius = 15.0;

    canvas.drawCircle(center, radius, paintInner);
    canvas.drawCircle(center, radius - paintOuter.strokeWidth / 2, paintOuter);

    final topStartPoint = Offset(center.dx, 0 - radius);
    final topEndPoint = Offset(center.dx, center.dy - radius);
    canvas.drawLine(topStartPoint, topEndPoint, paint);

    final leftStartPoint = Offset(0, center.dy);
    final leftEndPoint = Offset(center.dx - radius, center.dy);
    canvas.drawLine(leftStartPoint, leftEndPoint, paint);

    final rightStartPoint = Offset(center.dx + radius, center.dy);
    final rightEndPoint = Offset(size.width, center.dy);
    canvas.drawLine(rightStartPoint, rightEndPoint, paint);

    final targetLineX = center.dx;
    final targetLineY = size.height * 0.08; // 상대적 위치 (10% of screen height)

    final teeLineX = center.dx + size.width * 0.27;
    final teeLineY = size.height * 0.9; // 상대적 위치 (90% of screen height)

    const heelX = 0; // 상대적 위치 (20% of screen width)
    final heelY = teeLineY;
    _drawText(canvas, targetLineX, targetLineY, "Target line");
    _drawText(canvas, teeLineX, teeLineY, "Tee line");
    _drawText(canvas, heelX, heelY, "Heel");

    final testPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10.0;

    final testX = Offset(center.dx * 0.1, center.dy - radius * 2);
    final textY = Offset(center.dx * 0.1, center.dy);
    canvas.drawLine(testX, textY, testPaint);

    final test2X = Offset(center.dx * 0.1, center.dy - radius / 2 + 2.0);
    final text2Y = Offset(center.dx * 0.5, center.dy - radius / 2 + 2.0);
    canvas.drawLine(test2X, text2Y, testPaint);
  }

  void _drawText(Canvas canvas, centerX, centerY, text) {
    final textSpan = TextSpan(
      text: text,
    );

    final textPainter = TextPainter()
      ..text = textSpan
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center
      ..layout();

    final xCenter = (centerX + textPainter.width / 2);
    final yCenter = (centerY + textPainter.height / 2);
    final offset = Offset(xCenter, yCenter);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(AlignmentView oldDelegate) => false;
}
