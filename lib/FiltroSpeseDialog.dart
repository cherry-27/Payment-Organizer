import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payment_organiser/Spesa.dart';
import 'package:payment_organiser/SpesaViewModel.dart';
import 'package:provider/provider.dart';

class FiltroSpeseDialog extends StatefulWidget {
  final List<Spesa> spese;
  final void Function(List<Spesa>) onFiltra;

  const FiltroSpeseDialog({required this.spese, required this.onFiltra});

  @override
  State<FiltroSpeseDialog> createState() => _FiltroSpeseDialogState();
}

class _FiltroSpeseDialogState extends State<FiltroSpeseDialog> {
  List<String> categorie = [];
  List<String> selezionate = [];
  DateTime? dataInizio;
  DateTime? dataFine;
  List<bool> prezzi = [false, false, false];
  bool ordineAZ = false;

  @override
  void initState() {
    super.initState();
    categorie = widget.spese.map((e) => e.categoria).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filtra Spese'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categorie:'),
            Wrap(
              spacing: 8,
              children: categorie.map((cat) {
                return FilterChip(
                  label: Text(cat),
                  selected: selezionate.contains(cat),
                  onSelected: (val) {
                    setState(() {
                      val ? selezionate.add(cat) : selezionate.remove(cat);
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            Text('Prezzo:'),
            Column(
              children: [
                CheckboxListTile(
                    title: Text('< 50€'),
                    value: prezzi[0],
                    onChanged: (val) => setState(() => prezzi[0] = val!)),
                CheckboxListTile(
                    title: Text('50-100€'),
                    value: prezzi[1],
                    onChanged: (val) => setState(() => prezzi[1] = val!)),
                CheckboxListTile(
                    title: Text('> 100€'),
                    value: prezzi[2],
                    onChanged: (val) => setState(() => prezzi[2] = val!)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    dataInizio == null ? 'Inizio: -' : 'Inizio: ${dataInizio!.day}/${dataInizio!.month}/${dataInizio!.year}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (data != null) setState(() => dataInizio = data);
                  },
                  child: Text('Seleziona'),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    dataFine == null ? 'Fine: -' : 'Fine: ${dataFine!.day}/${dataFine!.month}/${dataFine!.year}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (data != null) setState(() => dataFine = data);
                  },
                  child: Text('Seleziona'),
                )
              ],
            ),
            CheckboxListTile(
              title: Text('Ordina A-Z'),
              value: ordineAZ,
              onChanged: (val) => setState(() => ordineAZ = val!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Provider.of<SpeseViewModel>(context, listen: false).rimuoviFiltri();
            Navigator.pop(context);
          },
          child: Text('Rimuovi filtri'),
        ),
        ElevatedButton(
          onPressed: () {
            var risultato = widget.spese;

            if (selezionate.isNotEmpty) {
              risultato = risultato.where((s) => selezionate.contains(s.categoria)).toList();
            }

            final filtriPrezzo = <Spesa>[];
            if (prezzi[0]) filtriPrezzo.addAll(risultato.where((s) => s.importo < 50));
            if (prezzi[1]) filtriPrezzo.addAll(risultato.where((s) => s.importo >= 50 && s.importo <= 100));
            if (prezzi[2]) filtriPrezzo.addAll(risultato.where((s) => s.importo > 100));
            if (prezzi.contains(true)) risultato = filtriPrezzo.toSet().toList();

            if (dataInizio != null && dataFine != null) {
              risultato = risultato.where((s) {
                final data = DateTime(s.anno, s.mese, s.giorno);
                return data.isAfter(dataInizio!.subtract(Duration(days: 1))) && data.isBefore(dataFine!.add(Duration(days: 1)));
              }).toList();
            }

            if (ordineAZ) {
              risultato.sort((a, b) => a.titolo.toLowerCase().compareTo(b.titolo.toLowerCase()));
            }

            widget.onFiltra(risultato);
            Navigator.pop(context);
          },
          child: Text('Applica'),
        ),
      ],
    );
  }
}
