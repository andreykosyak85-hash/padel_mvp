import 'package:flutter/material.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final Color _bgDark = const Color(0xFF0D1117);
  final Color _cardColor = const Color(0xFF1C1C1E);
  final Color _neonOrange = const Color(0xFFFF5500);

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  String _selectedCourt = "Central Padel Club";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        title: const Text("Создать матч", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Детали игры", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Выбор Клуба
            _buildOptionTile(Icons.location_on, "Клуб", _selectedCourt, () {}),
            const SizedBox(height: 15),

            // Выбор Даты
            _buildOptionTile(Icons.calendar_month, "Дата", "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
              if (d != null) setState(() => _selectedDate = d);
            }),
            const SizedBox(height: 15),

            // Выбор Времени
            _buildOptionTile(Icons.access_time, "Время", _selectedTime.format(context), () async {
              final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (t != null) setState(() => _selectedTime = t);
            }),

            const SizedBox(height: 30),
            const Text("Тип игры", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(child: _buildTypeCard("Friendly", true)),
                const SizedBox(width: 15),
                Expanded(child: _buildTypeCard("Competitive", false)),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _neonOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Матч создан! (Демо)"), backgroundColor: Colors.green)
                  );
                  Navigator.pop(context);
                }, 
                child: const Text("Опубликовать матч", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10)
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white70),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14)
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isSelected ? _neonOrange.withOpacity(0.2) : _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? _neonOrange : Colors.transparent)
      ),
      child: Center(
        child: Text(title, style: TextStyle(
          color: isSelected ? _neonOrange : Colors.grey, 
          fontWeight: FontWeight.bold,
          fontSize: 16
        )),
      ),
    );
  }
}