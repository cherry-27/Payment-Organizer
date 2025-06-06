import 'package:flutter/material.dart';

import 'SpeseGruppo.dart';

class RicercaSpeseGruppo extends SearchDelegate<String> {
  final List<SpeseGruppo> spese;

  RicercaSpeseGruppo(this.spese);

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: Icon(Icons.clear))];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, ''), icon: Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtrate = spese.where((s) =>
    s.titolo.toLowerCase().contains(query.toLowerCase()) ||
        s.descrizione.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      itemCount: filtrate.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(filtrate[i].titolo),
        onTap: () => close(context, query),
      ),
    );
  }
}