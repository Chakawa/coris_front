import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycorislife/services/subscription_service.dart';
import 'package:mycorislife/models/subscription.dart';
import 'package:mycorislife/features/client/presentation/screens/proposition_detail_page.dart';

class PropositionsPage extends StatefulWidget {
  const PropositionsPage({super.key});

  @override
  State<PropositionsPage> createState() => _PropositionsPageState();
}

class _PropositionsPageState extends State<PropositionsPage> with TickerProviderStateMixin {
  final SubscriptionService _service = SubscriptionService();
  List<Subscription> propositions = [];
  bool isLoading = true;
  String selectedFilter = 'Tous';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadPropositions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPropositions() async {
    try {
      final result = await _service.getPropositions();
      if (!mounted) return;
      
      setState(() {
        propositions = result;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  String _formatDate(dynamic dateValue) {
    try {
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

  String _getPropositionNumber(int index) {
    return "2025-13-CA${(index + 7075).toString().padLeft(3, '0')}";
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
      return const Color(0xFFF59E0B);
    } else if (produit.toLowerCase().contains('familis')) {
      return const Color(0xFFEC4899);
    } else {
      return const Color(0xFF002B6B); 
    }
  }

  LinearGradient _getBadgeGradient(String produit) {
    final Color primary = _getBadgeColor(produit);
    final Color secondary = Color.lerp(primary, Colors.white, 0.1)!;
    
    return LinearGradient(
      colors: [primary, secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
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
    } else {
      return 'ÉPARGNE BONUS';
    }
  }

  IconData _getProductIcon(String produit) {
    if (produit.toLowerCase().contains('solidarite')) {
      return Icons.people_outline;
    } else if (produit.toLowerCase().contains('emprunteur')) {
      return Icons.home_outlined;
    } else if (produit.toLowerCase().contains('etude')) {
      return Icons.school_outlined;
    } else if (produit.toLowerCase().contains('retraite')) {
      return Icons.savings_outlined;
    } else if (produit.toLowerCase().contains('serenite')) {
      return Icons.health_and_safety_outlined;
    } else if (produit.toLowerCase().contains('familis')) {
      return Icons.family_restroom_outlined;
    } else {
      return Icons.security_outlined;
    }
  }

  List<Subscription> get filteredPropositions {
    if (selectedFilter == 'Tous') {
      return propositions;
    }
    return propositions.where((sub) => 
      _getBadgeText(sub.produitNom) == selectedFilter
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(),
      body: isLoading
          ? _buildLoadingState()
          : propositions.isEmpty
              ? _buildEmptyState()
              : _buildPropositionsContent(),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF002B6B),
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF002B6B),
              Color(0xFF003A85),
            ],
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Mes Propositions",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            "${propositions.length} proposition${propositions.length > 1 ? 's' : ''}",
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Color(0xCCFFFFFF),
            ),
          ),
        ],
      ),
      leading: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0x33FFFFFF),
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
          margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0x26FFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0x33FFFFFF),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.white, size: 20),
            onPressed: _showFilterMenu,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002B6B)),
          ),
          SizedBox(height: 16),
          Text(
            "Chargement des propositions...",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 64,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Aucune proposition",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Vos propositions d'assurance apparaîtront ici",
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

  Widget _buildPropositionsContent() {
    return Column(
      children: [
        if (selectedFilter != 'Tous') _buildFilterChip(),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildPropositionsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF002B6B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedFilter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => selectedFilter = 'Tous'),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropositionsList() {
    final filtered = filteredPropositions;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildModernPropositionCard(filtered[index], index),
          );
        },
      ),
    );
  }

  Widget _buildModernPropositionCard(Subscription subscription, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handlePropositionTap(subscription),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec icône et numéro
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: _getBadgeGradient(subscription.produitNom),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getProductIcon(subscription.produitNom),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPropositionNumber(index),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(subscription.produitNom).withAlpha(26),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getBadgeText(subscription.produitNom),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getBadgeColor(subscription.produitNom),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Footer avec informations
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Créé le ${_formatDate(subscription.dateCreation)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Bouton "Payer maintenant" simplifié
                      ElevatedButton(
                        onPressed: () => _handlePayment(subscription),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002B6B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(0, 28),
                        ),
                        child: const Text(
                          'Payer maintenant',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePropositionTap(Subscription subscription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropositionDetailPage(
          subscriptionId: subscription.id,
          propositionNumber: _getPropositionNumber(propositions.indexOf(subscription)),
        ),
      ),
    );
  }

  void _handlePayment(Subscription subscription) {
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.payment,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Text("Redirection vers le paiement..."),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFilterMenu() {
    final filters = [
      'Tous', 
      'CORIS SOLIDARITÉ', 
      'FLEX EMPRUNTEUR', 
      'CORIS ÉTUDE', 
      'CORIS RETRAITE',
      'CORIS SÉRÉNITÉ',
      'CORIS FAMILIS'
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Filtrer par type",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            ...filters.map((filter) => ListTile(
              leading: filter == 'Tous' 
                  ? const Icon(Icons.list_alt, color: Color(0xFF64748B))
                  : Icon(
                      filter == selectedFilter 
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: filter == selectedFilter 
                          ? const Color(0xFF002B6B)
                          : const Color(0xFF64748B),
                    ),
              title: Text(
                filter,
                style: TextStyle(
                  color: filter == selectedFilter 
                      ? const Color(0xFF002B6B)
                      : const Color(0xFF0F172A),
                  fontWeight: filter == selectedFilter 
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
              onTap: () {
                setState(() => selectedFilter = filter);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}