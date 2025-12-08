// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ScreenTheme extends Cubit<ThemeMode> {
//   ScreenTheme() : super(ThemeMode.light) {
//     _loadTheme();
//   }
//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isDarkMode = prefs.getBool('Dark Mode') ?? false;
//     emit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
//   }

//   Future<void> toggleTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isDarkMode = state == ThemeMode.dark;
//     await prefs.setBool('darkMode', !isDarkMode);
//     emit(isDarkMode ? ThemeMode.light : ThemeMode.dark);
//   }

//   bool get isDarkMode => state == ThemeMode.dark;
// }
