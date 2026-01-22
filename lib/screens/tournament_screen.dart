import 'package:flutter/material.dart';

class TournamentScreen extends StatefulWidget {
  final String title;
  final List<dynamic> players;
  final int courts;

  const TournamentScreen({
    super.key, 
    required this.title, 
    required this.players, 
    required this.courts
  });

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

// Добавляем SingleTickerProviderStateMixin для работы анимации вкладок
class _TournamentScreenState extends State<TournamentScreen> with SingleTickerProviderStateMixin {
  int round = 1;
  List<Map<String, dynamic>> currentMatches = [];
  Map<String, int> scores = {};
  bool isTournamentFinished = false;
  
  // Явный контроллер для вкладок (FIX для кнопки "Посмотреть результаты")
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллер: 2 вкладки
    _tabController = TabController(length: 2, vsync: this);
    
    // Инициализируем очки
    for (var p in widget.players) {
      scores[p] = 0;
    }
    _generateRound();
  }

  @override
  void dispose() {
    _tabController.dispose(); // Обязательно освобождаем ресурсы
    super.dispose();
  }

  void _generateRound() {
    if (isTournamentFinished) return;

    setState(() {
      List<dynamic> pool = List.from(widget.players);
      pool.shuffle(); // Перемешиваем игроков

      currentMatches.clear();
      int matchesCount = (pool.length / 4).floor();
      if (matchesCount > widget.courts) matchesCount = widget.courts;

      for (int i = 0; i < matchesCount; i++) {
        currentMatches.add({
          'court': i + 1,
          'team1': [pool[i * 4], pool[i * 4 + 1]],
          'team2': [pool[i * 4 + 2], pool[i * 4 + 3]],
          'score1': 0,
          'score2': 0,
        });
      }
    });
  }

  void _finishRound() {
    // 1. Сохраняем очки текущего раунда
    for (var match in currentMatches) {
      int s1 = match['score1'];
      int s2 = match['score2'];
      
      for (var p in match['team1']) scores[p] = (scores[p] ?? 0) + s1;
      for (var p in match['team2']) scores[p] = (scores[p] ?? 0) + s2;
    }
    
    // 2. Увеличиваем раунд и генерируем новые пары
    setState(() {
      round++;
    });
    _generateRound();
  }

  void _finishTournamentEarly() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2538),
        title: const Text("Завершить турнир?", style: TextStyle(color: Colors.white)),
        content: const Text("Время вышло или корты закрываются. Текущие результаты станут финальными.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                isTournamentFinished = true;
              });
              Navigator.pop(context);
              
              // ПЕРЕКЛЮЧЕНИЕ НА ВКЛАДКУ РЕЗУЛЬТАТОВ (FIX)
              _tabController.animateTo(1); 
              
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Турнир завершен! Победители определены.")));
            }, 
            child: const Text("Завершить сейчас", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Убираем DefaultTabController, используем свой _tabController
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16)),
            Text(isTournamentFinished ? "ФИНАЛ" : "Раунд $round", style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
          ],
        ),
        backgroundColor: const Color(0xFF1C2538),
        actions: [
          if (!isTournamentFinished)
            IconButton(
              icon: const Icon(Icons.timer_off, color: Colors.redAccent),
              tooltip: "Завершить досрочно",
              onPressed: _finishTournamentEarly,
            )
        ],
        bottom: TabBar(
          controller: _tabController, // Подключаем наш контроллер
          indicatorColor: const Color(0xFF2979FF),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.sports_tennis), text: "Игры"),
            Tab(icon: Icon(Icons.leaderboard), text: "Таблица"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // Подключаем наш контроллер
        children: [
          // ВКЛАДКА 1: ИГРЫ
          isTournamentFinished 
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                const SizedBox(height: 20),
                const Text("Турнир завершен!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                // КНОПКА ТЕПЕРЬ РАБОТАЕТ
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1), 
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2979FF)),
                  child: const Text("Посмотреть результаты", style: TextStyle(color: Colors.white))
                )
              ],
            ))
          : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...currentMatches.map((match) => _buildMatchCard(match)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _finishRound,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text("Зафиксировать счёт и начать новый раунд", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          
          // ВКЛАДКА 2: ТАБЛИЦА
          _buildLeaderboard(),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return Card(
      color: const Color(0xFF1C2538),
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Корт №${match['court']}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const Icon(Icons.sports_tennis, size: 16, color: Colors.white24)
            ]),
            const Divider(color: Colors.white12, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (var p in match['team1']) Text(p, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))])),
                
                Row(
                  children: [
                    _buildScoreInput(match, 'score1'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(":", style: TextStyle(color: Colors.white54, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    _buildScoreInput(match, 'score2'),
                  ],
                ),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [for (var p in match['team2']) Text(p, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreInput(Map<String, dynamic> match, String key) {
    // ВАЖНО: Добавляем Key, который меняется каждый раунд.
    // Это заставляет Flutter перерисовывать поле ввода с нуля и очищать старые цифры.
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: TextField(
          // 🔥 FIX: Уникальный ключ для каждого раунда
          key: ValueKey("R${round}_C${match['court']}_$key"), 
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "0",
            hintStyle: TextStyle(color: Colors.white24),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (val) => match[key] = int.tryParse(val) ?? 0,
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    var sortedPlayers = scores.keys.toList()..sort((a, b) => scores[b]!.compareTo(scores[a]!));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedPlayers.length,
      itemBuilder: (context, index) {
        String player = sortedPlayers[index];
        bool isWinner = isTournamentFinished && index == 0;
        return Card(
          color: isWinner ? Colors.amber.withOpacity(0.2) : const Color(0xFF1C2538),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: index < 3 ? const Color(0xFF2979FF) : Colors.white10,
              foregroundColor: Colors.white,
              child: isWinner ? const Icon(Icons.emoji_events, color: Colors.white) : Text("${index + 1}"),
            ),
            title: Text(player, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: Text("${scores[player]} очков", style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}