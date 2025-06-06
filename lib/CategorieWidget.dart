import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_organiser/FornitoreCategorie.dart';

class CategorieWidget extends StatefulWidget {
  final TextEditingController controller;
  CategorieWidget({required this.controller});

  @override
  _CategorieWidgetState createState() => _CategorieWidgetState();
}

class _CategorieWidgetState extends State<CategorieWidget> {
  List<String> categorie = [];
  String? categoriaSelezionata;

  @override
  void initState() {
    super.initState();
    _caricaCategorie();
  }

  Future<void> _caricaCategorie() async {
    final tutte = await Fornitorecategorie().caricaCategorie();

    // Deduplica mantenendo l’ordine
    final viste = <String>{};
    final senzaDuplicati = tutte.where((c) => viste.add(c)).toList();

    final nuovaLista = [...senzaDuplicati, '➕ Aggiungi nuova categoria'];

    setState(() {
      categorie = nuovaLista;

      // Verifica che il valore sia presente una sola volta
      final selezionata = widget.controller.text;
      final count = nuovaLista.where((c) => c == selezionata).length;

      if (selezionata.isNotEmpty && count == 1) {
        categoriaSelezionata = selezionata;
      } else {
        categoriaSelezionata = null;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: categoriaSelezionata,
      items: categorie.map((categoria) {
        return DropdownMenuItem<String>(
          value: categoria,
          child: Text(categoria),
        );
      }).toList(),
      onChanged: (val) {
        if (val == '➕ Aggiungi nuova categoria') {
          _mostraDialogCategoria(context);
        } else {
          setState(() {
            categoriaSelezionata = val!;
            widget.controller.text = val!;
          });
        }
      },
      decoration: InputDecoration(labelText: 'Categoria'),
    );
  }

  void _mostraDialogCategoria(BuildContext context) {
    final nuovoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Aggiungi nuova categoria"),
        content: TextField(
          controller: nuovoController,
          decoration: InputDecoration(labelText: "Nome categoria"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Annulla")),
          ElevatedButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              final nome = nuovoController.text.trim();

              if (uid != null && nome.isNotEmpty) {
                final nomeNormalizzato = nome.toLowerCase();
                final nomeEsiste = categorie.any((c) => c.toLowerCase() == nomeNormalizzato);
                if (nomeEsiste) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('La categoria "$nome" esiste già')),
                );
              return;
              }
                await FirebaseFirestore.instance
                    .collection('Utenti')
                    .doc(uid)
                    .collection('categorie')
                    .add({'titolo': nome});

                await _caricaCategorie();

                setState(() {
                  categoriaSelezionata = nome;
                  widget.controller.text = nome;
                });
                Navigator.pop(context);
              }
            },
            child: Text("Conferma"),
          ),
        ],
      ),
    );
  }
}
