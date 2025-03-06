import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'menu.dart';

class GoalsPage extends StatefulWidget {
  final String currentUsername;

  const GoalsPage({super.key, required this.currentUsername});

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> with SingleTickerProviderStateMixin {
  int dailySteps = 0;
  int dailyStepGoal = 10000;

  int weeklyWorkouts = 0;
  int weeklyWorkoutGoal = 5;

  int monthlyCalories = 0;
  int monthlyCalorieGoal = 30000;

  double dailyDistance = 0.0;
  double dailyDistanceGoal = 10.0;

  int activeMinutes = 0;
  int activeMinutesGoal = 60;

  int waterIntake = 0;
  int waterGoal = 8;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _loadGoalsData();
  }

  Future<void> _loadGoalsData() async {
    final userBox = await Hive.openBox('userBox');
    final userData = userBox.get(widget.currentUsername) ?? {};

    setState(() {
      dailySteps = userData['dailySteps'] ?? 0;
      dailyStepGoal = userData['dailyStepGoal'] ?? 10000;

      weeklyWorkouts = userData['weeklyWorkouts'] ?? 0;
      weeklyWorkoutGoal = userData['weeklyWorkoutGoal'] ?? 5;

      monthlyCalories = userData['monthlyCalories'] ?? 0;
      monthlyCalorieGoal = userData['monthlyCalorieGoal'] ?? 30000;

      dailyDistance = userData['dailyDistance']?.toDouble() ?? 0.0;
      dailyDistanceGoal = userData['dailyDistanceGoal']?.toDouble() ?? 10.0;

      activeMinutes = userData['activeMinutes'] ?? 0;
      activeMinutesGoal = userData['activeMinutesGoal'] ?? 60;

      waterIntake = userData['waterIntake'] ?? 0;
      waterGoal = userData['waterGoal'] ?? 8;
    });
  }

  Future<void> _saveGoalsData() async {
    final userBox = await Hive.openBox('userBox');

    double averageProgress = _calculateAverageProgress();

    await userBox.put(widget.currentUsername, {
      ...userBox.get(widget.currentUsername) ?? {},
      'dailySteps': dailySteps,
      'dailyStepGoal': dailyStepGoal,
      'weeklyWorkouts': weeklyWorkouts,
      'weeklyWorkoutGoal': weeklyWorkoutGoal,
      'monthlyCalories': monthlyCalories,
      'monthlyCalorieGoal': monthlyCalorieGoal,
      'dailyDistance': dailyDistance,
      'dailyDistanceGoal': dailyDistanceGoal,
      'activeMinutes': activeMinutes,
      'activeMinutesGoal': activeMinutesGoal,
      'waterIntake': waterIntake,
      'waterGoal': waterGoal,
      'averageProgress': averageProgress, 
    });
  }

  double _calculateAverageProgress() {
    final progressList = [
      (dailySteps / dailyStepGoal).clamp(0.0, 1.0),
      (weeklyWorkouts / weeklyWorkoutGoal).clamp(0.0, 1.0),
      (monthlyCalories / monthlyCalorieGoal).clamp(0.0, 1.0),
      (dailyDistance / dailyDistanceGoal).clamp(0.0, 1.0),
      (activeMinutes / activeMinutesGoal).clamp(0.0, 1.0),
      (waterIntake / waterGoal).clamp(0.0, 1.0),
    ];

    double average = progressList.reduce((a, b) => a + b) / progressList.length;
    return (average * 100).toDouble(); 
  }

  void _incrementWaterIntake() {
    setState(() {
      waterIntake++;
    });
    _saveGoalsData();
  }

  void _addBurnedCalories() {
    TextEditingController calorieController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Add Burned Calories", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: calorieController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter calories",
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                int burned = int.tryParse(calorieController.text) ?? 0;
                setState(() {
                  monthlyCalories += burned;
                });
                _saveGoalsData();
                Navigator.pop(context);
              },
              child: const Text("Add", style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  void _addActiveMinutes(int minutes) {
    setState(() {
      activeMinutes += minutes;
    });
    _saveGoalsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuPage(currentUsername: widget.currentUsername)),
            );
          },
        ),
        title: const Text('Fitness Goals', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
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
          SafeArea(
            child: FadeTransition(
              opacity: _controller,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGoalCard("Daily Steps", dailySteps, dailyStepGoal, Colors.blueAccent),
                    _buildGoalCard("Weekly Workouts", weeklyWorkouts, weeklyWorkoutGoal, Colors.greenAccent),
                    _buildGoalCard("Monthly Calories", monthlyCalories, monthlyCalorieGoal, Colors.redAccent,
                        extraAction: _addBurnedCalories),
                    _buildGoalCard("Distance Walked", dailyDistance.toInt(), dailyDistanceGoal.toInt(), Colors.orangeAccent),
                    _buildGoalCard("Active Minutes", activeMinutes, activeMinutesGoal, Colors.purpleAccent,
                        extraAction: () => _addActiveMinutes(10)),
                    _buildGoalCard("Water Intake", waterIntake, waterGoal, Colors.cyanAccent,
                        extraAction: _incrementWaterIntake),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, int currentValue, int goalValue, Color color, {VoidCallback? extraAction}) {
    double progress = (goalValue != 0) ? (currentValue / goalValue).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text("$currentValue / $goalValue", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          if (extraAction != null)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.amber, size: 30),
              onPressed: extraAction,
            ),
        ],
      ),
    );
  }
}
