import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Gruppo.dart';

class CreaGruppoDialog extends StatefulWidget {
  final String uid;

  const CreaGruppoDialog({required this.uid});

  @override
  CreaGruppoDialogState createState() => CreaGruppoDialogState();
}

class CreaGruppoDialogState extends State<CreaGruppoDialog> {
  final _titoloController = TextEditingController();
  final _descrizioneController = TextEditingController();
  bool isLoading = false;

  void creaGruppo() async {
    final titolo = _titoloController.text.trim();
    final descrizione = _descrizioneController.text.trim();

    if (titolo.isEmpty) return;

    setState(() => isLoading = true);

    final idUnico = await Gruppo.generaCodiceUnico();

    final nuovoGruppo = Gruppo(
      id: '',
      titolo: titolo,
      descrizione: descrizione,
      idUnico: idUnico,
      membri: [widget.uid],
    );

    final docRef = await FirebaseFirestore.instance
        .collection('Gruppi')
        .add(nuovoGruppo.toMap());

    print('Nuovo gruppo creato con ID: ${docRef.id}');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crea nuovo gruppo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titoloController,
            decoration: const InputDecoration(labelText: 'Titolo gruppo'),
          ),
          TextField(
            controller: _descrizioneController,
            decoration: const InputDecoration(labelText: 'Descrizione'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : creaGruppo,
          child: isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Crea'),
        ),
      ],
    );
  }
}
