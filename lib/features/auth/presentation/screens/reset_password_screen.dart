import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mycorislife/config/theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final storage = const FlutterSecureStorage();

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        // A Remplacer par un appel API réel au backend Node.js
        await Future.delayed(const Duration(seconds: 2)); // Simulation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Un lien de réinitialisation a été envoyé à votre email."),
            ),
          );
          Navigator.pop(context); // Retour à la page de connexion
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : $e")),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.width * 0.045; 
    final padding = size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bleuCoris,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Réinitialiser le mot de passe",
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Réinitialiser votre mot de passe",
                    style: TextStyle(
                      fontSize: fontSize * 1.2,
                      fontWeight: FontWeight.bold,
                      color: bleuCoris,
                    ),
                  ),
                  SizedBox(height: fontSize),
                  Text(
                    "Entrez votre adresse email pour recevoir un lien de réinitialisation.",
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: fontSize * 0.8),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Adresse e-mail",
                      hintText: "idrissmikle@gmail.com",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: fontSize * 0.8,
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.white,
                        size: fontSize * 1.2,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: fontSize * 0.8,
                        vertical: fontSize * 0.7,
                      ),
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
                    style: TextStyle(fontSize: fontSize * 0.8),
                  ),
                  SizedBox(height: fontSize * 1.5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [rougeCoris, Color(0xFFE60000)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(fontSize * 0.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          minimumSize: Size(size.width * 0.35, fontSize * 2.5),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(fontSize * 0.5),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: fontSize,
                                height: fontSize,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Envoyer le lien",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize * 0.9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}