import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mycorislife/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:mycorislife/services/subscription_service.dart';
import 'package:intl/intl.dart';

class SouscriptionEtudePage extends StatefulWidget {
  final int? ageParent;
  final int? ageEnfant;
  final double? prime;
  final double? rente;
  final String? periodicite;
  final String? mode; // 'prime' ou 'rente'
  const SouscriptionEtudePage({
    super.key,
    this.ageParent,
    this.ageEnfant,
    this.prime,
    this.rente,
    this.periodicite,
    this.mode,
  });
  @override
  SouscriptionEtudePageState createState() => SouscriptionEtudePageState();
}

class SouscriptionEtudePageState extends State<SouscriptionEtudePage>
    with TickerProviderStateMixin {
  // Charte graphique CORIS améliorée
  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color rougeCoris = Color(0xFFE30613);
  static const Color bleuSecondaire = Color(0xFF1E4A8C);
  static const Color blanc = Colors.white;
  static const Color fondCarte = Color(0xFFF8FAFC);
  static const Color grisTexte = Color(0xFF64748B);
  static const Color grisLeger = Color(0xFFF1F5F9);
  static const Color vertSucces = Color(0xFF10B981);
  static const Color orangeWarning = Color(0xFFF59E0B);
  static const Color bleuClair = Color(0xFFE8F4FD);
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  int _currentStep = 0;
 
  // Form controllers
  final _formKey = GlobalKey<FormState>();
 
  // Step 1 controllers
  final _dureeController = TextEditingController();
  final _montantController = TextEditingController();
  final _dateEffetController = TextEditingController();
  String? _selectedPeriodicite;
  final _professionController = TextEditingController();
  DateTime? _dateEffetContrat;
  DateTime? _dateEcheanceContrat;
  final String _selectedDureeType = 'années';
String _selectedBeneficiaireIndicatif = '+225'; // Côte d'Ivoire par défaut
String _selectedContactIndicatif = '+225'; // Côte d'Ivoire par défaut
final List<Map<String, String>> _indicatifOptions = [
  {'code': '+225', 'pays': 'Côte d\'Ivoire'},
  {'code': '+226', 'pays': 'Burkina Faso'},
];

  // Step 2 controllers
  final _beneficiaireNomController = TextEditingController();
  final _beneficiaireContactController = TextEditingController();
  String _selectedLienParente = 'Enfant';
  final _personneContactNomController = TextEditingController();
  final _personneContactTelController = TextEditingController();
  String _selectedLienParenteUrgence = 'Parent';
  // Mode de souscription
   String _selectedMode = 'Mode Prime'; // 'Prime' ou 'Rente'
  // Variables pour les calculs
  double? _primeCalculee;
  double? _renteCalculee;
  File? _pieceIdentite;
  // Options de lien de parenté
  final List<String> _lienParenteOptions = [
    'Enfant',
    'Conjoint',
    'Parent',
    'Frère/Sœur',
    'Ami',
    'Autre'
  ];
  // Options de périodicité
  final List<String> _periodiciteOptions = [
    'Mensuel',
    'Trimestriel',
    'Semestriel',
    'Annuel'
  ];
  // Tableau tarifaire pour les rentes fixes (identique à simulation-etude.dart)
  final Map<int, Map<int, double>> tarifRenteFixe = {
    18: {
      60: 754, 72: 623, 84: 530, 96: 460, 108: 406, 120: 362, 132: 327, 144: 298, 156: 273, 168: 252, 180: 234, 192: 219, 204: 205, 216: 193, 228: 182, 240: 173
    },
    19: {
      60: 754, 72: 623, 84: 530, 96: 460, 108: 406, 120: 363, 132: 327, 144: 298, 156: 274, 168: 253, 180: 235, 192: 219, 204: 205, 216: 193, 228: 182, 240: 173
    },
    20: {
      60: 755, 72: 623, 84: 530, 96: 460, 108: 406, 120: 363, 132: 328, 144: 299, 156: 274, 168: 253, 180: 235, 192: 219, 204: 206, 216: 194, 228: 183, 240: 173
    },
    21: {
      60: 755, 72: 624, 84: 530, 96: 460, 108: 406, 120: 363, 132: 328, 144: 299, 156: 274, 168: 253, 180: 235, 192: 220, 204: 206, 216: 194, 228: 183, 240: 174
    },
    22: {
      60: 755, 72: 624, 84: 530, 96: 460, 108: 406, 120: 363, 132: 328, 144: 299, 156: 274, 168: 253, 180: 235, 192: 220, 204: 206, 216: 194, 228: 183, 240: 174
    },
    23: {
      60: 755, 72: 624, 84: 530, 96: 461, 108: 406, 120: 363, 132: 328, 144: 299, 156: 275, 168: 254, 180: 236, 192: 220, 204: 206, 216: 194, 228: 184, 240: 174
    },
    24: {
      60: 755, 72: 624, 84: 531, 96: 461, 108: 407, 120: 364, 132: 328, 144: 299, 156: 275, 168: 254, 180: 236, 192: 220, 204: 207, 216: 195, 228: 184, 240: 175
    },
    25: {
      60: 755, 72: 624, 84: 531, 96: 461, 108: 407, 120: 364, 132: 329, 144: 300, 156: 275, 168: 254, 180: 236, 192: 221, 204: 207, 216: 195, 228: 185, 240: 175
    },
    26: {
      60: 755, 72: 624, 84: 531, 96: 461, 108: 407, 120: 364, 132: 329, 144: 300, 156: 275, 168: 255, 180: 237, 192: 221, 204: 208, 216: 196, 228: 185, 240: 176
    },
    27: {
      60: 755, 72: 624, 84: 531, 96: 461, 108: 407, 120: 364, 132: 329, 144: 300, 156: 276, 168: 255, 180: 237, 192: 222, 204: 208, 216: 196, 228: 186, 240: 177
    },
    28: {
      60: 756, 72: 625, 84: 531, 96: 462, 108: 408, 120: 364, 132: 329, 144: 301, 156: 276, 168: 255, 180: 238, 192: 222, 204: 209, 216: 197, 228: 187, 240: 177
    },
    29: {
      60: 756, 72: 625, 84: 532, 96: 462, 108: 408, 120: 365, 132: 330, 144: 301, 156: 277, 168: 256, 180: 238, 192: 223, 204: 210, 216: 198, 228: 187, 240: 178
    },
    30: {
      60: 756, 72: 625, 84:  532, 96: 462, 108: 408, 120: 365, 132: 330, 144: 301, 156: 277, 168: 257, 180: 239, 192: 224, 204: 210, 216: 199, 228: 188, 240: 179
    },
    31: {
      60: 756, 72: 625, 84: 532, 96: 462, 108: 409, 120: 366, 132: 331, 144: 302, 156: 278, 168: 257, 180: 240, 192: 224, 204: 211, 216: 200, 228: 189, 240: 180
    },
    32: {
      60: 757, 72: 626, 84: 533, 96: 463, 108: 409, 120: 366, 132: 331, 144: 303, 156: 279, 168: 258, 180: 241, 192: 225, 204: 212, 216: 201, 228: 191, 240: 182
    },
    33: {
      60: 757, 72: 626, 84: 533, 96: 464, 108: 410, 120: 367, 132: 332, 144: 304, 156: 279, 168: 259, 180: 242, 192: 227, 204: 213, 216: 202, 228: 192, 240: 183
    },
    34: {
      60: 757, 72: 627, 84: 534, 96: 464, 108: 410, 120: 368, 132: 333, 144: 304, 156: 280, 168: 260, 180: 243, 192: 228, 204: 215, 216: 203, 228: 193, 240: 184
    },
    35: {
      60: 758, 72: 627, 84: 534, 96: 465, 108: 411, 120: 369, 132: 334, 144: 305, 156: 282, 168: 261, 180: 244, 192: 229, 204: 216, 216: 205, 228: 195, 240: 186
    },
    36: {
      60: 759, 72: 628, 84: 535, 96: 466, 108: 412, 120: 370, 132: 335, 144: 307, 156: 283, 168: 263, 180: 245, 192: 230, 204: 218, 216: 206, 228: 196, 240: 188
    },
    37: {
      60: 759, 72: 629, 84: 536, 96: 467, 108: 413, 120: 371, 132: 336, 144: 308, 156: 284, 168: 264, 180: 247, 192: 232, 204: 219, 216: 208, 228: 198, 240: 189
    },
    38: {
      60: 760, 72: 630, 84: 537, 96: 468, 108: 414, 120: 372, 132: 338, 144: 309, 156: 286, 168: 265, 180: 248, 192: 234, 204: 221, 216: 210, 228: 200, 240: 191
    },
    39: {
      60: 761, 72: 630, 84: 538, 96: 469, 108: 415, 120: 373, 132: 339, 144: 311, 156: 287, 168: 267, 180: 250, 192: 235, 204: 223, 216: 212, 228: 202, 240: 193
    },
    40: {
      60: 762, 72: 632, 84: 539, 96: 470, 108: 417, 120: 375, 132: 340, 144: 312, 156: 289, 168: 269, 180: 252, 192: 237, 204: 225, 216: 214, 228: 204, 240: 196
    },
    41: {
      60: 763, 72: 633, 84: 540, 96: 471, 108: 418, 120: 376, 132: 342, 144: 314, 156: 290, 168: 271, 180: 254, 192: 239, 204: 227, 216: 216, 228: 206, 240: 198
    },
    42: {
      60: 764, 72: 634, 84: 542, 96: 473, 108: 420, 120: 378, 132: 344, 144: 316, 156: 292, 168: 272, 180: 256, 192: 241, 204: 229, 216: 218, 228: 209, 240: 200
    },
    43: {
      60: 765, 72: 635, 84: 543, 96: 474, 108: 421, 120: 379, 132: 345, 144: 317, 156: 294, 168: 274, 180: 258, 192: 243, 204: 231, 216: 220, 228: 211, 240: 203
    },
    44: {
      60: 766, 72: 637, 84: 544, 96: 476, 108: 423, 120: 381, 132: 347, 144: 319, 156: 296, 168: 276, 180: 260, 192: 245, 204: 233, 216: 223, 228: 214, 240: 206
    },
    45: {
      60: 768, 72: 638, 84: 546, 96: 477, 108: 424, 120: 382, 132: 349, 144: 321, 156: 298, 168: 278, 180: 262, 192: 248, 204: 236, 216: 225, 228: 216, 240: 209
    },
    46: {
      60: 769, 72: 639, 84: 547, 96: 479, 108: 426, 120: 384, 132: 350, 144: 323, 156: 300, 168: 280, 180: 264, 192: 250, 204: 238, 216: 228, 228: 219, 240: 212
    },
    47: {
      60: 770, 72: 640, 84: 548, 96: 480, 108: 427, 120: 386, 132: 352, 144: 325, 156: 302, 168: 282, 180: 266, 192: 253, 204: 241, 216: 231, 228: 222, 240: 215
    },
    48: {
      60: 771, 72: 642, 84: 550, 96: 482, 108: 429, 120: 387, 132: 354, 144: 327, 156: 304, 168: 285, 180: 269, 192: 255, 204: 244, 216: 234, 228: 226, 240: 219
    },
    49: {
      60: 772, 72: 643, 84: 551, 96: 483, 108: 431, 120: 389, 132: 356, 144: 329, 156: 306, 168: 287, 180: 272, 192: 258, 204: 247, 216: 237, 228: 229, 240: 223
    },
    50: {
      60: 774, 72: 644, 84: 553, 96: 485, 108: 433, 120: 391, 132: 358, 144: 331, 156: 309, 168: 290, 180: 275, 192: 261, 204: 250, 216: 241, 228: 233, 240: 227
    },
    51: {
      60: 775, 72: 646, 84: 554, 96: 487, 108: 434, 120: 393, 132: 361, 144: 334, 156: 312, 168: 293, 180: 278, 192: 265, 204: 254, 216: 245, 228: 238, 240: 232
    },
    52: {
      60: 776, 72: 648, 84: 556, 96: 489, 108: 437, 120: 396, 132: 363, 144: 337, 156: 315, 168: 297, 180: 282, 192: 269, 204: 259, 216: 250, 228: 243, 240: 237
    },
    53: {
      60: 778, 72: 649, 84: 558, 96: 491, 108: 439, 120: 399, 132: 366, 144: 340, 156: 318, 168: 301, 180: 286, 192: 274, 204: 263, 216: 255, 228: 248, 240: 242
    },
    54: {
      60: 780, 72: 651, 84: 560, 96: 493, 108: 442, 120: 402, 132: 370, 144: 344, 156: 322, 168: 305, 180: 290, 192: 278, 204: 269, 216: 260, 228: 254, 240: 248
    },
    55: {
      60: 782, 72: 653, 84: 563, 96: 496, 108: 445, 120: 405, 132: 373, 144: 348, 156: 327, 168: 310, 180: 296, 192: 284, 204: 274, 216: 267, 228: 260, 240: 255
    },
    56: {
      60: 784, 72: 656, 84: 566, 96: 499, 108: 449, 120: 409, 132: 378, 144: 352, 156: 332, 168: 315, 180: 301, 192: 290, 204: 281, 216: 273, 228: 267, 240: 263
    },
    57: {
      60: 787, 72: 659, 84: 569, 96: 503, 108: 453, 120: 414, 132: 383, 144: 358, 156: 337, 168: 322, 180: 308, 192: 297, 204: 288, 216: 281, 228: 275, 240: 271
    },
    58: {
      60: 790, 72: 663, 84: 573, 96: 508, 108: 458, 120: 419, 132: 388, 144: 363, 156: 344, 168: 328, 180: 315, 192: 304, 204: 296, 216: 289, 228: 284, 240: 280
    },
    59: {
      60: 794, 72: 667, 84: 578, 96: 513, 108: 463, 120: 424, 132: 394, 144: 370, 156: 350, 168: 335, 180: 322, 192: 312, 204: 304, 216: 298, 228: 293, 240: 290
    },
    60: {
      60: 798, 72: 671, 84: 583, 96: 518, 108: 469, 120: 430, 132: 401, 144: 377, 156: 358, 168: 342, 180: 330, 192: 320, 204: 313, 216: 307, 228: 303, 240: 300
    },

  };
   final storage = const FlutterSecureStorage();

  // Nouvelles variables ajoutées
  int? _calculatedAgeParent;  // Âge calculé à partir de la BD si widget.ageParent est null

  @override
  void initState() {
    super.initState();
    // Chargez les données utilisateur dès l'initialisation si pas de simulation
    if (widget.ageParent == null) {
      _loadUserData().then((data) {
        _calculatedAgeParent = _calculateAgeFromBirthDate(data['date_naissance']);
        _recalculerValeurs();  // Recalculer après chargement
        if (mounted) {
          setState(() {});  // Rafraîchir l'UI
        }
      }).catchError((e) {
        if (mounted) {
          _showErrorSnackBar('Erreur lors du chargement des données utilisateur: $e');
        }
      });
    } else {
      _calculatedAgeParent = widget.ageParent;  // Utiliser la valeur de simulation si disponible
    }
    
    _prefillFromSimulation();
    _dateEffetContrat = DateTime.now();
    _dateEffetController.text = DateFormat('dd/MM/yyyy').format(_dateEffetContrat!);
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    // Ajouter un délai pour s'assurer que tout est initialisé avant le calcul
    Future.delayed(Duration(milliseconds: 100), () {
      _recalculerValeurs();
      if (mounted) {
        setState(() {}); // Forcer le rafraîchissement de l'interface
      }
    });
  }

  Future<Map<String, dynamic>> _loadUserData() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) throw Exception('Token non trouvé');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) return data['user'];
        throw Exception(data['message'] ?? 'Erreur');
      }
      throw Exception('Erreur serveur: ${response.statusCode}');
    } catch (e) {
      rethrow; // Correction: utiliser rethrow au lieu de throw
    }
  }

  int? _calculateAgeFromBirthDate(String? birthDateStr) {
    if (birthDateStr == null) return null;
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  void _prefillFromSimulation() {
    // Déterminer le mode de souscription
    if (widget.mode != null) {
      _selectedMode = widget.mode == 'prime' ? 'Mode Prime' : 'Mode Rente';
    } else {
      _selectedMode = 'Mode Prime'; // Valeur par défaut
    }
    // Pré-remplir l'âge de l'enfant si disponible
    if (widget.ageEnfant != null) {
      _dureeController.text = widget.ageEnfant!.toString();
    }
    
    // Pré-remplir le montant selon le mode
    if (widget.prime != null && _selectedMode == 'Mode Prime') {
      _montantController.text = widget.prime!.toStringAsFixed(0);
    } else if (widget.rente != null && _selectedMode == 'Mode Rente') {
      _montantController.text = widget.rente!.toStringAsFixed(0);
    }
    
    // Pré-remplir la périodicité
    if (widget.periodicite != null) {
      // Convertir la périodicité du format de la simulation au format de souscription
      String periodicite = widget.periodicite!;
      switch (periodicite) {
        case 'mensuel':
          _selectedPeriodicite = 'Mensuel';
          break;
        case 'trimestriel':
          _selectedPeriodicite = 'Trimestriel';
          break;
        case 'semestriel':
          _selectedPeriodicite = 'Semestriel';
          break;
        case 'annuel':
          _selectedPeriodicite = 'Annuel';
          break;
        default:
          _selectedPeriodicite = _periodiciteOptions.first;
      }
    } else {
      _selectedPeriodicite = _periodiciteOptions.first;
    }
    // Date d'effet par défaut (aujourd'hui)
    _dateEffetContrat = DateTime.now();
    _dateEffetController.text = DateFormat('dd/MM/yyyy').format(_dateEffetContrat!);
    
    // Mettre à jour la date d'échéance
    _updateEcheanceDate();
    
    // Forcer le recalcul immédiat des valeurs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculerValeurs();
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Méthode auxiliaire pour trouver la durée la plus proche
  int _closestDuree(int mois) {
    final palliers = [60, 72, 84, 96, 108, 120, 132, 144, 156, 168, 180, 192, 204, 216, 228, 240];
    for (int p in palliers) {
      if (mois <= p) return p;
    }
    return 240;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _pageController.dispose();
    _dureeController.dispose();
    _montantController.dispose();
    _dateEffetController.dispose();
    _professionController.dispose();
    _beneficiaireNomController.dispose();
    _beneficiaireContactController.dispose();
    _personneContactNomController.dispose();
    _personneContactTelController.dispose();
    super.dispose();
  }

  String _formatMontant(double montant) {
    return "${montant.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA";
  }

  void _formatMontantInput() {
    final text = _montantController.text.replaceAll(' ', '');
    if (text.isNotEmpty) {
      final value = double.tryParse(text);
      if (value != null) {
        _montantController.text = _formatNumber(value);
        _montantController.selection = TextSelection.fromPosition(
          TextPosition(offset: _montantController.text.length),
        );
      }
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
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
        setState(() {
          _pieceIdentite = File(result.files.single.path!);
        });
      }

      if (mounted) {
        _showSuccessSnackBar('Votre pièce d\'identité a été téléchargée avec succès.');
      }
    }
  } catch (e) {
    if (mounted) {
      _showErrorSnackBar('Une erreur s\'est produite lors de la sélection du fichier. Veuillez réessayer.');
    }
  }
}

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  Future<Map<String, dynamic>> _loadUserDataForRecap() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token non trouvé');
      }
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
          final userData = data['user'];
          if (userData['date_naissance'] != null) {
            final dateNaissance = DateTime.parse(userData['date_naissance']);
            final maintenant = DateTime.now();
            int age = maintenant.year - dateNaissance.year;
            if (maintenant.month < dateNaissance.month ||
                (maintenant.month == dateNaissance.month && maintenant.day < dateNaissance.day)) {
              age--;
            }
            userData['age'] = age;
          }
          return userData;
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la récupération des données');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      return {};
    }
  }

