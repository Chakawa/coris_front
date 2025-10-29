import 'package:flutter/material.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_retraite.dart';

class CorisRetraiteScreen extends StatefulWidget {
  const CorisRetraiteScreen({super.key});

  @override
  State<CorisRetraiteScreen> createState() => _CorisRetraiteScreenState();
}

class _CorisRetraiteScreenState extends State<CorisRetraiteScreen> {
  final _dureeController = TextEditingController();
  final _valeurController = TextEditingController();

  String selectedOption = 'capital';
  String selectedPeriodicite = 'annuel';
  double? result;
  String resultLabel = '';
  bool isLoading = false;

  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color rougeCoris = Color(0xFFE30613);
  static const Color vertCoris = Color(0xFF00A650);
  static const Color grisClairBg = Color(0xFFF8FAFB);

  // Tableau tarifaire (à insérer manuellement)
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

  void _resetSimulation() {
    setState(() {
      _dureeController.clear();
      _valeurController.clear();
      selectedOption = 'capital';
      selectedPeriodicite = 'annuel';
      result = null;
      resultLabel = '';
    });
  }

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
                    color: Color.alphaBlend(backgroundColor.withAlpha(25), Colors.white),
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

  bool _validateInputs() {
    if (_dureeController.text.trim().isEmpty) {
      _showProfessionalDialog(
        title: 'Champ obligatoire',
        message: 'Veuillez renseigner la durée du contrat pour continuer la simulation.',
        icon: Icons.edit_outlined,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange,
      );
      return false;
    }

    if (_valeurController.text.trim().isEmpty) {
      String fieldName = selectedOption == 'capital' ? 'capital souhaité' : 'prime à verser';
      _showProfessionalDialog(
        title: 'Champ obligatoire',
        message: 'Veuillez renseigner le $fieldName pour continuer la simulation.',
        icon: Icons.edit_outlined,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange,
      );
      return false;
    }

    return true;
  }

  String get currentHint {
    if (selectedOption == 'capital') {
      return 'Montant en FCFA';
    } else {
      final minPrime = minPrimes[selectedPeriodicite]!;
      return 'Minimum ${_formatNumber(minPrime.toDouble())} FCFA';
    }
  }

  double calculatePremium(int duration, String periodicity, double desiredCapital) {
    if (duration < 5 || duration > 50) {
      showError("Durée comprise entre 5 et 50 ans selon les principes du contrat CORIS RETRAITE.");
      return -1;
    }

    if (!premiumValues.containsKey(duration) || !premiumValues[duration]!.containsKey(periodicity)) {
      showError("Données non disponibles pour cette combinaison durée/périodicité.");
      return -1;
    }

    double primePour1Million = premiumValues[duration]![periodicity]!.toDouble();
    double calculatedPremium = (desiredCapital * primePour1Million) / 1000000;
    
    return calculatedPremium;
  }

  double calculateCapital(int duration, String periodicity, double paidPremium) {
    if (duration < 5 || duration > 50) {
      showError("Durée comprise entre 5 et 50 ans selon les principes du contrat CORIS RETRAITE.");
      return -1;
    }

    double minPremium = minPrimes[periodicity]!.toDouble();
    
    if (paidPremium < minPremium) {
      showError("Pour cette périodicité ($periodicity), la prime minimum est ${_formatNumber(minPremium)} FCFA.");
      return -1;
    }
    
    if (!premiumValues.containsKey(duration) || !premiumValues[duration]!.containsKey(periodicity)) {
      showError("Données non disponibles pour cette combinaison durée/périodicité.");
      return -1;
    }
    
    double primePour1Million = premiumValues[duration]![periodicity]!.toDouble();
    double calculatedCapital = (paidPremium * 1000000) / primePour1Million;
    
    return calculatedCapital;
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
      int duree = int.tryParse(_dureeController.text) ?? 0;
      double montant = double.tryParse(_valeurController.text.replaceAll(' ', '').replaceAll(',', '')) ?? 0;

      if (montant <= 0) {
        showError("Montant invalide. Veuillez entrer un montant positif.");
        setState(() => isLoading = false);
        return;
      }

      if (selectedOption == 'capital') {
        double calculatedPremium = calculatePremium(duree, selectedPeriodicite, montant);
        if (calculatedPremium != -1) {
          result = calculatedPremium;
          resultLabel = "Prime $selectedPeriodicite à verser";
        }
      } else {
        double calculatedCapital = calculateCapital(duree, selectedPeriodicite, montant);
        if (calculatedCapital != -1) {
          result = calculatedCapital;
          resultLabel = "Capital estimé au terme";
        }
      }
    } catch (e) {
      showError("Une erreur est survenue lors du calcul. Veuillez vérifier vos données.");
    }

