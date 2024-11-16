import 'package:flutter/material.dart';

const Color error = Colors.red;

const Color primaryText = Colors.indigo;
final Color secondaryText = Colors.indigo[900]!;




final Color carbColor = Colors.blue[600] ?? error;
final Color proteinColor = Colors.orange[400] ?? error;
final Color fatColor = Colors.deepPurple[700] ?? error;
final Color fibreColor = Colors.green[400] ?? error;

final List<Color> primaryBackgroundGradient = <Color>[
  const Color.fromARGB(255, 192, 227, 255),
  const Color.fromARGB(255, 235, 246, 255)
];

const shadownOnPrimaryBackgroundGradient =
    Color.fromARGB(86, 0, 21, 155);

final List<Color> secondaryBackgroundGradient = <Color>[
  const Color.fromARGB(255, 176, 219, 255),
  const Color.fromARGB(255, 213, 236, 255)
];
final List<Color> onSecondaryBackgroundGradient = <Color>[
  const Color.fromARGB(255, 20, 74, 223),
  const Color.fromARGB(255, 51, 64, 252)
];
