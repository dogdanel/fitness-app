import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../profile-related/profile.dart';
import 'timer.dart';
import 'history.dart';
import 'workout.dart';
import 'goals.dart';

class MenuPage extends StatefulWidget {
  final String currentUsername;

  const MenuPage({super.key, required this.currentUsername});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int totalWorkouts = 0;
  int todayWorkouts = 0;
  int personalBest = 0;
  double averageProgress = 0.0; 
  String username = '';

  @override
  void initState() {
    super.initState();
    username = widget.currentUsername;
    _loadWorkoutData();
    _loadGoalsData();
  }

  Future<void> _loadWorkoutData() async {
    final userBox = Hive.box('userBox');
    final userData = userBox.get(username) ?? {};

    setState(() {
      totalWorkouts = userData['totalWorkout'] ?? 0;
      todayWorkouts = userData['todayWorkout'] ?? 0;
      personalBest = userData['personalBest'] ?? 0;
    });

    if (todayWorkouts > personalBest) {
      setState(() {
        personalBest = todayWorkouts;
      });
      await userBox.put(username, {
        ...userData,
        'personalBest': personalBest,
      });
    }
  }

  Future<void> _loadGoalsData() async {
    final userBox = Hive.box('userBox');
    final userData = userBox.get(username) ?? {};

    setState(() {
      averageProgress = (userData['averageProgress'] ?? 0.0).toDouble();
    });
  }

  void _logout() {
    setState(() {
      username = '';
      totalWorkouts = 0;
      todayWorkouts = 0;
      personalBest = 0;
      averageProgress = 0.0;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(currentUsername: widget.currentUsername)),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12 && hour > 4) {
      return 'Good morning';
    } else if (hour < 18 && hour >= 12) {
      return 'Good afternoon';
    } else if (hour >= 20) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 10),
              _buildGoalsProgress(), 
              const SizedBox(height: 20),
              _buildStatsSection(),
              const SizedBox(height: 20),
              _buildMenuGrid(context),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                username.isNotEmpty ? username : 'User',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsProgress() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: (averageProgress / 100).clamp(0.0, 1.0), 
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              strokeWidth: 8,
            ),
          ),
          Text(
            "${averageProgress.round()}%", 
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatTile('assets/images/flame.png', 'STREAK', 'Today: $todayWorkouts\nPB: $personalBest'),
            _buildStatTile('assets/images/workout.png', 'TOTAL WORKOUTS', totalWorkouts.toString()),
     
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildMenuButton(context, 'History', Icons.history, WorkoutHistoryPage(currentUsername: username)),
            _buildMenuButton(context, 'Timer', Icons.timer, TimerPage(currentUsername: username)),
            _buildMenuButton(context, 'Goals', Icons.flag, GoalsPage(currentUsername: username)),
            _buildMenuButton(context, 'Workout', Icons.fitness_center, WorkoutPage(currentUsername: username)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ).then((_) {
          _loadWorkoutData();
          _loadGoalsData();
        });
      },
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
                  icon: const Icon(Icons.home, color: Colors.amberAccent, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage(currentUsername: username)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage(currentUsername: widget.currentUsername)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String imagePath, String title, String value) {
    return Column(
      children: [
        Image.asset(imagePath, height: 40),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ],
    );
  }
}
