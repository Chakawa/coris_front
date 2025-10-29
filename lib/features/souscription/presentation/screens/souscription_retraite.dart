import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mycorislife/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:mycorislife/services/subscription_service.dart';

// Enum pour le type de simulation
enum SimulationType { parPrime, parCapital }
enum Periode { mensuel, trimestriel, semestriel, annuel }

class SouscriptionRetraitePage extends StatefulWidget {
  final Map<String, dynamic>? simulationData;
  const SouscriptionRetraitePage({super.key, this.simulationData});

  @override
  SouscriptionRetraitePageState createState() => SouscriptionRetraitePageState();
}

class SouscriptionRetraitePageState extends State<SouscriptionRetraitePage>
    with TickerProviderStateMixin {
  // Charte graphique CORIS
  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color rougeCoris = Color(0xFFE30613);
  static const Color bleuSecondaire = Color(0xFF1E4A8C);
  static const Color blanc = Colors.white;
  static const Color fondCarte = Color(0xFFF8FAFC);
  static const Color grisTexte = Color(0xFF64748B);
  static const Color grisLeger = Color(0xFFF1F5F9);
  static const Color vertSucces = Color(0xFF10B981);
  static const Color orangeWarning = Color(0xFFF59E0B);

  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  int _currentStep = 0;

  // Contrôleurs pour la simulation
  final TextEditingController _primeController = TextEditingController();
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _dureeController = TextEditingController();

  // Variables pour la simulation
  int _dureeEnAnnees = 5;
  String _selectedUnite = 'années';
  Periode _selectedPeriode = Periode.annuel;
  SimulationType _currentSimulation = SimulationType.parPrime;
  String _selectedSimulationType = 'Par Prime';
  double _calculatedPrime = 0.0;
  double _calculatedCapital = 0.0;
  final List<String> _indicatifs = ['+225', '+226', '+237', '+228', '+229', '+234'];

  // Données utilisateur
  Map<String, dynamic> _userData = {};
  DateTime? _dateNaissance;
  int _age = 0;

  // Contrôleurs pour la souscription
  final _formKey = GlobalKey<FormState>();
  final _beneficiaireNomController = TextEditingController();
  final _beneficiaireContactController = TextEditingController();
  String _selectedLienParente = 'Enfant';
  final _personneContactNomController = TextEditingController();
  final _personneContactTelController = TextEditingController();
  String _selectedLienParenteUrgence = 'Parent';
  DateTime? _dateEffetContrat;
  DateTime? _dateEcheanceContrat;
  String _selectedBeneficiaireIndicatif = '+225';
  String _selectedContactIndicatif = '+225';

  File? _pieceIdentite;

  // Options
  final List<String> _lienParenteOptions = ['Enfant', 'Conjoint', 'Parent', 'Frère/Sœur', 'Ami', 'Autre'];
  final storage = FlutterSecureStorage();

  // Table tarifaire (identique à celle de la simulation)
  final Map<int, Map<String, int>> premiumValues = {
    5: {'mensuel': 17386, 'trimestriel': 51343, 'semestriel': 101813, 'annuel': 201890},
    6: {'mensuel': 14238, 'trimestriel': 41979, 'semestriel': 83298, 'annuel': 165176},
    7: {'mensuel': 11993, 'trimestriel': 35424, 'semestriel': 70324, 'annuel': 139012},
    8: {'mensuel': 10311, 'trimestriel': 30413, 'semestriel': 60397, 'annuel': 119431},
    9: {'mensuel': 9005, 'trimestriel': 26529, 'semestriel': 52698, 'annuel': 104236},
    10: {'mensuel': 7564, 'trimestriel': 22312, 'semestriel': 44228, 'annuel': 87501},
    11: {'mensuel': 6754, 'trimestriel': 19903, 'semestriel': 39467, 'annuel': 78095},
    12: {'mensuel': 6081, 'trimestriel': 17903, 'semestriel': 35511, 'annuel': 70277},
    13: {'mensuel': 5513, 'trimestriel': 16246, 'semestriel': 32233, 'annuel': 63797},
    14: {'mensuel': 5027, 'trimestriel': 14801, 'semestriel': 29372, 'annuel': 58140},
    15: {'mensuel': 4608, 'trimestriel': 13553, 'semestriel': 26900, 'annuel': 53253},
    16: {'mensuel': 4234, 'trimestriel': 12485, 'semestriel': 24745, 'annuel': 48991},
    17: {'mensuel': 3907, 'trimestriel': 11527, 'semestriel': 22851, 'annuel': 45243},
    18: {'mensuel': 3617, 'trimestriel': 10678, 'semestriel': 21173, 'annuel': 41924},
    19: {'mensuel': 3359, 'trimestriel': 9937, 'semestriel': 19705, 'annuel': 38965},
    20: {'mensuel': 3129, 'trimestriel': 9258, 'semestriel': 18362, 'annuel': 36313},
    21: {'mensuel': 2921, 'trimestriel': 8647, 'semestriel': 17152, 'annuel': 33923},
    22: {'mensuel': 2733, 'trimestriel': 8104, 'semestriel': 16057, 'annuel': 31759},
    23: {'mensuel': 2563, 'trimestriel': 7600, 'semestriel': 15061, 'annuel': 29792},
    24: {'mensuel': 2407, 'trimestriel': 7141, 'semestriel': 14153, 'annuel': 27998},
    25: {'mensuel': 2265, 'trimestriel': 6729, 'semestriel': 13337, 'annuel': 26386},
    26: {'mensuel': 2135, 'trimestriel': 6342, 'semestriel': 12573, 'annuel': 24874},
    27: {'mensuel': 2015, 'trimestriel': 5986, 'semestriel': 11868, 'annuel': 23482},
    28: {'mensuel': 1904, 'trimestriel': 5664, 'semestriel': 11218, 'annuel': 22196},
    29: {'mensuel': 1801, 'trimestriel': 5359, 'semestriel': 10616, 'annuel': 21006},
    30: {'mensuel': 1706, 'trimestriel': 5077, 'semestriel': 10057, 'annuel': 19901},
    31: {'mensuel': 1618, 'trimestriel': 4819, 'semestriel': 9547, 'annuel': 18874},
    32: {'mensuel': 1535, 'trimestriel': 4574, 'semestriel': 9063, 'annuel': 17917},
    33: {'mensuel': 1458, 'trimestriel': 4345, 'semestriel': 8610, 'annuel': 17023},
    34: {'mensuel': 1386, 'trimestriel': 4135, 'semestriel': 8187, 'annuel': 16187},
    35: {'mensuel': 1319, 'trimestriel': 3935, 'semestriel': 7791, 'annuel': 15405},
    36: {'mensuel': 1256, 'trimestriel': 3747, 'semestriel': 7419, 'annuel': 14671},
    37: {'mensuel': 1197, 'trimestriel': 3574, 'semestriel': 7077, 'annuel': 13994},
    38: {'mensuel': 1141, 'trimestriel': 3407, 'semestriel': 6748, 'annuel': 13345},
    39: {'mensuel': 1089, 'trimestriel': 3251, 'semestriel': 6439, 'annuel': 12733},
    40: {'mensuel': 1039, 'trimestriel': 3106, 'semestriel': 6147, 'annuel': 12156},
    41: {'mensuel': 993, 'trimestriel': 2967, 'semestriel': 5872, 'annuel': 11612},
    42: {'mensuel': 949, 'trimestriel': 2835, 'semestriel': 5611, 'annuel': 11098},
    43: {'mensuel': 907, 'trimestriel': 2713, 'semestriel': 5370, 'annuel': 10611},
    44: {'mensuel': 868, 'trimestriel': 2595, 'semestriel': 5137, 'annuel': 10151},
    45: {'mensuel': 830, 'trimestriel': 2483, 'semestriel': 4916, 'annuel': 9715},
    46: {'mensuel': 795, 'trimestriel': 2377, 'semestriel': 4706, 'annuel': 9301},
    47: {'mensuel': 761, 'trimestriel': 2277, 'semestriel': 4507, 'annuel': 8908},
    48: {'mensuel': 729, 'trimestriel': 2181, 'semestriel': 4319, 'annuel': 8535},
    49: {'mensuel': 699, 'trimestriel': 2091, 'semestriel': 4143, 'annuel': 8188},
    50: {'mensuel': 670, 'trimestriel': 2004, 'semestriel': 3972, 'annuel': 7850},
  };

  final Map<String, int> minPrimes = {
    'mensuel': 10000,
    'trimestriel': 30000,
    'semestriel': 60000,
    'annuel': 120000,
  };

  @override
  void initState() {
    super.initState();
   
    // Initialisation des animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    // Pré-remplir les données de simulation si fournies
    _prefillSimulationData();
   
    // Chargement des données utilisateur
    _loadUserData();
   
    // Listeners pour le calcul automatique
    _primeController.addListener(() {
      _formatTextField(_primeController);
      if (_currentSimulation == SimulationType.parPrime && _age > 0) {
        _effectuerCalcul();
      }
    });
   
    _capitalController.addListener(() {
      _formatTextField(_capitalController);
      if (_currentSimulation == SimulationType.parCapital && _age > 0) {
        _effectuerCalcul();
      }
    });
   
    _dureeController.addListener(() {
      if (_dureeController.text.isNotEmpty && _age > 0) {
        int? duree = int.tryParse(_dureeController.text);
        if (duree != null) {
          setState(() {
            _dureeEnAnnees = _selectedUnite == 'années' ? duree : duree ~/ 12;
          });
          _effectuerCalcul();
        }
      }
    });
  }

  void _prefillSimulationData() {
  if (widget.simulationData != null) {
    final data = widget.simulationData!;
    
    // Déterminer le type de simulation
    if (data['type'] == 'capital') {
      _currentSimulation = SimulationType.parCapital;
      _selectedSimulationType = 'Par Capital';
      if (data['capital'] != null) {
        _capitalController.text = _formatNumber(data['capital'].toDouble());
      }
    } else {
      _currentSimulation = SimulationType.parPrime;
      _selectedSimulationType = 'Par Prime';
      if (data['prime'] != null) {
        _primeController.text = _formatNumber(data['prime'].toDouble());
      }
    }
    
    // Pré-remplir la durée
    if (data['duree'] != null) {
      _dureeController.text = data['duree'].toString();
      _dureeEnAnnees = data['duree'];
    }
    
    // Pré-remplir la périodicité
    if (data['periodicite'] != null) {
      switch (data['periodicite']) {
        case 'mensuel': _selectedPeriode = Periode.mensuel; break;
        case 'trimestriel': _selectedPeriode = Periode.trimestriel; break;
        case 'semestriel': _selectedPeriode = Periode.semestriel; break;
        case 'annuel': _selectedPeriode = Periode.annuel; break;
      }
    }
    
    // Déclencher le calcul si l'âge est disponible
    if (_age > 0) {
      _effectuerCalcul();
    }
  }
}

  // Méthode pour charger les données utilisateur
  Future<void> _loadUserData() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) return;
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (mounted) {
            setState(() {
              _userData = data['user'];
              // Extraire la date de naissance et calculer l'âge
              if (_userData['date_naissance'] != null) {
                _dateNaissance = DateTime.parse(_userData['date_naissance']);
                final maintenant = DateTime.now();
                _age = maintenant.year - _dateNaissance!.year;
                if (maintenant.month < _dateNaissance!.month ||
                    (maintenant.month == _dateNaissance!.month && maintenant.day < _dateNaissance!.day)) {
                  _age--;
                }
              }
            });
            // Effectuer le calcul après le chargement des données
            if (_age > 0) {
              _effectuerCalcul();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement données utilisateur: $e');
    }
  }

  // Méthodes pour la simulation
  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  void _formatTextField(TextEditingController controller) {
    String text = controller.text.replaceAll(' ', '');
    if (text.isNotEmpty) {
      double? value = double.tryParse(text);
      if (value != null) {
        String formatted = _formatNumber(value);
        if (formatted != controller.text) {
          controller.value = controller.value.copyWith(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    }
  }

  String _getPeriodiciteKey() {
    switch (_selectedPeriode) {
      case Periode.mensuel: return 'mensuel';
      case Periode.trimestriel: return 'trimestriel';
      case Periode.semestriel: return 'semestriel';
      case Periode.annuel: return 'annuel';
    }
  }

  double calculatePremium(int duration, String periodicity, double desiredCapital) {
    if (duration < 5 || duration > 50) {
      return -1;
    }

    if (!premiumValues.containsKey(duration) || !premiumValues[duration]!.containsKey(periodicity)) {
      return -1;
    }

    // Récupérer la prime pour 1 million
    double primePour1Million = premiumValues[duration]![periodicity]!.toDouble();
    
    // Calculer la prime avec règle de trois
    double calculatedPremium = (desiredCapital * primePour1Million) / 1000000;
    
    return calculatedPremium;
  }

  double calculateCapital(int duration, String periodicity, double paidPremium) {
    if (duration < 5 || duration > 50) {
      return -1;
    }

    double minPremium = minPrimes[periodicity]!.toDouble();
    
    if (paidPremium < minPremium) {
      return -1;
    }
    
    if (!premiumValues.containsKey(duration) || !premiumValues[duration]!.containsKey(periodicity)) {
      return -1;
    }
    
    // Récupérer la prime pour 1 million
    double primePour1Million = premiumValues[duration]![periodicity]!.toDouble();
    
    // Calculer le capital avec règle de trois
    double calculatedCapital = (paidPremium * 1000000) / primePour1Million;
    
    return calculatedCapital;
  }

  void _effectuerCalcul() async {
    if (_age < 18 || _age > 69) {
      return;
    }

    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        String periodiciteKey = _getPeriodiciteKey();
      
        double prime = 0.0;
        double capital = 0.0;
        if (_currentSimulation == SimulationType.parPrime) {
          prime = double.tryParse(_primeController.text.replaceAll(' ', '')) ?? 0;
          if (prime <= 0) return;
        
          capital = calculateCapital(_dureeEnAnnees, periodiciteKey, prime);
          if (capital == -1) {
            capital = 0;
          }
        } else {
          capital = double.tryParse(_capitalController.text.replaceAll(' ', '')) ?? 0;
          if (capital <= 0) return;
        
          prime = calculatePremium(_dureeEnAnnees, periodiciteKey, capital);
          if (prime == -1) {
            prime = 0;
          }
        }
        _calculatedPrime = prime;
        _calculatedCapital = capital;
      });
    }
  }

  void _selectDateEffet() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          _dateEffetContrat = picked;
          // Calculer la date d'échéance
          final duree = int.tryParse(_dureeController.text) ?? 0;
          final dureeAnnees = _selectedUnite == 'années' ? duree : duree ~/ 12;
          _dateEcheanceContrat = picked.add(Duration(days: dureeAnnees * 365));
        });
      }
    }
  }

  void _onSimulationTypeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedSimulationType = newValue;
        _currentSimulation = newValue == 'Par Prime' 
            ? SimulationType.parPrime 
            : SimulationType.parCapital;
        _effectuerCalcul();
      });
    }
  }

  void _onPeriodeChanged(Periode? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedPeriode = newValue;
        _effectuerCalcul();
      });
    }
  }

  void _onUniteChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedUnite = newValue;
        if (_dureeController.text.isNotEmpty) {
          int duree = int.tryParse(_dureeController.text) ?? 0;
          _dureeEnAnnees = _selectedUnite == 'années' ? duree : duree ~/ 12;
          _effectuerCalcul();
        }
      });
    }
  }

  String _getPeriodeTextForDisplay() {
    switch (_selectedPeriode) {
      case Periode.mensuel: return 'Mensuel';
      case Periode.trimestriel: return 'Trimestriel';
      case Periode.semestriel: return 'Semestriel';
      case Periode.annuel: return 'Annuel';
    }
  }

  // Méthodes pour la souscription
  String _formatMontant(double montant) {
    return "${montant.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA";
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
        content: Row(children: [const Icon(Icons.error_outline, color: blanc), const SizedBox(width: 12), Text(message)]),
        backgroundColor: rougeCoris,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.check_circle, color: blanc), const SizedBox(width: 12), Text(message)]),
        backgroundColor: vertSucces,
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_currentStep == 0 && _validateStep1()) {
        setState(() => _currentStep++);
        _progressController.forward();
        _animationController.reset();
        _animationController.forward();
        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
      } else if (_currentStep == 1 && _validateStep2()) {
        setState(() => _currentStep++);
        _progressController.forward();
        _animationController.reset();
        _animationController.forward();
        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _progressController.reverse();
      _animationController.reset();
      _animationController.forward();
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    }
  }

  bool _validateStep1() {
    if (_currentSimulation == SimulationType.parPrime) {
      if (_primeController.text.trim().isEmpty) {
        _showErrorSnackBar('Veuillez saisir une prime');
        return false;
      }
    } else {
      if (_capitalController.text.trim().isEmpty) {
        _showErrorSnackBar('Veuillez saisir un capital');
        return false;
      }
    }
   
    if (_dureeController.text.trim().isEmpty) {
      _showErrorSnackBar('Veuillez saisir une durée');
      return false;
    }
   
    if (_age < 18 || _age > 69) {
      _showErrorSnackBar('Âge non valide (18-69 ans requis)');
      return false;
    }
   
    return true;
  }

  bool _validateStep2() {
    if (_beneficiaireNomController.text.trim().isEmpty ||
        _beneficiaireContactController.text.trim().isEmpty ||
        _personneContactNomController.text.trim().isEmpty ||
        _personneContactTelController.text.trim().isEmpty ||
        _pieceIdentite == null) {
      _showErrorSnackBar('Veuillez remplir tous les champs obligatoires');
      return false;
    }
    return true;
  }

  // Méthodes d'interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisLeger,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: bleuCoris,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [bleuCoris, bleuSecondaire],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.emoji_people_outlined, color: blanc, size: 28),
                              const SizedBox(width: 12),
                              Text('CORIS RETRAITE', style: const TextStyle(color: blanc, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Préparez sereinement votre retraite', style: TextStyle(color: blanc.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w400)),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: blanc), onPressed: () => Navigator.pop(context)),
            ),
            SliverToBoxAdapter(child: Container(margin: const EdgeInsets.all(20), child: _buildModernProgressIndicator())),
          ];
        },
        body: Column(
          children: [
            Expanded(child: PageView(controller: _pageController, physics: const NeverScrollableScrollPhysics(), children: [_buildStep1(), _buildStep2(), _buildStep3()])),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneFieldWithIndicatif({
    required TextEditingController controller,
    required String label,
    required String selectedIndicatif,
    required ValueChanged<String?> onIndicatifChanged,
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

  Widget _buildModernProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: blanc, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Row(children: [
        for (int i = 0; i < 3; i++) ...[
          Expanded(child: Column(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: i <= _currentStep ? bleuCoris : grisLeger, shape: BoxShape.circle, boxShadow: i <= _currentStep ? [BoxShadow(color: bleuCoris.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null), child: Icon(i == 0 ? Icons.account_balance_wallet : i == 1 ? Icons.person_add : Icons.check_circle, color: i <= _currentStep ? blanc : grisTexte, size: 20)),
            const SizedBox(height: 6),
            Text(i == 0 ? 'Simulation' : i == 1 ? 'Informations' : 'Validation', style: TextStyle(fontSize: 11, fontWeight: i <= _currentStep ? FontWeight.w600 : FontWeight.w400, color: i <= _currentStep ? bleuCoris : grisTexte)),
          ])),
          if (i < 2) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 20, left: 6, right: 6), decoration: BoxDecoration(color: i < _currentStep ? bleuCoris : grisLeger, borderRadius: BorderRadius.circular(1)))),
        ],
      ]),
    );
  }

  Widget _buildStep1() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  // Carte de simulation
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 6))]),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bleuCoris.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10))),
                            const SizedBox(width: 12),
                            Text("Souscrire à CORIS RETRAITE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: bleuCoris)),
                          ]),
                          const SizedBox(height: 20),
                         
                          // Sélecteur de type de simulation
                          _buildSimulationTypeDropdown(),
                          const SizedBox(height: 16),
                         
                          // Champ pour la prime/capital
                          _buildMontantField(),
                          const SizedBox(height: 16),
                         
                          // Champ pour la durée
                          _buildDureeField(),
                          const SizedBox(height: 16),
                         
                          // Sélecteur de périodicité
                          _buildPeriodiciteDropdown(),
                          const SizedBox(height: 16),
                         
                          // Champ date d'effet
                          _buildDateEffetField(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateEffetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date d\'effet du contrat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: bleuCoris)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _selectDateEffet,
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(
                text: _dateEffetContrat != null 
                  ? '${_dateEffetContrat!.day}/${_dateEffetContrat!.month}/${_dateEffetContrat!.year}' 
                  : ''
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                hintText: 'Sélectionner une date',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: Icon(Icons.calendar_today, size: 20, color: bleuCoris.withValues(alpha: 0.7)),
                filled: true,
                fillColor: fondCarte,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: bleuCoris, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationTypeDropdown() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: _selectedSimulationType,
          decoration: const InputDecoration(border: InputBorder.none, labelText: 'Mode de souscription', ),
          items: const [DropdownMenuItem(value: 'Par Prime', child: Text('Saisir la Prime')), DropdownMenuItem(value: 'Par Capital', child: Text('Saisir le Capital'))],
          onChanged: _onSimulationTypeChanged,
        ),
      ),
    );
  }

  Widget _buildMontantField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_currentSimulation == SimulationType.parPrime ? 'Prime souhaitée' : 'Capital souhaitée', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: bleuCoris)),
        const SizedBox(height: 6),
        TextField(
          controller: _currentSimulation == SimulationType.parPrime ? _primeController : _capitalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), hintText: 'Ex: 1 000 000', hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(Icons.monetization_on, size: 20, color: bleuCoris.withValues(alpha: 0.7)), suffixText: 'FCFA', filled: true, fillColor: fondCarte,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: bleuCoris, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDureeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Durée', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: bleuCoris)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(flex: 3, child: TextField(
              controller: _dureeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), hintText: 'Saisir la durée', hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: Icon(Icons.calendar_month, size: 20, color: bleuCoris.withValues(alpha: 0.7)), filled: true, fillColor: fondCarte,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: bleuCoris, width: 1.5)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: DropdownButtonFormField<String>(
              value: _selectedUnite,
              decoration: InputDecoration(
                isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), filled: true, fillColor: fondCarte,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(color: bleuCoris, width: 1.5)),
              ),
              items: const [DropdownMenuItem(value: 'années', child: Text('Années')), DropdownMenuItem(value: 'mois', child: Text('Mois'))],
              onChanged: _onUniteChanged,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodiciteDropdown() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<Periode>(
          value: _selectedPeriode,
          decoration: InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.calendar_today, color: bleuCoris), labelText: 'Périodicité'),
          items: const [
            DropdownMenuItem(value: Periode.mensuel, child: Text('Mensuel')),
            DropdownMenuItem(value: Periode.trimestriel, child: Text('Trimestriel')),
            DropdownMenuItem(value: Periode.semestriel, child: Text('Semestriel')),
            DropdownMenuItem(value: Periode.annuel, child: Text('Annuel')),
          ],
          onChanged: _onPeriodeChanged,
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildFormSection(
                      'Bénéficiaire en cas de décès',
                      Icons.family_restroom,
                      [
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
                      ],
                    ),
                    const SizedBox(height: 20),
                                        _buildFormSection(
                      'Contact d\'urgence',
                      Icons.contact_phone,
                      [
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: blanc, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: bleuCoris, size: 20), const SizedBox(width: 12), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: bleuCoris))]),
        const SizedBox(height: 16), ...children,
      ]),
    );
  }

  Widget _buildModernTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller, keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bleuCoris.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: bleuCoris, size: 20)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: grisLeger)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: grisLeger)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: bleuCoris, width: 2)), filled: true, fillColor: fondCarte, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Ce champ est obligatoire' : null,
    );
  }

  Widget _buildDropdownField({required String? value, required String label, required IconData icon, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      value: value, onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bleuCoris.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: bleuCoris, size: 20)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: grisLeger)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: grisLeger)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: bleuCoris, width: 2)), filled: true, fillColor: fondCarte, contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      items: items.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
      validator: (value) => value == null || value.isEmpty ? 'Ce champ est obligatoire' : null,
    );
  }

  Widget _buildDocumentUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: blanc, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.document_scanner, color: bleuCoris, size: 20), const SizedBox(width: 12), Text('Pièce d\'identité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: bleuCoris))]),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickDocument,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _pieceIdentite != null ? vertSucces.withValues(alpha: 0.1) : bleuCoris.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _pieceIdentite != null ? vertSucces : bleuCoris.withValues(alpha: 0.3), width: 2),
            ),
            child: Column(children: [
              AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Icon(_pieceIdentite != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined, size: 40, color: _pieceIdentite != null ? vertSucces : bleuCoris, key: ValueKey(_pieceIdentite != null))),
              const SizedBox(height: 10),
              Text(_pieceIdentite != null ? 'Document ajouté avec succès' : 'Télécharger votre pièce d\'identité', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _pieceIdentite != null ? vertSucces : bleuCoris)),
              const SizedBox(height: 6),
              Text(_pieceIdentite != null ? _pieceIdentite!.path.split('/').last : 'Formats acceptés: PDF, JPG, PNG (Max: 5MB)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: grisTexte)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildStep3() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FutureBuilder<Map<String, dynamic>>(
                future: Future.value(_userData),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: bleuCoris));
                  }
                  return _buildRecapContent(snapshot.data ?? {});
                },
              ),
            ),
          )
        );
      },
    );
  }

  Widget _buildRecapContent(Map<String, dynamic> userData) {
    final duree = _dureeController.text.isNotEmpty ? int.tryParse(_dureeController.text) ?? 0 : 0;
   
    return ListView(children: [
      _buildRecapSection('Informations Personnelles', Icons.person, bleuCoris, [
        _buildCombinedRecapRow('Civilité', userData['civilite'] ?? 'Non renseigné', 'Nom', userData['nom'] ?? 'Non renseigné'),
        _buildCombinedRecapRow('Prénom', userData['prenom'] ?? 'Non renseigné', 'Email', userData['email'] ?? 'Non renseigné'),
        _buildCombinedRecapRow('Téléphone', userData['telephone'] ?? 'Non renseigné', 'Date de naissance', userData['date_naissance'] != null ? _formatDate(userData['date_naissance']) : 'Non renseigné'),
        _buildCombinedRecapRow('Lieu de naissance', userData['lieu_naissance'] ?? 'Non renseigné', 'Adresse', userData['adresse'] ?? 'Non renseigné'),
      ]),
      const SizedBox(height: 20),
      _buildRecapSection('Produit Souscrit', Icons.emoji_people_outlined, vertSucces, [
        // Produit et Prime
        _buildCombinedRecapRow('Produit', 'CORIS RETRAITE', 'Prime ${_getPeriodeTextForDisplay()}', _formatMontant(_calculatedPrime)),
       
        // Capital au terme et Durée du contrat
        _buildCombinedRecapRow('Capital au terme', '${_formatNumber(_calculatedCapital)} FCFA', 'Durée du contrat', '$duree ${_selectedUnite == 'années' ? 'ans' : 'mois'}'),
       
        // Date d'effet et Date d'échéance
        _buildCombinedRecapRow('Date d\'effet', _dateEffetContrat != null ? '${_dateEffetContrat!.day}/${_dateEffetContrat!.month}/${_dateEffetContrat!.year}' : 'Non définie', 
                              'Date d\'échéance', _dateEcheanceContrat != null ? '${_dateEcheanceContrat!.day}/${_dateEcheanceContrat!.month}/${_dateEcheanceContrat!.year}' : 'Non définie'),
      ]),
      const SizedBox(height: 20),
      _buildRecapSection('Bénéficiaire et Contact d\'urgence', Icons.contacts, orangeWarning, [
        _buildSubsectionTitle('Bénéficiaire'),
        _buildRecapRow('Nom complet', _beneficiaireNomController.text.isEmpty ? 'Non renseigné' : _beneficiaireNomController.text),
        _buildRecapRow('Contact', '$_selectedBeneficiaireIndicatif ${_beneficiaireContactController.text.isEmpty ? 'Non renseigné' : _beneficiaireContactController.text}'), _buildRecapRow('Lien de parenté', _selectedLienParente),
        const SizedBox(height: 12),
        _buildSubsectionTitle('Contact d\'urgence'),
        _buildRecapRow('Nom complet', _personneContactNomController.text.isEmpty ? 'Non renseigné' : _personneContactNomController.text),
        _buildRecapRow('Contact', '$_selectedContactIndicatif ${_personneContactTelController.text.isEmpty ? 'Non renseigné' : _personneContactTelController.text}'), _buildRecapRow('Lien de parenté', _selectedLienParenteUrgence),
      ]),
      const SizedBox(height: 20),
      _buildRecapSection('Documents', Icons.description, bleuSecondaire, [
        _buildRecapRow('Pièce d\'identité', _pieceIdentite?.path.split('/').last ?? 'Non téléchargée'),
      ]),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: orangeWarning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: orangeWarning.withValues(alpha: 0.3))),
        child: Column(children: [
          Icon(Icons.info_outline, color: orangeWarning, size: 28), const SizedBox(height: 10),
          Text('Vérification Importante', style: TextStyle(fontWeight: FontWeight.w700, color: orangeWarning, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Vérifiez attentivement toutes les informations ci-dessus. Une fois la souscription validée, certaines modifications ne seront plus possibles.', textAlign: TextAlign.center, style: TextStyle(color: grisTexte, fontSize: 12, height: 1.4)),
        ]),
      ),
      const SizedBox(height: 20),
    ]);
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
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text('$label :', style: TextStyle(fontWeight: FontWeight.w500, color: grisTexte, fontSize: 12))),
        Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: isHighlighted ? vertSucces : bleuCoris, fontSize: isHighlighted ? 13 : 12))),
      ]),
    );
  }

  Widget _buildRecapSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: blanc, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 10), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ]), const SizedBox(height: 12), ...children,
      ]),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: bleuCoris, fontSize: 14));
  }

  Widget _buildCombinedRecapRow(String label1, String value1, String label2, String value2) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Flexible(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label1 :', style: TextStyle(fontWeight: FontWeight.w500, color: grisTexte, fontSize: 12)),
              Text(value1, style: TextStyle(fontWeight: FontWeight.w600, color: bleuCoris, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label2 :', style: TextStyle(fontWeight: FontWeight.w500, color: grisTexte, fontSize: 12)),
              Text(value2, style: TextStyle(fontWeight: FontWeight.w600, color: bleuCoris, fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}



  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: blanc, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -4))]),
      child: SafeArea(
        child: Row(children: [
          if (_currentStep > 0) Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(side: BorderSide(color: bleuCoris, width: 2), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.arrow_back, color: bleuCoris, size: 20), const SizedBox(width: 8),
                Text('Précédent', style: TextStyle(color: bleuCoris, fontWeight: FontWeight.w600, fontSize: 16)),
              ]),
            ),
          ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 2 ? _showPaymentOptions : _nextStep,
              style: ElevatedButton.styleFrom(backgroundColor: bleuCoris, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0, shadowColor: bleuCoris.withValues(alpha: 0.3)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_currentStep == 2 ? 'Finaliser' : 'Suivant', style: TextStyle(color: blanc, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(width: 8), Icon(_currentStep == 2 ? Icons.check : Icons.arrow_forward, color: blanc, size: 20),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  void _showPaymentOptions() {
    if (mounted) {
      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => PaymentBottomSheet(onPayNow: _processPayment, onPayLater: _saveAsProposition));
    }
  }

Future<int> _saveSubscriptionData() async {
  try {
    final subscriptionService = SubscriptionService();
    
    final subscriptionData = {
      'product_type': 'coris_retraite',
      'prime': _calculatedPrime,
      'capital': _calculatedCapital,
      'duree': int.parse(_dureeController.text),
      'duree_type': _selectedUnite,
      'periodicite': _getPeriodeTextForDisplay().toLowerCase(),
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
      'date_effet': _dateEffetContrat?.toIso8601String(),
      'date_echeance': _dateEcheanceContrat?.toIso8601String(),
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
    builder: (context) => LoadingDialog(paymentMethod: paymentMethod)
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

  void _showSuccessDialog(bool isPaid) {
    if (!mounted) return;
    showDialog(context: context, barrierDismissible: false, builder: (context) => SuccessDialog(isPaid: isPaid));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _pageController.dispose();
    _primeController.dispose();
    _capitalController.dispose();
    _dureeController.dispose();
    _beneficiaireNomController.dispose();
    _beneficiaireContactController.dispose();
    _personneContactNomController.dispose();
    _personneContactTelController.dispose();
    super.dispose();
  }
}

// Classes pour les dialogues
class LoadingDialog extends StatelessWidget {
  final String paymentMethod;
  const LoadingDialog({super.key, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Dialog(backgroundColor: Colors.transparent, child: Container(
      padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 60, height: 60, child: CircularProgressIndicator(color: Color(0xFF002B6B), strokeWidth: 3)),
        const SizedBox(height: 20), const Text('Traitement en cours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF002B6B))),
        const SizedBox(height: 8), Text('Paiement via $paymentMethod...', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
      ]),
    ));
  }
}

class SuccessDialog extends StatelessWidget {
  final bool isPaid;
  const SuccessDialog({super.key, required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Dialog(backgroundColor: Colors.transparent, child: Container(
      padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: isPaid ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFF59E0B).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(isPaid ? Icons.check_circle : Icons.schedule, color: isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B), size: 40)),
        const SizedBox(height: 20), Text(isPaid ? 'Souscription Réussie!' : 'Proposition Enregistrée!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF002B6B))),
        const SizedBox(height: 12), Text(isPaid ? 'Félicitations! Votre contrat CORIS RETRAITE est maintenant actif. Vous recevrez un email de confirmation sous peu.' : 'Votre proposition a été enregistrée avec succès. Vous pouvez effectuer le paiement plus tard depuis votre espace client.', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.4)),
        const SizedBox(height: 24), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF002B6B), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Retour à l\'accueil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))),
      ]),
    ));
  }
}

