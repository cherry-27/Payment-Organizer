import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:payment_organiser/RicercaSpeseGruppo.dart';

import 'SpeseGruppo.dart';

class SchermataSpeseGruppo extends StatefulWidget {
  final String gruppoId;
  final String titolo;

  SchermataSpeseGruppo({required this.gruppoId, required this.titolo});

  @override
  SchermataSpeseGruppoState createState() => SchermataSpeseGruppoState();
}

class SchermataSpeseGruppoState extends State<SchermataSpeseGruppo> {
  List<SpeseGruppo> spese = [];
  String ricerca = '';

  @override
  void initState() {
    super.initState();
    caricaSpese();
  }

  Future<void> caricaSpese() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Gruppi')
        .doc(widget.gruppoId)
        .collection('Spese')
        .get();

    setState(() {
      spese = snapshot.docs
          .map((doc) => SpeseGruppo.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  void mostraDialogNuovaSpesa() {
    final titoloController = TextEditingController();
    final descrizioneController = TextEditingController();
    final importoController = TextEditingController();
    DateTime data = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Aggiungi Spesa'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titoloController, decoration: InputDecoration(labelText: 'Titolo')),
              TextField(controller: descrizioneController, decoration: InputDecoration(labelText: 'Descrizione')),
              TextField(controller: importoController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Importo')),
              TextButton(
                onPressed: () async {
                  final nuovaData = await showDatePicker(
                    context: context,
                    initialDate: data,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (nuovaData != null) {
                    setState(() => data = nuovaData);
                  }
                },
                child: Text("Data: ${DateFormat('dd/MM/yyyy').format(data)}"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annulla')),
          ElevatedButton(
            onPressed: () async {
              final nuovaSpesa = SpeseGruppo(
                id: '',
                titolo: titoloController.text.trim(),
                descrizione: descrizioneController.text.trim(),
                importo: double.tryParse(importoController.text.trim()) ?? 0.0,
                data: data,
              );

              final docRef = await FirebaseFirestore.instance
                  .collection('Gruppi')
                  .doc(widget.gruppoId)
                  .collection('Spese')
                  .add(nuovaSpesa.toMap());

              setState(() {
                spese.add(SpeseGruppo.fromMap(docRef.id, nuovaSpesa.toMap()));
              });
              Navigator.pop(context);
            },
            child: Text('Aggiungi'),
          )
        ],
      ),
    );
  }

  void mostraDialogMembri() async {
    final gruppoDoc = await FirebaseFirestore.instance.collection('Gruppi').doc(widget.gruppoId).get();
    final membri = List<String>.from(gruppoDoc['utentiID']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Membri del gruppo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: membri.map((m) => Text(m)).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Chiudi'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final speseFiltrate = spese.where((s) =>
    s.titolo.toLowerCase().contains(ricerca.toLowerCase()) ||
        s.descrizione.toLowerCase().contains(ricerca.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titolo),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: mostraDialogMembri,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final testo = await showSearch(context: context, delegate: RicercaSpeseGruppo(spese));
              if (testo != null) setState(() => ricerca = testo);
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: speseFiltrate.length,
        itemBuilder: (_, index) {
          final spesa = speseFiltrate[index];
          return ListTile(
            title: Text(spesa.titolo),
            subtitle: Text("€${spesa.importo.toStringAsFixed(2)} - ${DateFormat('dd/MM/yyyy').format(spesa.data)}"),
            onTap: ()  => mostraDialogDettagli(spesa),

          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostraDialogNuovaSpesa,
        child: Icon(Icons.add),
      ),
    );
  }
void mostraDialogDettagli(SpeseGruppo spesa) {
  final titoloController = TextEditingController(text: spesa.titolo);
  final descrizioneController = TextEditingController(text: spesa.descrizione);
  final importoController = TextEditingController(text: spesa.importo.toString());
  DateTime data = spesa.data;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Dettagli Spesa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titoloController, decoration: InputDecoration(labelText: 'Titolo')),
          TextField(controller: descrizioneController, decoration: InputDecoration(labelText: 'Descrizione')),
          TextField(controller: importoController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Importo')),
          TextButton(
            onPressed: () async {
              final nuovaData = await showDatePicker(
                context: context,
                initialDate: data,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (nuovaData != null) {
                setState(() => data = nuovaData);
              }
            },
            child: Text("Data: ${DateFormat('dd/MM/yyyy').format(data)}"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            // Elimina spesa
            await FirebaseFirestore.instance
                .collection('Gruppi')
                .doc(widget.gruppoId)
                .collection('Spese')
                .doc(spesa.id)
                .delete();

            setState(() => spese.removeWhere((s) => s.id == spesa.id));
            Navigator.pop(context);
          },
          child: Text('Elimina', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () async {
            final modificata = SpeseGruppo(
              id: spesa.id,
              titolo: titoloController.text.trim(),
              descrizione: descrizioneController.text.trim(),
              importo: double.tryParse(importoController.text.trim()) ?? 0.0,
              data: data,
            );

            await FirebaseFirestore.instance
                .collection('Gruppi')
                .doc(widget.gruppoId)
                .collection('Spese')
                .doc(spesa.id)
                .set(modificata.toMap());

            setState(() {
              final index = spese.indexWhere((s) => s.id == spesa.id);
              spese[index] = modificata;
            });

            Navigator.pop(context);
          },
          child: Text('Salva'),
        ),
      ],
    ),
  );
}

}

