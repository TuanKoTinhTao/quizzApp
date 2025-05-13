import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showError("Email không hợp lệ");
      return;
    }

    if (password.length < 6) {
      _showError("Mật khẩu phải ít nhất 6 ký tự");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          toggleTheme: null,)));
      }
    } catch (e) {
      _showError("Đăng nhập thất bại: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
              const SizedBox(height: 20),
              Text("Đăng nhập", style: theme.textTheme.headlineMedium),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Đăng nhập"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                },
                child: const Text("Chưa có tài khoản? Đăng ký"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}