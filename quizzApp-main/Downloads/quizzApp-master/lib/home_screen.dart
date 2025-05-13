import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'quiz_screen.dart';
import 'edit_quiz_screen.dart';
import 'create_quiz_screen.dart';
import 'question_model.dart';

class HomeScreen extends StatefulWidget {
  final void Function(bool)? toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<Question>> quizSets = {};

  @override
  void initState() {
    super.initState();
    _loadQuizzesFromFirestore();
  }

  Future<void> _loadQuizzesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (doc.exists && doc.data()?['data'] != null) {
      final data = Map<String, dynamic>.from(doc.data()!['data']);
      if (!mounted) return;
      setState(() {
        quizSets = data.map((title, questionsJson) {
          final questions = (questionsJson as List)
              .map((q) => Question.fromJson(q))
              .toList();
          return MapEntry(title, questions);
        });
      });
    }
  }

  Future<void> _saveQuizzesToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final encoded = quizSets.map(
      (key, value) => MapEntry(key, value.map((q) => q.toJson()).toList()),
    );

    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(user.uid)
        .set({'data': encoded});
  }

  void _openProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin tài khoản",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("Email: ${user.email}"),
            Text("UID: ${user.uid}"),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Chế độ tối"),
              value: Theme.of(bottomSheetContext).brightness == Brightness.dark,
              onChanged: (value) {
                widget.toggleTheme?.call(value);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (bottomSheetContext.mounted) {
                    Navigator.pop(bottomSheetContext);
                  }
                });
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Đăng xuất"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (bottomSheetContext.mounted) {
                  Navigator.pop(bottomSheetContext);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _openProfile,
          )
        ],
      ),
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
      return const Center(child: Text("Chưa có quiz nào."));
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
      await _saveQuizzesToFirestore();
    }
  }

  Future<void> _deleteQuiz(String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa Quiz"),
        content: Text("Bạn chắc chắn muốn xóa \"$title\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => quizSets.remove(title));
      await _saveQuizzesToFirestore();
    }
  }

  Future<void> _createNewQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
    );

    if (result != null && result is MapEntry<String, List<Question>>) {
      setState(() {
        quizSets[result.key] = result.value;
      });
      await _saveQuizzesToFirestore();
    }
  }

  Widget _buildCreateButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _createNewQuiz,
        icon: const Icon(Icons.add),
        label: const Text('Tạo quiz mới'),
      ),
    );
  }
}
