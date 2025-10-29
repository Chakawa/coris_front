import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DescriptionSerenitePage extends StatelessWidget {
  const DescriptionSerenitePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String markdownContent = """
### **CORIS SÉRÉNITÉ PLUS**

**L'épargne-retraite flexible et performante pour construire votre avenir en toute sérénité.**

---

#### **Présentation du produit**

**CORIS SÉRÉNITÉ PLUS** est bien plus qu'un simple contrat d'épargne. C'est une solution financière innovante qui allie la sécurité d'un capital garanti à la flexibilité d'une épargne modulable. Conçu spécifiquement pour répondre aux besoins des épargnants avisés, ce contrat vous accompagne dans la préparation de votre retraite ou la réalisation de vos projets les plus ambitieux.

Grâce à sa structure unique, CORIS SÉRÉNITÉ PLUS s'adapte parfaitement à l'évolution de votre situation personnelle et professionnelle, vous offrant la liberté de moduler vos versements selon vos capacités financières du moment.

#### **Caractéristiques principales**

**🔒 Sécurité absolue**
- Capital 100% garanti à tout moment
- Protection totale de vos versements initiaux
- Couverture assurée par des organismes de renom

**📈 Rendement optimisé**
- Taux d'intérêt compétitif et attractif sur le marché
- Participation aux bénéfices de la compagnie d'assurance
- Revalorisation annuelle de votre capital

**⚡ Flexibilité maximale**
- Versements libres selon vos possibilités
- Possibilité d'effectuer des versements exceptionnels
- Adaptation aux variations de vos revenus
- Suspension temporaire possible sans pénalités

#### **Avantages exclusifs**

**💰 Avantages financiers**
* **Rendement supérieur** : Votre épargne bénéfie d'un taux d'intérêt particulièrement avantageux, supérieur aux livrets classiques
* **Capitalisation** : Les intérêts générés sont automatiquement réinvestis pour maximiser votre capital
* **Transparence totale** : Suivi en temps réel de l'évolution de votre épargne

**🎯 Avantages fiscaux**
* **Optimisation fiscale** : Bénéficiez d'avantages fiscaux selon la législation en vigueur
* **Défiscalisation** : Possibilité de déduction des versements dans certaines conditions
* **Transmission facilitée** : Conditions avantageuses pour la transmission de votre patrimoine

**🛡️ Sécurité et garanties**
* **Capital protégé** : Aucun risque de perte sur le montant de vos cotisations
* **Garantie décès** : Protection de vos proches en cas de décès
* **Stabilité** : Produit adossé à des actifs sécurisés et diversifiés

#### **Public cible**

**CORIS SÉRÉNITÉ PLUS** s'adresse particulièrement à :

**👥 Profils d'épargnants**
- Actifs souhaitant préparer leur retraite de manière progressive
- Personnes avec des revenus variables recherchant la flexibilité
- Épargnants prudents privilégiant la sécurité du capital
- Investisseurs débutants souhaitant se familiariser avec l'épargne long terme

**🎯 Objectifs patrimoniaux**
- Constitution d'un complément de retraite substantiel
- Financement de projets d'envergure (acquisition immobilière, études des enfants)
- Création d'une réserve financière sécurisée
- Optimisation de la transmission patrimoniale

#### **Modalités pratiques**

**💳 Versements**
- **Montant minimum** : Accessible dès 50€ par mois
- **Versements libres** : De 100€ à 50 000€ selon vos capacités
- **Périodicité flexible** : Mensuel, trimestriel, semestriel ou annuel
- **Versements exceptionnels** : Possibilité d'effectuer des versements ponctuels importants

**📊 Gestion et suivi**
- Interface en ligne dédiée pour le suivi de votre contrat
- Relevés périodiques détaillés
- Conseils personnalisés de nos experts
- Service client dédié et réactif

**🏆 Pourquoi choisir CORIS SÉRÉNITÉ PLUS ?**

Dans un environnement financier en constante évolution, CORIS SÉRÉNITÉ PLUS représente la solution idéale pour tous ceux qui souhaitent concilier performance et sécurité. Ce produit d'épargne nouvelle génération vous offre la possibilité de construire votre avenir financier en toute confiance, avec la garantie d'un accompagnement professionnel de qualité.

*Investir dans CORIS SÉRÉNITÉ PLUS, c'est faire le choix d'une épargne intelligente, flexible et sécurisée.*
""";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF002B6B),
        foregroundColor: Colors.white,
        title: const Text(
          'CORIS SÉRÉNITÉ PLUS',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF002B6B), Color(0xFF1e3c72)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF002B6B), Color(0xFF1e3c72)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 48.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE30613),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: const Text(
                        'PRODUIT PHARE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Icon(
                      Icons.security_outlined,
                      size: 48.0,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Votre épargne en toute confiance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Main Content
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: MarkdownBody(
                  data: markdownContent,
                  styleSheet: MarkdownStyleSheet(
                    // Titres principaux
                    h3: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002B6B),
                      height: 1.3,
                    ),
                    // Sous-titres
                    h4: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF002B6B),
                      height: 1.4,
                    ),
                    // Paragraphes
                    p: const TextStyle(
                      fontSize: 16.0,
                      height: 1.6,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w400,
                    ),
                    // Texte en gras
                    strong: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF002B6B),
                    ),
                    // Puces de liste
                    listBullet: const TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFFE30613),
                      fontWeight: FontWeight.bold,
                    ),
                    // Éléments de liste
                    
                    // Séparateur horizontal
                    horizontalRuleDecoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 2.0,
                        ),
                      ),
                    ),
                    // Code inline (pour les emojis)
                    code: const TextStyle(
                      backgroundColor: Colors.transparent,
                      color: Color(0xFFE30613),
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            
            // Call to Action Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[100]!,
                    Colors.grey[50]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Prêt à commencer votre épargne ?',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF002B6B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Action pour souscrire
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE30613),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 2.0,
                          ),
                          child: const Text(
                            'SOUSCRIRE MAINTENANT',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Action pour plus d'informations
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF002B6B),
                            side: const BorderSide(
                              color: Color(0xFF002B6B),
                              width: 2.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'PLUS D\'INFOS',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}