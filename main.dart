import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Providers/user-provider.dart';
import 'screens/user_list_dialog.dart';

void main() {
  runApp(const MyApp());
}

/// Configura o tema, a tela inicial e o estado compartilhado dos usuários.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF4F46E5);
    const primaryDark = Color(0xFF312E81);
    const accentGreen = Color(0xFF10B981);
    const surfaceSoft = Color(0xFFF3F6FF);
    const borderSoft = Color(0xFFE2E8F0);

    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'CRUD Usuários API',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryBlue,
            brightness: Brightness.light,
          ).copyWith(
            primary: primaryBlue,
            secondary: accentGreen,
            surface: Colors.white,
            onSurface: const Color(0xFF0F172A),
            primaryContainer: const Color(0xFFE0E7FF),
            secondaryContainer: const Color(0xFFDCFCE7),
          ),
          scaffoldBackgroundColor: surfaceSoft,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryDark,
            foregroundColor: Colors.white,
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: borderSoft),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderSoft),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryBlue, width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF475569)),
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
        home: const UserListScreen(),
      ),
    );
  }
}
