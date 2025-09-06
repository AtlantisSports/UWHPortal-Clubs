/// UWH Portal logo widget
library;

import 'package:flutter/material.dart';

class UWHPortalLogo extends StatelessWidget {
  final double? height;
  final double? width;
  
  const UWHPortalLogo({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 80,
      width: width,
      child: CustomPaint(
        painter: UWHLogoPainter(),
      ),
    );
  }
}

class UWHLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Blue gradient for UWH text
    final bluePaint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.6));
    
    // Draw "UWH" text (simplified representation)
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'UWH',
        style: TextStyle(
          fontSize: size.height * 0.35,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset((size.width - textPainter.width) / 2, size.height * 0.05)
    );
    
    // Draw "Portal" text
    final portalTextPainter = TextPainter(
      text: TextSpan(
        text: 'Portal',
        style: TextStyle(
          fontSize: size.height * 0.25,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    portalTextPainter.layout();
    portalTextPainter.paint(
      canvas, 
      Offset((size.width - portalTextPainter.width) / 2, size.height * 0.5)
    );
    
    // Draw hockey puck (simplified circle)
    final puckPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;
    
    final puckCenter = Offset(size.width * 0.85, size.height * 0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: puckCenter, 
        width: size.width * 0.15, 
        height: size.height * 0.2
      ), 
      puckPaint
    );
    
    // Draw puck highlight
    final highlightPaint = Paint()
      ..color = Colors.grey[500]!
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(puckCenter.dx - 2, puckCenter.dy - 2), 
        width: size.width * 0.1, 
        height: size.height * 0.12
      ), 
      highlightPaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
