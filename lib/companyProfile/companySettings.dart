import 'package:flutter/material.dart';

class CompanySettings extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDark;

  const CompanySettings({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<CompanySettings> createState() => _CompanySettingsState();
}

class _CompanySettingsState extends State<CompanySettings> {
  late bool _isDark;
  bool _notificationEnabled = true;

  final Color mainColor = Colors.blue; // لون الشركة

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Company Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Appearance"),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            value: _isDark,
            onChanged: (val) {
              setState(() => _isDark = val);
              widget.onToggleTheme(val);
            },
          ),
          const Divider(height: 32),
          _buildSectionTitle("Notifications"),
          _buildSwitchTile(
            icon: Icons.notifications_active,
            title: "Enable Notifications",
            value: _notificationEnabled,
            onChanged: (val) {
              setState(() => _notificationEnabled = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: mainColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: mainColor),
      title: Text(title, style: const TextStyle(fontSize: 17)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: mainColor,
        activeTrackColor: mainColor.withOpacity(0.4),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey[300],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    );
  }
}
