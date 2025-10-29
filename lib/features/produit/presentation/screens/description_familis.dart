import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DescriptionFamilisPage extends StatelessWidget {
  const DescriptionFamilisPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String markdownContent = """
### **CORIS FAMILIS** 

**L'assurance-vie pour protéger l'avenir de toute votre famille.**

**CORIS FAMILIS** est une assurance-vie complète qui couvre l'ensemble de votre foyer. En cas de décès de l'un des parents, un capital est versé pour aider à subvenir aux besoins des enfants et du conjoint survivant. Ce contrat est une solution de prévoyance qui assure la stabilité financière de votre famille.

**Avantages :**

* **Protection complète :** Une couverture pour toute la famille.

* **Capital garanti :** Un versement sécurisé aux bénéficiaires.

* **Tranquillité :** Une tranquillité d'esprit pour toute la famille.

**Idéal pour :** Les familles qui souhaitent une protection financière globale.
""";

    return Scaffold(
      appBar: AppBar(
        title: const Text('CORIS FAMILIS'),
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
