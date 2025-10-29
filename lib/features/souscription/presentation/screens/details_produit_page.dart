// lib/features/souscription/presentation/pages/details_produit_page.dart
import 'package:flutter/material.dart';
import 'package:mycorislife/models/produit_model.dart';

class DetailsProduitPage extends StatelessWidget {
  final Produit produit;

  const DetailsProduitPage({super.key, required this.produit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(produit.titre),
        backgroundColor: const Color(0xFF002B6B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              produit.image,
              width: double.infinity,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              produit.titre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              produit.description,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            const Text(
              "Avantages :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(
              produit.avantages,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Montant :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "${produit.montant.toStringAsFixed(0)} FCFA",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFE30613),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Tu redirigeras ici vers la page de paiement plus tard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Page de paiement à venir...")),
                  );
                },
                icon: const Icon(Icons.payment),
                label: const Text("Procéder au paiement"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002B6B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
