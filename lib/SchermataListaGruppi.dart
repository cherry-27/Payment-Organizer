import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CreaGuppoDialog.dart';
import 'SchermataSpeseGruppo.dart';
import 'gruppo.dart';

class SchermataListaGruppi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(body: Center(child: Text("Utente non autenticato")));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('I tuoi gruppi'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Gruppi')
            .where('utentiID', arrayContains: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nessun gruppo trovato'));
          }

          final gruppi = snapshot.data!.docs.map((doc) =>
              Gruppo.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

          return ListView.builder(
            itemCount: gruppi.length,
            itemBuilder: (context, index) {
              final gruppo = gruppi[index];
              return ListTile(
                title: Text(gruppo.titolo),
                subtitle: Text('Codice: ${gruppo.idUnico}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SchermataSpeseGruppo(
                        gruppoId: gruppo.id,
                        titolo: gruppo.titolo,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => CreaGruppoDialog(uid: uid),
            ),
            icon: Icon(Icons.group_add),
            label: Text('Crea Gruppo'),
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              final codiceController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Unisciti a un gruppo'),
                  content: TextField(
                    controller: codiceController,
                    decoration: InputDecoration(labelText: 'Inserisci codice gruppo'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Annulla'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final codiceInserito = codiceController.text.trim();

                        if (codiceInserito.isEmpty) return;

                        final query = await FirebaseFirestore.instance
                            .collection('Gruppi')
                            .where('idUnico', isEqualTo: codiceInserito)
                            .limit(1)
                            .get();

                        if (query.docs.isEmpty) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Codice gruppo non valido')),
                          );
                          return;
                        }

                        final gruppoDoc = query.docs.first;
                        final membri = List<String>.from(gruppoDoc['utentiID']);

                        if (!membri.contains(uid)) {
                          membri.add(uid);

                          await FirebaseFirestore.instance
                              .collection('Gruppi')
                              .doc(gruppoDoc.id)
                              .update({'utentiID': membri});
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Unito al gruppo con successo')),
                        );
                      },
                      child: Text('Unisciti'),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.login),
            label: Text('Unisciti'),
          ),
        ],
      ),
    );
  }
}
