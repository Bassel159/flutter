import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  final Function(bool) onToggleTheme;
  late bool isDark;

  Settings({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isDark = false;
  bool _notificationEnabled = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dark Theme",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _isDark,
                  onChanged: (val) {
                    setState(() {
                      _isDark = val;
                    });
                    widget.onToggleTheme(val); // استدعاء التبديل
                  },
                  activeColor: Colors.purple,
                  activeTrackColor: Colors.green[200],
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[200],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Notification Enabled",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _notificationEnabled,
                  onChanged: (val1) {
                    setState(() {
                      _notificationEnabled = val1;
                    });
                  },
                  activeColor: Colors.purple,
                  activeTrackColor: Colors.green[200],
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[200],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}