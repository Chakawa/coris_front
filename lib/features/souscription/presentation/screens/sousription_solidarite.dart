import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mycorislife/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:mycorislife/services/subscription_service.dart'; 

// Couleurs globales
const Color bleuCoris = Color(0xFF002B6B);
const Color rougeCoris = Color(0xFFE30613);
const Color blanc = Colors.white;
const Color fondGris = Color(0xFFF5F7FA);
const Color texteGris = Color(0xFF666666);
const Color grisClair = Color(0xFFE0E0E0);
const Color bleuSecondaire = Color(0xFF1E4A8C);
const Color fondCarte = Color(0xFFF8FAFC);
const Color grisTexte = Color(0xFF64748B);
const Color vertSucces = Color(0xFF10B981);
const Color orangeWarning = Color(0xFFF59E0B);
const Color grisLeger = Color(0xFFF1F5F9);

class Membre {
  String nomPrenom;
  DateTime dateNaissance;

  Membre({required this.nomPrenom, required this.dateNaissance});
}

class SouscriptionSolidaritePage extends StatefulWidget {
  final int? capital;
  final String? periodicite;
  final int? nbConjoints;
  final int? nbEnfants;
  final int? nbAscendants;

  const SouscriptionSolidaritePage({
    super.key,
    this.capital,
    this.periodicite,
    this.nbConjoints,
    this.nbEnfants,
    this.nbAscendants,
  });

  @override
  State<SouscriptionSolidaritePage> createState() => _SouscriptionSolidaritePageState();
}

