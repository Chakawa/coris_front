import 'dart:async';
import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController();
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  static const bleuCoris = Color(0xFF002B6B);
  static const rougeCoris = Color(0xFFE30613);

  final List<Map<String, String>> _carouselData = [
    {
      'title': 'CORIS ETUDE',
      'subtitle': 'Investissez dans l\'éducation',
      'description': 'Financement des études supérieures',
      'image': 'assets/images/etude.png',
      'route': '/etude',
    },
    {
      'title': 'CORIS RETRAITE',
      'subtitle': 'Préparez votre retraite sereinement',
      'description': 'Complément retraite personnalisé',
      'image': 'assets/images/retraite.png',
      'route': '/retraite',
    },
    {
      'title': 'CORIS EPARGNE',
      'subtitle': 'Épargnez intelligemment',
      'description': 'Solutions d\'épargne adaptées à vos besoins',
      'image': 'assets/images/epargne.png',
      'route': '/epargne',
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'image': 'assets/images/serenite.png',
      'title': 'CORIS SERENITE PLUS',
      'route': '/serenite',
    },
    {
      'image': 'assets/images/solidarite.png',
      'title': 'CORIS SOLIDARITE',
      'route': '/solidarite',
    },
    {
      'image': 'assets/images/emprunteur.png',
      'title': 'FLEX EMPRUNTEUR',
      'route': '/flex',
    },
    {
      'image': 'assets/images/prets.png',
      'title': 'PRETS SCOLAIRES',
      'route': '/prets',
    },
    {
      'image': 'assets/images/familis.png',
      'title': 'CORIS FAMILIS',
      'route': '/familis',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentCarouselIndex + 1) % _carouselData.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: bleuCoris,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MyCorisLife',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;
          double carouselHeight = screenHeight * 0.3;
          if (carouselHeight > 250) carouselHeight = 250;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bleuCoris,
                        Color.fromRGBO(0, 43, 107, 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chez l\'assureur qui vous rassure!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: carouselHeight,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                    itemCount: _carouselData.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, _carouselData[index]['route']!);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              children: [
                                Image.asset(
                                  _carouselData[index]['image']!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: screenHeight * 0.05,
                                  left: screenWidth * 0.05,
                                  right: screenWidth * 0.05,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _carouselData[index]['title']!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.06,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _carouselData[index]['subtitle']!,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _carouselData[index]['description']!,
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _carouselData.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentCarouselIndex == index ? rougeCoris : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        
                        Navigator.pushNamed(context, '/souscription');
                      },
                      icon: const Icon(Icons.add_circle_outline, color: bleuCoris, size: 22),
                      label: Text(
                        'Faire une souscription',
                        style: TextStyle(
                          color: bleuCoris,
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: bleuCoris, width: 2),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    'Nos Autres Produits',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: bleuCoris,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, _services[index]['route']);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                _services[index]['image'],
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 32,
                                    color: bleuCoris,
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _services[index]['title'],
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
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}