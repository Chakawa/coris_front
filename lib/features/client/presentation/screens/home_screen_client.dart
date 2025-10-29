import 'package:flutter/material.dart';

import 'home_content.dart';
import 'mes_propositions_page.dart';
import 'mes_contrats_page.dart';
import 'profil_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Couleurs de la charte graphique
  static const rougeCoris = Color(0xFFE30613);

  // Liste des widgets pour chaque onglet de la barre de navigation
  static const List<Widget> _pages = <Widget>[
    HomeContent(),        // Onglet 0: Accueil
    PropositionsPage(),   // Onglet 1: Propositions
    SizedBox.shrink(),    // Onglet 2: Placeholder pour Simuler
    ContratsPage(),       // Onglet 3: Contrats
    ProfilPage(),         // Onglet 4: Profil
  ];

  void _onItemTapped(int index) {
    // Cas spécial pour le bouton "Simuler" qui navigue vers une autre page
    if (index == 2) {
      Navigator.pushNamed(context, '/simulation');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // L'AppBar est maintenant spécifique à chaque page pour plus de flexibilité
      // Nous la retirons d'ici et la plaçons dans chaque page respective.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: rougeCoris,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 24),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded, size: 24),
            label: "Propositions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate, size: 24),
            label: "Simuler",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_rounded, size: 24),
            label: "Contrats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 24),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}