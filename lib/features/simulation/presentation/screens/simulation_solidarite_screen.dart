import 'package:flutter/material.dart';
import 'package:mycorislife/features/souscription/presentation/screens/sousription_solidarite.dart';


class SolidariteSimulationPage extends StatefulWidget {
  const SolidariteSimulationPage({super.key});

  @override
  State<SolidariteSimulationPage> createState() => _SolidariteSimulationPageState();
}

class _SolidariteSimulationPageState extends State<SolidariteSimulationPage> {
  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color rougeCoris = Color(0xFFE30613);
  static const Color vertCoris = Color(0xFF00A650);
  static const Color blanc = Colors.white;
  static const Color fondGris = Color(0xFFF5F7FA);
  static const Color texteGris = Color(0xFF666666);
  static const Color grisClair = Color(0xFFE0E0E0);

  int? selectedCapital = 500000;
  String selectedPeriodicite = 'Mensuel';
  int nbConjoints = 1;
  int nbEnfants = 1;
  int nbAscendants = 0;
  double? primeTotaleResult;

  final periodicites = ['Mensuel', 'Trimestriel', 'Semestriel', 'Annuel'];
  final capitalOptions = [500000, 1000000, 1500000, 2000000];

  // Tableaux tarifaires (à insérer manuellement)
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

// logique calcul
  void simulerPrime() {
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

  void _navigateToSubscription() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SouscriptionSolidaritePage(
        capital: selectedCapital,
        periodicite: selectedPeriodicite,
        nbConjoints: nbConjoints,
        nbEnfants: nbEnfants,
        nbAscendants: nbAscendants,
      ),
    ),
  );
}

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bleuCoris, Color(0xFF002B6B).withAlpha(204)], // .withOpacity(0.8) remplacé
        ),
        boxShadow: [
          BoxShadow(
            color: bleuCoris.withAlpha(77), // .withOpacity(0.3) remplacé
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
                  "CORIS SOLIDARITÉ",
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
      backgroundColor: fondGris,
      body: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Carte principale de simulation
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: blanc,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26), // .withOpacity(0.1) remplacé
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
                          // En-tête avec icône et titre
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: bleuCoris.withAlpha(26), // .withOpacity(0.1) remplacé
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
                          _buildStepper("Nombre de conjoints", nbConjoints, 1, 10, (val) {
                            setState(() => nbConjoints = val);
                          }),
                          _buildStepper("Nombre d'enfants", nbEnfants, 1, 20, (val) {
                            setState(() => nbEnfants = val);
                          }),
                          _buildStepper("Nombre d'ascendants", nbAscendants, 0, 4, (val) {
                            setState(() => nbAscendants = val);
                          }),
                          
                          const SizedBox(height: 20),
                          
                          // Bouton de simulation
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: simulerPrime,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: rougeCoris,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: const Row(
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
                  
                  // Carte de résultat
                  if (primeTotaleResult != null) _buildResultCard(),
                ],
              ),
            ),
          ),
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
            color: Colors.black.withAlpha(26), // .withOpacity(0.1) remplacé
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
          onChanged: (val) => setState(() => selectedCapital = val),
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
            color: Colors.black.withAlpha(26), // .withOpacity(0.1) remplacé
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
          onChanged: (val) => setState(() => selectedPeriodicite = val!),
        ),
      ),
    );
  }

  Widget _buildStepper(String label, int value, int min, int max, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF002B6B))),
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

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            vertCoris.withAlpha(26), // .withOpacity(0.1) remplacé
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vertCoris.withAlpha(51), width: 1), // .withOpacity(0.2) remplacé
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
                    color: vertCoris.withAlpha(26), // .withOpacity(0.1) remplacé
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.monetization_on, color: vertCoris, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Résultat de la simulation",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002B6B),
                        ),
                      ),
                      Text(
                        "Prime totale estimée",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
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
                border: Border.all(color: vertCoris.withAlpha(26)), // .withOpacity(0.1) remplacé
              ),
              child: Text(
                '${_formatNumber(primeTotaleResult!.toInt())} FCFA',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A650),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    onPressed: _navigateToSubscription, // Utiliser la nouvelle méthode
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