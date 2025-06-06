class Spesa {
  final String id;       // ID del documento Firestore
  final String uid;      // UID dell'utente proprietario della spesa
  final String titolo;
  final String descrizione;
  final int giorno;
  final int mese;
  final int anno;
  final double importo;
  final String categoria;

  Spesa({
    required this.id,
    required this.uid,
    required this.titolo,
    required this.descrizione,
    required this.giorno,
    required this.mese,
    required this.anno,
    required this.importo,
    required this.categoria,
  });

  String get dataString => '$giorno/$mese/$anno';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'titolo': titolo,
      'descrizione': descrizione,
      'giorno': giorno,
      'mese': mese,
      'anno': anno,
      'importo': importo,
      'categoria': categoria,
    };
  }

  factory Spesa.fromMap(String id, Map<String, dynamic> map) {
    return Spesa(
      id: id,
      uid: map['uid'] ?? '',
      titolo: map['titolo'] ?? '',
      descrizione: map['descrizione'] ?? '',
      giorno: map['giorno'] ?? 0,
      mese: map['mese'] ?? 0,
      anno: map['anno'] ?? 0,
      importo: (map['importo'] ?? 0).toDouble(),
      categoria: map['categoria'] ?? '',
    );
  }
}
