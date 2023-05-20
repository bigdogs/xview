import 'package:flutter/material.dart';

class NoFile extends StatelessWidget {
  const NoFile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          Icons.library_books,
          size: 96,
          color: Colors.blue,
        ),
        Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text(
              'NO FILE',
              style: TextStyle(fontSize: 24),
            ))
      ]),
    );
  }
}
