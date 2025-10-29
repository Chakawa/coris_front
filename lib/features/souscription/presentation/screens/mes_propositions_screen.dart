import 'package:flutter/material.dart';
import 'package:mycorislife/models/subscription.dart';
import 'package:mycorislife/services/subscription_service.dart';

class MesPropositionsPage extends StatefulWidget {
  const MesPropositionsPage({Key? key}) : super(key: key);

  @override
  State<MesPropositionsPage> createState() => _MesPropositionsPageState();
}

class _MesPropositionsPageState extends State<MesPropositionsPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Subscription> _propositions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPropositions();
  }

  Future<void> _loadPropositions() async {
    try {
      final propositions = await _subscriptionService.getPropositions();
      setState(() {
        _propositions = propositions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _onPropositionTap(Subscription proposition) async {
    try {
      // Naviguer vers l'écran de récapitulatif complet
      Navigator.pushNamed(
        context,
        '/recap-proposition',
        arguments: {
          'proposition': proposition,
          'isFromList': true,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Propositions'),
        backgroundColor: const Color(0xFF002B6B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPropositions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _propositions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune proposition disponible',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPropositions,
                  child: ListView.builder(
                    itemCount: _propositions.length,
                    itemBuilder: (context, index) {
                      final proposition = _propositions[index];
                      return _buildPropositionCard(proposition);
                    },
                  ),
                ),
    );
  }

  Widget _buildPropositionCard(Subscription proposition) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF002B6B).withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.description, color: Color(0xFF002B6B)),
        ),
        title: Text(
          '${proposition.produitNom} - #${proposition.numeroPolice}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildStatusChip(proposition.statut),
            const SizedBox(height: 4),
            Text('Créé le: ${proposition.formattedDateCreation}'),
            if (proposition.souscriptionData['capital'] != null)
              Text('Capital: ${proposition.capitalFormatted}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _onPropositionTap(proposition),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor = Colors.grey;
    String statusText = status;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        statusText = 'En attente';
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
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