class PaymentBottomSheet extends StatelessWidget {
  final Function(String) onPayNow;
  final VoidCallback onPayLater;
  const PaymentBottomSheet({super.key, required this.onPayNow, required this.onPayLater});

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4))]), child: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))), const SizedBox(height: 24),
      Row(children: [Icon(Icons.payment, color: Color(0xFF002B6B), size: 28), const SizedBox(width: 12), Text('Options de Paiement', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF002B6B)))]),
      const SizedBox(height: 24), _buildPaymentOption('Wave', Icons.waves, Colors.blue, 'Paiement mobile sécurisé', () => onPayNow('Wave')), const SizedBox(height: 12),
      _buildPaymentOption('Orange Money', Icons.phone_android, Colors.orange, 'Paiement mobile Orange', () => onPayNow('Orange Money')), const SizedBox(height: 24),
      Row(children: [Expanded(child: Divider(color: Colors.grey[300])), const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OU', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500))), Expanded(child: Divider(color: Colors.grey[300]))]), const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onPayLater, style: OutlinedButton.styleFrom(side: BorderSide(color: Color(0xFF002B6B), width: 2), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.schedule, color: Color(0xFF002B6B), size: 20), const SizedBox(width: 8), Text('Payer plus tard', style: TextStyle(color: Color(0xFF002B6B), fontWeight: FontWeight.w600, fontSize: 16))]))),
      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
    ]))));
  }
  Widget _buildPaymentOption(String title, IconData icon, Color color, String subtitle, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))), child: Row(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
      const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF002B6B), fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: Color(0xFF64748B), fontSize: 12))])),
      Icon(Icons.arrow_forward_ios, color: Color(0xFF64748B), size: 16),
    ])));
  }
}