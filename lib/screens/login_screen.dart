import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Доступ к supabase
import 'matches_screen.dart'; // <--- ИДЕМ СЮДА (Новый главный экран)
import 'auth_screen.dart'; // Экран входа/регистрации

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  // Функция для кнопки "Я просто посмотреть"
  void _skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MatchesScreen()),
    );
  }

  // Функция входа (если ты используешь Email/Google здесь)
  Future<void> _signIn() async {
    // Если у тебя тут была логика Google, она должна быть тут. 
    // Пока просто перекидываем на экран авторизации, если нужно
    Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип (если есть) или Текст
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Icon(Icons.sports_tennis, size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 30),
              
              const Text(
                "Padel MVP",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Твой путь к профессиональному\nрейтингу начинается здесь",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              
              const SizedBox(height: 50),

              // Кнопка Входа
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _signIn,
                  icon: const Icon(Icons.login, color: Colors.black),
                  label: const Text("Войти / Регистрация", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Кнопка "Я просто посмотреть" (ИСПРАВЛЕНА)
              TextButton(
                onPressed: _skipLogin, // <--- ТЕПЕРЬ ВЕДЕТ НА МАТЧИ
                child: const Text("Я просто посмотреть", style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}