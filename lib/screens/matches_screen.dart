import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'tournament_screen.dart'; // Убедись, что файл создан

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  // ==========================================
  // 1. СОСТОЯНИЕ ИГРОКА (FUT CARD DATA)
  // ==========================================
  double myRating = 3.40; 
  
  // Характеристики игрока
  Map<String, double> myStats = {
    'SMA': 3.8, // Смэш
    'DEF': 3.1, // Защита
    'TAC': 3.4, // Тактика
    'VOL': 3.5, // Слёта
    'LOB': 3.2, // Свеча
    'PHY': 3.9, // Физика
  };

  // ==========================================
  // 2. НАСТРОЙКИ И ЛОГИКА ТУРНИРОВ
  // ==========================================
  final List<String> gameFormats = [
    'MATCH', 
    'AMERICANO', 
    'MEXICANO', 
    'WINNER_COURT', 
    'TOURNAMENT'
  ];

  // Переменные для диалога создания
  int selectedCourts = 1; 
  String americanoType = 'STANDARD'; // Варианты: STANDARD, TEAM, MIXED
  int pointsLimit = 32; // До скольки очков играем

  // Веса форматов для расчета рейтинга
  double _getFormatWeight(String type) {
    switch (type) {
      case 'TOURNAMENT': return 1.2;    // Турнир дает больше рейтинга
      case 'MATCH': return 1.0;         // Обычный матч
      case 'AMERICANO': return 0.85;    // Американо чуть меньше
      case 'MEXICANO': return 0.75;     // Мексикано еще меньше (фан)
      case 'WINNER_COURT': return 0.8;  // Царь горы
      default: return 1.0;
    }
  }

  // ==========================================
  // 3. ДАННЫЕ МАТЧЕЙ (DATABASE MOCK)
  // ==========================================
  List<Map<String, dynamic>> matches = [
    {
      'id': 1, 
      'type': 'AMERICANO', 
      'title': 'Турнир выходного дня', 
      'time': '12:00',
      'minRating': 2.0, 
      'maxRating': 5.0, 
      'isPublic': true, 
      'courts': 2, // 2 корта = 8 мест
      'weight': 0.85,
      // Имитация уже записавшихся игроков
      'joinedPlayers': ['Иван', 'Сергей', 'Петр', 'Анна', 'Олег', 'Дмитрий', 'Елена'], 
      'status': 'OPEN' // Варианты: OPEN, IN_PROGRESS, FINISHED
    },
    {
      'id': 2, 
      'type': 'MATCH', 
      'title': 'Спарринг Pro', 
      'time': '18:00',
      'minRating': 4.0, 
      'maxRating': 6.0, 
      'isPublic': false, 
      'courts': 1, 
      'weight': 1.0,
      'joinedPlayers': ['Мария'], 
      'status': 'OPEN'
    },
  ];

  // ==========================================
  // 4. ЛОГИЧЕСКИЕ МЕТОДЫ (ЗАПИСЬ И СТАРТ)
  // ==========================================

  // Логика записи на матч (с листом ожидания)
  void _joinMatch(int index) {
    setState(() {
      var match = matches[index];
      List players = match['joinedPlayers'] ?? [];
      // Рассчитываем макс. вместимость (4 человека на корт)
      int maxPlayers = (match['courts'] ?? 1) * 4;

      // Проверка: записан ли я уже?
      if (!players.contains("ANDREY K.")) {
        players.add("ANDREY K."); // Добавляем текущего юзера
        match['joinedPlayers'] = players;
        
        // Проверка переполнения (Лист ожидания)
        if (players.length > maxPlayers) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Места закончились! Вы добавлены в лист ожидания (№${players.length - maxPlayers})"),
              backgroundColor: Colors.orange,
            )
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Вы успешно записаны на игру!"),
              backgroundColor: Colors.green,
            )
          );
        }
      } else {
        // Если уже записан - можно сделать отписку (пока просто уведомление)
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Вы уже записаны на эту игру."))
          );
      }
    });
  }

  // Логика запуска турнира (переход на экран сетки)
  void _openTournament(int index) {
    var match = matches[index];
    List players = match['joinedPlayers'] ?? [];
    
    // Проверка на минимальное количество (нужно хотя бы 4 для игры)
    if (players.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Недостаточно игроков для старта (минимум 4)"),
          backgroundColor: Colors.redAccent,
        )
      );
      // Если хочешь жесткий запрет, раскомментируй return
      // return; 
    }

    // Меняем статус матча на "В ПРОЦЕССЕ"
    setState(() {
      match['status'] = 'IN_PROGRESS';
    });

    // Открываем экран турнирной сетки
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentScreen(
          title: match['title'],
          players: players,
          courts: match['courts'] ?? 1,
        ),
      ),
    );
  }

  // ==========================================
  // 5. ДИАЛОГИ (СОЗДАНИЕ И РЕЗУЛЬТАТ)
  // ==========================================

  // Диалог создания новой игры (со всеми настройками)
  void _showCreateMatchDialog() {
    String title = 'Новая игра';
    String selectedFormat = 'MATCH'; 
    RangeValues currentRange = const RangeValues(1.0, 7.0);
    bool isPublic = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF10192B), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: const Text('Создать игру', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Название
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Название события',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                      onChanged: (val) => title = val,
                    ),
                    const SizedBox(height: 20),
                    
                    // Выбор формата
                    DropdownButton<String>(
                      value: selectedFormat,
                      dropdownColor: const Color(0xFF1C2538),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: gameFormats.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                      onChanged: (val) => setDialogState(() => selectedFormat = val!),
                    ),
                    
                    // Настройка кортов (Степпер)
                    const SizedBox(height: 20),
                    const Text("Количество кортов:", style: TextStyle(color: Colors.white70)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.blue), 
                          onPressed: () => setDialogState(() => selectedCourts > 1 ? selectedCourts-- : null)
                        ),
                        Text('$selectedCourts', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.blue), 
                          onPressed: () => setDialogState(() => selectedCourts++)
                        ),
                      ],
                    ),
                    Text("Всего мест: ${selectedCourts * 4}", style: const TextStyle(color: Colors.grey, fontSize: 12)),

                    // Доп. настройки для Американо
                    if (selectedFormat == 'AMERICANO') ...[
                      const SizedBox(height: 15),
                      DropdownButton<String>(
                        value: americanoType,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1C2538),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'STANDARD', child: Text('Стандарт (Смена партнеров)')),
                          DropdownMenuItem(value: 'TEAM', child: Text('Командный (Фикс. пары)')),
                          DropdownMenuItem(value: 'MIXED', child: Text('Микст (М + Ж)')),
                        ],
                        onChanged: (val) => setDialogState(() => americanoType = val!),
                      ),
                    ],

                    const SizedBox(height: 15),
                    // Публичность
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isPublic ? "🌎 Публичная" : "🔒 Частная", style: const TextStyle(color: Colors.white)),
                      value: isPublic,
                      activeColor: const Color(0xFF2979FF),
                      onChanged: (val) => setDialogState(() => isPublic = val),
                    ),
                    
                    // RangeSlider (Уровень)
                    const SizedBox(height: 20),
                    Text('Уровень: ${currentRange.start.toStringAsFixed(1)} - ${currentRange.end.toStringAsFixed(1)}', 
                         style: const TextStyle(color: Colors.blueAccent)),
                    RangeSlider(
                      values: currentRange,
                      min: 1.0, max: 7.0, divisions: 12,
                      activeColor: const Color(0xFF2979FF),
                      labels: RangeLabels(currentRange.start.toStringAsFixed(1), currentRange.end.toStringAsFixed(1)),
                      onChanged: (val) => setDialogState(() => currentRange = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Отмена', style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2979FF)),
                  onPressed: () {
                    // Сохранение нового матча
                    setState(() {
                      matches.insert(0, {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'type': selectedFormat,
                        'title': title.isEmpty ? "Новая игра" : title,
                        'time': 'Сегодня',
                        'minRating': currentRange.start,
                        'maxRating': currentRange.end,
                        'isPublic': isPublic,
                        'courts': selectedCourts,
                        'weight': _getFormatWeight(selectedFormat),
                        'joinedPlayers': [],
                        'status': 'OPEN'
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Создать', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Диалог ввода результата (влияет на рейтинг)
  void _showSmartResultDialog(double weight) {
    List<String> selectedSkills = [];
    bool isWin = true;
    final Map<String, String> skillTags = {
      'SMA': 'Смэш (Smash)', 'DEF': 'Защита (Defense)', 
      'TAC': 'Тактика (Tactics)', 'VOL': 'Слёта (Volley)', 
      'LOB': 'Свеча (Lob)', 'PHY': 'Физика (Physical)'
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C2538),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Итог матча", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Кнопки ПОБЕДА / ПОРАЖЕНИЕ
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => isWin = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isWin ? Colors.green : Colors.transparent,
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: const Center(child: Text("ПОБЕДА", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                    )
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => isWin = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isWin ? Colors.redAccent : Colors.transparent,
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: const Center(child: Text("ПОРАЖЕНИЕ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                    )
                  ),
                ]),
                
                const SizedBox(height: 20),
                const Text("Ключевые факторы:", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                
                // Теги навыков
                Wrap(
                  spacing: 8, 
                  runSpacing: 8,
                  children: skillTags.entries.map((e) => FilterChip(
                    label: Text(e.value),
                    labelStyle: const TextStyle(fontSize: 11),
                    selected: selectedSkills.contains(e.key),
                    onSelected: (v) => setDialogState(() => v ? selectedSkills.add(e.key) : selectedSkills.remove(e.key)),
                    backgroundColor: const Color(0xFF0A0E21),
                    selectedColor: isWin ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    checkmarkColor: Colors.white,
                  )).toList()
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена", style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Расчет изменения рейтинга
                  double change = 0.05 * weight;
                  myRating = (myRating + (isWin ? change : -change)).clamp(1.0, 7.0);
                  
                  // Обновление характеристик
                  for(var k in selectedSkills) {
                    if(myStats.containsKey(k)) {
                      myStats[k] = (myStats[k]! + (isWin ? 0.1 : -0.1)).clamp(0.0, 9.9);
                    }
                  }
                  // Физика всегда чуть растет
                  myStats['PHY'] = (myStats['PHY']! + 0.02).clamp(0.0, 9.9);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: isWin ? Colors.green : Colors.red),
              child: const Text("Сохранить", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 6. ВИЗУАЛ (FUT CARD И СПИСОК)
  // ==========================================

  // Виджет карточки игрока (FUT Style)
  Widget _buildFUTCard() {
    return Center(
      child: Container(
        width: 280, height: 420,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFF42A5F5), Color(0xFF1976D2)],
            begin: Alignment.topLeft, end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 25)],
        ),
        child: Stack(children: [
          // Рейтинг
          Positioned(top: 30, left: 20, child: Text(myRating.toStringAsFixed(2), style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Color(0xFF0A0E21)))),
          
          // Зона фото (заглушка с возможностью клика)
          Positioned(top: 60, right: 10, left: 50, bottom: 130, child: GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Функция загрузки фото в разработке"))),
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
              child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_a_photo, size: 40, color: Colors.black26), 
                Text("ЗАГРУЗИТЬ\nФОТО", textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold))
              ])),
            ),
          )),
          
          // Имя
          Positioned(bottom: 110, left: 0, right: 0, child: Center(child: Text("ANDREY K.", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0A0E21))))),
          
          // Статистика
          Positioned(bottom: 25, left: 25, right: 25, child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStatItem(myStats['VOL']!, "VOL"), _buildStatItem(myStats['SMA']!, "SMA")]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStatItem(myStats['LOB']!, "LOB"), _buildStatItem(myStats['DEF']!, "DEF")]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStatItem(myStats['PHY']!, "PHY"), _buildStatItem(myStats['TAC']!, "TAC")]),
          ]))
        ]),
      ),
    );
  }

  // Хелпер для отрисовки одного стата
  Widget _buildStatItem(double val, String label) {
    return Row(children: [
      Text(val.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0A0E21))), 
      const SizedBox(width: 4), 
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A0E21)))
    ]);
  }

  // ==========================================
  // 7. MAIN BUILD METHOD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      // Кнопка создания новой игры
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateMatchDialog,
        backgroundColor: const Color(0xFF2979FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Карточка профиля
            _buildFUTCard(),
            
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(alignment: Alignment.centerLeft, child: Text("Ближайшие игры", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            
            // Список матчей
            ListView.builder(
              padding: const EdgeInsets.all(16), 
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final m = matches[index];
                List players = m['joinedPlayers'] ?? [];
                int maxPlayers = (m['courts'] ?? 1) * 4;
                bool isFull = players.length >= maxPlayers;
                bool inProgress = m['status'] == 'IN_PROGRESS';

                return Card(
                  color: const Color(0xFF1C2538), 
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      // Заголовок карточки
                      ListTile(
                        leading: Icon(
                          m['type'] == 'TOURNAMENT' ? Icons.emoji_events : Icons.sports_tennis, 
                          color: inProgress ? Colors.greenAccent : const Color(0xFF2979FF)
                        ),
                        title: Text(m['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${m['type']} • Мест: ${players.length}/$maxPlayers • ${m['status'] == 'OPEN' ? 'Открыто' : 'Играют'}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12)
                        ),
                        // Кнопка чата
                        trailing: IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white54), 
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ChatScreen(chatTitle: m['title'])))
                        ),
                      ),
                      
                      // Кнопки действий
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Кнопка ЗАПИСАТЬСЯ (если не начато)
                            if (!inProgress) 
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _joinMatch(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFull ? Colors.orange : const Color(0xFF2979FF),
                                    padding: const EdgeInsets.symmetric(vertical: 12)
                                  ),
                                  child: Text(isFull ? "В лист ожидания" : "Записаться", style: const TextStyle(color: Colors.white)),
                                ),
                              ),
                            
                            const SizedBox(width: 10),

                            // Кнопка ЗАПУСТИТЬ или ОТКРЫТЬ СЕТКУ
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _openTournament(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 12)
                                ),
                                child: Text(inProgress ? "Открыть сетку" : "Запустить", style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                            
                            const SizedBox(width: 10),

                            // Кнопка ВВОДА СЧЕТА (для одиночных матчей)
                            if (m['type'] == 'MATCH')
                               IconButton(
                                 icon: const Icon(Icons.scoreboard, color: Colors.white),
                                 onPressed: () => _showSmartResultDialog(m['weight'] ?? 1.0), 
                                 tooltip: "Ввести результат",
                               ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}