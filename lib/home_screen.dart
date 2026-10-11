import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'question_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.backgrounds[0];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FloatingRocket(),
              const SizedBox(height: 8),
              Text(
                'Flutter Quiz',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Tampilkan halaman soal untuk memulai game
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const QuestionScreen();
                      },
                    ),
                  );
                },
                child: const Text('New Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ANIMASI KREASI SENDIRI #1:
/// Ikon roket yang melayang naik-turun sambil miring pelan (looping).
class FloatingRocket extends StatefulWidget {
  const FloatingRocket({super.key});

  @override
  State<FloatingRocket> createState() => _FloatingRocketState();
}

class _FloatingRocketState extends State<FloatingRocket>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutSine,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) {
        final t = _curved.value; // 0..1
        return Transform.translate(
          offset: Offset(0, (t - 0.5) * 24), // naik-turun 12px
          child: Transform.rotate(
            angle: (t - 0.5) * math.pi / 12, // miring +-7.5 derajat
            child: child,
          ),
        );
      },
      child: Icon(
        Icons.rocket_launch_rounded,
        size: 96,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
