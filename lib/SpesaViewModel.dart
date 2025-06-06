import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Spesa.dart';

class SpeseViewModel extends ChangeNotifier {
  final List<Spesa> spese = [];
  List<Spesa> filtrate = [];
  bool filtroAttivo = false;
  List<Spesa> get speseLista => filtroAttivo ? filtrate : spese;

  final firestore = FirebaseFirestore.instance;
  String ricerca = '';
  String get ricercaSpesa => ricerca;
  set ricercaSpesa(String valore) {
    ricerca = valore;
  }

  void setFiltrate(List<Spesa> nuoveFiltrate) {
    filtrate = nuoveFiltrate;
    filtroAttivo = true;
    notifyListeners();
  }

  void rimuoviFiltri() {
    filtrate.clear();
    filtroAttivo = false;
    notifyListeners();
  }

  void aggiornaQuery(String nuovaRicerca) {
    ricercaSpesa = nuovaRicerca.toLowerCase();

    if (ricercaSpesa.isNotEmpty) {
      filtroAttivo = false;
      filtrate = [];
    }

    notifyListeners();
  }


  List<Spesa> get speseFiltrate {
    if (ricercaSpesa.isNotEmpty) {
      return spese.where((spesa) {
        return spesa.titolo.toLowerCase().contains(ricerca) ||
            spesa.categoria.toLowerCase().contains(ricerca) ||
            spesa.importo.toString().contains(ricerca);
      }).toList();
    }

    if (filtroAttivo) {
      return filtrate;
    }

    return spese;
  }

  Future<void> caricaSpese() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await firestore
        .collection('Spese')
        .where('uid', isEqualTo: uid)
        .get();

    spese.clear();
    for (var doc in snapshot.docs) {
      spese.add(Spesa.fromMap(doc.id, doc.data()));
    }
    notifyListeners();
  }

  Future<void> aggiungiSpesa(Spesa spesa) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final nuovoSpesa = Spesa(
      id: '',
      uid: uid,
      titolo: spesa.titolo,
      descrizione: spesa.descrizione,
      giorno: spesa.giorno,
      mese: spesa.mese,
      anno: spesa.anno,
      importo: spesa.importo,
      categoria: spesa.categoria,
    );

    final docRef = await firestore.collection('Spese').add(nuovoSpesa.toMap());

    spese.add(Spesa.fromMap(docRef.id, nuovoSpesa.toMap()));
    notifyListeners();
  }

  Future<void> eliminaSpesa(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await firestore.collection('Spese').doc(id).delete();

    spese.removeWhere((spesa) => spesa.id == id);
    notifyListeners();
  }

  Future<void> modificaSpesa(Spesa spesa) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final spesaModificata = Spesa(
      id: spesa.id,
      uid: uid,
      titolo: spesa.titolo,
      descrizione: spesa.descrizione,
      giorno: spesa.giorno,
      mese: spesa.mese,
      anno: spesa.anno,
      importo: spesa.importo,
      categoria: spesa.categoria,
    );

    await firestore.collection('Spese').doc(spesa.id).set(spesaModificata.toMap());

    final index = spese.indexWhere((s) => s.id == spesa.id);
    if (index != -1) {
      spese[index] = spesaModificata;
      notifyListeners();
    }
  }
}
