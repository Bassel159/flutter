import 'package:flutter/material.dart';

class CompanySettings extends StatefulWidget {
  final Function(bool) onToggleTheme;
  late bool isDark;

  CompanySettings({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<CompanySettings> createState() => _CompanySettingsState();
}

class _CompanySettingsState extends State<CompanySettings> {
  bool _isDark = false;
  bool _notificationEnabled = true;

  final Color mainColor = Color.fromARGB(255, 72, 144, 180);

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Company Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingRow(
              label: "Dark Mode",
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
              label: "Enable Notifications",
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
