import 'package:flutter/material.dart';
import 'package:mycorislife/features/souscription/presentation/screens/souscription_serenite.dart';

class SimulationSereniteScreen extends StatefulWidget {
  const SimulationSereniteScreen({super.key});

  @override
  State<SimulationSereniteScreen> createState() => _SimulationSereniteScreenState();
}

class _SimulationSereniteScreenState extends State<SimulationSereniteScreen> {
  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color rougeCoris = Color(0xFFE30613);
  static const Color vertCoris = Color(0xFF00A650);
  static const Color backgroundGrey = Color(0xFFF8FAFB);
  static const Color bleuClair = Color(0xFFE8F4FD);

  // Contrôleurs pour les champs de saisie
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _primeController = TextEditingController();
  final TextEditingController _dureeController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();

  // Variables d'état
  DateTime? _dateNaissance;
  int _dureeEnMois = 12;
  String _selectedUnite = 'mois';
  Periode _selectedPeriode = Periode.annuel;
  SimulationType _currentSimulation = SimulationType.parCapital;
  double _resultatCalcul = 0.0;
  bool _calculEffectue = false;
  bool _isLoading = false;
  String _selectedSimulationType = 'Par Capital';

  // Tableau tarifaire (à insérer manuellement)
  final Map<int, Map<int, double>> _tarifaire = {
    18: {12: 211.068, 24: 107.682, 36: 73.248, 48: 56.051, 60: 45.749, 72: 38.895, 84: 34.010, 96: 30.356, 108: 27.524, 120: 25.266, 132: 23.426, 144: 21.900, 156: 20.616, 168: 19.521, 180: 18.578},
  19: {12: 216.612, 24: 110.520, 36: 75.183, 48: 57.535, 60: 46.962, 72: 39.927, 84: 34.913, 96: 31.163, 108: 28.256, 120: 25.939, 132: 24.051, 144: 22.485, 156: 21.166, 168: 20.043, 180: 19.075},
  20: {12: 222.215, 24: 113.384, 36: 77.134, 48: 59.030, 60: 48.183, 72: 40.966, 84: 35.822, 96: 31.976, 108: 28.993, 120: 26.616, 132: 24.679, 144: 23.073, 156: 21.721, 168: 20.568, 180: 19.576},
  21: {12: 227.940, 24: 116.309, 36: 79.126, 48: 60.555, 60: 49.429, 72: 42.026, 84: 36.750, 96: 32.804, 108: 29.745, 120: 27.307, 132: 25.320, 144: 23.673, 156: 22.286, 168: 21.104, 180: 20.086},
  22: {12: 233.824, 24: 119.313, 36: 81.171, 48: 62.121, 60: 50.708, 72: 43.114, 84: 37.703, 96: 33.655, 108: 30.518, 120: 28.017, 132: 25.979, 144: 24.289, 156: 22.867, 168: 21.655, 180: 20.612},
  23: {12: 239.895, 24: 122.413, 36: 83.281, 48: 63.737, 60: 52.028, 72: 44.238, 84: 38.686, 96: 34.534, 108: 31.315, 120: 28.749, 132: 26.659, 144: 24.926, 156: 23.467, 168: 22.224, 180: 21.154},
  24: {12: 246.167, 24: 125.616, 36: 85.461, 48: 65.407, 60: 53.393, 72: 45.399, 84: 39.702, 96: 35.442, 108: 32.139, 120: 29.507, 132: 27.363, 144: 25.584, 156: 24.088, 168: 22.813, 180: 21.716},
  25: {12: 252.640, 24: 128.921, 36: 87.712, 48: 67.131, 60: 54.802, 72: 46.598, 84: 40.752, 96: 36.380, 108: 32.991, 120: 30.290, 132: 28.090, 144: 26.265, 156: 24.730, 168: 23.423, 180: 22.298},
  26: {12: 259.322, 24: 132.334, 36: 90.037, 48: 68.912, 60: 56.257, 72: 47.837, 84: 41.837, 96: 37.349, 108: 33.871, 120: 31.099, 132: 28.841, 144: 26.970, 156: 25.395, 168: 24.054, 180: 22.900},
  27: {12: 266.209, 24: 135.852, 36: 92.433, 48: 70.748, 60: 57.757, 72: 49.114, 84: 42.955, 96: 38.349, 108: 34.779, 120: 31.934, 132: 29.617, 144: 27.697, 156: 26.081, 168: 24.705, 180: 23.522},
  28: {12: 273.306, 24: 139.478, 36: 94.903, 48: 72.640, 60: 59.303, 72: 50.430, 84: 44.107, 96: 39.380, 108: 35.715, 120: 32.796, 132: 30.419, 144: 28.448, 156: 26.791, 168: 25.379, 180: 24.166},
  29: {12: 280.625, 24: 143.217, 36: 97.449, 48: 74.592, 60: 60.898, 72: 51.788, 84: 45.297, 96: 40.444, 108: 36.683, 120: 33.687, 132: 31.247, 144: 29.225, 156: 27.525, 168: 26.077, 180: 24.833},
  30: {12: 288.169, 24: 147.071, 36: 100.074, 48: 76.603, 60: 62.543, 72: 53.190, 84: 46.526, 96: 41.544, 108: 37.683, 120: 34.608, 132: 32.104, 144: 30.029, 156: 28.284, 168: 26.800, 180: 25.524},
  31: {12: 295.952, 24: 151.047, 36: 102.783, 48: 78.680, 60: 64.242, 72: 54.638, 84: 47.796, 96: 42.681, 108: 38.718, 120: 35.561, 132: 32.991, 144: 30.862, 156: 29.073, 168: 27.550, 180: 26.242},
  32: {12: 303.987, 24: 155.154, 36: 105.583, 48: 80.828, 60: 66.001, 72: 56.138, 84: 49.112, 96: 43.860, 108: 39.790, 120: 36.550, 132: 33.912, 144: 31.728, 156: 29.892, 168: 28.330, 180: 26.988},
  33: {12: 312.260, 24: 159.385, 36: 108.470, 48: 83.044, 60: 67.816, 72: 57.686, 84: 50.471, 96: 45.077, 108: 40.900, 120: 37.573, 132: 34.866, 144: 32.624, 156: 30.741, 168: 29.139, 180: 27.763},
  34: {12: 320.759, 24: 163.736, 36: 111.439, 48: 85.324, 60: 69.684, 72: 59.280, 84: 51.871, 96: 46.333, 108: 42.044, 120: 38.629, 132: 35.851, 144: 33.551, 156: 31.619, 168: 29.976, 180: 28.565},
  35: {12: 329.461, 24: 168.191, 36: 114.481, 48: 87.661, 60: 71.599, 72: 60.916, 84: 53.308, 96: 47.623, 108: 43.220, 120: 39.716, 132: 36.865, 144: 34.505, 156: 32.523, 168: 30.839, 180: 29.392},
  36: {12: 338.379, 24: 172.759, 36: 117.601, 48: 90.059, 60: 73.566, 72: 62.597, 84: 54.787, 96: 48.951, 108: 44.432, 120: 40.836, 132: 37.911, 144: 35.490, 156: 33.457, 168: 31.730, 180: 30.247},
  37: {12: 347.501, 24: 177.433, 36: 120.795, 48: 92.516, 60: 75.582, 72: 64.322, 84: 56.305, 96: 50.315, 108: 45.678, 120: 41.988, 132: 38.987, 144: 36.504, 156: 34.420, 168: 32.648, 180: 31.128},
  38: {12: 356.831, 24: 182.217, 36: 124.067, 48: 95.035, 60: 77.651, 72: 66.093, 84: 57.865, 96: 51.718, 108: 46.960, 120: 43.174, 132: 40.096, 144: 37.550, 156: 35.412, 168: 33.595, 180: 32.036},
  39: {12: 366.360, 24: 187.107, 36: 127.414, 48: 97.614, 60: 79.772, 72: 67.910, 84: 59.466, 96: 53.159, 108: 48.278, 120: 44.394, 132: 41.237, 144: 38.625, 156: 36.433, 168: 34.570, 180: 32.972},
  40: {12: 376.073, 24: 192.096, 36: 130.834, 48: 100.251, 60: 81.942, 72: 69.770, 84: 61.107, 96: 54.636, 108: 49.629, 120: 45.646, 132: 42.408, 144: 39.729, 156: 37.481, 168: 35.572, 180: 33.934},
  41: {12: 385.954, 24: 197.179, 36: 134.320, 48: 102.942, 60: 84.157, 72: 71.671, 84: 62.784, 96: 56.147, 108: 51.011, 120: 46.926, 132: 43.606, 144: 40.860, 156: 38.555, 168: 36.599, 180: 34.921},
  42: {12: 395.974, 24: 202.335, 36: 137.859, 48: 105.675, 60: 86.410, 72: 73.604, 84: 64.491, 96: 57.685, 108: 52.419, 120: 48.231, 132: 44.827, 144: 42.012, 156: 39.650, 168: 37.646, 180: 35.927},
  43: {12: 406.137, 24: 207.570, 36: 141.455, 48: 108.454, 60: 88.701, 72: 75.572, 84: 66.228, 96: 59.251, 108: 53.853, 120: 49.560, 132: 46.071, 144: 43.187, 156: 40.768, 168: 38.715, 180: 36.956},
  44: {12: 416.435, 24: 212.878, 36: 145.103, 48: 111.276, 60: 91.028, 72: 77.570, 84: 67.993, 96: 60.842, 108: 55.310, 120: 50.911, 132: 47.337, 144: 44.383, 156: 41.906, 168: 39.804, 180: 38.004},
  45: {12: 426.866, 24: 218.258, 36: 148.803, 48: 114.138, 60: 93.388, 72: 79.598, 84: 69.785, 96: 62.458, 108: 56.790, 120: 52.285, 132: 48.625, 144: 45.600, 156: 43.065, 168: 40.915, 180: 39.074},
  46: {12: 437.430, 24: 223.709, 36: 152.552, 48: 117.037, 60: 95.780, 72: 81.653, 84: 71.601, 96: 64.097, 108: 58.293, 120: 53.680, 132: 49.933, 144: 46.838, 156: 44.244, 168: 42.046, 180: 40.167},
  47: {12: 448.143, 24: 229.236, 36: 156.353, 48: 119.978, 60: 98.206, 72: 83.738, 84: 73.445, 96: 65.762, 108: 59.821, 120: 55.099, 132: 51.265, 144: 48.099, 156: 45.448, 168: 43.203, 180: 41.285},
  48: {12: 459.029, 24: 234.853, 36: 160.217, 48: 122.968, 60: 100.675, 72: 85.861, 84: 75.324, 96: 67.459, 108: 61.379, 120: 56.547, 132: 52.626, 144: 49.390, 156: 46.682, 168: 44.391, 180: 42.436},
  49: {12: 470.112, 24: 240.573, 36: 164.153, 48: 126.015, 60: 103.192, 72: 88.028, 84: 77.242, 96: 69.194, 108: 62.972, 120: 58.031, 132: 54.022, 144: 50.716, 156: 47.952, 168: 45.616, 180: 43.625},
  50: {12: 481.407, 24: 246.404, 36: 168.168, 48: 129.126, 60: 105.764, 72: 90.243, 84: 79.206, 96: 70.970, 108: 64.606, 120: 59.554, 132: 55.459, 144: 52.084, 156: 49.265, 168: 46.886, 180: 44.859},
  51: {12: 492.933, 24: 252.360, 36: 172.273, 48: 132.309, 60: 108.398, 72: 92.514, 84: 81.219, 96: 72.795, 108: 66.288, 120: 61.126, 132: 56.945, 144: 53.501, 156: 50.629, 168: 48.206, 180: 46.145},
  52: {12: 504.687, 24: 258.439, 36: 176.465, 48: 135.563, 60: 111.092, 72: 94.839, 84: 83.284, 96: 74.670, 108: 68.021, 120: 62.749, 132: 58.482, 144: 54.971, 156: 52.045, 168: 49.581, 180: 47.487},
  53: {12: 516.671, 24: 264.642, 36: 180.747, 48: 138.890, 60: 113.849, 72: 97.221, 84: 85.406, 96: 76.602, 108: 69.809, 120: 64.428, 132: 60.077, 144: 56.500, 156: 53.522, 168: 51.017, 180: 48.892},
  54: {12: 528.894, 24: 270.975, 36: 185.123, 48: 142.291, 60: 116.674, 72: 99.670, 84: 87.592, 96: 78.598, 108: 71.663, 120: 66.174, 132: 61.738, 144: 58.096, 156: 55.066, 168: 52.522, 180: 50.366},
  55: {12: 541.357, 24: 277.437, 36: 189.591, 48: 145.774, 60: 119.575, 72: 102.192, 84: 89.851, 96: 80.666, 108: 73.589, 120: 67.991, 132: 63.472, 144: 59.765, 156: 56.686, 168: 54.102, 180: 51.917},
  56: {12: 554.072, 24: 284.035, 36: 194.170, 48: 149.355, 60: 122.569, 72: 104.803, 84: 92.197, 96: 82.820, 108: 75.600, 120: 69.893, 132: 65.291, 144: 61.520, 156: 58.391, 168: 55.768, 180: 53.555},
  57: {12: 567.054, 24: 290.806, 36: 198.885, 48: 153.059, 60: 125.676, 72: 107.522, 84: 94.647, 96: 85.074, 108: 77.709, 120: 71.893, 132: 67.208, 144: 63.372, 156: 60.193, 168: 57.532, 180: 55.289},
  58: {12: 580.212, 24: 297.691, 36: 203.704, 48: 156.855, 60: 128.872, 72: 110.327, 84: 97.180, 96: 87.413, 108: 79.904, 120: 73.979, 132: 69.209, 144: 65.309, 156: 62.080, 168: 59.383, 180: 57.113},
  59: {12: 593.509, 24: 304.693, 36: 208.618, 48: 160.744, 60: 132.156, 72: 113.217, 84: 99.798, 96: 89.836, 108: 82.183, 120: 76.148, 132: 71.295, 144: 67.331, 156: 64.054, 168: 61.322, 180: 59.028},
  60: {12: 606.852, 24: 311.731, 36: 213.582, 48: 164.684, 60: 135.492, 72: 116.163, 84: 102.476, 96: 92.321, 108: 84.524, 120: 78.382, 132: 73.447, 144: 69.421, 156: 66.100, 168: 63.336, 180: 61.021},
  61: {12: 620.256, 24: 318.848, 36: 218.619, 48: 168.693, 60: 138.900, 72: 119.183, 84: 105.228, 96: 94.880, 108: 86.940, 120: 80.691, 132: 75.676, 144: 71.592, 156: 68.228, 168: 65.435, 180: 63.104},
  62: {12: 633.637, 24: 325.971, 36: 223.673, 48: 172.734, 60: 142.348, 72: 122.247, 84: 108.027, 96: 97.488, 108: 89.409, 120: 83.056, 132: 77.966, 144: 73.827, 156: 70.425, 168: 67.609, 180: 65.264},
  63: {12: 647.006, 24: 333.107, 36: 228.764, 48: 176.822, 60: 145.849, 72: 125.365, 84: 110.881, 96: 100.154, 108: 91.938, 120: 85.486, 132: 80.324, 144: 76.136, 156: 72.701, 168: 69.865, 180: 67.515},
  64: {12: 660.380, 24: 340.302, 36: 233.920, 48: 180.977, 60: 149.412, 72: 128.545, 84: 113.799, 96: 102.887, 108: 94.539, 120: 87.993, 132: 82.764, 144: 78.530, 156: 75.068, 168: 72.219, 180: 69.868},
  65: {12: 673.678, 24: 347.480, 36: 239.085, 48: 185.144, 60: 152.995, 72: 131.752, 84: 116.752, 96: 105.663, 108: 97.189, 120: 90.555, 132: 85.266, 144: 80.994, 156: 77.512, 168: 74.658, 180: 72.315},
  66: {12: 687.096, 24: 354.662, 36: 244.254, 48: 189.326, 60: 156.602, 72: 134.993, 84: 119.748, 96: 108.489, 108: 99.898, 120: 93.183, 132: 87.841, 144: 83.539, 156: 80.045, 168: 77.196, 180: 74.871},
  67: {12: 700.093, 24: 361.797, 36: 249.407, 48: 193.511, 60: 160.228, 72: 138.267, 84: 122.786, 96: 111.367, 108: 102.667, 120: 95.880, 132: 90.496, 144: 86.173, 156: 82.678, 168: 79.844, 180: 77.549},
  68: {12: 713.310, 24: 368.993, 36: 254.629, 48: 197.774, 60: 163.940, 72: 141.631, 84: 125.922, 96: 114.349, 108: 105.547, 120: 98.697, 132: 93.278, 144: 88.945, 156: 85.459, 168: 82.653, 180: 80.403},
  69: {12: 725.580, 24: 376.248, 36: 259.924, 48: 202.119, 60: 167.741, 72: 145.092, 84: 129.161, 96: 117.443, 108: 108.548, 120: 101.644, 132: 96.202, 144: 91.870, 156: 88.409, 168: 85.646, 180: 83.457},
  };

