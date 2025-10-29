import 'package:flutter/material.dart';

class HomeSouscriptionPage extends StatelessWidget {
  const HomeSouscriptionPage({super.key}); // ✅ super parameter utilisé

  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color rougeCoris = Color(0xFFE30613);
  static const Color blanc = Colors.white;
  static const Color ombrage = Colors.black;

  final List<Map<String, dynamic>> produits = const [
    {
      'image': 'assets/images/retraitee.png',
      'title': 'CORIS RETRAITE',
      'route': '/souscription_retraite',
    },
    {
      'image': 'assets/images/etudee.png',
      'title': 'CORIS ETUDE',
      'route': '/souscription_etude',
    },
    {
      'image': 'assets/images/serenite.png',
      'title': 'CORIS SERENITE PLUS',
      'route': '/souscription_serenite',
    },
    {
      'image': 'assets/images/solidarite.png',
      'title': 'CORIS SOLIDARITE',
      'route': '/souscription_solidarite',
    },
    {
      'image': 'assets/images/emprunteur.png',
      'title': 'FLEX EMPRUNTEUR',
      'route': '/souscription_emprunteur',
    },
    {
      'image': 'assets/images/familis.png',
      'title': 'CORIS FAMILIS',
      'route': '/souscription_familis',
    },
    {
      'image': 'assets/images/prets.png',
      'title': 'PRETS SCOLAIRE',
      'route': '/souscription_prets',
    },
    {
      'image': 'assets/images/epargnee.png',
      'title': 'CORIS EPARGNE BONUS',
      'route': '/souscription_epargne',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildProductsSection(context),
              const SizedBox(height: 30),
              _buildAssistanceSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// ----------- APPBAR ---------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bleuCoris,
      elevation: 2,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Souscription Produits",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bleuCoris, Color.fromRGBO(0, 43, 107, 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  /// ----------- HEADER CARD ---------------
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bleuCoris,
              bleuCoris.withValues(alpha: 0.8), // ✅ remplacé
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bleuCoris.withValues(alpha: 0.25), // ✅ remplacé
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: ombrage.withValues(alpha: 0.05), // ✅ remplacé
              spreadRadius: 0,
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: blanc.withValues(alpha: 0.15), // ✅ remplacé
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: blanc.withValues(alpha: 0.2), // ✅ remplacé
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.diamond_outlined,
                size: 32,
                color: blanc,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Solutions d\'assurance sur mesure',
              style: TextStyle(
                color: blanc,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Découvrez nos produits conçus pour répondre à vos besoins\net protéger votre avenir',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blanc.withValues(alpha: 0.9), // ✅ remplacé
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.3,
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
                    color: Colors.black.withValues(alpha: 0.05), // ✅ remplacé
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
              Colors.grey[100]!.withValues(alpha: 0.8), // ✅ remplacé
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rougeCoris.withValues(alpha: 0.15), // ✅ remplacé
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: rougeCoris.withValues(alpha: 0.08), // ✅ remplacé
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), // ✅ remplacé
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rougeCoris.withValues(alpha: 0.1), // ✅ remplacé
                    rougeCoris.withValues(alpha: 0.05), // ✅ remplacé
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: rougeCoris.withValues(alpha: 0.2), // ✅ remplacé
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.support_agent,
                color: rougeCoris,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Appeler un Conseiller",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: bleuCoris,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Nos conseillers sont à votre écoute",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rougeCoris,
                    rougeCoris.withValues(alpha: 0.8), // ✅ remplacé
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rougeCoris.withValues(alpha: 0.2), // ✅ remplacé
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.phone, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
