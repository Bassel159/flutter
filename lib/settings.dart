import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  final Function(bool) onToggleTheme;
  late bool isDark;

  Setting({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _isDark = false;
  bool _notificationEnabled = true;

  final Color mainColor = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingRow(
              label: "Dark Theme",
              value: _isDark,
              onChanged: (val) {
                setState(() {
                  _isDark = val;
                });
                widget.onToggleTheme(val);
              },
            ),
            Divider(),
            _buildSettingRow(
              label: "Notification Enabled",
              value: _notificationEnabled,
              onChanged: (val) {
                setState(() {
                  _notificationEnabled = val;
                });
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: mainColor,
            activeTrackColor: mainColor.withOpacity(0.4),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
