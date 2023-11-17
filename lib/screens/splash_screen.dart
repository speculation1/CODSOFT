import 'package:best_todo_app/screens/name_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      body: Center(
        child: CustomPaint(
          painter: MyPainter(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  ' Best ToDo App',
                  style: GoogleFonts.lato(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 400,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NameCaptureScreen(),
                      ),
                    );
                  },
                  child: const Text('Get Started'),
                )
                    .animate(
                      onPlay: (controller) {
                        Tween(begin: 0, end: 1);
                      },
                    )
                    .scale(
                        curve: Curves.easeInSine,
                        duration: Duration(milliseconds: 400))
                    .shake(curve: Curves.bounceIn),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    const Color color1 = Colors.blue;
    const Color color2 = Colors.purple;
    const Color color3 = Colors.deepOrange;

    const Gradient gradient = LinearGradient(
      colors: [color1, color2, color3],
      stops: [0.0, 0.5, 1.0],
    );

    // Paint the background with a gradient
    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw beautiful curves using Bezier paths
    final Path path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.7,
        size.width * 0.5,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.5,
        size.width,
        size.height * 0.6,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint pathPaint = Paint()..color = Colors.white;
    canvas.drawPath(path, pathPaint);
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      var rect = Offset.zero & size;
      var width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return [
        CustomPainterSemantics(
          rect: rect,
          properties: const SemanticsProperties(
            label: 'gradient_background',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
