import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'menu.dart';
import '../profile-related/profile.dart';
import 'history.dart';

class TimerPage extends StatefulWidget {
  final String currentUsername;

  const TimerPage({super.key, required this.currentUsername});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _start = 0;
  bool _isRunning = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _start++;
      });
    });
  }

  void pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      _start = 0;
      _isRunning = false;
    });
  }

  Future<void> stopAndSaveTimer() async {
    if (_start == 0) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    final duration = formatTime(_start);
    final date = DateTime.now().toString().split(' ')[0];

    final workoutHistoryBox = await Hive.openBox('workoutHistoryBox');

    
    workoutHistoryBox.add({
      'username': widget.currentUsername,
      'date': date,
      'duration': duration,
      'name': 'General Workout',
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkoutHistoryPage(currentUsername: widget.currentUsername)),
    );

    resetTimer();
  }

  String formatTime(int milliseconds) {
    final hours = (milliseconds ~/ 360000).toString().padLeft(2, '0');
    final minutes = ((milliseconds % 360000) ~/ 6000).toString().padLeft(2, '0');
    final seconds = ((milliseconds % 6000) ~/ 100).toString().padLeft(2, '0');
    final millis = (milliseconds % 100).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds:$millis';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
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
          SafeArea(
            child: FadeTransition(
              opacity: _controller,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimerDisplay(),
                  const SizedBox(height: 40),
                  _buildTimerControls(),
                  const SizedBox(height: 60),
                  _buildProgressIndicator(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTimerDisplay() {
    return Column(
      children: [
        Text(
          formatTime(_start),
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Workout Timer",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton("Start", Colors.green, startTimer, !_isRunning),
        const SizedBox(width: 20),
        _buildControlButton("Pause", Colors.orange, pauseTimer, _isRunning),
        const SizedBox(width: 20),
        _buildControlButton("Stop & Save", Colors.red, stopAndSaveTimer, !_isRunning && _start > 0),
      ],
    );
  }

  Widget _buildControlButton(String title, Color color, VoidCallback onPressed, bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(title, style: const TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  Widget _buildProgressIndicator() {
    double progress = (_start % 360000) / 360000;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Workout Progress", style: TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(height: 10),
          Text("${(_start ~/ 6000)} min completed", style: const TextStyle(color: Colors.grey)),
        ],
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
                  icon: const Icon(Icons.home, color: Colors.amber, size: 35),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage(currentUsername: widget.currentUsername)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white, size: 35),
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
}