void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: rougeCoris,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: blanc, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attention',
                    style: TextStyle(
                      color: blanc,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: blanc,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 4),
    ),
  );
}

 void _nextStep() {
  if (_currentStep < 2) {
    bool canProceed = false;
    if (_currentStep == 0 && _validateStep1()) {
      canProceed = true;
    } else if (_currentStep == 1 && _validateStep2()) {
      canProceed = true;
      _recalculerValeurs();  // Call here before moving to recap (step 3)
    }
    if (canProceed) {
      setState(() => _currentStep++);
      _progressController.forward();
      _animationController.reset();
      _animationController.forward();
      _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }
}

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _progressController.reverse();
      _animationController.reset();
      _animationController.forward();
      _pageController.previousPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

 bool _validateStep1() {
  if (_dureeController.text.trim().isEmpty ||
      _montantController.text.trim().isEmpty ||
      _selectedPeriodicite == null ||
      _dateEffetContrat == null) {
    _showErrorSnackBar('Veuillez compléter tous les champs obligatoires avant de continuer.');
    return false;
  }

  final age = int.tryParse(_dureeController.text);
  if (age == null || age < 0 || age > 17) {
    _showErrorSnackBar('L\'âge de l\'enfant doit être compris entre 0 et 17 ans.');
    return false;
  }

  if (_calculatedAgeParent == null || _calculatedAgeParent! < 18 || _calculatedAgeParent! > 60) {
    _showErrorSnackBar('L\'âge du souscripteur doit être compris entre 18 et 60 ans pour ce produit.');
    return false;
  }

  final montant = double.tryParse(_montantController.text.replaceAll(' ', ''));
  if (montant == null || montant <= 0) {
    _showErrorSnackBar('Le montant saisi est invalide. Veuillez entrer un montant positif.');
    return false;
  }

  return true;
}

bool _validateStep2() {
  if (_beneficiaireNomController.text.trim().isEmpty ||
      _beneficiaireContactController.text.trim().isEmpty ||
      _personneContactNomController.text.trim().isEmpty ||
      _personneContactTelController.text.trim().isEmpty) {
    _showErrorSnackBar('Veuillez renseigner tous les contacts et informations de bénéficiaire.');
    return false;
  }

  if (_pieceIdentite == null) {
    _showErrorSnackBar('Le téléchargement d\'une pièce d\'identité est obligatoire pour continuer.');
    return false;
  }

  // Validation des numéros de téléphone
  if (!RegExp(r'^[0-9]{8,15}$').hasMatch(_beneficiaireContactController.text)) {
    _showErrorSnackBar('Le numéro du bénéficiaire semble invalide. Veuillez vérifier.');
    return false;
  }

  if (!RegExp(r'^[0-9]{8,15}$').hasMatch(_personneContactTelController.text)) {
    _showErrorSnackBar('Le numéro de contact d\'urgence semble invalide. Veuillez vérifier.');
    return false;
  }

  return true;
}

void _showSuccessSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: vertSucces,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: blanc, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Succès',
                    style: TextStyle(
                      color: blanc,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: blanc,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 3),
    ),
  );
}

  void _showPaymentOptions() async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PaymentBottomSheet(
      onPayNow: (paymentMethod) {
        Navigator.pop(context);
        _processPayment(paymentMethod);
      },
      onPayLater: () {
        Navigator.pop(context);
        _saveAsProposition();
      },
    ),
  );
}

