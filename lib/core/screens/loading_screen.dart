import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingScreen extends StatefulWidget {
  final String message;

  const LoadingScreen({
    Key? key,
    this.message = 'Yükleniyor...',
  }) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF5467FF),
              const Color(0xFF7B4EFF),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or app title
              Text(
                'Englitics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 80),

              // Custom animated loading indicator
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 80,
                    height: 80,
                    child: CustomPaint(
                      painter: LoadingPainter(
                        animation: _animationController,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 40),

              // Loading message
              Text(
                widget.message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingPainter extends CustomPainter {
  final Animation<double> animation;

  LoadingPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw loading arc
    final loadingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final startAngle = -0.5 * 3.14; // Start at the top
    final sweepAngle = animation.value * 2 * 3.14; // Full circle

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      loadingPaint,
    );

    // Draw small rotating circle at the end of the arc
    final dotRadius = 5.0;
    final dotAngle = startAngle + sweepAngle;
    final dotX = center.dx + (radius * math.cos(dotAngle));
    final dotY = center.dy + (radius * math.sin(dotAngle));

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant LoadingPainter oldDelegate) {
    return true;
  }
}
