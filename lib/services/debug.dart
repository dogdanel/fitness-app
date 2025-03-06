import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final Box userBox = Hive.box('userBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Page'),
        backgroundColor: Colors.blueAccent,
      ),
      body: userBox.isEmpty
          ? const Center(child: Text('No users found.'))
          : ListView.builder(
              itemCount: userBox.length,
              itemBuilder: (context, index) {
                final username = userBox.keyAt(index);
                final userData = userBox.get(username);

                final password = userData['password'] ?? 'N/A';
                final totalWorkout = userData['totalWorkout'] ?? 0;
                final todayWorkout = userData['todayWorkout'] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                  child: ListTile(
                    title: Text('Username: $username', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Password: $password'),
                        Text('Total Workouts: $totalWorkout'),
                        Text('Today\'s Workouts: $todayWorkout'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          userBox.delete(username);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
