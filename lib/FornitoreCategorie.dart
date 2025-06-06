import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Fornitorecategorie {
  final List<String> categorie = [
    "Alimentari", "Trasporti", "Svago", "Abbigliamento", "Casa"
  ];

  Future<List<String>> caricaCategorie() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final List<String> result = [...categorie];
    if (uid == null) return result;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Utenti')
          .doc(uid)
          .collection('categorie')
          .get();

      for (var doc in snapshot.docs) {
        final nome = doc.get('titolo');
        if (nome is String && !result.contains(nome)) {
          result.add(nome);
        }
      }
    } catch (e) {
      debugPrint("Errore Firestore: $e");
    }

    return result;
  }
}
