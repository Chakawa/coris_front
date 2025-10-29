import 'package:flutter/material.dart';
import 'package:mycorislife/features/auth/presentation/screens/login_screen.dart';
import 'package:mycorislife/features/auth/presentation/screens/register_screen.dart';
import 'package:mycorislife/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:mycorislife/features/client/presentation/screens/home_screen_client.dart';
import 'package:mycorislife/features/commercial/presentation/screens/commercial_home_screen.dart';
import 'package:mycorislife/features/produit/presentation/screens/produits_screen.dart';
import 'package:mycorislife/features/simulation/presentation/screens/simulation_etude_screen.dart';
import 'package:mycorislife/features/simulation/presentation/screens/simulation_retraite_screen.dart';
import 'package:mycorislife/features/simulation/presentation/screens/simulation_serenite_screen.dart';
import 'package:mycorislife/features/simulation/presentation/screens/simulation_solidarite_screen.dart';
import 'package:mycorislife/features/simulation/presentation/screens/simulation_familis_screen.dart';
import 'package:mycorislife/features/simulation/presentation/screens/flex_emprunteur_page.dart';
import 'package:mycorislife/features/client/presentation/screens/profil_screen.dart';
import 'package:mycorislife/features/souscription/presentation/screens/home_souscription.dart';
import 'package:mycorislife/features/souscription/presentation/screens/mes_propositions_screen.dart';
import 'package:mycorislife/features/souscription/presentation/screens/recap_proposition_screen.dart.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_epargne.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_etude.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_familis.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_flex.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_prets_scolaire.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_retraite.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_serenite.dart';
import 'package:mycorislife/features/souscription/presentation/screens/sousription_solidarite.dart';
import 'package:mycorislife/features/produit/presentation/screens/desciption_epargne.dart';
import 'package:mycorislife/features/produit/presentation/screens/desciption_retraite.dart';
import 'package:mycorislife/features/produit/presentation/screens/description_solidarite.dart';
import 'package:mycorislife/features/produit/presentation/screens/description_familis.dart';
import 'package:mycorislife/features/produit/presentation/screens/description_serenite.dart';
import 'package:mycorislife/features/produit/presentation/screens/description_flex.dart';
import 'package:mycorislife/features/produit/presentation/screens/description_etude.dart';
import 'package:mycorislife/features/produit/presentation/screens/description_prets.dart';
import 'package:mycorislife/features/commercial/presentation/screens/profile_commercial.dart';
import 'package:mycorislife/features/souscription/presentation/screens/recap.dart';
import 'package:mycorislife/models/subscription.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // public
  '/': (context) => const LoginScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/reset_password': (context) => const ResetPasswordScreen(),

  // client route
  '/client_home': (context) => const HomePage(),
  '/clientHome': (context) => HomePage(),

  // Simulations Client
  '/simulation_etude': (context) => const SimulationEtudeScreen(),
  '/simulation_retraite': (context) => const CorisRetraiteScreen(),
  '/simulation_emprunteur': (context) => const FlexEmprunteurPage(),
  '/simulation_serenite': (context) => const SimulationSereniteScreen(),
  '/simulation_solidarite': (context) => const SolidariteSimulationPage(),
  '/simulation_familis': (context) => const SimulationFamilisScreen(),
  '/simulation': (context) => ProduitsPage(),

  // Souscriptions Client
  '/souscription': (context) => HomeSouscriptionPage(),
  '/souscription_epargne': (context) => SouscriptionEpargnePage(),
  '/souscription_etude': (context) => SouscriptionEtudePage(),
  '/souscription_familis': (context) => SouscriptionFamilisPage(),
  '/souscription_emprunteur': (context) => SouscriptionFlexPage(),
  '/souscription_prets': (context) => const SouscriptionPretsScolairePage(),
  '/souscription_retraite': (context) => SouscriptionRetraitePage(),
  '/souscription_serenite': (context) => SouscriptionSerenitePage(),
  '/souscription_solidarite': (context) => const SouscriptionSolidaritePage(),

  // commercial route
  '/commercial_home': (context) => const CommercialHomePage(),
  '/commercialHome': (context) => CommercialHomePage(),
  '/profileCommercial': (context) => CommercialProfile(),

  // description
  '/produits': (context) => HomeSouscriptionPage(),
  '/serenite': (context) => const DescriptionSerenitePage(),
  '/solidarite': (context) => const DescriptionSolidaritePage(),
  '/flex': (context) => const DescriptionFlexPage(),
  '/prets': (context) => const DescriptionPretsPage(),
  '/familis': (context) => const DescriptionFamilisPage(),
  '/etude': (context) => const DescriptionEtudePage(),
  '/retraite': (context) => const DescriptionRetraitePage(),
  '/epargne': (context) => const DescriptionEpargnePage(),

  // profil
  '/profile': (context) => const ProfilPage(),
  '/commercial-profile': (context) => const CommercialProfile(),

  // Mes propositions
  '/mes-propositions': (context) => const MesPropositionsPage(),

  // Récapitulatif proposition - CORRIGÉ
  '/recap-proposition': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return RecapPropositionScreen(
      proposition: args['proposition'] as Subscription,
      isFromList: args['isFromList'] as bool? ?? true,
    );
  },
};