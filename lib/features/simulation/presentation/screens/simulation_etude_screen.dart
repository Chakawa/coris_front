import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_etude.dart';

class SimulationEtudeScreen extends StatefulWidget {
  const SimulationEtudeScreen({super.key});

  @override
  State<SimulationEtudeScreen> createState() => _SimulationEtudeScreenState();
}

class _SimulationEtudeScreenState extends State<SimulationEtudeScreen> {
  final _dateNaissanceParentController = TextEditingController();
  final _ageEnfantController = TextEditingController();
  final _valeurController = TextEditingController();

  String selectedOption = 'rente';
  String selectedPeriodicite = 'mensuel';
  double? result;
  String resultLabel = '';
  bool isLoading = false;
  int? ageParent;
  int? dureeContrat;

  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color rougeCoris = Color(0xFFE30613);
  static const Color vertCoris = Color(0xFF00A650);
  static const Color bleuClair = Color(0xFFE8F4FD);
  static const Color grisClairBg = Color(0xFFF8FAFB);

  // Tableau tarifaire pour les rentes fixes
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

  void _showProfessionalDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      backgroundColor.withAlpha(25),
                      Colors.transparent,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B6B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002B6B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Compris',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showError(String message) {
    _showProfessionalDialog(
      title: 'Paramètres invalides',
      message: message,
      icon: Icons.warning_rounded,
      iconColor: Colors.orange,
      backgroundColor: Colors.orange,
    );
  }

  void _updateAgeParent() {
    String dateText = _dateNaissanceParentController.text.trim();
    if (dateText.isNotEmpty) {
      try {
        DateTime dateNaissance = DateFormat('dd/MM/yyyy').parse(dateText);
        final now = DateTime.now();
        int age = now.year - dateNaissance.year;
        if (now.month < dateNaissance.month || 
            (now.month == dateNaissance.month && now.day < dateNaissance.day)) {
          age--;
        }
        
        setState(() {
          ageParent = age;
        });
      } catch (e) {
        setState(() {
          ageParent = null;
        });
      }
    } else {
      setState(() {
        ageParent = null;
      });
    }
  }

  void _updateDureeContrat() {
    String ageText = _ageEnfantController.text.trim();
    if (ageText.isNotEmpty) {
      int? age = int.tryParse(ageText);
      if (age != null && age >= 0 && age <= 17) {
        setState(() {
          dureeContrat = 17 - age;
        });
      } else {
        setState(() {
          dureeContrat = null;
        });
      }
    } else {
      setState(() {
        dureeContrat = null;
      });
    }
  }

  bool _validateInputs() {
    if (_dateNaissanceParentController.text.trim().isEmpty) {
      _showProfessionalDialog(
        title: 'Champ obligatoire',
        message: 'Veuillez renseigner la date de naissance du parent pour continuer la simulation.',
        icon: Icons.edit_outlined,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange,
      );
      return false;
    }

    if (ageParent == null || ageParent! < 18 || ageParent! > 60) {
      showError("L'âge du parent doit être compris entre 18 et 60 ans.");
      return false;
    }

    if (_ageEnfantController.text.trim().isEmpty) {
      _showProfessionalDialog(
        title: 'Champ obligatoire',
        message: 'Veuillez renseigner l\'âge de l\'enfant pour continuer la simulation.',
        icon: Icons.edit_outlined,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange,
      );
      return false;
    }

    int? ageEnfant = int.tryParse(_ageEnfantController.text);
    if (ageEnfant == null || ageEnfant < 0 || ageEnfant > 17) {
      showError("L'âge de l'enfant doit être compris entre 0 et 17 ans.");
      return false;
    }

    if (_valeurController.text.trim().isEmpty) {
      String fieldName = selectedOption == 'rente' ? 'prime' : 'rente souhaitée';
      _showProfessionalDialog(
        title: 'Champ obligatoire',
        message: 'Veuillez renseigner la $fieldName pour continuer la simulation.',
        icon: Icons.edit_outlined,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange,
      );
      return false;
    }

    return true;
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  void _formatMontantInput() {
    final text = _valeurController.text.replaceAll(' ', '');
    if (text.isNotEmpty) {
      final value = double.tryParse(text);
      if (value != null) {
        _valeurController.text = _formatNumber(value);
        _valeurController.selection = TextSelection.fromPosition(
          TextPosition(offset: _valeurController.text.length),
        );
      }
    }
  }

  double _convertToMensuel(double valeur, String periodicite) {
    switch (periodicite) {
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
    switch (periodicite) {
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

  void simuler() async {
    if (!_validateInputs()) return;

    setState(() {
      isLoading = true;
      result = null;
      resultLabel = '';
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      int ageParentValue = ageParent!;
      int ageEnfant = int.parse(_ageEnfantController.text);
      int dureeMois = ((17 - ageEnfant) * 12).round();
      dureeMois = closestDuree(dureeMois);

      double valeur = double.tryParse(_valeurController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
      if (valeur <= 0) {
        showError("Montant invalide.");
        setState(() => isLoading = false);
        return;
      }

      if (selectedOption == 'rente') {
        double primeMensuelle = _convertToMensuel(valeur, selectedPeriodicite);
        result = calculateRente(ageParentValue, dureeMois, primeMensuelle);
        if (result == 0) {
          showError("Aucune donnée disponible pour cet âge ou cette durée.");
          setState(() => isLoading = false);
          return;
        }
        resultLabel = "Rente annuelle au terme";
      } else {
        double renteSouhaitee = valeur;
        double primeMensuelle = calculatePrime(ageParentValue, dureeMois, renteSouhaitee);
        if (primeMensuelle == 0) {
          showError("Aucune donnée disponible pour cet âge ou cette durée.");
          setState(() => isLoading = false);
          return;
        }
        result = _convertFromMensuel(primeMensuelle, selectedPeriodicite);
        resultLabel = "Prime $selectedPeriodicite";
      }
    } catch (e) {
      showError("Une erreur est survenue lors du calcul. Veuillez vérifier vos données.");
    }

    setState(() => isLoading = false);
  }

  double calculateRente(int age, int dureeMois, double primeMensuelle) {
    if (!tarifRenteFixe.containsKey(age)) return 0;
    
    int dureeEffective = closestDuree(dureeMois);
    if (!tarifRenteFixe[age]!.containsKey(dureeEffective)) return 0;

    double primeMensuelleBase = tarifRenteFixe[age]![dureeEffective]!;
    return (primeMensuelle * 10000) / primeMensuelleBase;
  }

  double calculatePrime(int age, int dureeMois, double renteSouhaitee) {
    if (!tarifRenteFixe.containsKey(age)) return 0;
    
    int dureeEffective = closestDuree(dureeMois);
    if (!tarifRenteFixe[age]!.containsKey(dureeEffective)) return 0;

    double primeMensuelleBase = tarifRenteFixe[age]![dureeEffective]!;
    return (renteSouhaitee * primeMensuelleBase) / 10000;
  }

  int closestDuree(int mois) {
    final palliers = [60, 72, 84, 96, 108, 120, 132, 144, 156, 168, 180, 192, 204, 216, 228, 240];
    for (int p in palliers) {
      if (mois <= p) return p;
    }
    return 240;
  }

  void _resetSimulation() {
    setState(() {
      _dateNaissanceParentController.clear();
      _ageEnfantController.clear();
      _valeurController.clear();
      selectedOption = 'rente';
      selectedPeriodicite = 'mensuel';
      result = null;
      resultLabel = '';
      ageParent = null;
      dureeContrat = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClairBg,
      body: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSimulationCard(constraints),
                        const SizedBox(height: 16),
                        if (result != null) _buildResultCard(constraints),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bleuCoris,
            Color.alphaBlend(
              bleuCoris.withAlpha(204),
              Colors.transparent,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: bleuCoris.withAlpha(76),
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
              const Icon(Icons.school, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "CORIS ÉTUDE",
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

  Widget _buildSimulationCard(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: bleuCoris, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Paramètres de simulation",
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: bleuCoris,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildSimulationTypeDropdown(),
            const SizedBox(height: 16),
            
            _buildDateNaissanceParentField(constraints),
            const SizedBox(height: 16),
            
            _buildAgeEnfantField(constraints),
            const SizedBox(height: 16),
            
            _buildPeriodiciteDropdown(),
            const SizedBox(height: 16),
            
            _buildMontantField(constraints),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : simuler,
                style: ElevatedButton.styleFrom(
                  backgroundColor: rougeCoris,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_filled, size: 22),
                          SizedBox(width: 8),
                          Text(
                            "Simuler",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildSimulationTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: selectedOption == 'rente' ? 'Par Prime' : 'Par Rente',
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.calculate, color: Color(0xFF002B6B)),
            labelText: 'Type de simulation',
          ),
          items: const [
            DropdownMenuItem(
              value: 'Par Prime',
              child: Text('Par Prime'),
            ),
            DropdownMenuItem(
              value: 'Par Rente',
              child: Text('Par Rente'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedOption = value == 'Par Prime' ? 'rente' : 'prime';
              _valeurController.clear();
              result = null;
            });
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
            color: Colors.black.withAlpha(25),
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
          items: const [
            DropdownMenuItem(
              value: 'mensuel',
              child: Text('Mensuel'),
            ),
            DropdownMenuItem(
              value: 'trimestriel',
              child: Text('Trimestriel'),
            ),
            DropdownMenuItem(
              value: 'semestriel',
              child: Text('Semestriel'),
            ),
            DropdownMenuItem(
              value: 'annuel',
              child: Text('Annuel'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedPeriodicite = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateNaissanceParentField(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de naissance du parent',
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.035,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _dateNaissanceParentController,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
              firstDate: DateTime(1960),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
            );
            if (picked != null) {
              setState(() {
                _dateNaissanceParentController.text = DateFormat('dd/MM/yyyy').format(picked);
                _updateAgeParent();
              });
            }
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: 'JJ/MM/AAAA',
            hintStyle: TextStyle(fontSize: constraints.maxWidth * 0.035),
            prefixIcon: Icon(Icons.calendar_today, size: 20, color: bleuCoris.withAlpha(178)),
            suffixText: ageParent != null ? '($ageParent ans)' : null,
            filled: true,
            fillColor: bleuClair.withAlpha(76),
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
        if (ageParent != null && (ageParent! < 18 || ageParent! > 60))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'L\'âge du parent doit être compris entre 18 et 60 ans',
              style: TextStyle(
                color: Colors.orange,
                fontSize: constraints.maxWidth * 0.03,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAgeEnfantField(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Âge de l\'enfant',
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.035,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _ageEnfantController,
          keyboardType: TextInputType.number,
          onChanged: (value) => _updateDureeContrat(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: 'Ex: 5',
            hintStyle: TextStyle(fontSize: constraints.maxWidth * 0.035),
            prefixIcon: Icon(Icons.child_care, size: 20, color: bleuCoris.withAlpha(178)),
            suffixText: dureeContrat != null ? '($dureeContrat ans)' : null,
            filled: true,
            fillColor: bleuClair.withAlpha(76),
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
        if (_ageEnfantController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Durée du contrat: ${dureeContrat ?? 0} ans (${(dureeContrat ?? 0) * 12} mois)',
              style: TextStyle(
                color: bleuCoris,
                fontSize: constraints.maxWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMontantField(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedOption == 'rente'
              ? 'Prime $selectedPeriodicite souhaitée'
              : 'Rente souhaitée',
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.035,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _valeurController,
          keyboardType: TextInputType.number,
          onChanged: (value) => _formatMontantInput(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: 'Montant en FCFA',
            hintStyle: TextStyle(fontSize: constraints.maxWidth * 0.035),
            prefixIcon: Icon(Icons.monetization_on, size: 20, color: bleuCoris.withAlpha(178)),
            suffixText: 'CFA',
            filled: true,
            fillColor: bleuClair.withAlpha(76),
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

  Widget _buildResultCard(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            vertCoris.withAlpha(25),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vertCoris.withAlpha(51), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.05),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: vertCoris.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.monetization_on, color: vertCoris, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Résultat de la simulation",
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: bleuCoris,
                        ),
                      ),
                      Text(
                        resultLabel,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.035,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: bleuCoris),
                  onPressed: _resetSimulation,
                  tooltip: 'Nouvelle simulation',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: vertCoris.withAlpha(25)),
              ),
              child: Text(
                '${_formatNumber(result!)} FCFA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: constraints.maxWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: vertCoris,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SouscriptionEtudePage(
                        ageParent: ageParent,
                        ageEnfant: int.parse(_ageEnfantController.text),
                        prime: selectedOption == 'rente' 
                            ? double.parse(_valeurController.text.replaceAll(' ', ''))
                            : result!,
                        rente: selectedOption == 'prime'
                            ? double.parse(_valeurController.text.replaceAll(' ', ''))
                            : result!,
                        periodicite: selectedPeriodicite,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: vertCoris,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Souscrire",
                  style: TextStyle(
                    fontSize: 16,
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