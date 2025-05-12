import 'package:flutter/material.dart';
import 'question_model.dart';

class QuestionInputWidget extends StatefulWidget {
  final Function(Question) onAdd;

  const QuestionInputWidget({super.key, required this.onAdd});

  @override
  State<QuestionInputWidget> createState() => _QuestionInputWidgetState();
}

class _QuestionInputWidgetState extends State<QuestionInputWidget> {
  final _questionController = TextEditingController();
  final _answers = List<TextEditingController>.generate(4, (_) => TextEditingController());
  int _correctAnswerIndex = 0;

  void _handleAdd() {
    final qText = _questionController.text.trim();
    if (qText.isEmpty) return;

    final answersList = List.generate(4, (i) => 
      Answer(_answers[i].text.trim(), i == _correctAnswerIndex));

    if (answersList.any((a) => a.answerText.isEmpty)) return;

    final newQuestion = Question(qText, answersList);
    widget.onAdd(newQuestion);

    _questionController.clear();
    for (final ctrl in _answers) {
      ctrl.clear();
    }
    setState(() {
      _correctAnswerIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add New Question', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _questionController,
          decoration: const InputDecoration(labelText: 'Question'),
        ),
        const SizedBox(height: 8),
        ...List.generate(4, (index) {
          return RadioListTile(
            title: TextField(
              controller: _answers[index],
              decoration: InputDecoration(labelText: 'Answer ${index + 1}'),
            ),
            value: index,
            groupValue: _correctAnswerIndex,
            onChanged: (val) {
              setState(() {
                _correctAnswerIndex = val!;
              });
            },
          );
        }),
        ElevatedButton(
          onPressed: _handleAdd,
          child: const Text('Add Question'),
        ),
      ],
    );
  }
}
