import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class SchermataRegistrazione extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confermaPassword = TextEditingController();
  final TextEditingController nickname = TextEditingController();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      final doc = await FirebaseFirestore.instance.collection('utenti').doc(uid).get();

      if (!doc.exists || !doc.data()!.containsKey('nickname')) {
        final nicknameController = TextEditingController();

        showDialog(
          context: context,
          builder: (context) {
            final nicknameController = TextEditingController();

            return AlertDialog(
              title: Text('Inserisci il tuo nickname'),
              content: TextField(
                controller: nicknameController,
                decoration: InputDecoration(
                  labelText: 'Nickname',
                ),
              ),
                actions: [
                TextButton(
                onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nickname = nicknameController.text.trim();
                    if (nickname.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('Utenti')
                          .doc(userCredential.user!.uid)
                          .set({
                          'nickname': nickname,
                          'email': FirebaseAuth.instance.currentUser!.email,
                          'utenteID': uid,});

                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/solo');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Inserisci un nickname valido')),
                      );
                    }
                  },
                  child: Text('Conferma'),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, '/solo');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore Google: ${e.toString()}')));
    }
  }
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
              onPressed: () async {
                if (email.text.isEmpty || password.text.isEmpty || nickname.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compila tutti i campi')));
                  return;
                }
                if (password.text != confermaPassword.text) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Le password non coincidono')));
                  return;
                }

                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email.text.trim(),
                    password: password.text.trim(),
                  );
                final uid = FirebaseAuth.instance.currentUser!.uid;

                await FirebaseFirestore.instance
                    .collection('Utenti')
                    .doc(uid)
                    .set({
                'email': email.text.trim(),
                'nickname': nickname.text.trim(),
                'utenteID': uid,
                });
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: ${e.toString()}')));
                }
              },
              child: Text('Registrati'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.account_circle),
              label: Text("Accedi con Google"),
              onPressed: () => signInWithGoogle(context),
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