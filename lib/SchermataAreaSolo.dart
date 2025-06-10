import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payment_organiser/CategorieWidget.dart';
import 'package:payment_organiser/RicercaSpesa.dart';
import 'package:payment_organiser/Spesa.dart';
import 'package:payment_organiser/SpesaViewModel.dart';
import 'package:provider/provider.dart';
import 'FiltroSpeseDialog.dart';

class SchermataSolo extends StatefulWidget {
  @override
  _SchermataSoloState createState() => _SchermataSoloState();
}

class _SchermataSoloState extends State<SchermataSolo> {
  Map<String, dynamic>? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _caricaDatiUtente();
  }

  Future<void> _caricaDatiUtente() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('Utenti').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Le mie Spese"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              final spese = Provider.of<SpeseViewModel>(context, listen: false).speseLista;
              showSearch(context: context, delegate: RicercaSpesa(spese));
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              final viewModel = Provider.of<SpeseViewModel>(context, listen: false);
              await showDialog(
                context: context,
                builder: (context) => FiltroSpeseDialog(
                  spese: viewModel.speseLista,
                  onFiltra: (filtrate) => viewModel.setFiltrate(filtrate),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(child: Text("Dati utente non trovati"))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Ciao, ${userData!['nickname']} 👋",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: Consumer<SpeseViewModel>(
              builder: (context, viewModel, _) {
                final spese = viewModel.speseFiltrate;
                if (spese.isEmpty) {
                  return Center(child: Text("Nessuna spesa inserita"));
                }
                return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: spese.length,
                  itemBuilder: (context, index) {
                    final spesa = spese[index];
                    return Card(
                      color: Color(0xFFC8E6C9),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(spesa.titolo),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(spesa.categoria),
                            Text(spesa.descrizione),
                            Text("Data: ${spesa.dataString}", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Text("€${spesa.importo.toStringAsFixed(2)}"),
                        onTap: () => _modificaSpesa(context, spesa),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/aggiungiSpesa');
        },
        backgroundColor: Color(0xFF4CAF50),
        child: Icon(Icons.add),
      ),
    );
  }

  void _modificaSpesa(BuildContext context, Spesa spesa) {
    final titoloController = TextEditingController(text: spesa.titolo);
    final descrizioneController = TextEditingController(text: spesa.descrizione);
    final importoController = TextEditingController(text: spesa.importo.toString());
    final categoriaController = TextEditingController(text: spesa.categoria);
    DateTime data = DateTime(spesa.anno, spesa.mese, spesa.giorno);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Modifica Spesa'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: titoloController, decoration: InputDecoration(labelText: 'Titolo')),
                    SizedBox(height: 8),
                    TextField(controller: descrizioneController, decoration: InputDecoration(labelText: 'Descrizione')),
                    SizedBox(height: 8),
                    TextField(
                      controller: importoController,
                      decoration: InputDecoration(labelText: 'Importo'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    CategorieWidget(controller: categoriaController),
                    SizedBox(height: 8),
                    Text("Data: ${data.day}/${data.month}/${data.year}"),
                    TextButton(
                      onPressed: () async {
                        final nuovaData = await showDatePicker(
                          context: context,
                          initialDate: data,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (nuovaData != null) {
                          setState(() => data = nuovaData);
                        }
                      },
                      child: Text("Cambia data"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Provider.of<SpeseViewModel>(context, listen: false).eliminaSpesa(spesa.id);
                    Navigator.of(context).pop();
                  },
                  child: Text('Elimina', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nuovaSpesa = Spesa(
                      id: spesa.id,
                      uid: spesa.uid,
                      titolo: titoloController.text.trim(),
                      descrizione: descrizioneController.text.trim(),
                      importo: double.tryParse(importoController.text.trim()) ?? 0.0,
                      categoria: categoriaController.text.trim(),
                      giorno: data.day,
                      mese: data.month,
                      anno: data.year,
                    );

                    await Provider.of<SpeseViewModel>(context, listen: false).modificaSpesa(nuovaSpesa);
                    Navigator.of(context).pop();
                  },
                  child: Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
