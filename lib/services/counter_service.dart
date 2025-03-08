// lib/services/counter_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class CounterService {
  // Get counter value from local storage
  Future<int> getCounter(String counterId) async {
    try {
      // Load from local storage
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('counter_$counterId') ?? 0;
    } catch (e) {
      // Return default value if error
      return 0;
    }
  }

  // Update counter locally
  Future<int> updateCounter(String counterId, int newValue) async {
    try {
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('counter_$counterId', newValue);
      return newValue;
    } catch (e) {
      throw Exception('Failed to update counter: $e');
    }
  }
}