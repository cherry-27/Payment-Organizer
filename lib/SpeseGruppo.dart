import 'package:cloud_firestore/cloud_firestore.dart';


class SpeseGruppo {
  final String id;
  final String titolo;
  final String descrizione;
  final double importo;
  final DateTime data;

  SpeseGruppo({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.importo,
    required this.data,
  });

  factory SpeseGruppo.fromMap(String id, Map<String, dynamic> data) {
    return SpeseGruppo(
      id: id,
      titolo: data['titolo'],
      descrizione: data['descrizione'],
      importo: data['importo'],
      data: (data['data'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'titolo': titolo,
    'descrizione': descrizione,
    'importo': importo,
    'data': Timestamp.fromDate(data),
  };
}

