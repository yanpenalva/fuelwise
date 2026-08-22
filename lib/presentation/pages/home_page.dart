import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuelwise'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Compare etanol e gasolina e descubra qual vale mais a pena abastecer.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
