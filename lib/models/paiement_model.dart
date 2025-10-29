// lib/features/souscription/data/models/paiement_model.dart
class Paiement {
  final String id;
  final String souscriptionId;
  final double montant;
  final String methode;
  final String statut; // 'en_attente', 'reussi', 'echoue'
  final DateTime datePaiement;

  Paiement({
    required this.id,
    required this.souscriptionId,
    required this.montant,
    required this.methode,
    required this.statut,
    DateTime? datePaiement,
  }) : datePaiement = datePaiement ?? DateTime.now();

  factory Paiement.fromMap(Map<String, dynamic> map) {
    return Paiement(
      id: map['id'],
      souscriptionId: map['souscription_id'],
      montant: map['montant'].toDouble(),
      methode: map['methode'],
      statut: map['statut'],
      datePaiement: DateTime.parse(map['date_paiement']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'souscription_id': souscriptionId,
      'montant': montant,
      'methode': methode,
      'statut': statut,
      'date_paiement': datePaiement.toIso8601String(),
    };
  }
}