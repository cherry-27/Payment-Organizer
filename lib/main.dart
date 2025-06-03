import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'schermata_registrazione.dart';
import 'schermata_login.dart';
import 'schermata_area_solo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment Organiser',
      theme: ThemeData(
        textTheme: GoogleFonts.lilitaOneTextTheme(Theme
            .of(context)
            .textTheme),
        scaffoldBackgroundColor: Color(0xFFE8F5E9),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF388E3C),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF66BB6A),
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF2E7D32),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF388E3C)),
          ),
          labelStyle: TextStyle(color: Color(0xFF2E7D32)),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => SchermataLogin(),
        '/register': (context) => SchermataRegistrazione(),
        '/solo': (context) => SchermataSolo(),
      },
    );
  }
}