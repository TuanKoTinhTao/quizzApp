//edit_screen
import 'package:flutter/material.dart';
import 'question_model.dart';

class EditQuizScreen extends StatefulWidget {
  final String quizTitle;
  final List<Question> initialQuestions;

  const EditQuizScreen({
    super.key,
    required this.quizTitle,
    required this.initialQuestions,
  });

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  late List<Question> questions;

  final _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers = List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;

  @override
  void initState() {
    super.initState();
    questions = List<Question>.from(widget.initialQuestions);
  }

  void _addQuestion() {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;

    List<Answer> answers = List.generate(4, (i) {
      return Answer(_answerControllers[i].text.trim(), i == _correctIndex);
    });

    if (answers.any((a) => a.answerText.isEmpty)) return;

    setState(() {
      questions.add(Question(text, answers));
      _questionController.clear();
      for (final c in _answerControllers) {
        c.clear();
      }
      _correctIndex = 0;
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Quiz: ${widget.quizTitle}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Current Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...questions.asMap().entries.map((entry) {
              final i = entry.key;
              final q = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(q.questionText),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeQuestion(i),
                  ),
                ),
              );
            }),
            const Divider(),
            const Text('Add New Question', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question Text'),
            ),
            const SizedBox(height: 8),
            ...List.generate(4, (index) {
              return RadioListTile(
                title: TextField(
                  controller: _answerControllers[index],
                  decoration: InputDecoration(labelText: 'Answer ${index + 1}'),
                ),
                value: index,
                groupValue: _correctIndex,
                onChanged: (val) {
                  setState(() {
                    _correctIndex = val!;
                  });
                },
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Add Question'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, questions);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
