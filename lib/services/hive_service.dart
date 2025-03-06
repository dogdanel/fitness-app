import 'package:hive/hive.dart';

class HiveService {
  final Box _userBox = Hive.box('userBox');

  void saveUser(String username, String email, String password, int totalWorkout, int todayWorkout) {
    _userBox.put(username, {
      'email': email,
      'password': password,
      'totalWorkout': totalWorkout,
      'todayWorkout': todayWorkout,
    });
  }

  
  String? getEmail(String username) => _userBox.get(username)?['email'];
  String? getPassword(String username) => _userBox.get(username)?['password'];
  int getTotalWorkout(String username) => _userBox.get(username)?['totalWorkout'] ?? 0;
  int getTodayWorkout(String username) => _userBox.get(username)?['todayWorkout'] ?? 0;

  void updateTotalWorkout(String username, int newTotalWorkout) {
    _userBox.put(username, {
      ..._userBox.get(username),
      'totalWorkout': newTotalWorkout,
    });
  }

  void updateTodayWorkout(String username, int newTodayWorkout) {
    _userBox.put(username, {
      ..._userBox.get(username),
      'todayWorkout': newTodayWorkout,
    });
  }

  void clearUserData(String username) {
    _userBox.delete(username);
  }

  List<String> getAllUsers() {
    return _userBox.keys.cast<String>().toList();
  }
}