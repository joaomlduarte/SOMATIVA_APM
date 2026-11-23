import 'package:flutter/material.dart';

import '../tema.dart';

class LogoMangeFlix extends StatelessWidget {
  const LogoMangeFlix({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.play_circle_fill, size: 72, color: corPrincipal),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: 'Mange ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Flix', style: TextStyle(color: corPrincipal)),
            ],
          ),
        ),
      ],
    );
  }
}
