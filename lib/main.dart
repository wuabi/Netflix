import 'package:flutter/material.dart';

import 'models/app_state.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/my_list_screen.dart';
import 'screens/movies_screen.dart';
import 'screens/series_screen.dart';

void main() => runApp(NetflixApp());

class NetflixApp extends StatelessWidget {
  NetflixApp({super.key});
  final AppState state = AppState();

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Netflix',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF141414),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE50914),
        secondary: Color(0xFFB3B3B3),
        secondaryContainer: Color(0xFF333333),
        onSecondaryContainer: Colors.white,
        surface: Color(0xFF222222),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF141414)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF222222),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFF555555)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE50914),
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF222222),
        selectedColor: const Color(0xFF58151C),
        side: const BorderSide(color: Color(0xFF444444)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    initialRoute: '/',
    routes: {
      '/': (_) => const IntroScreen(),
      '/login': (_) => LoginScreen(state: state),
      '/home': (_) => HomeScreen(state: state),
      '/search': (_) => SearchScreen(state: state),
      '/movies': (_) => MoviesScreen(state: state),
      '/series': (_) => SeriesScreen(state: state),
      '/list': (_) => MyListScreen(state: state),
    },
  );
}
