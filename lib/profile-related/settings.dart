import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool vibrationEnabled = true;
  bool autoSyncEnabled = true;
  String username = "User";
  String email = "email@example.com";
  String phoneNumber = "+123456789";
  String language = "English";
  bool locationAccess = false;
  bool twoFactorAuth = false;
  bool biometricUnlock = false;

  bool showUsernameField = false;
  bool showEmailField = false;
  bool showPhoneField = false;
  String passwordConfirmation = "";
  String newUsername = "";
  String newEmail = "";
  String newPhoneNumber = "";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      autoSyncEnabled = prefs.getBool('autoSyncEnabled') ?? true;
      username = prefs.getString('username') ?? "User";
      email = prefs.getString('email') ?? "email@example.com";
      phoneNumber = prefs.getString('phoneNumber') ?? "+123456789";
      language = prefs.getString('language') ?? "English";
      locationAccess = prefs.getBool('locationAccess') ?? false;
      twoFactorAuth = prefs.getBool('twoFactorAuth') ?? false;
      biometricUnlock = prefs.getBool('biometricUnlock') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('email', email);
    prefs.setString('phoneNumber', phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amberAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Account"),
            _buildExpandableTextField("Username", username, Icons.person, () {
              setState(() => showUsernameField = !showUsernameField);
            }, showUsernameField, (newValue) {
              setState(() {
                username = newValue;
                _saveSettings();
              });
            }),
            _buildExpandableTextField("Email", email, Icons.email, () {
              setState(() => showEmailField = !showEmailField);
            }, showEmailField, (newValue) {
              setState(() {
                email = newValue;
                _saveSettings();
              });
            }),
            _buildExpandableTextField("Phone Number", phoneNumber, Icons.phone, () {
              setState(() => showPhoneField = !showPhoneField);
            }, showPhoneField, (newValue) {
              setState(() {
                phoneNumber = newValue;
                _saveSettings();
              });
            }),
            Divider(color: Colors.grey.shade800, thickness: 1.5),
            _buildSectionTitle("Appearance"),
            const SizedBox(height: 20),
            _buildStyledDropdown(
              ['Dark', 'Light', 'System Default'],
              _getThemeModeString(Provider.of<ThemeProvider>(context).themeMode),
              Icons.palette,
              (value) {
                if (value != null) {
                  setState(() {
                    ThemeMode selectedTheme = _getThemeMode(value);
                    Provider.of<ThemeProvider>(context, listen: false).setThemeMode(selectedTheme);
                    _saveSettings();
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            _buildStyledDropdown(
              ['English', 'Spanish', 'French', 'German'],
              language,
              Icons.language,
              (value) {
                setState(() {
                  language = value!;
                  _saveSettings();
                });
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableTextField(
      String label, String value, IconData icon, VoidCallback onTap, bool isExpanded, Function(String) onChanged) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.amberAccent),
          title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white),
          onTap: onTap,
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                _buildStyledTextField("Current Password", passwordConfirmation, Icons.lock, (value) {
                  setState(() => passwordConfirmation = value);
                }),
                const SizedBox(height: 10),
                _buildStyledTextField("New $label", value, icon, (newValue) {
                  onChanged(newValue);
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStyledTextField(String label, String value, IconData icon, Function(String) onChanged) {
    return TextField(
      obscureText: label.contains("Password"),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.amberAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildStyledDropdown(List<String> options, String selectedValue, IconData icon, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      dropdownColor: const Color(0xFF1E1E1E),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.amberAccent),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.amberAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}


  
  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
      return 'System Default';
    }
  }

  
  ThemeMode _getThemeMode(String value) {
    switch (value) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      case 'System Default':
      default:
        return ThemeMode.system;
    }
  }




  