Future<int> _saveSubscriptionData() async {
  try {
    final subscriptionService = SubscriptionService();
    
    // Calculer la durée en mois (jusqu'à 17 ans)
    final ageEnfant = int.tryParse(_dureeController.text) ?? 0;
    final dureeMois = ((17 - ageEnfant) * 12).round();

    final subscriptionData = {
      'product_type': 'coris_etude',
      'duree_mois': dureeMois,
      'montant': double.parse(_montantController.text.replaceAll(' ', '')).toInt(),
      'periodicite': _selectedPeriodicite?.toLowerCase(),
      'mode_souscription': _selectedMode.toLowerCase().replaceAll('mode ', ''),
      'prime_calculee': _primeCalculee?.toInt() ?? 0,
      'rente_calculee': _renteCalculee?.toInt() ?? 0,
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
      'profession': _professionController.text.trim(),
      'date_effet': _dateEffetContrat?.toIso8601String(),
      'date_echeance': _dateEcheanceContrat?.toIso8601String(),
      'piece_identite': _pieceIdentite?.path.split('/').last ?? '',
      'age_enfant': ageEnfant,
      'age_souscripteur': _calculatedAgeParent,
    };

    final response = await subscriptionService.createSubscription(subscriptionData);
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode != 201 || !responseData['success']) {
      throw Exception(responseData['message'] ?? 'Erreur lors de la sauvegarde');
    }
    
    // RETOURNEZ l'ID de la souscription créée
    return responseData['data']['id'];
    
  } catch (e) {
    rethrow; // Correction: utiliser rethrow au lieu de throw
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
    rethrow; // Correction: utiliser rethrow au lieu de throw
  }
}

