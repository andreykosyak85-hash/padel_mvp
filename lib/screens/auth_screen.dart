import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Чтобы получить доступ к переменной supabase
import 'quiz_screen.dart';
import 'matches_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // Режим: Вход или Регистрация
  bool isLoading = false; // Крутилка загрузки

  // Контроллеры для полей ввода
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 🔥 ГЛАВНАЯ ФУНКЦИЯ ВХОДА/РЕГИСТРАЦИИ
  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Заполните все поля")));
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // --- ЛОГИКА ВХОДА ---
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        // Если успеха, идем на главную
        if (mounted) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MatchesScreen()));
        }
      } else {
        // --- ЛОГИКА РЕГИСТРАЦИИ ---
        await supabase.auth.signUp(
          email: email,
          password: password,
        );
        // Если успеха, идем на КВИЗ (так как юзер новый)
        if (mounted) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const QuizScreen()));
        }
      }
    } on AuthException catch (error) {
      // Ошибки от Supabase (неверный пароль, юзер уже есть и т.д.)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Произошла ошибка сети"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text("Welcome to\nPadel MVP", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(isLogin ? "Войдите, чтобы продолжить" : "Создайте аккаунт для старта", style: const TextStyle(color: Colors.grey, fontSize: 16)),
              
              const SizedBox(height: 40),
              
              // ПОЛЯ ВВОДА
              _buildTextField("Email", Icons.email_outlined, _emailController),
              const SizedBox(height: 15),
              _buildTextField("Пароль (минимум 6 символов)", Icons.lock_outline, _passwordController, isPassword: true),
              
              const SizedBox(height: 25),
              
              // КНОПКА ОСНОВНАЯ (С индикатором загрузки)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit, // Если грузимся - кнопка неактивна
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isLogin ? "Войти" : "Создать аккаунт", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const Spacer(),
              
              // ПЕРЕКЛЮЧАТЕЛЬ РЕЖИМА
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isLogin ? "Нет аккаунта?" : "Уже есть аккаунт?", style: const TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(isLogin ? "Зарегистрироваться" : "Войти", style: const TextStyle(color: Color(0xFF2979FF))),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1C2538), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller, // Подключили контроллер
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}