  @override
  void initState() {
    super.initState();
    _capitalController.addListener(() => _formatTextField(_capitalController));
    _primeController.addListener(() => _formatTextField(_primeController));
  }

  @override
  void dispose() {
    _capitalController.dispose();
    _primeController.dispose();
    _dureeController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

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

  int _calculateAge() {
    if (_dateNaissance == null) return 0;
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - _dateNaissance!.year;
    if (currentDate.month < _dateNaissance!.month || 
        (currentDate.month == _dateNaissance!.month && currentDate.day < _dateNaissance!.day)) {
      age--;
    }
    return age;
  }

  bool _isAgeValid() {
    int age = _calculateAge();
    return age >= 18 && age <= 69;
  }

  int _findDureeTarifaire(int dureeSaisie) {
    if (_tarifaire.isEmpty) return dureeSaisie;
    
    List<int> durees = _tarifaire[18]!.keys.toList()..sort();
    for (int duree in durees) {
      if (duree >= dureeSaisie) return duree;
    }
    return durees.last;
  }

  double _getPrimePour1000() {
    int age = _calculateAge();
    int duree = _findDureeTarifaire(_dureeEnMois);
    
    if (_tarifaire.isEmpty) return 0.0;
    
    if (!_tarifaire.containsKey(age)) {
      List<int> ages = _tarifaire.keys.toList()..sort();
      for (int a in ages) {
        if (a >= age) {
          age = a;
          break;
        }
      }
      if (age > ages.last) age = ages.last;
    }
    
    return _tarifaire[age]?[duree] ?? 0.0;
  }

  double _getCoefficientPeriodicite() {
    switch (_selectedPeriode) {
      case Periode.mensuel:
        return 1.04 / 12;
      case Periode.trimestriel:
        return 1.03 / 4;
      case Periode.semestriel:
        return 1.02 / 2;
      case Periode.annuel:
        return 1.0;
    }
  }

  void _resetSimulation() {
    setState(() {
      _capitalController.clear();
      _primeController.clear();
      _dureeController.clear();
      _dateNaissanceController.clear();
      _dateNaissance = null;
      _selectedPeriode = Periode.annuel;
      _currentSimulation = SimulationType.parCapital;
      _selectedSimulationType = 'Par Capital';
      _calculEffectue = false;
      _resultatCalcul = 0.0;
    });
  }

  void _navigateToSubscription() {
  // Préparer les données de simulation
  final simulationData = {
    'capital': _currentSimulation == SimulationType.parCapital 
        ? double.tryParse(_capitalController.text.replaceAll(' ', '')) 
        : null,
    'prime': _currentSimulation == SimulationType.parPrime
        ? double.tryParse(_primeController.text.replaceAll(' ', ''))
        : null,
    'duree': int.tryParse(_dureeController.text),
    'dureeUnite': _selectedUnite,
    'periodicite': _getPeriodeText(),
    'resultat': _resultatCalcul,
    'typeSimulation': _currentSimulation == SimulationType.parCapital ? 'Par Capital' : 'Par Prime',
  };

  // Naviguer vers la page de souscription
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SouscriptionSerenitePage(simulationData: simulationData),
    ),
  );
}

  void _effectuerCalcul() async {
    if (_dateNaissance == null || !_isAgeValid()) {
      _showMessage("Veuillez saisir une date de naissance valide (âge entre 18 et 69 ans)");
      return;
    }

    double primePour1000 = _getPrimePour1000();
    if (primePour1000 == 0.0) {
      _showMessage("Erreur lors de la lecture du tableau tarifaire");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _calculEffectue = true;
      _isLoading = false;
      double coefficient = _getCoefficientPeriodicite();
      
      if (_currentSimulation == SimulationType.parCapital) {
        String capitalText = _capitalController.text.replaceAll(' ', '');
        double capital = double.tryParse(capitalText) ?? 0;
        if (capital <= 0) {
          _showMessage("Veuillez saisir un capital valide");
          _calculEffectue = false;
          return;
        }
        
        double primeAnnuelle = (capital / 1000) * primePour1000;
        
        if (_selectedPeriode == Periode.annuel) {
          _resultatCalcul = primeAnnuelle;
        } else {
          _resultatCalcul = primeAnnuelle * coefficient;
        }
      } else {
        String primeText = _primeController.text.replaceAll(' ', '');
        double prime = double.tryParse(primeText) ?? 0;
        if (prime <= 0) {
          _showMessage("Veuillez saisir une prime valide");
          _calculEffectue = false;
          return;
        }
        
        double primeAnnuellePour1000 = primePour1000;
        double primePeriodiquePour1000;
        
        if (_selectedPeriode == Periode.annuel) {
          primePeriodiquePour1000 = primeAnnuellePour1000;
        } else {
          primePeriodiquePour1000 = primeAnnuellePour1000 * coefficient;
        }
        
        _resultatCalcul = (prime / primePeriodiquePour1000) * 1000;
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: rougeCoris,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onSimulationTypeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedSimulationType = newValue;
        _currentSimulation = newValue == 'Par Capital' 
            ? SimulationType.parCapital 
            : SimulationType.parPrime;
        _calculEffectue = false;
        _resultatCalcul = 0.0;
      });
    }
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
              const Icon(Icons.health_and_safety, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "CORIS SÉRÉNITÉ PLUS",
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
    int age = _calculateAge();
    String ageText = age > 0 ? "($age ans)" : "";

    return Scaffold(
      backgroundColor: backgroundGrey,
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
                      color: Colors.white,
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
                          
                          // Sélecteur de type de simulation
                          _buildSimulationTypeDropdown(),
                          const SizedBox(height: 16),
                          
                          // Champ pour le capital/prime
                          _buildMontantField(),
                          const SizedBox(height: 16),
                          
                          // Champ pour la date de naissance
                          _buildDateNaissanceField(ageText),
                          const SizedBox(height: 16),
                          
                          // Champ pour la durée
                          _buildDureeField(),
                          const SizedBox(height: 16),
                          
                          // Sélecteur de périodicité
                          _buildPeriodiciteDropdown(),
                          const SizedBox(height: 20),
                          
                          // Bouton de simulation
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _effectuerCalcul,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: rougeCoris,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: _isLoading
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
                  
                  // Carte de résultat
                  if (_calculEffectue) _buildResultCard(),
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
            color: Colors.black.withAlpha(26), // .withOpacity(0.1) remplacé
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: _selectedSimulationType,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.calculate, color: Color(0xFF002B6B)),
            labelText: 'Type de simulation',
          ),
          items: const [
            DropdownMenuItem(
              value: 'Par Capital',
              child: Text('Par Capital'),
            ),
            DropdownMenuItem(
              value: 'Par Prime',
              child: Text('Par Prime'),
            ),
          ],
          onChanged: _onSimulationTypeChanged,
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
        child: DropdownButtonFormField<Periode>(
          value: _selectedPeriode,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF002B6B)),
            labelText: 'Périodicité',
          ),
          items: [
            DropdownMenuItem(
              value: Periode.mensuel,
              child: const Text('Mensuel'),
            ),
            DropdownMenuItem(
              value: Periode.trimestriel,
              child: const Text('Trimestriel'),
            ),
            DropdownMenuItem(
              value: Periode.semestriel,
              child: const Text('Semestriel'),
            ),
            DropdownMenuItem(
              value: Periode.annuel,
              child: const Text('Annuel'),
            ),
          ],
          onChanged: (Periode? newValue) {
            setState(() {
              _selectedPeriode = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildMontantField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentSimulation == SimulationType.parCapital 
              ? 'Capital souhaité' 
              : 'Prime à verser',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _currentSimulation == SimulationType.parCapital 
              ? _capitalController 
              : _primeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: 'Ex: 1 000 000',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(Icons.monetization_on, size: 20, color: bleuCoris.withAlpha(179)), // .withOpacity(0.7) remplacé
            suffixText: 'FCFA',
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

  Widget _buildDateNaissanceField(String ageText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de naissance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _dateNaissanceController,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
              firstDate: DateTime(1950),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
            );
            if (picked != null) {
              setState(() {
                _dateNaissance = picked;
                _dateNaissanceController.text = "${picked.day}/${picked.month}/${picked.year}";
              });
            }
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: 'JJ/MM/AAAA',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(Icons.calendar_today, size: 20, color: bleuCoris.withAlpha(179)), // .withOpacity(0.7) remplacé
            suffixText: ageText,
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

  Widget _buildDureeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durée',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: bleuCoris,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _dureeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  hintText: 'Saisir la durée',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.calendar_month, size: 20, color: bleuCoris.withAlpha(179)), // .withOpacity(0.7) remplacé
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
                onChanged: (value) {
                  int? duree = int.tryParse(value);
                  if (duree != null) {
                    setState(() {
                      _dureeEnMois = _selectedUnite == 'années' ? duree * 12 : duree;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedUnite,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                items: const [
                  DropdownMenuItem(
                    value: 'mois',
                    child: Text('Mois'),
                  ),
                  DropdownMenuItem(
                    value: 'années',
                    child: Text('Années'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnite = newValue!;
                    if (_dureeController.text.isNotEmpty) {
                      int duree = int.tryParse(_dureeController.text) ?? 0;
                      _dureeEnMois = _selectedUnite == 'années' ? duree * 12 : duree;
                    }
                  });
                },
              ),
            ),
          ],
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
                        _currentSimulation == SimulationType.parCapital 
                            ? "Prime ${_getPeriodeText()} à verser" 
                            : "Capital garanti",
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
                border: Border.all(color: vertCoris.withAlpha(26)), // .withOpacity(0.1) remplacé
              ),
              child: Text(
                '${_formatNumber(_resultatCalcul)} FCFA',
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
    onPressed: _navigateToSubscription, 
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

  String _getPeriodeText() {
    switch (_selectedPeriode) {
      case Periode.mensuel:
        return 'mensuelle';
      case Periode.trimestriel:
        return 'trimestrielle';
      case Periode.semestriel:
        return 'semestrielle';
      case Periode.annuel:
        return 'annuelle';
    }
  }
}

enum Periode { mensuel, trimestriel, semestriel, annuel }
enum SimulationType { parCapital, parPrime }