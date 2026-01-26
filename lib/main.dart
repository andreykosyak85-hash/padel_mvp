import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Импорты твоих экранов (убедись, что названия файлов совпадают)
import 'screens/auth_screen.dart'; // Твой экран входа/регистрации
import 'screens/quiz_screen.dart'; // Твой экран квиза
import 'screens/home_screen.dart'; // Главная (Dashboard)
import 'screens/matches_screen.dart'; // Матчи (тот, что мы делали)
import 'screens/profile_screen.dart'; // Профиль
import 'screens/booking_screen.dart'; // Если есть бронирование

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Вставь свои ключи Supabase
  await Supabase.initialize(
    url: 'https://ktbjxkbazkcwhuilcwdr.supabase.co',
    anonKey: 'sb_publishable_7KiMaH9VWnjeiURtgke_zA_GqrotD0A',
  );

  runApp(const MyApp());
}

// Глобальная переменная для удобства
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Padel IQ Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF007AFF),
      ),
      // 🔥 ГЛАВНАЯ ТОЧКА ВХОДА - ШЛЮЗ АВТОРИЗАЦИИ
      home: const AuthGate(),
    );
  }
}

// --------------------------------------------------------
// 🚪 ШЛЮЗ АВТОРИЗАЦИИ (РЕШАЕТ КУДА ИДТИ)
// --------------------------------------------------------
// --------------------------------------------------------
// 🚪 ШЛЮЗ АВТОРИЗАЦИИ (STREAM VERSION - БЕЗ БАГОВ)
// --------------------------------------------------------
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Слушаем состояние авторизации (Вход/Выход)
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, authSnapshot) {
        // Если грузится сам Supabase
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = authSnapshot.data?.session;

        // 2. Если НЕ вошел -> Экран Входа
        if (session == null) {
          return const AuthScreen();
        }

        // 3. Если вошел -> СЛУШАЕМ ПРОФИЛЬ (Realtime)
        // Это решит проблему задержки создания профиля
        return StreamBuilder<Map<String, dynamic>>(
          stream: supabase
              .from('profiles')
              .stream(primaryKey: ['id'])
              .eq('id', session.user.id)
              .map((data) => data.isNotEmpty ? data.first : {}), // Берем первую запись
          builder: (context, profileSnapshot) {
            
            // Пока ждем данные профиля -> Крутим спиннер
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final profile = profileSnapshot.data;

            // Если профиль еще не создался (база тупит) или данных нет
            if (profile == null || profile.isEmpty) {
               // Можно показать "Создаем ваш профиль..."
               return const Scaffold(body: Center(child: Text("Настройка профиля...")));
            }

            // 🔥 ГЛАВНАЯ ПРОВЕРКА УРОВНЯ
            final level = (profile['level'] as num?) ?? 0; // Если null, считаем 0

            if (level == 0) {
              return const QuizScreen(); // Уровень 0 -> КВИЗ
            } else {
              return const MainScaffold(); // Уровень есть -> ГЛАВНАЯ
            }
          },
        );
      },
    );
  }
}
// --------------------------------------------------------
// 📱 ГЛАВНЫЙ ЭКРАН С ВКЛАДКАМИ (BOTTOM NAVIGATION)
// --------------------------------------------------------
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Список страниц для вкладок
  final List<Widget> _pages = [
    const HomeScreen(), // 0: Главная
    const MatchesScreen(), // 1: Матчи (Наш новый экран)
    const Center(
        child: Text("Бронирование (Скоро)",
            style: TextStyle(color: Colors.white))), // 2: Бронь (заглушка)
    const ProfileScreen(), // 3: Профиль
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Показываем текущую страницу
      body: _pages[_currentIndex],

      // Нижнее меню
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0D1117), // Цвет фона меню
          selectedItemColor: const Color(0xFF007AFF), // Активный цвет (синий)
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed, // Чтобы не прыгало
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: "Главная"),
            BottomNavigationBarItem(
                icon: Icon(Icons.sports_tennis), label: "Матчи"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month), label: "Бронь"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),
          ],
        ),
      ),
    );
  }
}
