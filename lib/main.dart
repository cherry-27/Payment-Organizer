import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payment_organiser/SchermataAggiungiSpesa.dart';
import 'package:provider/provider.dart';
import 'package:payment_organiser/SpesaViewModel.dart';
import 'SchermataRegistrazione.dart';
import 'SchermataLogin.dart';
import 'SchermataAreaSolo.dart';
import 'SchermataIniziale.dart';
import 'SchermataListaGruppi.dart';
import 'SchermataSpeseGruppo.dart'; // o qualunque nome usi per la schermata gruppo


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => SpeseViewModel()..caricaSpese(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment Organiser',
      theme: ThemeData(
        textTheme: GoogleFonts.lilitaOneTextTheme(
          Theme.of(context).textTheme,
        ),
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
        '/': (context) => SchermataIniziale(),
        '/login': (context) => SchermataLogin(),
        '/register': (context) => SchermataRegistrazione(),
        '/solo': (context) => SchermataSolo(),
        '/aggiungiSpesa': (context) => SchermataAggiungiSpesa(),
        '/gruppo': (context) => SchermataListaGruppi(),
        '/speseGruppo': (context) => SchermataSpeseGruppo(
        gruppoId: '', // verrà sovrascritto da ModalRoute
        titolo: ''),
      },
    ),
    );
  }
}
