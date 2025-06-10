import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SchermataRegistrazione extends StatefulWidget {
  @override
  _SchermataRegistrazioneState createState() => _SchermataRegistrazioneState();
}

class _SchermataRegistrazioneState extends State<SchermataRegistrazione> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confermaPassword = TextEditingController();
  final TextEditingController nickname = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confermaPassword.dispose();
    nickname.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    setState(() => loading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      final doc = await FirebaseFirestore.instance.collection('utenti').doc(uid).get();

      if (!doc.exists || !doc.data()!.containsKey('nickname')) {
        _richiediNickname(userCredential.user!.uid);
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore Google: ${e.toString()}')));
    } finally {
      setState(() => loading = false);
    }
  }

  void _richiediNickname(String uid) {
    final nicknameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Inserisci il tuo nickname'),
          content: TextField(
            controller: nicknameController,
            decoration: InputDecoration(labelText: 'Nickname'),
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
                  FirebaseFirestore.instance.collection('utenti').doc(uid).set({
                    'nickname': nickname,
                    'email': FirebaseAuth.instance.currentUser!.email,
                    'utenteID': uid,
                  });
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inserisci un nickname valido')));
                }
              },
              child: Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registrati() async {
    if (email.text.isEmpty || password.text.isEmpty || nickname.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compila tutti i campi')));
      return;
    }
    if (password.text != confermaPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Le password non coincidono')));
      return;
    }

    setState(() => loading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('utenti').doc(uid).set({
        'email': email.text.trim(),
        'nickname': nickname.text.trim(),
        'utenteID': uid,
      });

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: ${e.toString()}')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            const Text(
              "Registrazione",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 32),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            TextField(controller: confermaPassword, obscureText: true, decoration: const InputDecoration(labelText: 'Conferma Password')),
            const SizedBox(height: 16),
            TextField(controller: nickname, decoration: const InputDecoration(labelText: 'Nickname')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : _registrati,
              child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Registrati'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_circle),
              label: const Text("Accedi con Google"),
              onPressed: loading ? null : signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
