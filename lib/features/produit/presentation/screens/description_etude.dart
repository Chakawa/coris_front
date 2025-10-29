import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DescriptionEtudePage extends StatelessWidget {
  const DescriptionEtudePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String markdownContent = """
### **CORIS ÉTUDE** 🎓

**L'avenir de vos enfants commence aujourd'hui.**

Le contrat **CORIS ÉTUDE** est conçu pour vous aider à garantir un avenir scolaire et professionnel serein à vos enfants. Il s'agit d'un plan d'épargne qui vous permet de constituer, à votre rythme, un capital pour couvrir leurs frais de scolarité (école primaire, secondaire, université) ou les aider à démarrer leur vie d'adulte.

**Avantages :**

* **Flexibilité :** Vous choisissez la durée de l'épargne et le montant des cotisations.

* **Sécurité :** Le capital est garanti, même en cas de décès de l'assuré.

* **Rendement :** Votre épargne est valorisée chaque année grâce à un taux d'intérêt attractif.

**Idéal pour :** Les parents qui veulent investir dans l'éducation de leurs enfants.
""";

    return Scaffold(
      appBar: AppBar(
        title: const Text('CORIS ÉTUDE'),
        backgroundColor: const Color(0xFF002B6B), // Couleur Coris Bleu
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
                color: Color(0xFFE30613), // Couleur Coris Rouge
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