class _SouscriptionSolidaritePageState extends State<SouscriptionSolidaritePage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  // Données de simulation
  int? selectedCapital;
  String selectedPeriodicite = 'Mensuel';
  int nbConjoints = 1;
  int nbEnfants = 1;
  int nbAscendants = 0;
  double? primeTotaleResult;

  // Données des membres
  List<Membre> conjoints = [];
  List<Membre> enfants = [];
  List<Membre> ascendants = [];

  // Données utilisateur
  Map<String, dynamic> _userData = {};
  final storage = FlutterSecureStorage();
  bool _isLoading = true;

  // Contrôleurs pour l'étape 2 (bénéficiaire et contact d'urgence)
  final TextEditingController _beneficiaireNomController = TextEditingController();
  final TextEditingController _beneficiaireContactController = TextEditingController();
  final TextEditingController _personneContactNomController = TextEditingController();
  final TextEditingController _personneContactTelController = TextEditingController();
  String _selectedLienParente = 'Conjoint(e)';
  String _selectedLienParenteUrgence = 'Conjoint(e)';
  String _selectedBeneficiaireIndicatif = '+221';
  String _selectedContactIndicatif = '+221';
  File? _pieceIdentite;

  final List<String> _lienParenteOptions = [
    'Conjoint(e)',
    'Enfant',
    'Parent',
    'Frère/Soeur',
    'Autre'
  ];

  final List<String> _indicatifs = ['+221', '+223', '+224', '+226', '+227', '+228', '+229', '+225'];

  final periodicites = ['Mensuel', 'Trimestriel', 'Semestriel', 'Annuel'];
  final capitalOptions = [500000, 1000000, 1500000, 2000000];

  final Map<int, Map<String, double>> primeTotaleFamilleBase = {
    500000: {'mensuel': 2699, 'trimestriel': 8019, 'semestriel': 15882, 'annuelle': 31141},
    1000000: {'mensuel': 5398, 'trimestriel': 16038, 'semestriel': 31764, 'annuelle': 62283},
    1500000: {'mensuel': 8097, 'trimestriel': 24057, 'semestriel': 47646, 'annuelle': 93424},
    2000000: {'mensuel': 10796, 'trimestriel': 32076, 'semestriel': 63529, 'annuelle': 124566},
  };
  final Map<int, Map<String, int>> surprimesConjointsSupplementaires = {
    500000: {'mensuel': 860, 'trimestriel': 2555, 'semestriel': 5061, 'annuelle': 9924},
    1000000: {'mensuel': 1720, 'trimestriel': 5111, 'semestriel': 10123, 'annuelle': 19848},
    1500000: {'mensuel': 2580, 'trimestriel': 7666, 'semestriel': 15184, 'annuelle': 29773},
    2000000: {'mensuel': 3440, 'trimestriel': 10222, 'semestriel': 20245, 'annuelle': 39697},
  };
  final Map<int, Map<String, int>> surprimesEnfantsSupplementaires = {
    500000: {'mensuel': 124, 'trimestriel': 370, 'semestriel': 732, 'annuelle': 1435},
    1000000: {'mensuel': 249, 'trimestriel': 739, 'semestriel': 1464, 'annuelle': 2870},
    1500000: {'mensuel': 373, 'trimestriel': 1109, 'semestriel': 2196, 'annuelle': 4306},
    2000000: {'mensuel': 498, 'trimestriel': 1478, 'semestriel': 2928, 'annuelle': 5741},
  };
  final Map<int, Map<String, int>> surprimesAscendants = {
    500000: {'mensuel': 1547, 'trimestriel': 4596, 'semestriel': 9104, 'annuelle': 17850},
    1000000: {'mensuel': 3094, 'trimestriel': 9193, 'semestriel': 18207, 'annuelle': 35700},
    1500000: {'mensuel': 4641, 'trimestriel': 13789, 'semestriel': 27311, 'annuelle': 53550},
    2000000: {'mensuel': 6188, 'trimestriel': 18386, 'semestriel': 36414, 'annuelle': 71400},
  };

  Future<void> _loadUserData() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _userData = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement données utilisateur: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Préremplir avec les valeurs de simulation si fournies
    selectedCapital = widget.capital ?? 500000;
    selectedPeriodicite = widget.periodicite ?? 'Mensuel';
    nbConjoints = widget.nbConjoints ?? 1;
    nbEnfants = widget.nbEnfants ?? 1;
    nbAscendants = widget.nbAscendants ?? 0;
    
    // Initialiser les listes de membres
    conjoints = List.generate(nbConjoints, (index) => Membre(nomPrenom: '', dateNaissance: DateTime.now()));
    enfants = List.generate(nbEnfants, (index) => Membre(nomPrenom: '', dateNaissance: DateTime.now()));
    ascendants = List.generate(nbAscendants, (index) => Membre(nomPrenom: '', dateNaissance: DateTime.now()));
    
    // Calculer la prime initiale
    _calculerPrime();
    
    // Charger les données utilisateur
    _loadUserData();
  }

  void _calculerPrime() {
    if (selectedCapital == null) return;

    // Détermine la clé de la périodicité pour les maps de tarifs
    String key = selectedPeriodicite.toLowerCase() == 'annuel'
        ? 'annuelle'
        : selectedPeriodicite.toLowerCase();

    // Calcul de la prime de base et des surprimes
    final double base = primeTotaleFamilleBase[selectedCapital]?[key] ?? 0;
    final int conjointSuppl = (surprimesConjointsSupplementaires[selectedCapital]?[key] ?? 0) *
        (nbConjoints > 1 ? nbConjoints - 1 : 0);
    final int enfantsSuppl = (surprimesEnfantsSupplementaires[selectedCapital]?[key] ?? 0) *
        (nbEnfants > 6 ? nbEnfants - 6 : 0);
    final int ascendantsSuppl = (surprimesAscendants[selectedCapital]?[key] ?? 0) * nbAscendants;

    setState(() {
      primeTotaleResult = base + conjointSuppl + enfantsSuppl + ascendantsSuppl;
    });
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  // MÉTHODES CRITIQUES POUR LE STATUT DE PAIEMENT
  Future<int> _saveSubscriptionData() async {
    try {
      final subscriptionService = SubscriptionService();
      
      // Convertir les listes de membres en format JSON
      final conjointsData = conjoints.map((membre) => {
        'nom_prenom': membre.nomPrenom,
        'date_naissance': membre.dateNaissance.toIso8601String(),
      }).toList();
      
      final enfantsData = enfants.map((membre) => {
        'nom_prenom': membre.nomPrenom,
        'date_naissance': membre.dateNaissance.toIso8601String(),
      }).toList();
      
      final ascendantsData = ascendants.map((membre) => {
        'nom_prenom': membre.nomPrenom,
        'date_naissance': membre.dateNaissance.toIso8601String(),
      }).toList();

      final subscriptionData = {
        'product_type': 'coris_solidarite',
        'capital': selectedCapital,
        'periodicite': selectedPeriodicite.toLowerCase(),
        'prime_totale': primeTotaleResult,
        'nombre_conjoints': nbConjoints,
        'nombre_enfants': nbEnfants,
        'nombre_ascendants': nbAscendants,
        'conjoints': conjointsData,
        'enfants': enfantsData,
        'ascendants': ascendantsData,
        'beneficiaire': {
          'nom': _beneficiaireNomController.text.trim(),
          'contact': '$_selectedBeneficiaireIndicatif ${_beneficiaireContactController.text.trim()}',
          'lien_parente': _selectedLienParente,
        },
        'contact_urgence': {
          'nom': _personneContactNomController.text.trim(),
          'contact': '$_selectedContactIndicatif ${_personneContactTelController.text.trim()}',
          'lien_parente': _selectedLienParenteUrgence,
        },
        'piece_identite': _pieceIdentite?.path.split('/').last ?? '',
        // NE PAS inclure 'status' ici - il sera 'proposition' par défaut dans la base
      };

      final response = await subscriptionService.createSubscription(subscriptionData);
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 201 || !responseData['success']) {
        throw Exception(responseData['message'] ?? 'Erreur lors de la sauvegarde');
      }
      
      // RETOURNER l'ID de la souscription créée
      return responseData['data']['id'];
      
    } catch (e) {
      debugPrint('Erreur sauvegarde souscription: $e');
      rethrow;
    }
  }

  Future<void> _updatePaymentStatus(int subscriptionId, bool paymentSuccess, {String? paymentMethod}) async {
    try {
      final subscriptionService = SubscriptionService();
      final response = await subscriptionService.updatePaymentStatus(
        subscriptionId, 
        paymentSuccess,
        paymentMethod: paymentMethod,
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200 || !responseData['success']) {
        throw Exception(responseData['message'] ?? 'Erreur lors de la mise à jour du statut');
      }
      
      debugPrint('Statut mis à jour: ${paymentSuccess ? 'contrat' : 'proposition'}');
      
    } catch (e) {
      debugPrint('Erreur mise à jour statut: $e');
      rethrow;
    }
  }

  Future<bool> _simulatePayment(String paymentMethod) async {
    // Simulation d'un délai de paiement
    await Future.delayed(const Duration(seconds: 2));
    
    // Pour la démo, retournez true pour succès, false pour échec
    return true; // Changez en false pour tester l'échec
  }

  void _processPayment(String paymentMethod) async {
    if (!mounted) return;
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context) => _LoadingDialog(paymentMethod: paymentMethod)
    );
   
    try {
      // ÉTAPE 1: Sauvegarder la souscription (statut: 'proposition' par défaut)
      final subscriptionId = await _saveSubscriptionData();
      
      // ÉTAPE 2: Simuler le paiement
      final paymentSuccess = await _simulatePayment(paymentMethod);
      
      // ÉTAPE 3: Mettre à jour le statut selon le résultat du paiement
      await _updatePaymentStatus(subscriptionId, paymentSuccess, paymentMethod: paymentMethod);
      
      if (mounted) {
        Navigator.pop(context); // Fermer le loading
        
        if (paymentSuccess) {
          _showSuccessDialog(true); // Contrat activé
        } else {
          _showErrorSnackBar('Paiement échoué. Votre proposition a été sauvegardée.');
        }
      }
      
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('Erreur lors du traitement: $e');
      }
    }
  }

  void _saveAsProposition() async {
    try {
      // Sauvegarde avec statut 'proposition' par défaut
      await _saveSubscriptionData();
      if (mounted) {
        _showSuccessDialog(false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la sauvegarde: $e');
      }
    }
  }

  // FIN DES MÉTHODES CRITIQUES

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bleuCoris, bleuCoris.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: bleuCoris.withValues(alpha: 0.3),
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
              const Icon(Icons.group, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "SOUSCRIPTION CORIS SOLIDARITÉ",
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

  Widget _buildProgressIndicator() {
    // Déterminer le nombre d'étapes en fonction des membres
    int totalSteps = 6; // Paramètres + Récapitulatif
    if (nbConjoints == 0) totalSteps--;
    if (nbEnfants == 0) totalSteps--;
    if (nbAscendants == 0) totalSteps--;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blanc, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 20, 
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalSteps, (index) {
          bool isActive = index <= _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive ? bleuCoris : grisLeger,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? blanc : grisTexte,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (index < totalSteps - 1) Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isActive ? bleuCoris : grisLeger,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélecteur de capital
          _buildCapitalDropdown(),
          const SizedBox(height: 16),
          
          // Sélecteur de périodicité
          _buildPeriodiciteDropdown(),
          const SizedBox(height: 25),
          
          // Séparateur
          const Divider(color: grisClair, height: 1, thickness: 1),
          const SizedBox(height: 25),
          
          // Steppers pour les membres de la famille
          _buildStepper("Nombre de conjoints", nbConjoints, 0, 10, (val) {
            setState(() {
              nbConjoints = val;
              conjoints = List.generate(nbConjoints, (index) => 
                index < conjoints.length ? conjoints[index] : Membre(nomPrenom: '', dateNaissance: DateTime.now()));
            });
            _calculerPrime();
          }),
          const SizedBox(height: 16),
          
          _buildStepper("Nombre d'enfants", nbEnfants, 0, 20, (val) {
            setState(() {
              nbEnfants = val;
              enfants = List.generate(nbEnfants, (index) => 
                index < enfants.length ? enfants[index] : Membre(nomPrenom: '', dateNaissance: DateTime.now()));
            });
            _calculerPrime();
          }),
          const SizedBox(height: 16),
          
          _buildStepper("Nombre d'ascendants", nbAscendants, 0, 4, (val) {
            setState(() {
              nbAscendants = val;
              ascendants = List.generate(nbAscendants, (index) => 
                index < ascendants.length ? ascendants[index] : Membre(nomPrenom: '', dateNaissance: DateTime.now()));
            });
            _calculerPrime();
          }),
        ],
      ),
    );
  }

  Widget _buildCapitalDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<int>(
          value: selectedCapital,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.attach_money, color: Color(0xFF002B6B)),
            labelText: 'Capital à garantir',
          ),
          items: capitalOptions
              .map((val) => DropdownMenuItem(
                    value: val,
                    child: Text(
                      '${_formatNumber(val)} FCFA',
                      style: const TextStyle(color: Color(0xFF002B6B), fontWeight: FontWeight.w500),
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() => selectedCapital = val);
            _calculerPrime();
          },
        ),
      ),
    );
  }

  Widget _buildPeriodiciteDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: selectedPeriodicite,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF002B6B)),
            labelText: 'Périodicité',
          ),
          items: periodicites
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(
                      p,
                      style: const TextStyle(color: Color(0xFF002B6B), fontWeight: FontWeight.w500),
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() => selectedPeriodicite = val!);
            _calculerPrime();
          },
        ),
      ),
    );
  }

  Widget _buildStepper(String label, int value, int min, int max, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: const TextStyle(fontSize: 16, color: Color(0xFF002B6B), fontWeight: FontWeight.w500)
          ),
          Row(
            children: [
              _buildStepperButton(Icons.remove, () => onChanged((value - 1).clamp(min, max)), value > min),
              SizedBox(
                width: 40,
                child: Text(
                  "$value",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002B6B)),
                ),
              ),
              _buildStepperButton(Icons.add, () => onChanged((value + 1).clamp(min, max)), value < max),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onPressed, bool isEnabled) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isEnabled ? bleuCoris : grisClair,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: isEnabled ? onPressed : null,
        icon: Icon(icon, size: 18, color: isEnabled ? blanc : texteGris),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStepConjoints() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(nbConjoints, (index) {
          return _buildMembreForm(
            titre: 'Conjoint ${index + 1}',
            membre: conjoints[index],
            onChanged: (membre) {
              setState(() {
                conjoints[index] = membre;
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildStepEnfants() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(nbEnfants, (index) {
          return _buildMembreForm(
            titre: 'Enfant ${index + 1}',
            membre: enfants[index],
            onChanged: (membre) {
              setState(() {
                enfants[index] = membre;
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildStepAscendants() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(nbAscendants, (index) {
          return _buildMembreForm(
            titre: 'Ascendant ${index + 1}',
            membre: ascendants[index],
            onChanged: (membre) {
              setState(() {
                ascendants[index] = membre;
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildMembreForm({required String titre, required Membre membre, required Function(Membre) onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002B6B),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: membre.nomPrenom,
            decoration: InputDecoration(
              labelText: 'Nom et prénom',
              labelStyle: TextStyle(color: bleuCoris.withValues(alpha: 0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: grisClair, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: bleuCoris, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyle(color: bleuCoris, fontSize: 16),
            onChanged: (value) {
              onChanged(Membre(nomPrenom: value, dateNaissance: membre.dateNaissance));
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date de naissance',
              labelStyle: TextStyle(color: bleuCoris.withValues(alpha: 0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: grisClair, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: bleuCoris, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: Icon(Icons.calendar_today, color: bleuCoris),
            ),
            controller: TextEditingController(
              text: membre.dateNaissance != DateTime.now() 
                ? "${membre.dateNaissance.day.toString().padLeft(2, '0')}/${membre.dateNaissance.month.toString().padLeft(2, '0')}/${membre.dateNaissance.year}" 
                : ""
            ),
            style: TextStyle(color: bleuCoris, fontSize: 16),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
  context: context,
  initialDate: membre.dateNaissance,
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
  builder: (context, child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: bleuCoris,
          onPrimary: Colors.white,
        ),
        dialogTheme: DialogThemeData(  // Remplace dialogBackgroundColor
          backgroundColor: Colors.white,
        ),
      ),
      child: child!,
    );
  },
);
              if (picked != null && picked != membre.dateNaissance) {
                onChanged(Membre(nomPrenom: membre.nomPrenom, dateNaissance: picked));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildFormSection(
              'Bénéficiaire et Contact d\'urgence',
              Icons.contacts,
              [
                _buildSubSectionTitle('Bénéficiaire en cas de décès'),
                _buildModernTextField(
                  controller: _beneficiaireNomController,
                  label: 'Nom complet du bénéficiaire',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                // Champ avec indicatif
                _buildPhoneFieldWithIndicatif(
                  controller: _beneficiaireContactController,
                  label: 'Contact du bénéficiaire',
                  selectedIndicatif: _selectedBeneficiaireIndicatif,
                  onIndicatifChanged: (value) {
                    setState(() {
                      _selectedBeneficiaireIndicatif = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  value: _selectedLienParente,
                  label: 'Lien de parenté',
                  icon: Icons.link,
                  items: _lienParenteOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedLienParente = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildSubSectionTitle('Contact d\'urgence'),
                _buildModernTextField(
                  controller: _personneContactNomController,
                  label: 'Nom complet',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                // Champ avec indicatif
                _buildPhoneFieldWithIndicatif(
                  controller: _personneContactTelController,
                  label: 'Contact téléphonique',
                  selectedIndicatif: _selectedContactIndicatif,
                  onIndicatifChanged: (value) {
                    setState(() {
                      _selectedContactIndicatif = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  value: _selectedLienParenteUrgence,
                  label: 'Lien de parenté',
                  icon: Icons.link,
                  items: _lienParenteOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedLienParenteUrgence = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDocumentUploadSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: bleuCoris,
        ),
      ),
    );
  }

  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: blanc, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 2)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            children: [
              Icon(icon, color: bleuCoris, size: 20), 
              const SizedBox(width: 12), 
              Text(
                title, 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600, 
                  color: bleuCoris
                )
              )
            ]
          ), 
          const SizedBox(height: 16), 
          ...children,
        ]
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: bleuCoris.withValues(alpha: 0.7)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8), 
          padding: const EdgeInsets.all(8), 
          decoration: BoxDecoration(
            color: bleuCoris.withValues(alpha: 0.1), 
            borderRadius: BorderRadius.circular(8)
          ), 
          child: Icon(icon, color: bleuCoris, size: 20)
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: grisLeger)
        ), 
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: grisLeger)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: bleuCoris, width: 2)
        ), 
        filled: true, 
        fillColor: fondCarte, 
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Ce champ est obligatoire' : null,
    );
  }

  Widget _buildPhoneFieldWithIndicatif({
    required TextEditingController controller,
    required String label,
    required String selectedIndicatif,
    required Function(String?) onIndicatifChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: bleuCoris)),
        const SizedBox(height: 6),
        Row(
          children: [
            // Dropdown pour l'indicatif
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: fondCarte,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: grisLeger),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedIndicatif,
                  isExpanded: true,
                  items: _indicatifs.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(value, style: const TextStyle(fontSize: 14)),
                      ),
                    );
                  }).toList(),
                  onChanged: onIndicatifChanged,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Champ de téléphone
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  hintText: '00 00 00 00',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.phone_outlined, size: 20, color: bleuCoris.withValues(alpha: 0.7)),
                  filled: true,
                  fillColor: fondCarte,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: bleuCoris, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  if (!RegExp(r'^[0-9]{8,15}$').hasMatch(value.replaceAll(' ', ''))) {
                    return 'Numéro de téléphone invalide';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: bleuCoris.withValues(alpha: 0.7)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8), 
          padding: const EdgeInsets.all(8), 
          decoration: BoxDecoration(
            color: bleuCoris.withValues(alpha: 0.1), 
            borderRadius: BorderRadius.circular(8)
          ), 
          child: Icon(icon, color: bleuCoris, size: 20)
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: grisLeger)
        ), 
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: grisLeger)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: bleuCoris, width: 2)
        ), 
        filled: true, 
        fillColor: fondCarte, 
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      items: items.map((value) => DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null || value.isEmpty ? 'Ce champ est obligatoire' : null,
    );
  }

  Widget _buildDocumentUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: blanc, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 2)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            children: [
              Icon(Icons.document_scanner, color: bleuCoris, size: 20), 
              const SizedBox(width: 12), 
              Text(
                'Pièce d\'identité', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600, 
                  color: bleuCoris
                )
              )
            ]
          ), 
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickDocument,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), 
              width: double.infinity, 
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _pieceIdentite != null ? vertSucces.withValues(alpha: 0.1) : bleuCoris.withValues(alpha: 0.05), 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _pieceIdentite != null ? vertSucces : bleuCoris.withValues(alpha: 0.3), 
                  width: 2
                ),
              ),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300), 
                    child: Icon(
                      _pieceIdentite != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined, 
                      size: 40, 
                      color: _pieceIdentite != null ? vertSucces : bleuCoris, 
                      key: ValueKey(_pieceIdentite != null)
                    )
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _pieceIdentite != null ? 'Document ajouté avec succès' : 'Télécharger votre pièce d\'identité', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600, 
                      color: _pieceIdentite != null ? vertSucces : bleuCoris
                    )
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _pieceIdentite != null ? _pieceIdentite!.path.split('/').last : 'Formats acceptés: PDF, JPG, PNG (Max: 5MB)', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      color: grisTexte, 
                      fontSize: 11
                    )
                  ),
                ]
              ),
            ),
          ),
        ]
      ),
    );
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null) {
        if (mounted) {
          setState(() => _pieceIdentite = File(result.files.single.path!));
          _showSuccessSnackBar('Document ajouté avec succès');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la sélection du fichier');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: blanc), 
            const SizedBox(width: 12), 
            Text(message)
          ]
        ),
        backgroundColor: rougeCoris,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: blanc), 
            const SizedBox(width: 12), 
            Text(message)
          ]
        ),
        backgroundColor: vertSucces,
      ),
    );
  }

  // Méthode pour déterminer les étapes actives en fonction des membres
  List<Widget> _getActiveSteps() {
    List<Widget> steps = [_buildStep1()];
    
    if (nbConjoints > 0) {
      steps.add(_buildStepConjoints());
    }
    
    if (nbEnfants > 0) {
      steps.add(_buildStepEnfants());
    }
    
    if (nbAscendants > 0) {
      steps.add(_buildStepAscendants());
    }
    
    steps.add(_buildStep2());
    steps.add(_buildStepRecap());
    
    return steps;
  }

  // Méthode pour obtenir le nombre total d'étapes
  int _getTotalSteps() {
    int total = 2; // Étape 1 et étape finale (bénéficiaire/contact)
    if (nbConjoints > 0) total++;
    if (nbEnfants > 0) total++;
    if (nbAscendants > 0) total++;
    total++; // Récapitulatif
    return total;
  }

  Widget _buildStepRecap() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations personnelles
          _buildRecapSection('Informations Personnelles', Icons.person, bleuCoris, [
            _buildCombinedRecapRow('Civilité', _userData['civilite'] ?? 'Non renseigné', 'Nom', _userData['nom'] ?? 'Non renseigné'),
            _buildCombinedRecapRow('Prénom', _userData['prenom'] ?? 'Non renseigné', 'Email', _userData['email'] ?? 'Non renseigné'),
            _buildCombinedRecapRow('Téléphone', _userData['telephone'] ?? 'Non renseigné', 'Date de naissance', _formatDate(_userData['date_naissance'] ?? '')),
            _buildCombinedRecapRow('Lieu de naissance', _userData['lieu_naissance'] ?? 'Non renseigné', 'Adresse', _userData['adresse'] ?? 'Non renseigné'),
          ]),
          const SizedBox(height: 12),
          
          // Produit souscrit
          _buildRecapSection('Produit Souscrit', Icons.emoji_people_outlined, vertSucces, [
            _buildCombinedRecapRow('Produit', 'CORIS SOLIDARITÉ', 'Périodicité', selectedPeriodicite),
            _buildCombinedRecapRow('Capital garanti', '${_formatNumber(selectedCapital!)} FCFA', 'Prime totale', '${_formatNumber(primeTotaleResult!.toInt())} FCFA'),
          ]),
          const SizedBox(height: 12),
          
          // Conjoints
          if (conjoints.isNotEmpty) ...[
            _buildRecapSection('Conjoint(s)', Icons.people, bleuCoris, 
              conjoints.map((conjoint) => _buildMembreRecap(conjoint)).toList()
            ),
            const SizedBox(height: 12),
          ],
          
          // Enfants
          if (enfants.isNotEmpty) ...[
            _buildRecapSection('Enfant(s)', Icons.child_care, bleuCoris, 
              enfants.map((enfant) => _buildMembreRecap(enfant)).toList()
            ),
            const SizedBox(height: 12),
          ],
          
          // Ascendants
          if (ascendants.isNotEmpty) ...[
            _buildRecapSection('Ascendant(s)', Icons.elderly, bleuCoris, 
              ascendants.map((ascendant) => _buildMembreRecap(ascendant)).toList()
            ),
            const SizedBox(height: 12),
          ],
          
          // Bénéficiaire et Contact d'urgence dans une seule carte
          _buildRecapSection('Bénéficiaire et Contact d\'urgence', Icons.contacts, bleuSecondaire, [
            _buildSubsectionTitle('Bénéficiaire'),
            _buildRecapRow('Nom complet', _beneficiaireNomController.text.isEmpty ? 'Non renseigné' : _beneficiaireNomController.text),
            _buildRecapRow('Contact', '$_selectedBeneficiaireIndicatif ${_beneficiaireContactController.text.isEmpty ? 'Non renseigné' : _beneficiaireContactController.text}'),
            _buildRecapRow('Lien de parenté', _selectedLienParente),
            const SizedBox(height: 8),
            _buildSubsectionTitle('Contact d\'urgence'),
            _buildRecapRow('Nom complet', _personneContactNomController.text.isEmpty ? 'Non renseigné' : _personneContactNomController.text),
            _buildRecapRow('Contact', '$_selectedContactIndicatif ${_personneContactTelController.text.isEmpty ? 'Non renseigné' : _personneContactTelController.text}'),
            _buildRecapRow('Lien de parenté', _selectedLienParenteUrgence),
          ]),
          const SizedBox(height: 12),
          
          // Documents
          _buildRecapSection('Documents', Icons.description, bleuSecondaire, [
            _buildRecapRow('Pièce d\'identité', _pieceIdentite?.path.split('/').last ?? 'Non téléchargée'),
          ]),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration(
              color: orangeWarning.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: orangeWarning.withValues(alpha: 0.3))
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: orangeWarning, size: 24), 
                const SizedBox(height: 8),
                Text(
                  'Vérification Importante', 
                  style: TextStyle(
                    fontWeight: FontWeight.w700, 
                    color: orangeWarning, 
                    fontSize: 12
                  ), 
                  textAlign: TextAlign.center
                ),
                const SizedBox(height: 6),
                Text(
                  'Vérifiez attentivement toutes les informations ci-dessus. Une fois la souscription validée, certaines modifications ne seront plus possibles.', 
                  textAlign: TextAlign.center, 
                  style: TextStyle(
                    color: grisTexte, 
                    fontSize: 10, 
                    height: 1.4
                  )
                ),
              ]
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildRecapRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          SizedBox(
            width: 110, 
            child: Text(
              '$label :', 
              style: TextStyle(
                fontWeight: FontWeight.w500, 
                color: grisTexte, 
                fontSize: 12
              )
            )
          ),
          Expanded(
            child: Text(
              value, 
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                color: isHighlighted ? vertSucces : bleuCoris, 
                fontSize: isHighlighted ? 13 : 12
              )
            )
          ),
        ]
      ),
    );
  }

  Widget _buildRecapSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: blanc, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 2)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), 
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(6)
                ), 
                child: Icon(icon, color: color, size: 18)
              ),
              const SizedBox(width: 10), 
              Text(
                title, 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w700, 
                  color: color
                )
              ),
            ]
          ), 
          const SizedBox(height: 12), 
          ...children,
        ]
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(
      title, 
      style: TextStyle(
        fontWeight: FontWeight.w600, 
        color: bleuCoris, 
        fontSize: 14
      )
    );
  }

  Widget _buildCombinedRecapRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  '$label1 :', 
                  style: TextStyle(
                    fontWeight: FontWeight.w500, 
                    color: grisTexte, 
                    fontSize: 12
                  )
                ),
                Text(
                  value1, 
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    color: bleuCoris, 
                    fontSize: 12
                  )
                ),
              ]
            )
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  '$label2 :', 
                  style: TextStyle(
                    fontWeight: FontWeight.w500, 
                    color: grisTexte, 
                    fontSize: 12
                  )
                ),
                Text(
                  value2, 
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    color: bleuCoris, 
                    fontSize: 12
                  )
                ),
              ]
            )
          ),
        ]
      ),
    );
  }

  Widget _buildMembreRecap(Membre membre) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            membre.nomPrenom,
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              color: bleuCoris, 
              fontSize: 12
            )
          ),
          Text(
            'Date de naissance: ${membre.dateNaissance.day.toString().padLeft(2, '0')}/${membre.dateNaissance.month.toString().padLeft(2, '0')}/${membre.dateNaissance.year}',
            style: TextStyle(
              color: grisTexte, 
              fontSize: 11
            )
          ),
        ]
      ),
    );
  }

  void _showPaymentOptions() {
    if (mounted) {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true, 
        backgroundColor: Colors.transparent, 
        builder: (context) => _PaymentBottomSheet(
          onPayNow: _processPayment, 
          onPayLater: _saveAsProposition
        )
      );
    }
  }

  void _showSuccessDialog(bool isPaid) {
    if (mounted) {
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (context) => _SuccessDialog(isPaid: isPaid)
      );
    }
  }

  void _nextStep() {
    if (_currentStep < _getTotalSteps() - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400), 
        curve: Curves.easeInOut
      );
    } else {
      _showPaymentOptions();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400), 
        curve: Curves.easeInOut
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondGris,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: bleuCoris))
          : Column(
              children: [
                _buildModernHeader(),
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _getActiveSteps(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20), 
                  decoration: BoxDecoration(
                    color: blanc, 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05), 
                        blurRadius: 20, 
                        offset: const Offset(0, -4)
                      )
                    ]
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (_currentStep > 0) Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: bleuCoris, width: 2), 
                              padding: const EdgeInsets.symmetric(vertical: 16), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, 
                              children: [
                                Icon(Icons.arrow_back, color: bleuCoris, size: 20), 
                                const SizedBox(width: 8),
                                Text(
                                  'Précédent', 
                                  style: TextStyle(
                                    color: bleuCoris, 
                                    fontWeight: FontWeight.w600, 
                                    fontSize: 16
                                  )
                                ),
                              ]
                            ),
                          ),
                        ),
                        if (_currentStep > 0) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentStep == _getTotalSteps() - 1 ? bleuCoris : rougeCoris, 
                              padding: const EdgeInsets.symmetric(vertical: 16), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                              elevation: 0, 
                              shadowColor: (_currentStep == _getTotalSteps() - 1 ? bleuCoris : rougeCoris).withValues(alpha: 0.3)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, 
                              children: [
                                Text(
                                  _currentStep == _getTotalSteps() - 1 ? 'Finaliser' : 'Suivant', 
                                  style: TextStyle(
                                    color: blanc, 
                                    fontWeight: FontWeight.w700, 
                                    fontSize: 16
                                  )
                                ),
                                const SizedBox(width: 8), 
                                Icon(
                                  _currentStep == _getTotalSteps() - 1 ? Icons.check : Icons.arrow_forward, 
                                  color: blanc, 
                                  size: 20
                                ),
                              ]
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// Classes pour les dialogues
class _LoadingDialog extends StatelessWidget {
  final String paymentMethod;
  const _LoadingDialog({required this.paymentMethod});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, 
      child: Container(
        padding: const EdgeInsets.all(24), 
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), 
              blurRadius: 20, 
              offset: const Offset(0, 8)
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            SizedBox(
              width: 60, 
              height: 60, 
              child: CircularProgressIndicator(
                color: Color(0xFF002B6B), 
                strokeWidth: 3
              )
            ),
            const SizedBox(height: 20), 
            const Text(
              'Traitement en cours', 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w700, 
                color: Color(0xFF002B6B)
              )
            ),
            const SizedBox(height: 8), 
            Text(
              'Paiement via $paymentMethod...', 
              textAlign: TextAlign.center, 
              style: const TextStyle(
                color: Color(0xFF64748B), 
                fontSize: 14
              )
            ),
          ]
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final bool isPaid;
  const _SuccessDialog({required this.isPaid});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, 
      child: Container(
        padding: const EdgeInsets.all(24), 
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), 
              blurRadius: 20, 
              offset: const Offset(0, 8)
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              width: 80, 
              height: 80, 
              decoration: BoxDecoration(
                color: isPaid ? vertSucces.withValues(alpha: 0.1) : orangeWarning.withValues(alpha: 0.1), 
                shape: BoxShape.circle
              ), 
              child: Icon(
                isPaid ? Icons.check_circle : Icons.schedule, 
                color: isPaid ? vertSucces : orangeWarning, 
                size: 40
              )
            ),
            const SizedBox(height: 20), 
            const Text(
              'Souscription Réussie!', 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w700, 
                color: Color(0xFF002B6B)
              )
            ),
            const SizedBox(height: 12), 
            Text(
              isPaid ? 'Félicitations! Votre contrat CORIS SOLIDARITÉ est maintenant actif. Vous recevrez un email de confirmation sous peu.' : 'Votre proposition a été enregistrée avec succès. Vous pouvez effectuer le paiement plus tard depuis votre espace client.', 
              textAlign: TextAlign.center, 
              style: const TextStyle(
                color: Color(0xFF64748B), 
                fontSize: 14, 
                height: 1.4
              )
            ),
            const SizedBox(height: 24), 
            SizedBox(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF002B6B), 
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ), 
                child: const Text(
                  'Retour à l\'accueil', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w600
                  )
                )
              ),
            ),
          ]
        ),
      ),
    );
  }
}

