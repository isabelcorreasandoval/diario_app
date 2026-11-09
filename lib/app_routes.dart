import 'package:flutter/material.dart';
import 'models/diary_entry.dart';
import 'screens/entry_detail_screen.dart';
import 'screens/entry_form_screen.dart';
import 'screens/home_screen.dart';

class AppRoutes {
  static const home = '/';
  static const form = '/form';
  static const detail = '/detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case form:
        return MaterialPageRoute(builder: (_) => const EntryFormScreen());
      case detail:
        final entry = settings.arguments as DiaryEntry;
        return MaterialPageRoute(builder: (_) => EntryDetailScreen(entry: entry));
      case home:
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}