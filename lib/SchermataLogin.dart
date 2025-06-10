import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SchermataLogin extends StatefulWidget {
  @override
  _SchermataLoginState createState() => _SchermataLoginState();
}

class _SchermataLoginState extends State<SchermataLogin> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Text("Login", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            SizedBox(height: 40),
            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email.text.trim(),
                    password: password.text.trim(),
                  );
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login fallito: ${e.toString()}')));
                }
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text("Non hai un account? Registrati"),
            )
          ],
        ),
      ),
    );
  }
}
