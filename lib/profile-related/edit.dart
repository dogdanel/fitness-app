import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUsername;

  const EditProfilePage({super.key, required this.currentUsername});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();

  late Box userBox;

  @override
@override
void initState() {
  super.initState();
  userBox = Hive.box('userBox');
  final userData = userBox.get(widget.currentUsername);

  if (userData != null) {
    _emailController.text = userData['email'] ?? '';
    _usernameController.text = widget.currentUsername;
  } else {
    _emailController.text = '';
    _usernameController.text = widget.currentUsername;
  }
}

  void _updateProfile() {
    final currentPassword = _currentPasswordController.text;
    final userData = userBox.get(widget.currentUsername);

    if (userData['password'] == currentPassword) {
      final newEmail = _emailController.text;
      final newUsername = _usernameController.text;
      final newPassword = _passwordController.text.isNotEmpty
          ? _passwordController.text
          : userData['password'];

      if (newUsername != widget.currentUsername) {
        userBox.delete(widget.currentUsername);
        userBox.put(newUsername, {
          'email': newEmail,
          'password': newPassword,
        });
      } else {
        userBox.put(widget.currentUsername, {
          'email': newEmail,
          'password': newPassword,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect current password!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField('Username', _usernameController),
              const SizedBox(height: 16),
              _buildInputField('Email', _emailController),
              const SizedBox(height: 16),
              _buildInputField('New Password (optional)', _passwordController, obscureText: true),
              const SizedBox(height: 24),
              _buildInputField('Current Password', _currentPasswordController, obscureText: true, validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              }),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _updateProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool obscureText = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900]?.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
