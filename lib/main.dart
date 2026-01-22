import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Убедись, что этот файл создан
import 'tournament_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  // --- 📊 СОСТОЯНИЕ ИГРОКА ---
  double myRating = 3.40; 
  bool _hasCustomPhoto = false;

  // Живые характеристики игрока
  Map<String, double> myStats = {
    'VOL': 3.5, // Volea (Слёта)
    'SMA': 3.8, // Smash (Смэш)
    'LOB': 3.2, // Globo (Свеча)
    'DEF': 3.1, // Defense (Защита)
    'PHY': 3.9, // Physical (Физика)
    'TAC': 3.4, // Tactics (Тактика)
  };

  // --- 📋 СПИСОК МАТЧЕЙ ---
  List<Map<String, dynamic>> matches = [
    {
      'id': 1, 
      'type': 'MATCH', 
      'title': 'Утренний спарринг', 
      'time': '09:00', 
      'court': 'Корт №3', 
      'price': '800₽',
      'isPublic': true,
    },
    {
      'id': 2, 
      'type': 'AMERICANO', 
      'title': 'Дневной турнир', 
      'time': '14:00', 
      'court': 'Корт №1', 
      'price': '1500₽',
      'isPublic': false,
    },
  ];

  // --- 🛠️ ЛОГИКА ДИАЛОГОВ ---

  // Создание новой игры или группы
  void _showCreateMatchDialog() {
    String matchName = "";
    bool isPublic = true;
    String matchType = "MATCH";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1C2538),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Новая игра или группа", style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Название",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (val) => matchName = val,
                  ),
                  const SizedBox(height: 15),
                  SwitchListTile(
                    title: Text(isPublic ? "🌎 Публичная" : "🔒 Частная", style: const TextStyle(color: Colors.white)),
                    value: isPublic,
                    activeColor: const Color(0xFF2979FF),
                    onChanged: (val) => setStateDialog(() => isPublic = val),
                  ),
                  DropdownButton<String>(
                    value: matchType,
                    dropdownColor: const Color(0xFF1C2538),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: "MATCH", child: Text("Матч", style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: "AMERICANO", child: Text("Американо", style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: "GROUP", child: Text("Группа", style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (val) => setStateDialog(() => matchType = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    matches.insert(0, {
                      'id': DateTime.now().millisecondsSinceEpoch,
                      'type': matchType,
                      'title': matchName.isEmpty ? "Новая игра" : matchName,
                      'time': "Сегодня",
                      'court': "Корт №1",
                      'price': "0₽",
                      'isPublic': isPublic,
                    });
                  });
                  Navigator.pop(context);
                },
                child: const Text("Создать"),
              ),
            ],
          );
        });
      },
    );
  }

  // Ввод результата и оценка навыков
  void _showSmartResultDialog() {
    List<String> selectedSkills = [];
    bool isWin = true;

    final Map<String, String> skillTags = {
      'SMA': 'Смэш (Smash)',
      'DEF': 'Защита (Defense)',
      'TAC': 'Тактика (Tactics)',
      'VOL': 'Слёта (Volley)',
      'LOB': 'Свеча (Lob)',
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          Color themeColor = isWin ? Colors.green : Colors.redAccent;
          return AlertDialog(
            backgroundColor: const Color(0xFF1C2538),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Итог матча", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: isWin ? Colors.green : Colors.grey),
                        onPressed: () => setDialogState(() => isWin = true),
                        child: const Text("ПОБЕДА"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: !isWin ? Colors.redAccent : Colors.grey),
                        onPressed: () => setDialogState(() => isWin = false),
                        child: const Text("ПРОИГРЫШ"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Какие навыки проявились?", style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 5,
                  children: skillTags.entries.map((entry) {
                    final isSelected = selectedSkills.contains(entry.key);
                    return FilterChip(
                      label: Text(entry.value, style: const TextStyle(fontSize: 10)),
                      selected: isSelected,
                      selectedColor: themeColor,
                      onSelected: (val) {
                        setDialogState(() {
                          val ? selectedSkills.add(entry.key) : selectedSkills.remove(entry.key);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (isWin) {
                      myRating += 0.05;
                      for (var k in selectedSkills) { myStats[k] = (myStats[k]! + 0.1).clamp(0, 9.9); }
                    } else {
                      myRating -= 0.05;
                      for (var k in selectedSkills) { myStats[k] = (myStats[k]! - 0.1).clamp(0, 9.9); }
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text("Сохранить"),
              ),
            ],
          );
        });
      },
    );
  }

  // --- 🎨 ВИЗУАЛЬНЫЕ КОМПОНЕНТЫ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Padel MVP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateMatchDialog,
        backgroundColor: const Color(0xFF2979FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildFUTCard(),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(alignment: Alignment.centerLeft, child: Text("Активные игры", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matches.length,
              itemBuilder: (context, index) => _buildMatchCard(matches[index], index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFUTCard() {
    return Container(
      width: 300, height: 450,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFE3F2FD), const Color(0xFF42A5F5)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Stack(
        children: [
          Positioned(top: 25, left: 20, child: Text(myRating.toStringAsFixed(2), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900))),
          Positioned(top: 80, left: 20, child: const Icon(Icons.flag, size: 28)),
          Positioned(
            top: 50, right: 20, left: 20, bottom: 140,
            child: Container(
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.person_add_alt_1, size: 50, color: Colors.black26),
            ),
          ),
          Positioned(
            bottom: 100, left: 0, right: 0,
            child: Container(color: Colors.black12, padding: const EdgeInsets.all(5), child: const Center(child: Text("ANDREY K.", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)))),
          ),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStatRow(myStats['VOL']!, "VOL"), _buildStatRow(myStats['SMA']!, "SMA")]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStatRow(myStats['LOB']!, "LOB"), _buildStatRow(myStats['DEF']!, "DEF")]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStatRow(myStats['PHY']!, "PHY"), _buildStatRow(myStats['TAC']!, "TAC")]),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatRow(double val, String label) {
    return Row(children: [Text(val.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 12))]);
  }

  Widget _buildMatchCard(Map<String, dynamic> match, int index) {
    return Card(
      color: const Color(0xFF1C2538),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(match['type'] == 'MATCH' ? Icons.sports_tennis : Icons.emoji_events, color: const Color(0xFF2979FF)),
        title: Text(match['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("${match['time']} • ${match['isPublic'] ? '🌎' : '🔒'}", style: const TextStyle(color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.chat, color: Colors.white54), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ChatScreen(chatTitle: match['title'])))),
            ElevatedButton(onPressed: _showSmartResultDialog, child: const Text("Счёт")),
          ],
        ),
      ),
    );
  }
}