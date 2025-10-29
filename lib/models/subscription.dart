class Subscription {
  final int id;
  final int userId;
  final String numeroPolice;
  final String produitNom;
  final String statut;
  final DateTime dateCreation;
  final DateTime? dateValidation;
  final Map<String, dynamic> souscriptionData;

  Subscription({
    required this.id,
    required this.userId,
    required this.numeroPolice,
    required this.produitNom,
    required this.statut,
    required this.dateCreation,
    this.dateValidation,
    required this.souscriptionData,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      numeroPolice: json['numero_police'],
      produitNom: json['produit_nom'],
      statut: json['statut'],
      dateCreation: DateTime.parse(json['date_creation']),
      dateValidation: json['date_validation'] != null ? DateTime.parse(json['date_validation']) : null,
      souscriptionData: json['souscriptiondata'],
    );
  }

  String get formattedDateCreation {
    return '${dateCreation.day.toString().padLeft(2, '0')}/${dateCreation.month.toString().padLeft(2, '0')}/${dateCreation.year}';
  }

  String get formattedDateValidation {
    if (dateValidation == null) return '-';
    return '${dateValidation!.day.toString().padLeft(2, '0')}/${dateValidation!.month.toString().padLeft(2, '0')}/${dateValidation!.year}';
  }

  String get capitalFormatted {
    final capital = souscriptionData['capital'] ?? souscriptionData['montant'] ?? 0;
    return '${capital.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
  }

  String get primeFormatted {
    final prime = souscriptionData['prime'] ?? souscriptionData['prime_calculee'] ?? souscriptionData['prime_mensuelle'] ?? 0;
    return '${prime.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
  }
}