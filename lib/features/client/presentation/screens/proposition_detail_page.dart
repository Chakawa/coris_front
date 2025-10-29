import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import 'package:mycorislife/services/subscription_service.dart';

class PropositionDetailPage extends StatefulWidget {
  final int subscriptionId;
  final String propositionNumber;

  const PropositionDetailPage({
    super.key,
    required this.subscriptionId,
    required this.propositionNumber,
  });

  @override
  PropositionDetailPageState createState() => PropositionDetailPageState();
}

class PropositionDetailPageState extends State<PropositionDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final SubscriptionService _service = SubscriptionService();
  Map<String, dynamic>? _subscriptionData;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    ));

    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    try {
      final data = await _service.getSubscriptionDetail(widget.subscriptionId);
      
      developer.log('=== TOUTES LES CLÉS DISPONIBLES ===');
      if (data['subscription'] != null) {
        developer.log('Clés dans subscription: ${data['subscription'].keys}');
        data['subscription'].forEach((key, value) {
          if (key != 'souscriptiondata') {
            developer.log('$key: $value (type: ${value.runtimeType})');
          }
        });
        
        if (data['subscription']['souscriptiondata'] != null) {
          developer.log('=== SOUSCRIPTIONDATA ===');
          developer.log('Type: ${data['subscription']['souscriptiondata'].runtimeType}');
          if (data['subscription']['souscriptiondata'] is Map) {
            data['subscription']['souscriptiondata'].forEach((key, value) {
              developer.log('$key: $value');
            });
          } else {
            developer.log('Contenu: ${data['subscription']['souscriptiondata']}');
          }
        }
      }
      
      setState(() {
        _subscriptionData = data['subscription'];
        _userData = data['user'];
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      developer.log('Erreur: $e', error: e);
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return 'Non définie';
      
      DateTime date;
      if (dateValue is DateTime) {
        date = dateValue;
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return 'Date inconnue';
      }
      
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return "Date inconnue";
    }
  }

  String _formatMontant(dynamic montant) {
    if (montant == null) return '0 FCFA';
    
    final numValue = montant is String ? double.tryParse(montant) ?? 0 : (montant as num).toDouble();
    return "${numValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA";
  }

  Color _getBadgeColor(String produit) {
    if (produit.toLowerCase().contains('solidarite')) {
      return const Color(0xFF002B6B);
    } else if (produit.toLowerCase().contains('emprunteur')) {
      return const Color(0xFFEF4444);
    } else if (produit.toLowerCase().contains('etude')) {
      return const Color(0xFF8B5CF6);
    } else if (produit.toLowerCase().contains('retraite')) {
      return const Color(0xFF10B981);
    } else if (produit.toLowerCase().contains('serenite')) {
      return const Color(0xFF002B6B);
    } else if (produit.toLowerCase().contains('familis')) {
      return const Color(0xFFF59E0B);
    } else if (produit.toLowerCase().contains('epargne')) {
      return const Color(0xFF8B5CF6);
    } else {
      return const Color(0xFF002B6B);
    }
  }

  String _getBadgeText(String produit) {
    if (produit.toLowerCase().contains('solidarite')) {
      return 'CORIS SOLIDARITÉ';
    } else if (produit.toLowerCase().contains('emprunteur')) {
      return 'FLEX EMPRUNTEUR';
    } else if (produit.toLowerCase().contains('etude')) {
      return 'CORIS ÉTUDE';
    } else if (produit.toLowerCase().contains('retraite')) {
      return 'CORIS RETRAITE';
    } else if (produit.toLowerCase().contains('serenite')) {
      return 'CORIS SÉRÉNITÉ';
    } else if (produit.toLowerCase().contains('familis')) {
      return 'CORIS FAMILIS';
    } else if (produit.toLowerCase().contains('epargne')) {
      return 'CORIS ÉPARGNE BONUS';
    } else {
      return 'ASSURANCE VIE';
    }
  }

  String _getProductType() {
    return _subscriptionData?['produit_nom'] ?? _subscriptionData?['product_type'] ?? 'Produit inconnu';
  }

  Map<String, dynamic> _getSubscriptionDetails() {
    return _subscriptionData?['souscriptiondata'] ?? {};
  }

  Map<String, dynamic> _getSolidariteData() {
    final details = _getSubscriptionDetails();
    
    final dateEffet = details['date_effet'] ?? _subscriptionData?['date_effet'] ?? _subscriptionData?['date_creation'];
    
    dynamic dateEcheanceCalculee;
    if (dateEffet != null) {
      try {
        DateTime dateEffetDt = _parseDate(dateEffet);
        
        dateEcheanceCalculee = DateTime(
          dateEffetDt.year + 1,
          dateEffetDt.month,
          dateEffetDt.day,
          dateEffetDt.hour,
          dateEffetDt.minute,
          dateEffetDt.second,
        );
        
      } catch (e) {
        developer.log('Erreur calcul date échéance: $e', error: e);
      }
    }
    
    return {
      'capital': details['capital'] ?? _subscriptionData?['capital'] ?? 0,
      'prime_totale': details['prime_totale'] ?? _subscriptionData?['prime_totale'] ?? _subscriptionData?['prime'] ?? 0,
      'periodicite': details['periodicite'] ?? _subscriptionData?['periodicite'] ?? 'Mensuelle',
      'date_effet': dateEffet,
      'date_echeance': details['date_echeance'] ?? _subscriptionData?['date_echeance'] ?? dateEcheanceCalculee,
      'duree_contrat': '1 an',
      'conjoints': _extractMembres(details, 'conjoints'),
      'enfants': _extractMembres(details, 'enfants'),
      'ascendants': _extractMembres(details, 'ascendants'),
    };
  }

  DateTime _parseDate(dynamic dateValue) {
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.parse(dateValue);
    return DateTime.now();
  }

  List<dynamic> _extractMembres(Map<String, dynamic> details, String type) {
    final membres = details[type];
    
    developer.log('=== EXTRACTION MEMBRES $type ===');
    developer.log('Type: $type');
    developer.log('Valeur trouvée: $membres');
    developer.log('Type de la valeur: ${membres?.runtimeType}');
    
    if (membres is List) {
      developer.log('Nombre de membres: ${membres.length}');
      
      for (var i = 0; i < membres.length; i++) {
        developer.log('Membre $i: ${membres[i]}');
        if (membres[i] is Map) {
          developer.log('  Clés du membre: ${membres[i].keys}');
          
          if (!membres[i].containsKey('lien_parente')) {
            if (type == 'conjoints') {
              membres[i]['lien_parente'] = 'Conjoint(e)';
            } else if (type == 'enfants') {
              membres[i]['lien_parente'] = 'Enfant';
            } else if (type == 'ascendants') {
              membres[i]['lien_parente'] = 'Ascendant';
            }
          }
        }
      }
      return membres;
    }
    
    return [];
  }

  Widget _buildProductSection() {
    final productType = _getProductType().toLowerCase();

    if (productType.contains('solidarite')) {
      final solidariteData = _getSolidariteData();
      return _buildSolidariteSection(solidariteData);
    } else if (productType.contains('epargne')) {
      return _buildEpargneSection(_getSubscriptionDetails());
    } else if (productType.contains('etude')) {
      return _buildEtudeSection(_getSubscriptionDetails());
    } else if (productType.contains('familis')) {
      return _buildFamilisSection(_getSubscriptionDetails());
    } else if (productType.contains('emprunteur')) {
      return _buildFlexEmprunteurSection(_getSubscriptionDetails());
    } else if (productType.contains('retraite')) {
      return _buildRetraiteSection(_getSubscriptionDetails());
    } else if (productType.contains('serenite')) {
      return _buildSereniteSection(_getSubscriptionDetails());
    } else {
      return _buildDefaultProductSection(_getSubscriptionDetails());
    }
  }

  Widget _buildSolidariteSection(Map<String, dynamic> data) {
    developer.log('=== DONNÉES FINALES SOLIDARITÉ ===');
    developer.log('Capital: ${data['capital']}');
    developer.log('Prime: ${data['prime_totale']}');
    developer.log('Conjoints: ${data['conjoints']}');
    developer.log('Enfants: ${data['enfants']}');
    developer.log('Ascendants: ${data['ascendants']}');
    developer.log('Date effet: ${data['date_effet']}');
    developer.log('Date échéance: ${data['date_echeance']}');
    developer.log('Conjoints count: ${data['conjoints'].length}');
    developer.log('Enfants count: ${data['enfants'].length}');
    developer.log('Ascendants count: ${data['ascendants'].length}');

    final capital = data['capital'] ?? 0;
    final primeTotale = data['prime_totale'] ?? 0;
    final periodicite = data['periodicite'] ?? 'Non définie';
    final conjoints = data['conjoints'] ?? [];
    final enfants = data['enfants'] ?? [];
    final ascendants = data['ascendants'] ?? [];

    return _buildRecapSection(
      'Produit Souscrit',
      Icons.people_outline,
      const Color(0xFF10B981),
      [
        _buildCombinedRecapRow('Produit', 'CORIS SOLIDARITÉ', 'Périodicité', periodicite),
        _buildCombinedRecapRow('Capital garanti', _formatMontant(capital), 'Prime totale', _formatMontant(primeTotale)),
        
        if (conjoints.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildMembresSection('Conjoint(s)', Icons.people_outline, conjoints),
        ],
        
        if (enfants.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildMembresSection('Enfant(s)', Icons.child_care_outlined, enfants),
        ],
        
        if (ascendants.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildMembresSection('Ascendant(s)', Icons.elderly_outlined, ascendants),
        ],

        if (conjoints.isEmpty && enfants.isEmpty && ascendants.isEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECDCA)),
            ),
            child: const Text(
              'Aucun membre ajouté à cette souscription',
              style: TextStyle(
                color: Color(0xFFD92D20),
                fontSize: 12,
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        _buildCombinedRecapRow(
          'Date d\'effet', 
          _formatDate(data['date_effet']),
          'Date d\'échéance', 
          _formatDate(data['date_echeance']),
        ),
      ], 
    );
  }

  Widget _buildMembresSection(String titre, IconData icone, List<dynamic> membres) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, size: 16, color: const Color(0xFF002B6B)),
            const SizedBox(width: 8),
            Text(
              titre,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF002B6B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...membres.map((membre) => _buildMembreRecap(membre)),
      ],
    );
  }

  Widget _buildMembreRecap(dynamic membre) {
    developer.log('=== CONSTRUCTION MEMBRE ===');
    developer.log('Données membre: $membre');
    developer.log('Type: ${membre.runtimeType}');

    final nomPrenom = membre['nom_prenom'] ?? 'Non renseigné';
    final dateNaissance = membre['date_naissance'] ?? membre['birthDate'] ?? membre['dateNaissance'];
    
    String lienParente = '';
    if (membre.containsKey('lien_parente')) {
      lienParente = membre['lien_parente'] ?? '';
    } else {
      lienParente = 'Membre assuré';
    }

    developer.log('Nom complet extrait: $nomPrenom');
    developer.log('Date naissance: $dateNaissance');
    developer.log('Lien parenté: $lienParente');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nomPrenom,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          if (lienParente.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Relation: $lienParente',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
          if (dateNaissance != null) ...[
            const SizedBox(height: 4),
            Text(
              'Né(e) le: ${_formatDate(dateNaissance)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEpargneSection(Map<String, dynamic> data) {
    return _buildRecapSection(
      'Produit Souscrit',
      Icons.savings_outlined,
      const Color(0xFF10B981),
      [
        _buildRecapRow('Produit', 'CORIS ÉPARGNE BONUS'),
        _buildRecapRow('Capital au terme', _formatMontant(data['capital'])),
        _buildRecapRow('Prime mensuelle', _formatMontant(data['prime_mensuelle'])),
        _buildRecapRow('Durée', '15 ans (180 mois)'),
        _buildRecapRow('Date d\'effet', _formatDate(data['date_effet'])),
        _buildRecapRow('Date de fin', _formatDate(data['date_fin'])),
        _buildRecapRow('Bonus', _getBonusText(data)),
      ],
    );
  }

  String _getBonusText(Map<String, dynamic> data) {
    final capital = data['capital'] ?? 0;
    if (capital >= 6000000) return '+ 15% de bonus au terme';
    if (capital >= 4000000) return '+ 10% de bonus au terme';
    if (capital >= 2000000) return '+ 7% de bonus au terme';
    return '+ 5% de bonus au terme';
  }

  Widget _buildEtudeSection(Map<String, dynamic> data) {
    final mode = data['mode_souscription'] ?? 'Mode Prime';
    final prime = data['prime_calculee'] ?? data['prime'];
    final rente = data['rente_calculee'] ?? data['rente'];

    return _buildRecapSection(
      'Produit Souscrit',
      Icons.school_outlined,
      const Color(0xFF10B981),
      [
        _buildCombinedRecapRow('Produit', 'CORIS ÉTUDE', 'Mode', mode),
        
        if (mode == 'Mode Rente') ...[
          _buildCombinedRecapRow('Rente au terme', _formatMontant(rente), 'Prime ${data['periodicite']}', _formatMontant(prime)),
        ] else ...[
          _buildCombinedRecapRow('Prime ${data['periodicite']}', _formatMontant(prime), 'Rente au terme', _formatMontant(rente)),
        ],
        
        _buildCombinedRecapRow('Durée', '${data['duree_mois'] != null ? (data['duree_mois'] ~/ 12) : data['age_enfant']} ans', 'Périodicité', data['periodicite'] ?? 'Non définie'),
        _buildCombinedRecapRow(
          'Date d\'effet', 
          _formatDate(data['date_effet']),
          'Date d\'échéance', 
          _formatDate(data['date_echeance'])
        ),
      ],
    );
  }

  Widget _buildFamilisSection(Map<String, dynamic> data) {
    final duree = data['duree'] ?? 'Non définie';
    final capital = data['capital'] ?? 0;
    final prime = data['prime'] ?? data['prime_calculee'] ?? 0;

    return _buildRecapSection(
      'Produit Souscrit',
      Icons.family_restroom_outlined,
      const Color(0xFF10B981),
      [
        _buildCombinedRecapRow('Produit', 'CORIS FAMILIS', 'Durée', '$duree années'),
        _buildCombinedRecapRow(
          'Prime ${data['periodicite'] == 'unique' ? 'unique' : 'annuelle'}', 
          _formatMontant(prime), 
          'Capital à garantir', 
          _formatMontant(capital)
        ),
        _buildCombinedRecapRow(
          'Date d\'effet', 
          _formatDate(data['date_effet']), 
          'Date d\'échéance', 
          _formatDate(data['date_echeance'])
        ),
      ],
    );
  }

  Widget _buildFlexEmprunteurSection(Map<String, dynamic> data) {
    return _buildRecapSection(
      'Produit Souscrit',
      Icons.home_outlined,
      const Color(0xFF10B981),
      [
        _buildCombinedRecapRow('Produit', 'FLEX EMPRUNTEUR', 'Type de prêt', data['type_pret'] ?? 'Non défini'),
        _buildCombinedRecapRow('Capital à garantir', _formatMontant(data['capital']), 'Durée', '${data['duree']} ${data['duree_type']}'),
        if (data['date_effet'] != null && data['date_echeance'] != null)
          _buildCombinedRecapRow('Date d\'effet', _formatDate(data['date_effet']), 'Date d\'échéance', _formatDate(data['date_echeance'])),
        if (data['date_effet'] != null && data['date_echeance'] == null)
          _buildCombinedRecapRow('Date d\'effet', _formatDate(data['date_effet']), '', ''),
        if (data['date_effet'] == null && data['date_echeance'] != null)
          _buildCombinedRecapRow('Date d\'échéance', _formatDate(data['date_echeance']), '', ''),
        _buildCombinedRecapRow('Prime annuelle estimée', _formatMontant(data['prime_annuelle']), '', ''),
        if (data['garantie_prevoyance'] == true && data['garantie_perte_emploi'] == true)
          _buildCombinedRecapRow('Garantie Prévoyance', _formatMontant(data['capital_prevoyance']), 'Garantie Perte d\'emploi', _formatMontant(data['capital_perte_emploi'])),
        if (data['garantie_prevoyance'] == true && data['garantie_perte_emploi'] != true)
          _buildCombinedRecapRow('Garantie Prévoyance', _formatMontant(data['capital_prevoyance']), '', ''),
        if (data['garantie_prevoyance'] != true && data['garantie_perte_emploi'] == true)
          _buildCombinedRecapRow('Garantie Perte d\'emploi', _formatMontant(data['capital_perte_emploi']), '', ''),
      ],
    );
  }

  Widget _buildRetraiteSection(Map<String, dynamic> data) {
    final duree = data['duree'] ?? 'Non définie';
    
    return _buildRecapSection(
      'Produit Souscrit',
      Icons.savings_outlined,
      const Color(0xFF10B981),
      [
        _buildCombinedRecapRow('Produit', 'CORIS RETRAITE', 'Prime ${data['periodicite']}', _formatMontant(data['prime'])),
        _buildCombinedRecapRow('Capital au terme', _formatMontant(data['capital']), 'Durée du contrat', '$duree ${data['duree_type'] == 'années' ? 'ans' : 'mois'}'),
        _buildCombinedRecapRow(
          'Date d\'effet', 
          _formatDate(data['date_effet']), 
          'Date d\'échéance', 
          _formatDate(data['date_echeance'])
        ),
      ],
    );
  }

  Widget _buildSereniteSection(Map<String, dynamic> data) {
    final duree = data['duree'] ?? 'Non définie';
    
    return _buildRecapSection(
      'Produit Souscrit',
      Icons.health_and_safety_outlined,
      const Color(0xFF10B981),
      [
        _buildCombinedRecapRow('Produit', 'CORIS SÉRÉNITÉ', 'Prime ${data['periodicite']}', _formatMontant(data['prime'])),
        _buildCombinedRecapRow('Capital au terme', _formatMontant(data['capital']), 'Durée du contrat', '$duree ${data['duree_type'] == 'années' ? 'ans' : 'mois'}'),
        _buildCombinedRecapRow(
          'Date d\'effet', 
          _formatDate(data['date_effet']), 
          'Date d\'échéance', 
          _formatDate(data['date_echeance'])
        ),
      ],
    );
  }

  Widget _buildDefaultProductSection(Map<String, dynamic> data) {
    return _buildRecapSection(
      'Produit Souscrit',
      Icons.security_outlined,
      const Color(0xFF10B981),
      [
        _buildRecapRow('Produit', _getBadgeText(_getProductType())),
        _buildRecapRow('Statut', _subscriptionData?['statut'] ?? 'En attente'),
        _buildRecapRow('Date de création', _formatDate(_subscriptionData?['date_creation'] ?? _subscriptionData?['created_at'])),
        
        if (data['capital'] != null)
          _buildRecapRow('Capital', _formatMontant(data['capital'])),
        
        if (data['prime'] != null)
          _buildRecapRow('Prime', _formatMontant(data['prime'])),
        
        if (data['duree'] != null)
          _buildRecapRow('Durée', data['duree'].toString()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B6B)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Chargement des détails...",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: const Color(0xFF002B6B),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Erreur de chargement",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadSubscriptionData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002B6B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final badgeColor = _getBadgeColor(_getProductType());
    
    // CORRECTION: Utilisation de Color.alphaBlend au lieu de withOpacity
    final badgeColorWithOpacity = Color.alphaBlend(
      badgeColor.withAlpha((255 * 0.8).round()),
      Colors.transparent,
    );

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: badgeColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                badgeColor,
                badgeColorWithOpacity,
              ],
            ),
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.propositionNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              _getBadgeText(_getProductType()),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // CORRECTION: Utilisation de couleurs prédéfinies avec opacité
          color: const Color.fromRGBO(255, 255, 255, 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.2),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            // CORRECTION: Utilisation de couleurs prédéfinies avec opacité
            color: const Color.fromRGBO(255, 255, 255, 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 20),
            onPressed: _shareProposition,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildUserInfoCard(),
          const SizedBox(height: 16),
          _buildProductSection(),
          const SizedBox(height: 16),
          _buildBeneficiariesCard(),
          const SizedBox(height: 16),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informations Personnelles",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildCombinedRecapRow('Civilité', _userData?['civilite'] ?? 'Non renseigné', 'Nom', _userData?['nom'] ?? 'Non renseigné'),
            _buildCombinedRecapRow('Prénom', _userData?['prenom'] ?? 'Non renseigné', 'Email', _userData?['email'] ?? 'Non renseigné'),
            _buildCombinedRecapRow('Téléphone', _userData?['telephone'] ?? 'Non renseigné', 'Date de naissance', _formatDate(_userData?['date_naissance'])),
            _buildCombinedRecapRow('Lieu de naissance', _userData?['lieu_naissance'] ?? 'Non renseigné', 'Adresse', _userData?['adresse'] ?? 'Non renseigné'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  // CORRECTION: Utilisation de withAlpha au lieu de withOpacity
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRecapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedRecapRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label1 :',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                Text(
                  value1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label2 :',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                Text(
                  value2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiariesCard() {
    final subscriptionData = _getSubscriptionDetails();
    final beneficiaire = subscriptionData['beneficiaire'];
    final contactUrgence = subscriptionData['contact_urgence'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bénéficiaires et Contacts",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),

            if (beneficiaire != null) ...[
              _buildContactItem(
                "Bénéficiaire",
                beneficiaire['nom'] ?? 'Non spécifié',
                beneficiaire['lien_parente'] ?? 'Bénéficiaire',
                beneficiaire['contact'],
                Icons.person_outline,
              ),
              const SizedBox(height: 12),
            ],

            if (contactUrgence != null) ...[
              _buildContactItem(
                "Contact d'urgence",
                contactUrgence['nom'] ?? 'Non spécifié',
                contactUrgence['lien_parente'] ?? 'Contact',
                contactUrgence['contact'],
                Icons.contact_phone_outlined,
              ),
            ],

            if (beneficiaire == null && contactUrgence == null) ...[
              const Text(
                "Aucun bénéficiaire ou contact spécifié",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String type, String nom, String relation, String? contact, IconData icon) {
    final badgeColor = _getBadgeColor(_getProductType());
    
    // CORRECTION: Utilisation de withAlpha au lieu de withOpacity
    final badgeColorWithAlpha = badgeColor.withAlpha(25);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeColorWithAlpha,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: badgeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nom,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (relation.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    relation,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                if (contact != null && contact.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _rejectProposition,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    foregroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Refuser',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _acceptAndPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getBadgeColor(_getProductType()),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Accepter et Payer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareProposition() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage en cours de développement'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _rejectProposition() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la proposition'),
        content: const Text('Êtes-vous sûr de vouloir refuser cette proposition d\'assurance ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Proposition refusée'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }

  void _acceptAndPay() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Redirection vers le processus de paiement...'),
        backgroundColor: _getBadgeColor(_getProductType()),
      ),
    );
  }
}