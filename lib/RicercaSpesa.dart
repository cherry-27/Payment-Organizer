import 'package:flutter/material.dart';
import 'package:payment_organiser/SpesaViewModel.dart';
import 'package:provider/provider.dart';
import 'Spesa.dart';

class RicercaSpesa extends SearchDelegate {
  final List<Spesa> tutteLeSpese;

  RicercaSpesa(this.tutteLeSpese);

  @override
  String get searchFieldLabel => 'Cerca per titolo, categoria o importo';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final risultati = _filtraSpese(query);

    if (risultati.isEmpty) {
      return Center(child: Text("Nessuna spesa trovata"));
    }

    return ListView.builder(
      itemCount: risultati.length,
      itemBuilder: (context, index) {
        final spesa = risultati[index];
        return ListTile(
          title: Text(spesa.titolo),
          subtitle: Text("${spesa.categoria} - €${spesa.importo.toStringAsFixed(2)}"),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggerimenti = _filtraSpese(query);

    return ListView.builder(
      itemCount: suggerimenti.length,
      itemBuilder: (context, index) {
        final spesa = suggerimenti[index];
        return ListTile(
          title: Text(spesa.titolo),
          subtitle: Text("${spesa.categoria} - €${spesa.importo.toStringAsFixed(2)}"),
          onTap: () {
            query = spesa.titolo;
            showResults(context);
          },
        );
      },
    );
  }

  List<Spesa> _filtraSpese(String query) {
    final testo = query.toLowerCase();
    return tutteLeSpese.where((spesa) {
      return spesa.titolo.toLowerCase().contains(testo) ||
          spesa.categoria.toLowerCase().contains(testo) ||
          spesa.importo.toString().contains(testo);
    }).toList();
  }
}