    setState(() => isLoading = false);
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bleuCoris, Color.lerp(bleuCoris, Colors.black, 0.2)!],
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 43, 107, 0.3),
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
              const Icon(Icons.emoji_people, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "CORIS RETRAITE",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClairBg,
      body: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(0, 43, 107, 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.settings, color: bleuCoris, size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Paramètres de simulation",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF002B6B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          _buildSimulationTypeDropdown(),
                          const SizedBox(height: 16),
                          
                          _buildDureeField(),
                          const SizedBox(height: 16),
                          
                          _buildPeriodiciteDropdown(),
                          const SizedBox(height: 16),
                          
                          _buildMontantField(),
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
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (result != null) _buildResultCard(),
                ],
              ),
            ),
          ),
        ],
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
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: selectedOption,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.calculate, color: Color(0xFF002B6B)),
            labelText: 'Type de simulation',
          ),
          items: const [
            DropdownMenuItem(
              value: 'capital',
              child: Text('Par Capital'),
            ),
            DropdownMenuItem(
              value: 'prime',
              child: Text('Par Prime'),
            ),
          ],
          onChanged: (val) => setState(() {
            selectedOption = val!;
            _valeurController.clear();
            result = null;
          }),
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
            color: Color.fromRGBO(0, 0, 0, 0.1),
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
          onChanged: (val) => setState(() {
            selectedPeriodicite = val!;
            _valeurController.clear();
            result = null;
          }),
        ),
      ),
    );
  }

  Widget _buildDureeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durée du contrat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _dureeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: 'Entre 5 et 50 ans',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(Icons.schedule, size: 20, color: Color.fromRGBO(0, 43, 107, 0.7)),
            suffixText: 'ans',
            filled: true,
            fillColor: Color.fromRGBO(232, 244, 253, 0.3),
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

  Widget _buildMontantField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedOption == 'capital' ? 'Capital souhaité' : 'Prime à verser',
          style: TextStyle(
            fontSize: 16,
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
            hintText: currentHint,
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(Icons.monetization_on, size: 20, color: Color.fromRGBO(0, 43, 107, 0.7)),
            suffixText: 'FCFA',
            filled: true,
            fillColor: Color.fromRGBO(232, 244, 253, 0.3),
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

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(0, 166, 80, 0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromRGBO(0, 166, 80, 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 166, 80, 0.1),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: bleuCoris,
                        ),
                      ),
                      Text(
                        resultLabel,
                        style: TextStyle(
                          fontSize: 14,
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
                border: Border.all(color: Color.fromRGBO(0, 166, 80, 0.1)),
              ),
              child: Text(
                '${_formatNumber(result!)} FCFA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
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
                      builder: (context) => SouscriptionRetraitePage(
                        simulationData: {
                          'type': selectedOption,
                          'duree': int.parse(_dureeController.text),
                          'periodicite': selectedPeriodicite,
                          'capital': selectedOption == 'capital' 
                              ? double.parse(_valeurController.text.replaceAll(' ', ''))
                              : result!,
                          'prime': selectedOption == 'prime'
                              ? double.parse(_valeurController.text.replaceAll(' ', ''))
                              : result!,
                        },
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