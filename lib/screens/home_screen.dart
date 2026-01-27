import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'create_match_screen.dart'; // Импортируем новый экран

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Цветовая палитра
  final Color _bgDark = const Color(0xFF0D1117);
  final Color _cardColor = const Color(0xFF1C1C1E);
  
  // Спортивный неон
  final Color _neonGreen = const Color(0xFFccff00);
  final Color _neonCyan = const Color(0xFF00E5FF);
  final Color _neonOrange = const Color(0xFFFF5500);

  String _username = "Игрок";
  String _avatarUrl = "";
  double _level = 0.0;
  bool _isLoading = true;

  // Данные для "Часов"
  final Map<String, String> _healthStats = {
    'kcal': '680',
    'bpm': '145',
    'dist': '4.5 км',
    'last_score': '6-3, 6-4',
    'tour_rank': '2 место',
    'is_tournament': 'true'
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select('username, avatar_url, level')
          .eq('id', uid)
          .single();

      if (mounted) {
        setState(() {
          _username = data['username'] ?? "Игрок";
          _avatarUrl = data['avatar_url'] ?? "";
          _level = (data['level'] ?? 0).toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  LinearGradient _getLevelGradient(double level) {
    if (level >= 5.0) {
      return const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    } else if (level >= 4.0) {
      return const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF2979FF)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    } else if (level >= 3.0) {
      return const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF64DD17)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    } else {
      return const LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFF616161)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      // AppBar с логотипом
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: Row(
          children: [
            // ЛОГОТИП
            // Если файл assets/logo.png существует, он покажется. 
            // Если нет - покажется иконка как запасной вариант (errorBuilder).
            SizedBox(
              height: 32, // Высота логотипа
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.sports_tennis, color: _neonGreen, size: 30);
                },
              ),
            ),
            const SizedBox(width: 10),
            const Text("PADEL IQ", 
              style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 1
              )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white), 
            onPressed: () {}
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === ВЕРХНИЙ БЛОК ===
                SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("Привет, $_username! 👋", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 5),
                            const Text("Готов к игре?", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white10),
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))]
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_month, color: _neonCyan, size: 16),
                                        const SizedBox(width: 5),
                                        const Text("Сегодня, 19:00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const Spacer(),
                                    const Text("Central Padel Club", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    const Text("Корт №4", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _getLevelGradient(_level),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: _getLevelGradient(_level).colors.first.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                            ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  image: _avatarUrl.isNotEmpty 
                                    ? DecorationImage(image: NetworkImage(_avatarUrl), fit: BoxFit.cover)
                                    : null
                                ),
                                child: _avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                              ),
                              const SizedBox(height: 10),
                              Text(_level.toString(), 
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                              const Text("LEVEL", 
                                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // === КНОПКИ ДЕЙСТВИЯ (ТЕПЕРЬ ЖИВЫЕ!) ===
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        "Найти игру", 
                        Icons.search, 
                        Colors.blue,
                        // Логика нажатия (пока просто Снэкбар, потом сделаем переход на Matches)
                        () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Переходим к поиску...")));
                        }
                      )
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        "Создать матч", 
                        Icons.add, 
                        _neonOrange,
                        // Логика нажатия: Открываем экран создания
                        () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateMatchScreen()));
                        }
                      )
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // === БЛОК "HEALTH & WATCH" ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Статистика (Last Game)", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Icon(Icons.watch, color: Colors.grey[600], size: 18),
                  ],
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildNeonStatCard("ККАЛ", _healthStats['kcal']!, Icons.local_fire_department, _neonOrange),
                      const SizedBox(width: 12),
                      _buildNeonStatCard("ПУЛЬС", _healthStats['bpm']!, Icons.favorite, Colors.redAccent),
                      const SizedBox(width: 12),
                      _buildNeonStatCard("ДИСТАНЦИЯ", _healthStats['dist']!, Icons.directions_run, _neonCyan),
                      const SizedBox(width: 12),
                      _healthStats['is_tournament'] == 'true'
                          ? _buildNeonStatCard("ТУРНИР", _healthStats['tour_rank']!, Icons.emoji_events, Colors.amber)
                          : _buildNeonStatCard("СЧЕТ", _healthStats['last_score']!, Icons.scoreboard, Colors.white),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text("Padel World", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildNewsCard("Турнир Valencia Open", "Регистрация открыта до пятницы!", Icons.app_registration),
                const SizedBox(height: 10),
                _buildNewsCard("Совет тренера", "Как улучшить 'bandeja' - разбор техники.", Icons.lightbulb_outline, isTip: true),
                const SizedBox(height: 10),
                _buildNewsCard("Партнер рядом", "Ivan (3.5) ищет партнера на завтра.", Icons.person_add_alt_1),
                const SizedBox(height: 80),
              ],
            ),
          ),
    );
  }

  // Обновленный виджет кнопки - принимает onTap
  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap, // Подключили нажатие
      style: ElevatedButton.styleFrom(
        backgroundColor: _cardColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.5))
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNeonStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151517),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, spreadRadius: 0)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value, 
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
          Text(label, 
            style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNewsCard(String title, String subtitle, IconData icon, {bool isTip = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isTip ? Colors.amber.withOpacity(0.1) : _neonGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(icon, color: isTip ? Colors.amber : _neonGreen),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14)
        ],
      ),
    );
  }
}