import 'package:flutter/material.dart';
import 'question_model.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _quizNameController = TextEditingController();
  final _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers =
      List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;

  final List<Question> _questions = [];

  void _addQuestion() {
    final qText = _questionController.text.trim();
    if (qText.isEmpty) return;

    final answers = List.generate(4, (i) {
      return Answer(_answerControllers[i].text.trim(), i == _correctIndex);
    });

    if (answers.any((a) => a.answerText.isEmpty)) return;

    setState(() {
      _questions.add(Question(qText, answers));
      _questionController.clear();
      for (final c in _answerControllers) {
        c.clear();
      }
      _correctIndex = 0;
    });
  }

  void _submitQuiz() {
    if (_quizNameController.text.isNotEmpty && _questions.isNotEmpty) {
      Navigator.pop(
        context,
        MapEntry(_quizNameController.text.trim(), _questions),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Quiz')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _quizNameController,
              decoration: const InputDecoration(labelText: 'Quiz Name'),
            ),
            const SizedBox(height: 16),
            const Text('Add New Question',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // Câu hỏi - height lớn hơn
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _questionController,
                expands: true,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Các đáp án
            ...List.generate(4, (index) {
              return RadioListTile(
                value: index,
                groupValue: _correctIndex,
                onChanged: (val) {
                  setState(() {
                    _correctIndex = val!;
                  });
                },
                title: Container(
                  height: 60,
                  child: TextField(
                    controller: _answerControllers[index],
                    expands: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Answer ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addQuestion,
                child: const Text('Add Question'),
              ),
            ),
            const Divider(height: 32),
            const Text('Preview Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._questions.map((q) => ListTile(title: Text(q.questionText))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitQuiz,
                child: const Text('Save and Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