Future<bool> _simulatePayment(String paymentMethod) async {
  // Simulation d'un délai de paiement
  await Future.delayed(const Duration(seconds: 2));
  
  // Pour la démo, retournez true pour succès, false pour échec
  return true; // Changez en false pour tester l'échec
}

void _processPayment(String paymentMethod) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _LoadingDialog(paymentMethod: paymentMethod),
  );
 
  try {
    // ÉTAPE 1: Sauvegarder la souscription (statut: 'proposition' par défaut)
    final subscriptionId = await _saveSubscriptionData();
    
    // ÉTAPE 2: Simuler le paiement
    final paymentSuccess = await _simulatePayment(paymentMethod);
    
    // ÉTAPE 3: Mettre à jour le statut selon le résultat du paiement
    await _updatePaymentStatus(subscriptionId, paymentSuccess, paymentMethod: paymentMethod);
    
    if (mounted) {
    Navigator.pop(context);
  } 
    
    if (paymentSuccess) {
      _showSuccessDialog(true); 
    } else {
      _showErrorSnackBar('Paiement échoué. Votre proposition a été sauvegardée.');
    }
    
  } catch (e) {
    if (mounted) {
    Navigator.pop(context);
  }
    _showErrorSnackBar('Erreur lors du traitement: $e');
  }
}
  
  void _saveAsProposition() async {
  try {
    // Sauvegarde avec statut 'proposition' par défaut
     await _saveSubscriptionData();
    _showSuccessDialog(false);
  } catch (e) {
    _showErrorSnackBar('Erreur lors de la sauvegarde: $e');
  }
}

  void _showSuccessDialog(bool isPaid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessDialog(isPaid: isPaid),
    );
  }

  void _selectDateEffet() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12, 31),
      initialDatePickerMode: DatePickerMode.day,
    );
   
    if (picked != null && mounted) {
      setState(() {
        _dateEffetContrat = picked;
        _dateEffetController.text = DateFormat('dd/MM/yyyy').format(picked);
        _updateEcheanceDate();
      });
    }
  }

  void _updateEcheanceDate() {
    if (_dureeController.text.isNotEmpty && _dateEffetContrat != null) {
      final duree = int.tryParse(_dureeController.text) ?? 0;
      final dureeMois = _selectedDureeType == 'années' ? duree * 12 : duree;
      setState(() {
        _dateEcheanceContrat = DateTime(
          _dateEffetContrat!.year,
          _dateEffetContrat!.month,
          _dateEffetContrat!.day,
        ).add(Duration(days: dureeMois * 30));
      });
    }
  }

  double _convertToMensuel(double valeur, String periodicite) {
    if (valeur <= 0) return 0;
 
    // Convertir en minuscules pour la comparaison
    String periodiciteLower = periodicite.toLowerCase();
 
    switch (periodiciteLower) {
      case 'trimestriel':
        double primeAnnuelle = (valeur * 4) / 1.03;
        return (primeAnnuelle * 1.04) / 12;
      case 'semestriel':
        double primeAnnuelle = (valeur * 2) / 1.02;
        return (primeAnnuelle * 1.04) / 12;
      case 'annuel':
        return (valeur * 1.04) / 12;
      case 'mensuel':
      default:
        return valeur;
    }
  }

  double _convertFromMensuel(double primeMensuelle, String periodicite) {
    if (primeMensuelle <= 0) return 0;
 
    // Convertir en minuscules pour la comparaison
    String periodiciteLower = periodicite.toLowerCase();
 
    switch (periodiciteLower) {
      case 'trimestriel':
        double primeAnnuelle = (primeMensuelle * 12) / 1.04;
        return (primeAnnuelle * 1.03) / 4;
      case 'semestriel':
        double primeAnnuelle = (primeMensuelle * 12) / 1.04;
        return (primeAnnuelle * 1.02) / 2;
      case 'annuel':
        return (primeMensuelle * 12) / 1.04;
      case 'mensuel':
      default:
        return primeMensuelle;
    }
  }

  double _calculateRente(int age, int dureeMois, double primeMensuelle) {
 
    if (!tarifRenteFixe.containsKey(age)) {
      return 0;
    }
 
    int dureeEffective = _closestDuree(dureeMois);
 
    if (!tarifRenteFixe[age]!.containsKey(dureeEffective)) {
      return 0;
    }
    double primeMensuelleBase = tarifRenteFixe[age]![dureeEffective]!;
 
    double rente = (primeMensuelle * 10000) / primeMensuelleBase;
 
    return rente;
  }

  double _calculatePrime(int age, int dureeMois, double renteSouhaitee) {
 
    if (!tarifRenteFixe.containsKey(age)) {
      return 0;
    }
 
    int dureeEffective = _closestDuree(dureeMois);
 
    if (!tarifRenteFixe[age]!.containsKey(dureeEffective)) {
      return 0;
    }
    double primeMensuelleBase = tarifRenteFixe[age]![dureeEffective]!;
 
    double primeMensuelle = (renteSouhaitee * primeMensuelleBase) / 10000;
 
    return primeMensuelle;
  }

  void _recalculerValeurs() {
 
    // Vérifier que toutes les données nécessaires sont disponibles
    if (_calculatedAgeParent == null ||
        _dureeController.text.isEmpty ||
        _montantController.text.isEmpty ||
        _selectedPeriodicite == null) {
      _primeCalculee = 0;
      _renteCalculee = 0;
      return;
    }
    try {
      // Nettoyer le montant (supprimer les espaces)
      final montantText = _montantController.text.replaceAll(' ', '');
      final montant = double.parse(montantText);
     
      // Calculer la durée en mois (jusqu'à 17 ans)
      final ageEnfant = int.parse(_dureeController.text);
      final dureeMois = ((17 - ageEnfant) * 12).round();
      final dureeEffective = _closestDuree(dureeMois);
 
      // Déterminer le mode de calcul en fonction de _selectedMode
      if (_selectedMode == 'Mode Prime') {
        // Mode Prime: calculer la rente correspondante
        double primeMensuelle = _convertToMensuel(montant, _selectedPeriodicite!);
       
        _renteCalculee = _calculateRente(_calculatedAgeParent!, dureeEffective, primeMensuelle);
        _primeCalculee = montant;
       
      } else {
        // Mode Rente: calculer la prime correspondante
        double primeMensuelle = _calculatePrime(_calculatedAgeParent!, dureeEffective, montant);
       
        _primeCalculee = _convertFromMensuel(primeMensuelle, _selectedPeriodicite!);
        _renteCalculee = montant;
       
      }
 
      // Forcer la mise à jour de l'interface
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // En cas d'erreur, mettre les valeurs à 0
      _primeCalculee = 0;
      _renteCalculee = 0;
      if (mounted) {
        setState(() {});
      }
    }
  }

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
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school_outlined,
                                  color: blanc, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'CORIS ÉTUDE',
                                style: TextStyle(
                                  color: blanc,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Préparez l\'avenir éducatif de vos enfants',
                            style: TextStyle(
                              color: blanc.withAlpha(230), // .withOpacity(0.9) remplacé
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: blanc),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(16),
                child: _buildModernProgressIndicator(),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: blanc,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8), // .withOpacity(0.03) remplacé
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: i <= _currentStep ? bleuCoris : grisLeger,
                      shape: BoxShape.circle,
                      boxShadow: i <= _currentStep ? [
                        BoxShadow(
                          color: bleuCoris.withAlpha(51), // .withOpacity(0.2) remplacé
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      i == 0 ? Icons.account_balance_wallet :
                      i == 1 ? Icons.person_add : Icons.check_circle,
                      color: i <= _currentStep ? blanc : grisTexte,
                      size: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    i == 0 ? 'Prime' : i == 1 ? 'Infos' : 'Valid',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: i <= _currentStep ? FontWeight.w600 : FontWeight.w400,
                      color: i <= _currentStep ? bleuCoris : grisTexte,
                    ),
                  ),
                ],
              ),
            ),
            if (i < 2)
              Expanded(
                child: Container(
                  height: 2,
                  margin: EdgeInsets.only(bottom: 15, left: 4, right: 4),
                  decoration: BoxDecoration(
                    color: i < _currentStep ? bleuCoris : grisLeger,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ],
      ),
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: blanc,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10), // .withOpacity(0.04) remplacé
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Souscrire à CORIS ÉTUDE",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: bleuCoris,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                         
                          
                          _buildModeDropdown(),
                          const SizedBox(height: 16),
                         
                         
                          _buildAgeEnfantField(),
                          const SizedBox(height: 16),
                         
                          
                          _buildPeriodiciteDropdown(),
                          const SizedBox(height: 16),
                         
                          
                          _buildMontantField(),
                          const SizedBox(height: 16),
                         
                          
                          _buildDateEffetField(),
                          SizedBox(height: 16),
                          if (_calculatedAgeParent != null && _primeCalculee != null && _renteCalculee != null)  
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: vertSucces.withAlpha(26), // .withOpacity(0.1) remplacé
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Résultats Calculés :', style: TextStyle(fontWeight: FontWeight.bold, color: vertSucces)),
                                  SizedBox(height: 8),
                                  Text('Prime : ${_formatMontant(_primeCalculee!)}'),
                                  Text('Rente : ${_formatMontant(_renteCalculee!)}'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // .withOpacity(0.1) remplacé
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: _selectedMode,
          decoration: const InputDecoration(
            border: InputBorder.none,
            labelText: 'Quel montant souhaitez-vous saisir ?',
          ),
          items: const [
            DropdownMenuItem(
              value: 'Mode Prime',
              child: Text('Saisir la prime'),
            ),
            DropdownMenuItem(
              value: 'Mode Rente',
              child: Text('Saisir la rente'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedMode = value;
                _recalculerValeurs(); 
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: bleuCoris,
        fontSize: 14,
      ),
    );
  }

  Widget _buildAgeEnfantField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Âge de l\'enfant',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: _dureeController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateEcheanceDate();
            _recalculerValeurs();
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'âge est obligatoire';
            }
            final age = int.tryParse(value);
            if (age == null || age < 0 || age > 17) {
              return 'L\'âge doit être entre 0 et 17 ans';
            }
            return null;
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: 'saisissez l\'age de votre enfant',
            prefixIcon: Icon(Icons.child_care, size: 20, color: bleuCoris.withAlpha(179)), // .withOpacity(0.7) remplacé
            filled: true,
            fillColor: bleuClair.withAlpha(77), // .withOpacity(0.3) remplacé
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: bleuCoris, width: 1.5),
            ),
            errorStyle: TextStyle(fontSize: 12),
          ),
        ),
        if (_dureeController.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Durée du contrat: ${(17 - (int.tryParse(_dureeController.text) ?? 0))} ans (${(17 - (int.tryParse(_dureeController.text) ?? 0)) * 12} mois)',
              style: TextStyle(
                color: bleuCoris,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPeriodiciteDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // .withOpacity(0.1) remplacé
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: _selectedPeriodicite,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF002B6B)),
            labelText: 'Périodicité',
          ),
          items: _periodiciteOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPeriodicite = value;
              _recalculerValeurs();
            });
          },
        ),
      ),
    );
  }

  Widget _buildMontantField() {
    String label = _selectedMode == 'Mode Rente' ? 'Rente au terme' : 'Prime $_selectedPeriodicite';
    String hint = _selectedMode == 'Mode Rente' ? 'Montant de la rente en FCFA' : 'Montant de la prime en FCFA';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: _montantController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _formatMontantInput();
            _recalculerValeurs();
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: hint,
            prefixIcon: Icon(Icons.monetization_on, size: 20, color: bleuCoris.withAlpha(179)), // .withOpacity(0.7) remplacé
            suffixText: 'CFA',
            filled: true,
            fillColor: bleuClair.withAlpha(77), // .withOpacity(0.3) remplacé
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: bleuCoris, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateEffetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date d\'effet du contrat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: _selectDateEffet,
          child: AbsorbPointer(
            child: TextFormField(
              controller: _dateEffetController,
              decoration: InputDecoration(
                hintText: 'JJ/MM/AAAA',
                prefixIcon: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bleuCoris.withAlpha(26), // .withOpacity(0.1) remplacé
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_today, color: bleuCoris, size: 20),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: grisLeger),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: grisLeger),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: bleuCoris, width: 2),
                ),
                filled: true,
                fillColor: fondCarte,
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
          ),
        ),
      ],
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      SizedBox(height: 16),
                      // MODIFICATION ICI - Champ avec indicatif
                      _buildPhoneFieldWithIndicatif(
                        controller: _beneficiaireContactController,
                        label: 'Contact du bénéficiaire',
                        selectedIndicatif: _selectedBeneficiaireIndicatif,
                        onIndicatifChanged: (value) {
                          setState(() {
                            _selectedBeneficiaireIndicatif = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
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

                  SizedBox(height: 20),

                  _buildFormSection(
                    'Contact d\'urgence',
                    Icons.contact_phone,
                    [
                      _buildModernTextField(
                        controller: _personneContactNomController,
                        label: 'Nom complet',
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 16),
                      // MODIFICATION ICI - Champ avec indicatif
                      _buildPhoneFieldWithIndicatif(
                        controller: _personneContactTelController,
                        label: 'Contact téléphonique',
                        selectedIndicatif: _selectedContactIndicatif,
                        onIndicatifChanged: (value) {
                          setState(() {
                            _selectedContactIndicatif = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
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

                  SizedBox(height: 20),

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

Widget _buildPhoneFieldWithIndicatif({
  required TextEditingController controller,
  required String label,
  required String selectedIndicatif,
  required ValueChanged<String> onIndicatifChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: bleuCoris,
        ),
      ),
      SizedBox(height: 6),
      Row(
        children: [
          // Dropdown pour l'indicatif (plus petit et discret)
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: fondCarte,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: grisLeger),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedIndicatif,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, size: 20, color: bleuCoris),
                items: _indicatifOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['code'],
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        option['code']!,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onIndicatifChanged(value);
                  }
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          // Champ de texte pour le numéro
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Numéro de téléphone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: grisLeger),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: grisLeger),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: bleuCoris, width: 1.5),
                ),
                filled: true,
                fillColor: fondCarte,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le numéro de téléphone est obligatoire';
                }
                if (!RegExp(r'^[0-9]{8,15}$').hasMatch(value)) {
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

  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blanc,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // .withOpacity(0.05) remplacé
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: bleuCoris, size: 20),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: bleuCoris,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bleuCoris.withAlpha(26), // .withOpacity(0.1) remplacé
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: bleuCoris, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grisLeger),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grisLeger),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: bleuCoris, width: 2),
        ),
        filled: true,
        fillColor: fondCarte,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ce champ est obligatoire';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bleuCoris.withAlpha(26), // .withOpacity(0.1) remplacé
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: bleuCoris, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grisLeger),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grisLeger),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: bleuCoris, width: 2),
        ),
        filled: true,
        fillColor: fondCarte,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire';
        }
        return null;
      },
    );
  }

  Widget _buildDocumentUploadSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blanc,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // .withOpacity(0.05) remplacé
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.document_scanner, color: bleuCoris, size: 20),
              SizedBox(width: 12),
              Text(
                'Pièce d\'identité',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: bleuCoris,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _pickDocument,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _pieceIdentite != null
                  ? vertSucces.withAlpha(26) // .withOpacity(0.1) remplacé
                  : bleuCoris.withAlpha(13), // .withOpacity(0.05) remplacé
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _pieceIdentite != null
                    ? vertSucces
                    : bleuCoris.withAlpha(77), // .withOpacity(0.3) remplacé
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      _pieceIdentite != null
                        ? Icons.check_circle_outline
                        : Icons.cloud_upload_outlined,
                      size: 40,
                      color: _pieceIdentite != null ? vertSucces : bleuCoris,
                      key: ValueKey(_pieceIdentite != null),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _pieceIdentite != null
                      ? 'Document ajouté avec succès'
                      : 'Télécharger votre pièce d\'identité',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _pieceIdentite != null ? vertSucces : bleuCoris,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    _pieceIdentite != null
                      ? _pieceIdentite!.path.split('/').last
                      : 'Formats acceptés: PDF, JPG, PNG (Max: 5MB)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: grisTexte,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _loadUserDataForRecap(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: bleuCoris),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 48, color: rougeCoris),
                        SizedBox(height: 16),
                        Text('Erreur lors du chargement des données'),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                final userData = snapshot.data ?? {};
                return _buildRecapContent(userData);
              },
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildRecapContent(Map<String, dynamic> userData) {
  final primeDisplay = _primeCalculee ?? 0;
  final renteDisplay = _renteCalculee ?? 0;
  final duree = int.tryParse(_dureeController.text) ?? 0;

  if (primeDisplay == 0 || renteDisplay == 0) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: rougeCoris),
          SizedBox(height: 16),
          Text(
            'Calcul en cours...',
            style: TextStyle(
              color: bleuCoris,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Veuillez patienter pendant le calcul des valeurs',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: grisTexte,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  return ListView(
    children: [
      _buildRecapSection(
        'Informations Personnelles',
        Icons.person,
        bleuCoris,
        [
          _buildCombinedRecapRow('Civilité', userData['civilite'] ?? 'Non renseigné', 'Nom', userData['nom'] ?? 'Non renseigné'),
          _buildCombinedRecapRow('Prénom', userData['prenom'] ?? 'Non renseigné', 'Email', userData['email'] ?? 'Non renseigné'),
          _buildCombinedRecapRow('Téléphone', userData['telephone'] ?? 'Non renseigné', 'Date de naissance', userData['date_naissance'] != null ? _formatDate(userData['date_naissance']) : 'Non renseigné'),
          _buildCombinedRecapRow('Lieu de naissance', userData['lieu_naissance'] ?? 'Non renseigné', 'Adresse', userData['adresse'] ?? 'Non renseigné'),
        ],
      ),

      SizedBox(height: 20),

      _buildRecapSection(
        'Produit Souscrit',
        Icons.school,
        vertSucces,
        [
          _buildCombinedRecapRow('Produit', 'CORIS ÉTUDE', 'Mode', _selectedMode),
          
          if (_selectedMode == 'Mode Rente') ...[
            _buildCombinedRecapRow('Rente au terme', _formatMontant(renteDisplay), 'Prime $_selectedPeriodicite', _formatMontant(primeDisplay)),
          ] else ...[
            _buildCombinedRecapRow('Prime $_selectedPeriodicite', _formatMontant(primeDisplay), 'Rente au terme', _formatMontant(renteDisplay)),
          ],
          
          _buildCombinedRecapRow('Durée', '$duree ans', 'Périodicité', _selectedPeriodicite ?? 'Non définie'),
          _buildCombinedRecapRow(
            'Date d\'effet', 
            _dateEffetContrat != null ? '${_dateEffetContrat!.day}/${_dateEffetContrat!.month}/${_dateEffetContrat!.year}' : 'Non définie',
            'Date d\'échéance', 
            _dateEcheanceContrat != null ? '${_dateEcheanceContrat!.day}/${_dateEcheanceContrat!.month}/${_dateEcheanceContrat!.year}' : 'Non définie'
          ),
        ],
      ),

      SizedBox(height: 20),

      // SECTION UNIQUE POUR BÉNÉFICIAIRE ET CONTACT D'URGENCE
      _buildRecapSection(
        'Contacts',
        Icons.contacts,
        bleuSecondaire,
        [
          // Bénéficiaire
          _buildSubsectionTitle('Bénéficiaire en cas de décès'),
          SizedBox(height: 8),
          _buildCombinedRecapRow(
            'Nom complet', 
            _beneficiaireNomController.text.isNotEmpty ? _beneficiaireNomController.text : 'Non renseigné',
            'Lien de parenté', 
            _selectedLienParente
          ),
          _buildRecapRow(
            'Téléphone', 
            _beneficiaireContactController.text.isNotEmpty 
              ? '$_selectedBeneficiaireIndicatif ${_beneficiaireContactController.text}' 
              : 'Non renseigné'
          ),
          
          SizedBox(height: 16),
          
          // Contact d'urgence
          _buildSubsectionTitle('Contact d\'urgence'),
          SizedBox(height: 8),
          _buildCombinedRecapRow(
            'Nom complet', 
            _personneContactNomController.text.isNotEmpty ? _personneContactNomController.text : 'Non renseigné',
            'Lien de parenté', 
            _selectedLienParenteUrgence
          ),
          _buildRecapRow(
            'Téléphone', 
            _personneContactTelController.text.isNotEmpty 
              ? '$_selectedContactIndicatif ${_personneContactTelController.text}' 
              : 'Non renseigné'
          ),
        ],
      ),

      SizedBox(height: 20),

      _buildRecapSection(
        'Documents',
        Icons.description,
        Colors.purple,
        [
          _buildRecapRow('Pièce d\'identité', _pieceIdentite?.path.split('/').last ?? 'Non téléchargée'),
        ],
      ),

      SizedBox(height: 20),

      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: orangeWarning.withAlpha(26), // .withOpacity(0.1) remplacé
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: orangeWarning.withAlpha(77)), // .withOpacity(0.3) remplacé
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: orangeWarning, size: 28),
            SizedBox(height: 10),
            Text(
              'Vérification Importante',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: orangeWarning,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Veuillez vérifier attentivement toutes les informations ci-dessus avant de finaliser votre souscription. Une fois validée, certaines modifications ne seront plus possibles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: grisTexte,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}

  Widget _buildRecapRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
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
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isHighlighted ? vertSucces : bleuCoris,
                fontSize: isHighlighted ? 13 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blanc,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // .withOpacity(0.05) remplacé
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(26), // .withOpacity(0.1) remplacé
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCombinedRecapRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
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
                    fontSize: 12,
                  ),
                ),
                Text(
                  value1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: bleuCoris,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label2 :',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: grisTexte,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value2,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: bleuCoris,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: blanc,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // .withOpacity(0.05) remplacé
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: bleuCoris, width: 2),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, color: bleuCoris, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Précédent',
                        style: TextStyle(
                          color: bleuCoris,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _currentStep == 2 ? _showPaymentOptions : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bleuCoris,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: bleuCoris.withAlpha(77), // .withOpacity(0.3) remplacé
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == 2 ? 'Finaliser' : 'Suivant',
                      style: TextStyle(
                        color: blanc,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      _currentStep == 2 ? Icons.check : Icons.arrow_forward,
                      color: blanc,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  final String paymentMethod;
  const _LoadingDialog({required this.paymentMethod});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26), // .withOpacity(0.1) remplacé
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: Color(0xFF002B6B),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Traitement en cours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF002B6B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Paiement via $paymentMethod...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ],
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
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26), // .withOpacity(0.1) remplacé
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isPaid ? Color(0xFF10B981).withAlpha(26) : Color(0xFFF59E0B).withAlpha(26), // .withOpacity(0.1) remplacé
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPaid ? Icons.check_circle : Icons.schedule,
                color: isPaid ? Color(0xFF10B981) : Color(0xFFF59E0B),
                size: 40,
              ),
            ),
            SizedBox(height: 20),
            Text(
              isPaid ? 'Souscription Réussie!' : 'Proposition Enregistrée!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF002B6B),
              ),
            ),
            SizedBox(height: 12),
            Text(
              isPaid
                ? 'Félicitations! Votre contrat CORIS ÉTUDE est maintenant actif. Vous recevrez un email de confirmation sous peu.'
                : 'Votre proposition a été enregistrée avec succès. Vous pouvez effectuer le paiement plus tard depuis votre espace client.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF002B6B),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBottomSheet extends StatelessWidget {
  final Function(String) onPayNow;
  final VoidCallback onPayLater;
  const _PaymentBottomSheet({
    required this.onPayNow,
    required this.onPayLater,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // .withOpacity(0.1) remplacé
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.payment, color: Color(0xFF002B6B), size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Options de Paiement',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF002B6B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildPaymentOption(
                'Wave',
                Icons.waves,
                Colors.blue,
                'Paiement mobile sécurisé',
                () => onPayNow('Wave'),
              ),
              SizedBox(height: 12),
              _buildPaymentOption(
                'Orange Money',
                Icons.phone_android,
                Colors.orange,
                'Paiement mobile Orange',
                () => onPayNow('Orange Money'),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OU',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onPayLater,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF002B6B), width: 2),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, color: Color(0xFF002B6B)),
                      SizedBox(width: 8),
                      Text(
                        'Payer plus tard',
                        style: TextStyle(
                          color: Color(0xFF002B6B),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withAlpha(51)), // .withOpacity(0.2) remplacé
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(26), // .withOpacity(0.1) remplacé
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF002B6B),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF64748B),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}