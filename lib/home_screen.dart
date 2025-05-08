import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quizz_app/edit_quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_screen.dart';
import 'create_quiz_screen.dart';
import 'question_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<Question>> quizSets = {};

  @override
  void initState() {
    super.initState();
    _loadSavedQuizzes();
  }

  Future<void> _loadSavedQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('custom_quizzes');

    if (savedData != null) {
      final decoded = json.decode(savedData) as Map<String, dynamic>;

      setState(() {
        quizSets = decoded.map((title, questionsJson) {
          final questions = (questionsJson as List)
              .map((q) => Question.fromJson(q))
              .toList();
          return MapEntry(title, questions);
        });
      });
    }
  }

  Future<void> _saveCustomQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = quizSets.map(
      (key, value) => MapEntry(key, value.map((q) => q.toJson()).toList()),
    );
    await prefs.setString('custom_quizzes', json.encode(encoded));
  }

  Future<void> _deleteQuiz(String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Quiz"),
        content: Text("Are you sure you want to delete \"$title\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => quizSets.remove(title));
      await _saveCustomQuizzes();
    }
  }

  Future<void> _editQuiz(String title) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditQuizScreen(
          quizTitle: title,
          initialQuestions: quizSets[title]!,
        ),
      ),
    );

    if (result != null && result is List<Question>) {
      setState(() {
        quizSets[title] = result;
      });
      await _saveCustomQuizzes();
    }
  }

  Future<void> _createNewQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateQuizScreen(),
      ),
    );

    if (result != null && result is MapEntry<String, List<Question>>) {
      setState(() {
        quizSets[result.key] = result.value;
      });
      await _saveCustomQuizzes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Quiz')),
      body: Column(
        children: [
          Expanded(child: _buildQuizList()),
          _buildCreateButton(),
        ],
      ),
    );
  }

  Widget _buildQuizList() {
    if (quizSets.isEmpty) {
      return const Center(child: Text("No quizzes found."));
    }

    return ListView(
      children: quizSets.entries.map((entry) {
        final title = entry.key;

        return ListTile(
          title: Text(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editQuiz(title),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteQuiz(title),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(questions: quizSets[title]!),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCreateButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _createNewQuiz,
        child: const Text('Create New Quiz'),
      ),
    );
  }
}
