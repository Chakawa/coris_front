// lib/features/souscription/data/models/produit_model.dart

class Produit {
  final String id;
  final String titre;
  final String image;
  final String description;
  final String avantages;
  final double montant;

  Produit({
    required this.id,
    required this.titre,
    required this.image,
    required this.description,
    required this.avantages,
    required this.montant,
  });
}
