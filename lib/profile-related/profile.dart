import 'package:flutter/material.dart';
import 'package:flutter_application_1/first%20pages/login.dart';
import 'package:hive/hive.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../menu-related/menu.dart';
import 'edit.dart';

class ProfilePage extends StatefulWidget {
  final String currentUsername;

  const ProfilePage({super.key, required this.currentUsername});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    username = widget.currentUsername;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userBox = Hive.box('userBox');
    final userData = userBox.get(username);

    setState(() {
      email = userData != null ? userData['email'] ?? '' : '';
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      username.isNotEmpty ? username : 'User',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email.isNotEmpty ? email : 'No email provided',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    _buildQRCodeCard(),
                    const SizedBox(height: 30),
                    _buildProfileMenu(context),
                    const SizedBox(height: 20),
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildQRCodeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: QrImageView(
            data: username.isNotEmpty ? username : 'user_data',
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMenuButton(context, 'Edit Profile', Icons.edit, EditProfilePage(currentUsername: username)),
        _buildMenuButton(context, 'Log Out', Icons.exit_to_app, const LoginPage()),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Widget? page) {
    return GestureDetector(
      onTap: page != null
          ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
              _loadUserData(); 
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage(currentUsername: username)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.amber, size: 30),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
