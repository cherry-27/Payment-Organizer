import 'package:flutter/material.dart';

class SchermataIniziale extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Benvenuto")),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.person, size: 60),
                  onPressed: () {
                    Navigator.pushNamed(context, '/solo');
                  },
                ),
                Text("Area Personale"),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.group, size: 60),
                  onPressed: () {
                    Navigator.pushNamed(context, '/gruppo');
                  },
                ),
                Text("Area Gruppo"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
