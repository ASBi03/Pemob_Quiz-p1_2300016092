import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'view_model.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late final QuizViewModel viewModel = QuizViewModel(
    onGameOver: _handleGameOver,
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        // ANIMASI CODELAB: latar gradient berganti halus tiap pertanyaan
        // (AnimatedContainer meng-interpolasi warna gradient secara implisit).
        final palette = AppColors.backgrounds[(viewModel.answeredQuestionCount) %
            AppColors.backgrounds.length];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0,
              actions: [
                TextButton(
                  onPressed:
                      viewModel.hasNextQuestion && viewModel.didAnswerQuestion
                      ? () {
                          viewModel.getNextQuestion();
                        }
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
            body: Center(
              child: Column(
                children: [
                  QuestionCard(question: viewModel.currentQuestion?.question),
                  const Spacer(),
                  AnswerCards(
                    onTapped: (index) {
                      viewModel.checkAnswer(index);
                    },
                    answers: viewModel.currentQuestion?.possibleAnswers ?? [],
                    correctAnswer: viewModel.didAnswerQuestion
                        ? viewModel.currentQuestion?.correctAnswer
                        : null,
                    selectedAnswer: viewModel.selectedAnswer,
                  ),
                  StatusBar(viewModel: viewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleGameOver() async {
    // Beri waktu animasi warna jawaban terakhir terlihat dulu.
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // ANIMASI CODELAB (paket `animations`): dialog muncul dengan fade + scale.
    showModal<void>(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(
        barrierDismissible: false,
      ),
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.diamond_rounded, color: AppColors.gem),
              const SizedBox(width: 8),
              Text('Score: ${viewModel.score} / ${viewModel.totalQuestions}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String? question;

  const QuestionCard({required this.question, super.key});

  @override
  Widget build(BuildContext context) {
    // ANIMASI CODELAB: kartu soal "membalik" (flip 3D) saat soal berganti.
    // Kartu lama berputar 0 -> 90 derajat (hilang), kartu baru 90 -> 0 (muncul).
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final rotate = Tween<double>(begin: math.pi / 2, end: 0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspektif
                ..rotateX(rotate.value),
              child: child,
            );
          },
        );
      },
      child: Card(
        key: ValueKey(question),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            question ?? '',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      ),
    );
  }
}

class AnswerCards extends StatelessWidget {
  final List<String> answers;
  final ValueChanged<int> onTapped;
  final int? correctAnswer;
  final int? selectedAnswer;

  const AnswerCards({
    required this.answers,
    required this.onTapped,
    required this.correctAnswer,
    required this.selectedAnswer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 5 / 2,
      children: List.generate(answers.length, (index) {
        final isCorrect = correctAnswer == index;
        final isWrong =
            correctAnswer != null &&
            selectedAnswer == index &&
            selectedAnswer != correctAnswer;
        return AnswerCard(
          key: ValueKey(answers[index]),
          text: answers[index],
          isCorrect: isCorrect,
          isWrong: isWrong,
          onTap: () => onTapped(index),
        );
      }),
    );
  }
}

/// Satu kartu jawaban.
/// - ANIMASI CODELAB: warna berubah halus (TweenAnimationBuilder + ColorTween).
/// - ANIMASI KREASI SENDIRI #2: jawaban benar "membal" (elasticOut),
///   jawaban salah bergetar ke kiri-kanan (shake).
class AnswerCard extends StatefulWidget {
  final String text;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const AnswerCard({
    required this.text,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
    super.key,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(covariant AnswerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isWrong && widget.isWrong) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color color = scheme.primaryContainer;
    if (widget.isCorrect) color = AppColors.correct;
    if (widget.isWrong) color = AppColors.wrong;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        // Gelombang sinus yang meredam: getar 3x lalu berhenti.
        final dx = math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedScale(
        scale: widget.isCorrect ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: color),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (context, animatedColor, child) {
            return Card.filled(
              color: animatedColor,
              elevation: 2,
              margin: const EdgeInsets.all(8),
              clipBehavior: Clip.hardEdge,
              child: child,
            );
          },
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusBar extends StatelessWidget {
  final QuizViewModel viewModel;

  const StatusBar({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final total = viewModel.totalQuestions;
    final progress = total == 0 ? 0.0 : viewModel.answeredQuestionCount / total;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Question ${viewModel.answeredQuestionCount} / $total',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Score: ${viewModel.score}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DiamondScore(score: viewModel.score, total: total),
              ],
            ),
            const SizedBox(height: 12),
            // ANIMASI CODELAB: progress bar mengisi dengan halus (implisit).
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    color: AppColors.gem,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ANIMASI CODELAB (versi sendiri): deretan ikon skor. Ikon intan pink
/// "pop" dengan efek membal saat jawaban benar (codelab: bintang kuning).
class DiamondScore extends StatelessWidget {
  final int score;
  final int total;

  const DiamondScore({required this.score, required this.total, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final earned = i < score;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          switchInCurve: Curves.elasticOut,
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            earned ? Icons.diamond_rounded : Icons.diamond_outlined,
            key: ValueKey(earned),
            size: 28,
            color: earned ? AppColors.gem : Colors.black38,
          ),
        );
      }),
    );
  }
}
