import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Gruppo {
  final String id; // ← può essere presente o opzionale
  final String titolo;
  final String descrizione;
  final String idUnico;
  final List<String> membri;

  Gruppo({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.idUnico,
    required this.membri,
  });

  Map<String, dynamic> toMap() {
    return {
      'titolo': titolo,
      'descrizione': descrizione,
      'idUnico': idUnico,
      'utentiID': membri,
    };
  }

  factory Gruppo.fromMap(Map<String, dynamic> data, String id) {
    return Gruppo(
      id: id,
      titolo: data['titolo'] ?? '',
      descrizione: data['descrizione'] ?? '',
      idUnico: data['idUnico'] ?? '',
      membri: List<String>.from(data['membri'] ?? []),
    );
  }
  static Future<String> generaCodiceUnico() async {
    final gruppiRef = FirebaseFirestore.instance.collection('gruppi');
    final random = Random();

    while (true) {
      final codice = (random.nextInt(1000000) + 1).toString();
      final snapshot = await gruppiRef.where('idUnico', isEqualTo: codice).get();
      if (snapshot.docs.isEmpty) {
        return codice;
      }
    }
  }
}
