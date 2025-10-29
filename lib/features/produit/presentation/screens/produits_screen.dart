import 'package:flutter/material.dart';

class ProduitsPage extends StatelessWidget {
  const ProduitsPage({super.key}); // ✅ super paramètre moderne

  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color rougeCoris = Color(0xFFE30613);
  static const Color blanc = Colors.white;
  static const Color ombrage = Colors.black;

  final List<Map<String, dynamic>> produits = const [
    {
      'image': 'assets/images/retraitee.png',
      'title': 'CORIS RETRAITE',
      'route': '/simulation_retraite',
    },
    {
      'image': 'assets/images/etudee.png',
      'title': 'CORIS ETUDE',
      'route': '/simulation_etude',
    },
    {
      'image': 'assets/images/serenite.png',
      'title': 'CORIS SERENITE PLUS',
      'route': '/simulation_serenite',
    },
    {
      'image': 'assets/images/solidarite.png',
      'title': 'CORIS SOLIDARITE',
      'route': '/simulation_solidarite',
    },
    {
      'image': 'assets/images/emprunteur.png',
      'title': 'FLEX EMPRUNTEUR',
      'route': '/simulation_emprunteur',
    },
    {
      'image': 'assets/images/familis.png',
      'title': 'CORIS FAMILIS',
      'route': '/simulation_familis',
    },
  ];

  /// ----------- HEADER MODERNE ---------------
  Widget _buildModernHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bleuCoris,
            bleuCoris.withValues(alpha: 0.85), // ✅ corrigé
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: bleuCoris.withValues(alpha: 0.3), // ✅ corrigé
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Nos Produits",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ----------- CARD BLEUE ---------------
  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bleuCoris,
              Color.fromARGB(255, 0, 60, 140), // cette ligne reste valide
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: bleuCoris.withValues(alpha: 0.25), // ✅ corrigé
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: ombrage.withValues(alpha: 0.05), // ✅ corrigé
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: blanc.withValues(alpha: 0.15), // ✅ corrigé
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: blanc.withValues(alpha: 0.2), // ✅ corrigé
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.calculate_outlined,
                size: 36,
                color: blanc,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simulation Personnalisée',
                    style: TextStyle(
                      color: blanc,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Découvrez la solution qui vous correspond avec notre outil de simulation avancé',
                    style: TextStyle(
                      color: blanc.withValues(alpha: 0.9), // ✅ corrigé
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ----------- SECTION PRODUITS ---------------
  Widget _buildProductsSection(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(maxWidth: 600),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.8,
        ),
        itemCount: produits.length,
        itemBuilder: (context, index) {
          final produit = produits[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, produit['route']),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), // ✅ corrigé
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    produit['image'],
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 32, color: bleuCoris);
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      produit['title'],
                      style: TextStyle(
                        fontSize: screenWidth * 0.028,
                        fontWeight: FontWeight.w600,
                        color: bleuCoris,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ----------- SECTION ASSISTANCE ---------------
  Widget _buildAssistanceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey[50]!,
              Colors.grey[100]!.withValues(alpha: 0.8), // ✅ corrigé
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rougeCoris.withValues(alpha: 0.15), // ✅ corrigé
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: rougeCoris.withValues(alpha: 0.08), // ✅ corrigé
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), // ✅ corrigé
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rougeCoris.withValues(alpha: 0.1), // ✅ corrigé
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: rougeCoris.withValues(alpha: 0.2), // ✅ corrigé
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.support_agent,
                color: rougeCoris,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Appeler un Conseiller",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: bleuCoris,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Nos conseillers sont à votre écoute",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    rougeCoris,
                    rougeCoris.withValues(alpha: 0.8), // ✅ corrigé
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rougeCoris.withValues(alpha: 0.3), // ✅ corrigé
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.phone, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildModernHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 10),
                  _buildProductsSection(context),
                  const SizedBox(height: 30),
                  _buildAssistanceSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
