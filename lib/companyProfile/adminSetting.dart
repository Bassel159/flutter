import 'package:flutter/material.dart';

class AdminSettings extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDark;

  const AdminSettings({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  late bool _isDark;
  bool _notificationEnabled = true;
  bool _receiveReports = true;

  final Color mainColor = Colors.red; // لون الأدمن

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
          "Admin Settings",
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
            icon: Icons.notifications,
            title: "Enable Notifications",
            value: _notificationEnabled,
            onChanged: (val) {
              setState(() => _notificationEnabled = val);
            },
          ),
          _buildSwitchTile(
            icon: Icons.flag,
            title: "Receive Reports",
            value: _receiveReports,
            onChanged: (val) {
              setState(() => _receiveReports = val);
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
