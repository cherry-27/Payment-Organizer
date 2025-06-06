import 'package:flutter/material.dart';
import 'package:payment_organiser/CategorieWidget.dart';
import 'package:provider/provider.dart';
import 'Spesa.dart';
import 'SpesaViewModel.dart';

class SchermataAggiungiSpesa extends StatefulWidget {
  @override
  AggiungiSpesaState createState() => AggiungiSpesaState();
}

class AggiungiSpesaState extends State<SchermataAggiungiSpesa> {
  final titolo = TextEditingController();
  final descrizione = TextEditingController();
  final importo = TextEditingController();
  final categoria = TextEditingController();

  DateTime? dataSelezionata;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuova Spesa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titolo,
                decoration: InputDecoration(labelText: 'Titolo'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descrizione,
                decoration: InputDecoration(labelText: 'Descrizione'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: importo,
                decoration: InputDecoration(labelText: 'Importo'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              CategorieWidget(controller: categoria),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(dataSelezionata == null
                        ? 'Nessuna data selezionata'
                        : 'Data: ${dataSelezionata!.day}/${dataSelezionata!.month}/${dataSelezionata!.year}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final data = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (data != null) {
                        setState(() {
                          dataSelezionata = data;
                        });
                      }
                    },
                    child: Text("Seleziona data"),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (titolo.text.isEmpty ||
                      importo.text.isEmpty ||
                      dataSelezionata == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Compila tutti i campi obbligatori')),
                    );
                    return;
                  }

                  final nuovaSpesa = Spesa(
                    id: '',
                    uid: '',
                    titolo: titolo.text.trim(),
                    descrizione: descrizione.text.trim(),
                    giorno: dataSelezionata!.day,
                    mese: dataSelezionata!.month,
                    anno: dataSelezionata!.year,
                    importo: double.tryParse(importo.text.trim()) ?? 0,
                    categoria: categoria.text.trim(),
                  );

                  await Provider.of<SpeseViewModel>(context, listen: false)
                      .aggiungiSpesa(nuovaSpesa);

                  Navigator.pop(context); // Torna indietro dopo salvataggio
                },
                child: Text('Salva Spesa'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
