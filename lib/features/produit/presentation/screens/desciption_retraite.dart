import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DescriptionRetraitePage extends StatelessWidget {
  const DescriptionRetraitePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String markdownContent = """
### **CORIS RETRAITE** 

**Préparez votre retraite et profitez pleinement de votre vie.**

Le contrat **CORIS RETRAITE** est un plan d'épargne retraite qui vous permet de vous constituer un capital solide pour votre avenir. Que vous soyez salarié, travailleur indépendant ou entrepreneur, ce produit vous offre la liberté financière de vivre la retraite que vous avez toujours souhaitée.

**Avantages :**

* **Sécurité :** Un capital garanti pour une tranquillité d'esprit totale.

* **Rendement :** Votre épargne fructifie à un taux avantageux.

* **Fiscalité :** Des avantages fiscaux peuvent s'appliquer sur vos cotisations.

**Idéal pour :** Toute personne souhaitant se prémunir contre la perte de revenus après la vie active.
""";

    return Scaffold(
      appBar: AppBar(
        title: const Text('CORIS RETRAITE'),
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
