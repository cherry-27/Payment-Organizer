import 'package:flutter/material.dart';

class SchermataSolo extends StatelessWidget {
  final List<Map<String, dynamic>> spese = [
    {
      "titolo": "Spesa 1",
      "descrizione": "Descrizione dettagliata della spesa 1",
      "data": "2024-05-01",
      "importo": 0,
      "categoria": "Alimentari"
    },
    {
      "titolo": "Spesa 2",
      "descrizione": "Pagamento abbonamento mensile",
      "data": "2024-05-03",
      "importo": 5,
      "categoria": "Trasporti"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Le mie Spese"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.filter_list)),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: spese.length,
        itemBuilder: (context, index) {
          final spesa = spese[index];
          return Card(
            color: Color(0xFFC8E6C9),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(spesa['titolo']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spesa['categoria']),
                  Text(spesa['descrizione']),
                  Text("Data: ${spesa['data']}", style: TextStyle(fontSize: 12)),
                ],
              ),
              trailing: Text("€${spesa['importo'].toStringAsFixed(2)}"),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF4CAF50),
        child: Icon(Icons.add),
      ),
    );
  }
}
