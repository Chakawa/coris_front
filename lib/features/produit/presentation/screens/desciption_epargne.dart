import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DescriptionEpargnePage extends StatelessWidget {
  const DescriptionEpargnePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String markdownContent = """
### **CORIS ÉPARGNE** 

**Constituez votre capital à votre rythme et en toute simplicité.**

Le contrat **CORIS ÉPARGNE** est un contrat d'assurance-vie qui vous permet de vous constituer un capital pour vos projets futurs. Que ce soit pour un achat important, un voyage ou simplement pour créer un fonds de sécurité, ce produit d'épargne est la solution idéale pour faire fructifier votre argent sans risque.

**Avantages :**

* **Simplicité :** Un contrat facile à comprendre et à gérer.

* **Sécurité :** Un taux de rendement garanti.

* **Accessibilité :** Des cotisations adaptées à votre budget.

**Idéal pour :** Toute personne souhaitant épargner régulièrement en toute sécurité.
""";

    return Scaffold(
      appBar: AppBar(
        title: const Text('CORIS ÉPARGNE'),
        backgroundColor: const Color(0xFF002B6B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MarkdownBody(
            data: markdownContent,
            styleSheet: MarkdownStyleSheet(
              h3: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE30613),
              ),
              p: const TextStyle(fontSize: 16.0),
              listBullet: const TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}
