import 'package:flutter/material.dart';

class SchermataRegistrazione extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confermaPassword = TextEditingController();
  final TextEditingController nickname = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            Text("Registrazione", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            SizedBox(height: 32),
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
            SizedBox(height: 16),
            TextField(
              controller: confermaPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Conferma Password',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: nickname,
              decoration: InputDecoration(
                labelText: 'Nickname',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/solo'),
              child: Text('Registrati'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.account_circle),
              label: Text("Accedi con Google"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF43A047),
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}