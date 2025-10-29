import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mycorislife/config/theme.dart';
import 'package:mycorislife/services/auth_service.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;
  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
  final storage = const FlutterSecureStorage();

  // Contrôleurs pour stocker les données
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  DateTime? dateNaissance;
  final lieuNaissanceController = TextEditingController();

  final emailController = TextEditingController();
  final telephoneController = TextEditingController();
  final adresseController = TextEditingController();
  String? selectedPays = 'Côte d’Ivoire';
  String selectedIndicatif = '+225';

  final numeroPieceController = TextEditingController();
  final villeDelivranceController = TextEditingController();
  DateTime? dateDelivrance;
  DateTime? dateExpiration;
  final autoriteDelivranceController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedCivilite = 'Monsieur';
  String? selectedDocumentType = 'CNI';

  final List<Map<String, String>> indicatifs = [
    {'pays': 'Côte d’Ivoire', 'indicatif': '+225', 'flag': '🇨🇮'},
    {'pays': 'Burkina Faso', 'indicatif': '+226', 'flag': '🇧🇫'},
  ];

  void nextPage() {
    if (_currentPage < _formKeys.length && 
        _formKeys[_currentPage].currentState != null &&
        _formKeys[_currentPage].currentState!.validate() && 
        _currentPage < 2) {
      setState(() => _currentPage++);
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeInOut);
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _controller.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  bool get hasUppercase => passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => passwordController.text.contains(RegExp(r'[a-z]'));
  bool get hasDigit => passwordController.text.contains(RegExp(r'[0-9]'));
  bool get hasSpecial =>
      passwordController.text.contains(RegExp(r'[!@#\$&*~_.,;:^%()-]'));
  bool get hasMinLength => passwordController.text.length >= 8;

  bool get isPasswordValid =>
      hasUppercase && hasLowercase && hasDigit && hasSpecial && hasMinLength;

  Future<void> _register() async {
    if (_currentPage >= _formKeys.length) return;
    
    final form = _formKeys[_currentPage].currentState;
    if (form == null || !form.validate()) return;

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final payload = {
        "email": emailController.text.trim(),
        "password": passwordController.text,
        "nom": nomController.text.trim(),
        "prenom": prenomController.text.trim(),
        "civilite": selectedCivilite ?? "Monsieur",
        "date_naissance": dateNaissance?.toIso8601String().split('T').first,
        "lieu_naissance": lieuNaissanceController.text.trim(),
        "telephone": "$selectedIndicatif${telephoneController.text.replaceAll(RegExp(r'[^0-9]'), '')}",
        "adresse": adresseController.text.trim(),
        "pays": selectedPays ?? "Côte d'Ivoire",
      };

      await AuthService.registerClient(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text("Inscription réussie !"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Erreur: ${e.toString().replaceFirst('Exception: ', '')}"),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildCondition(bool condition, String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            condition ? Icons.check_circle : Icons.radio_button_unchecked,
            color: condition ? Colors.green : Colors.grey,
            size: fontSize * 0.9,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: condition ? Colors.black : Colors.grey[600],
              fontSize: fontSize * 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    TextInputType? inputType,
    String? hintText,
    String? Function(String?)? validator,
    required double fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: fontSize * 0.8),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: fontSize * 0.9)),
        SizedBox(height: fontSize * 0.3),
        TextFormField(
          controller: controller,
          keyboardType: inputType ?? TextInputType.text,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText ?? label,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: fontSize * 0.8),
            prefixIcon: icon != null
                ? Icon(icon, color: bleuCoris, size: fontSize * 1.2)
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
                horizontal: fontSize * 0.8, vertical: fontSize * 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fontSize * 0.4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fontSize * 0.4),
              borderSide: const BorderSide(color: bleuCoris, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fontSize * 0.4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fontSize * 0.4),
              borderSide: const BorderSide(color: rougeCoris, width: 2),
            ),
          ),
          style: TextStyle(fontSize: fontSize * 0.8),
        ),
      ],
    );
  }

  Widget _buildDateField(
  String label, {
  IconData? icon,
  required Function(DateTime?) onDateSelected,
  String? hintText,
  required DateTime? date,
  required double fontSize,
}) {
  String? value = date != null
      ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
      : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: fontSize * 0.8),
      Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: fontSize * 0.9)),
      SizedBox(height: fontSize * 0.3),
      GestureDetector(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: bleuCoris,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(foregroundColor: bleuCoris),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() => onDateSelected(picked));
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            readOnly: true,
            controller: TextEditingController(text: value ?? ''), // Contrôleur avec valeur
            decoration: InputDecoration(
              hintText: value == null ? (hintText ?? label) : null, // Pas de hint si date sélectionnée
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: fontSize * 0.8),
              prefixIcon: icon != null
                  ? Icon(icon, color: bleuCoris, size: fontSize * 1.2)
                  : null,
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(
                  horizontal: fontSize * 0.8, vertical: fontSize * 0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(fontSize * 0.4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(fontSize * 0.4),
                borderSide: const BorderSide(color: bleuCoris, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(fontSize * 0.4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(fontSize * 0.4),
                borderSide: const BorderSide(color: rougeCoris, width: 2),
              ),
            ),
            validator: (_) => date == null ? "Veuillez sélectionner une date." : null,
            style: TextStyle(fontSize: fontSize * 0.8),
          ),
        ),
      ),
    ],
  );
}
  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items, {
    IconData? icon,
    required Function(String?) onChanged,
    required double fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: fontSize * 0.8),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: fontSize * 0.9)),
        SizedBox(height: fontSize * 0.3),
        DropdownButtonFormField<String>(
          value: value,
          icon: Icon(Icons.arrow_drop_down, color: bleuCoris, size: fontSize * 1.2),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: fontSize * 0.8),
            prefixIcon: icon != null
                ? Icon(icon, color: bleuCoris, size: fontSize * 1.2)
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
                horizontal: fontSize * 0.8, vertical: fontSize * 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fontSize * 0.4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fontSize * 0.4),
              borderSide: const BorderSide(color: bleuCoris, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fontSize * 0.4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fontSize * 0.4),
              borderSide: const BorderSide(color: rougeCoris, width: 2),
            ),
          ),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(fontSize: fontSize * 0.8)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? "Veuillez sélectionner une option." : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.width * 0.045; 
    final padding = size.width * 0.05; 

    return Scaffold(
     appBar: AppBar(
  backgroundColor: bleuCoris,
  leading: _currentPage > 0
      ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: previousPage,
        )
      : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
  title: const Text(
    "Inscription",
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  centerTitle: true,
  elevation: 4,
  shadowColor: Colors.black45,
),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F4F8), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(padding),
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [rougeCoris, Color(0xFFE60000)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(padding * 0.6),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Étape ${_currentPage + 1} sur 3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize * 0.9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Étape 1 : Informations personnelles
                    Form(
                      key: _formKeys[0],
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          children: [
                       Text(
                              "Informations personnelles",
                              style: TextStyle(
                                fontSize: fontSize * 1.2,
                                fontWeight: FontWeight.bold,
                                color: bleuCoris,
                              ),
                            ),
                            _buildDropdown(
                              'Civilité',
                              selectedCivilite,
                              ['Monsieur', 'Madame', 'Mademoiselle'],
                              icon: Icons.person,
                              onChanged: (val) => setState(() => selectedCivilite = val),
                              fontSize: fontSize,
                            ),
                            _buildTextField(
                              'Nom',
                              nomController,
                              icon: Icons.person,
                              hintText: 'OUATTARA',
                              validator: (value) =>
                                  value!.isEmpty ? "Veuillez entrer votre nom." : null,
                              fontSize: fontSize,
                            ),
                            _buildTextField(
                              'Prénom',
                              prenomController,
                              icon: Icons.person_outline,
                              hintText: 'Drissa',
                              validator: (value) =>
                                  value!.isEmpty ? "Veuillez entrer votre prénom." : null,
                              fontSize: fontSize,
                            ),
                            _buildDateField(
                              'Date de naissance',
                              icon: Icons.calendar_today,
                              date: dateNaissance,
                              onDateSelected: (date) => setState(() => dateNaissance = date),
                              hintText: '01/01/1986',
                              fontSize: fontSize,
                            ),
                            _buildTextField(
                              'Lieu de naissance',
                              lieuNaissanceController,
                              icon: Icons.location_on,
                              validator: (value) => value!.isEmpty
                                  ? "Veuillez entrer votre lieu de naissance."
                                  : null,
                              fontSize: fontSize,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Étape 2 : Contact
                    Form(
                      key: _formKeys[1],
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          children: [
                            Text(
                              "Contact",
                              style: TextStyle(
                                fontSize: fontSize * 1.2,
                                fontWeight: FontWeight.bold,
                                color: bleuCoris,
                              ),
                            ),
                            _buildTextField(
                              'Adresse e-mail',
                              emailController,
                              icon: Icons.email,
                              inputType: TextInputType.emailAddress,
                              hintText: 'idrissmikle@gmail.com',
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Veuillez entrer votre email.";
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return "Veuillez entrer un email valide.";
                                }
                                return null;
                              },
                              fontSize: fontSize,
                            ),
                            SizedBox(height: fontSize * 0.8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Téléphone',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: fontSize * 0.9),
                              ),
                            ),
                            SizedBox(height: fontSize * 0.3),
                            Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    
    Container(
      width: size.width * 0.22, 
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(fontSize * 0.4),
      ),
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.2), 
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedIndicatif,
          isExpanded: true, 
          items: indicatifs.map((item) {
            return DropdownMenuItem<String>(
              value: item['indicatif'],
              child: Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Text(item['flag']!, style: TextStyle(fontSize: fontSize * 0.8)),
                  SizedBox(width: fontSize * 0.1),
                  Flexible( 
                    child: Text(
                      item['indicatif']!,
                      style: TextStyle(fontSize: fontSize * 0.7),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => selectedIndicatif = val!);
          },
        ),
      ),
    ),
                                SizedBox(width: fontSize * 0.3),
                                Expanded(
                                  child: TextFormField(
                                    controller: telephoneController,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Veuillez entrer votre numéro de téléphone.";
                                      }
                                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                        return "Veuillez entrer un numéro valide (10 chiffres).";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: '0798167534',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400], fontSize: fontSize * 0.8),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: fontSize * 0.8, vertical: fontSize * 0.7),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(fontSize * 0.4),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(fontSize * 0.4),
                                        borderSide: const BorderSide(color: bleuCoris, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(fontSize * 0.4),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(fontSize * 0.4),
                                        borderSide: const BorderSide(color: rougeCoris, width: 2),
                                      ),
                                    ),
                                    style: TextStyle(fontSize: fontSize * 0.8),
                                  ),
                                ),
                              ],
                            ),
                            _buildTextField(
                              'Adresse',
                              adresseController,
                              icon: Icons.location_city,
                              hintText: 'Treichville, Bernabe, 512',
                              validator: (value) =>
                                  value!.isEmpty ? "Veuillez entrer votre adresse." : null,
                              fontSize: fontSize,
                            ),
                            _buildDropdown(
                              'Pays de résidence',
                              selectedPays,
                              ['Côte d’Ivoire', 'Mali', 'Burkina Faso'],
                              icon: Icons.public,
                              onChanged: (val) => setState(() => selectedPays = val),
                              fontSize: fontSize,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Étape 3 : Pièce d'identité
                
                    
                    Form(
                      key: _formKeys[2],
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Créer un mot de passe",
                              style: TextStyle(
                                fontSize: fontSize * 1.2,
                                fontWeight: FontWeight.bold,
                                color: bleuCoris,
                              ),
                            ),
                            SizedBox(height: fontSize),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                if (!isPasswordValid) {
                                  return "Le mot de passe ne respecte pas les critères.";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                hintText: '********',
                                hintStyle:
                                    TextStyle(color: Colors.grey[400], fontSize: fontSize * 0.8),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(fontSize * 0.4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(fontSize * 0.4),
                                  borderSide: const BorderSide(color: bleuCoris, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(fontSize * 0.4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(fontSize * 0.4),
                                  borderSide: const BorderSide(color: rougeCoris, width: 2),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: bleuCoris,
                                    size: fontSize * 1.2,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              style: TextStyle(fontSize: fontSize * 0.8),
                            ),
                            SizedBox(height: fontSize * 0.8),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return "Les mots de passe ne correspondent pas.";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Confirmer le mot de passe',
                                hintText: '********',
                                hintStyle:
                                    TextStyle(color: Colors.grey[400], fontSize: fontSize * 0.8),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(fontSize * 0.4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(fontSize * 0.4),
                                  borderSide: const BorderSide(color: bleuCoris, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(fontSize * 0.4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(fontSize * 0.4),
                                  borderSide: const BorderSide(color: rougeCoris, width: 2),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: bleuCoris,
                                    size: fontSize * 1.2,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                              ),
                              style: TextStyle(fontSize: fontSize * 0.8),
                            ),
                            SizedBox(height: fontSize),
                            _buildCondition(hasUppercase, "✓ Une lettre majuscule", fontSize),
                            _buildCondition(hasLowercase, "✓ Une lettre minuscule", fontSize),
                            _buildCondition(hasDigit, "✓ Un chiffre", fontSize),
                            _buildCondition(hasSpecial, "✓ Un caractère spécial", fontSize),
                            _buildCondition(hasMinLength, "✓ 8 caractères minimum", fontSize),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
  padding: EdgeInsets.all(padding),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [

      if (_currentPage > 0)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(fontSize * 0.6),
            border: Border.all(
              color: bleuCoris,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: bleuCoris.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: previousPage,
            icon: const Icon(Icons.arrow_back, color: bleuCoris),
            label: Text(
              "Précédent",
              style: TextStyle(
                color: bleuCoris,
                fontSize: fontSize * 0.9,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              minimumSize: Size(size.width * 0.35, fontSize * 2.8),
              padding: EdgeInsets.symmetric(horizontal: fontSize * 0.8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(fontSize * 0.6),
              ),
            ),
          ),
        )
      else
        const SizedBox(width: 1),
        
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _currentPage == 2 &&
                    isPasswordValid &&
                    passwordController.text == confirmPasswordController.text
                ? [rougeCoris, const Color(0xFFE60000)]
                : _currentPage < 2
                    ? [bleuCoris, const Color(0xFF0041A3)]
                    : [Colors.grey[400]!, Colors.grey[500]!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(fontSize * 0.6),
          boxShadow: [
            BoxShadow(
              color: (_currentPage == 2 ? rougeCoris : bleuCoris).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : (_currentPage == 2
                  ? (isPasswordValid &&
                          passwordController.text == confirmPasswordController.text
                      ? _register
                      : null)
                  : nextPage),
          icon: isLoading
              ? SizedBox(
                  width: fontSize * 0.8,
                  height: fontSize * 0.8,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  _currentPage == 2 ? Icons.person_add : Icons.arrow_forward,
                  color: Colors.white,
                ),
          label: Text(
            _currentPage == 2 ? "Créer mon compte" : "Continuer",
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize * 0.9,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            minimumSize: Size(size.width * 0.4, fontSize * 2.8),
            padding: EdgeInsets.symmetric(horizontal: fontSize * 0.8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(fontSize * 0.6),
            ),
          ),
        ),
      ),
    ],
  ),
)
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    lieuNaissanceController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    numeroPieceController.dispose();
    villeDelivranceController.dispose();
    autoriteDelivranceController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }
}