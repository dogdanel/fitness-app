import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class WorkoutPage extends StatefulWidget {
  final String currentUsername;

  const WorkoutPage({super.key, required this.currentUsername});

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> with SingleTickerProviderStateMixin {
  int totalWorkouts = 0;
  int todayWorkouts = 0;
  int personalBest = 0;

  final HiveService _hiveService = HiveService();

  final Map<String, List<Map<String, String>>> workouts = {
    'Warm-Up': [
      {'Jumping Jacks': 'Jump while spreading legs and arms outward, then return.\n\nRecommended: 3 sets of 30 sec'},
      {'Arm Circles': 'Extend arms and make small circles, then reverse.\n\nRecommended: 3 sets of 20 sec each direction'},
    ],
    'Beginner': [
      {'Push-ups': 'Start in a plank, lower your body, then push back up.\n\nRecommended: 3 sets of 10 reps'},
      {'Squats': 'Lower your hips and keep back straight, then stand.\n\nRecommended: 3 sets of 12 reps'},
    ],
    'Intermediate': [
      {'Lunges': 'Step forward, lower hips, then return to standing.\n\nRecommended: 3 sets of 10 reps per leg'},
      {'Plank': 'Hold a straight-body position on forearms.\n\nRecommended: 3 sets of 30 sec'},
    ],
    'Advanced': [
      {'Burpees': 'Squat, kick feet back, do a push-up, return to squat, jump up.\n\nRecommended: 3 sets of 12 reps'},
      {'Pull-ups': 'Grab the bar, pull up, lower down.\n\nRecommended: 3 sets of 8 reps'},
    ],
    'Cool-Down': [
      {'Stretching': 'Stretch major muscle groups for at least 15 sec.\n\nRecommended: 3 sets of 15 sec per stretch'},
      {'Breathing': 'Deep breaths in through nose, out through mouth.\n\nRecommended: 3 sets of 1 min each'},
    ],
  };

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    setState(() {
      totalWorkouts = _hiveService.getTotalWorkout(widget.currentUsername) ?? 0;
      todayWorkouts = _hiveService.getTodayWorkout(widget.currentUsername) ?? 0;
    });
  }

  void _incrementTotalWorkouts() {
    setState(() {
      totalWorkouts++;
      todayWorkouts++;

      _hiveService.updateTotalWorkout(widget.currentUsername, totalWorkouts);
      _hiveService.updateTodayWorkout(widget.currentUsername, todayWorkouts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Workout Routines', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildProgressBar(),
                    const SizedBox(height: 20),
                    ...workouts.entries.map((entry) => _buildWorkoutSection(entry.key, entry.value)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = (todayWorkouts / 5).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Daily Progress", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$todayWorkouts / 5 Workouts Completed",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection(String level, List<Map<String, String>> exercises) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(
          level,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: exercises.map((exercise) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(
              exercise.keys.first,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              exercise.values.first,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            trailing: ElevatedButton(
              onPressed: _incrementTotalWorkouts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start', style: TextStyle(color: Colors.white)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
