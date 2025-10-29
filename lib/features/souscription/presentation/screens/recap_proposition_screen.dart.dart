import 'package:flutter/material.dart';
import 'package:mycorislife/models/subscription.dart';

class RecapPropositionScreen extends StatelessWidget {
  final Subscription proposition;
  final bool isFromList; // Pour savoir si on vient de la liste des propositions

  const RecapPropositionScreen({
    Key? key,
    required this.proposition,
    this.isFromList = true,
  }) : super(key: key);

  BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(isFromList ? 'Récapitulatif Proposition' : 'Récapitulatif'),
        backgroundColor: const Color(0xFF002B6B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Informations du produit
            _buildProductInfoCard(),
            const SizedBox(height: 20),

            // Informations personnelles (si disponibles)
            _buildPersonalInfoCard(),
            const SizedBox(height: 20),

            // Informations du bénéficiaire (si disponibles)
            _buildBeneficiaryInfoCard(),
            const SizedBox(height: 20),

            // Informations de contact d'urgence (si disponibles)
            _buildEmergencyContactCard(),
            const SizedBox(height: 20),

            // Documents (si disponibles)
            _buildDocumentsCard(),
            const SizedBox(height: 20),

            // Boutons d'action si on vient de la liste
            if (isFromList && proposition.statut == 'pending')
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 50, color: Color(0xFF10B981)),
            const SizedBox(height: 10),
            Text(
              'Proposition ${proposition.numeroPolice}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002B6B),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Produit: ${proposition.produitNom}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _buildStatusChip(proposition.statut),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    final data = proposition.souscriptionData;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.savings, color: Color(0xFF002B6B)),
                SizedBox(width: 10),
                Text(
                  'Informations du Produit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoRow('Capital assuré', proposition.capitalFormatted),
            _buildInfoRow('Prime', proposition.primeFormatted),
            _buildInfoRow(
                'Date de création', proposition.formattedDateCreation),
            if (proposition.dateValidation != null)
              _buildInfoRow(
                  'Date de validation', proposition.formattedDateValidation),
            if (data['duree_mois'] != null)
              _buildInfoRow('Durée', '${data['duree_mois']} mois'),
            if (data['date_effet'] != null)
              _buildInfoRow('Date d\'effet', _formatDate(data['date_effet'])),
            if (data['date_fin'] != null)
              _buildInfoRow('Date de fin', _formatDate(data['date_fin'])),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    final data = proposition.souscriptionData;

    // Si pas d'infos personnelles spécifiques, on n'affiche pas
    if (data['user'] == null && data['nom'] == null) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Color(0xFF002B6B)),
                SizedBox(width: 10),
                Text(
                  'Informations Personnelles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (data['user'] != null) ...[
              _buildInfoRow('Nom', data['user']['nom'] ?? ''),
              _buildInfoRow('Prénom', data['user']['prenom'] ?? ''),
              _buildInfoRow('Email', data['user']['email'] ?? ''),
              if (data['user']['telephone'] != null)
                _buildInfoRow('Téléphone', data['user']['telephone']),
            ] else if (data['nom'] != null) ...[
              _buildInfoRow('Nom', data['nom'] ?? ''),
              _buildInfoRow('Prénom', data['prenom'] ?? ''),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficiaryInfoCard() {
    final data = proposition.souscriptionData;

    if (data['beneficiaire'] == null) {
      return const SizedBox();
    }

    final benef = data['beneficiaire'];
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.family_restroom, color: Color(0xFF002B6B)),
                SizedBox(width: 10),
                Text(
                  'Bénéficiaire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoRow('Nom complet', benef['nom'] ?? ''),
            _buildInfoRow('Contact', benef['contact'] ?? ''),
            _buildInfoRow('Lien de parenté', benef['lien_parente'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
    final data = proposition.souscriptionData;

    if (data['contact_urgence'] == null) {
      return const SizedBox();
    }

    final contact = data['contact_urgence'];
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contact_phone, color: Color(0xFF002B6B)),
                SizedBox(width: 10),
                Text(
                  'Contact d\'Urgence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoRow('Nom complet', contact['nom'] ?? ''),
            _buildInfoRow('Contact', contact['contact'] ?? ''),
            _buildInfoRow('Lien de parenté', contact['lien_parente'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsCard() {
    final data = proposition.souscriptionData;

    if (data['piece_identite'] == null && data['documents'] == null) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, color: Color(0xFF002B6B)),
                SizedBox(width: 10),
                Text(
                  'Documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (data['piece_identite'] != null)
              _buildInfoRow('Pièce d\'identité', data['piece_identite']),
            if (data['documents'] != null && data['documents'] is List)
              ...(data['documents'] as List)
                  .map((doc) => _buildInfoRow('Document', doc.toString()))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Actions disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002B6B),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implémenter le paiement
                  _showPaymentOptions(context!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002B6B),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Payer maintenant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implémenter le partage
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Color(0xFF002B6B)),
                ),
                child: const Text(
                  'Partager la proposition',
                  style: TextStyle(color: Color(0xFF002B6B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choisir un mode de paiement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // TODO: Ajouter les options de paiement réelles
              ListTile(
                leading: const Icon(Icons.phone_android, color: Colors.orange),
                title: const Text('Orange Money'),
                onTap: () {
                  Navigator.pop(context);
                  // Paiement Orange Money
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android, color: Colors.blue),
                title: const Text('Wave'),
                onTap: () {
                  Navigator.pop(context);
                  // Paiement Wave
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Non renseigné',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor = Colors.grey;
    String statusText = status;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        statusText = 'En attente de paiement';
        break;
      case 'validated':
        chipColor = Colors.green;
        statusText = 'Validée';
        break;
      case 'paid':
        chipColor = Colors.blue;
        statusText = 'Payée';
        break;
      case 'rejected':
        chipColor = Colors.red;
        statusText = 'Rejetée';
        break;
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Non définie';
    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      } catch (e) {
        return date;
      }
    }
    return date.toString();
  }
}
