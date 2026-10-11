import 'package:flutter/cupertino.dart';
import 'model.dart';

class QuizViewModel extends ChangeNotifier {
  final QuestionBank _questionBank = QuestionBank();
  final VoidCallback onGameOver;
  late final int totalQuestions;
  Question? currentQuestion;
  int answeredQuestionCount = 0;
  int score = 0;
  bool didAnswerQuestion = false;

  /// Jawaban yang dipilih pemain pada soal saat ini (null = belum menjawab).
  int? selectedAnswer;

  bool get hasNextQuestion => answeredQuestionCount < totalQuestions;

  QuizViewModel({required this.onGameOver}) {
    totalQuestions = _questionBank.remainingQuestions;
    getNextQuestion();
  }

  void getNextQuestion() {
    if (_questionBank.hasNextQuestion) {
      currentQuestion = _questionBank.getRandomQuestion();
      answeredQuestionCount++;
    }

    didAnswerQuestion = false;
    selectedAnswer = null;

    notifyListeners();
  }

  void checkAnswer(int selectedIndex) {
    // Abaikan tap berikutnya setelah soal dijawab (mencegah skor ganda dan
    // dialog Game Over muncul berkali-kali).
    if (didAnswerQuestion) return;

    selectedAnswer = selectedIndex;
    if (currentQuestion?.correctAnswer == selectedIndex) {
      score++;
    }

    didAnswerQuestion = true;

    if (!_questionBank.hasNextQuestion) {
      onGameOver();
    }

    notifyListeners();
  }
}
