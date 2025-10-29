import 'package:flutter/material.dart';

class SouscriptionPretsScolairePage extends StatefulWidget {
  const SouscriptionPretsScolairePage({super.key});

  @override
  State<SouscriptionPretsScolairePage> createState() => _SouscriptionPretsScolairePageState();
}

class _SouscriptionPretsScolairePageState extends State<SouscriptionPretsScolairePage> {
  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color fondGris = Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondGris,
      appBar: AppBar(
        backgroundColor: bleuCoris,
        title: const Text(
          'PRÊTS SCOLAIRES',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: bleuCoris,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                'Souscription non disponible',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: bleuCoris,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'La souscription en ligne n\'est pas disponible pour ce produit.\nVeuillez vous rendre en agence.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bleuCoris,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Retour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}