class _PaymentBottomSheet extends StatelessWidget {
  final Function(String) onPayNow;
  final VoidCallback onPayLater;
  const _PaymentBottomSheet({required this.onPayNow, required this.onPayLater});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), 
            blurRadius: 20, 
            offset: const Offset(0, -4)
          )
        ]
      ), 
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20), 
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Container(
                width: 40, 
                height: 4, 
                decoration: BoxDecoration(
                  color: Colors.grey[300], 
                  borderRadius: BorderRadius.circular(2)
                )
              ), 
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.payment, color: Color(0xFF002B6B), size: 28), 
                  const SizedBox(width: 12), 
                  const Text(
                    'Options de Paiement', 
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.w700, 
                      color: Color(0xFF002B6B)
                    )
                  )
                ]
              ), 
              const SizedBox(height: 24), 
              _buildPaymentOption('Wave', Icons.waves, Colors.blue, 'Paiement mobile sécurisé', () => onPayNow('Wave')), 
              const SizedBox(height: 12),
              _buildPaymentOption('Orange Money', Icons.phone_android, Colors.orange, 'Paiement mobile Orange', () => onPayNow('Orange Money')), 
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])), 
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16), 
                    child: Text(
                      'OU', 
                      style: TextStyle(
                        color: Color(0xFF64748B), 
                        fontWeight: FontWeight.w500
                      )
                    )
                  ), 
                  Expanded(child: Divider(color: Colors.grey[300])),
                ]
              ), 
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, 
                child: OutlinedButton(
                  onPressed: onPayLater, 
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF002B6B), width: 2), 
                    padding: const EdgeInsets.symmetric(vertical: 16), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ), 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Icon(Icons.schedule, color: Color(0xFF002B6B), size: 20), 
                      const SizedBox(width: 8), 
                      const Text(
                        'Payer plus tard', 
                        style: TextStyle(
                          color: Color(0xFF002B6B), 
                          fontWeight: FontWeight.w600, 
                          fontSize: 16
                        )
                      )
                    ]
                  )
                )
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ]
          )
        )
      )
    );
  }
  
  Widget _buildPaymentOption(String title, IconData icon, Color color, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, 
      borderRadius: BorderRadius.circular(16), 
      child: Container(
        width: double.infinity, 
        padding: const EdgeInsets.all(20), 
        decoration: BoxDecoration(
          color: Color(0xFFF8FAFC), 
          borderRadius: BorderRadius.circular(16), 
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2))
        ), 
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), 
                borderRadius: BorderRadius.circular(12)
              ), 
              child: Icon(icon, color: color, size: 24)
            ),
            const SizedBox(width: 16), 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      color: Color(0xFF002B6B), 
                      fontSize: 16
                    )
                  ), 
                  const SizedBox(height: 4), 
                  Text(
                    subtitle, 
                    style: TextStyle(
                      color: Color(0xFF64748B), 
                      fontSize: 12
                    )
                  )
                ]
              )
            ),
            Icon(Icons.arrow_forward_ios, color: Color(0xFF64748B), size: 16),
          ]
        )
      )
    );
  }
}