import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  static const Color bleuCoris = Color(0xFF002B6B);
  static const Color rougeCoris = Color(0xFFE30613);
  static const Color blanc = Colors.white;
  static const Color fondGris = Color(0xFFF0F4F8);
  static const Color vertAccent = Color(0xFF10B981);
  static const Color orangeAccent = Color(0xFFF59E0B);

  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondGris,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: bleuCoris,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Mon Profil',
                style: TextStyle(
                  color: blanc,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF002B6B),
                      Color(0xFF003A85),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 80,
                    color: blanc,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: blanc),
                onPressed: () {
                  _showNotifications(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: blanc),
                onPressed: () {
                  _showSettings(context);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildUserProfileCard(context),
                const SizedBox(height: 24),
                _buildSettingsSection(
                  context,
                  title: 'Gestion des Contrats',
                  icon: Icons.assignment_outlined,
                  items: [
                    ProfileMenuItem(
                      icon: Icons.add_circle_outline,
                      title: 'Rattacher un contrat',
                      subtitle: 'Associer un nouveau contrat à votre profil',
                      iconColor: vertAccent,
                      onTap: () => _showContractDialog(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Rattacher une proposition',
                      subtitle: 'Lier une proposition d\'assurance',
                      iconColor: orangeAccent,
                      onTap: () => _showPropositionDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSettingsSection(
                  context,
                  title: 'Informations personnelles',
                  icon: Icons.person_outline,
                  items: [
                    ProfileMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Modifier votre profil',
                      subtitle: 'Mettre à jour vos informations',
                      onTap: () {
                        _navigateToEditProfile(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSettingsSection(
                  context,
                  title: 'Sécurité & Vérification',
                  icon: Icons.security_outlined,
                  items: [
                    ProfileMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Modifier votre mot de passe',
                      subtitle: 'Changer votre mot de passe actuel',
                      onTap: () {
                        _navigateToChangePassword(context);
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Authentification à deux facteurs',
                      subtitle: 'Sécuriser davantage votre compte',
                      onTap: () {
                        _navigateTo2FA(context);
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Documents KYC',
                      subtitle: 'Vérification d\'identité complétée',
                      iconColor: vertAccent,
                      trailing: const Icon(Icons.check_circle, color: vertAccent, size: 20),
                      onTap: () {
                        _navigateToDocuments(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSettingsSection(
                  context,
                  title: 'Support & Contact',
                  icon: Icons.support_agent_outlined,
                  items: [
                    ProfileMenuItem(
                      icon: Icons.help_center_outlined,
                      title: 'Centre d\'aide',
                      subtitle: 'FAQ, guides et contact',
                      onTap: () {
                        _showHelpAndSupport(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSettingsSection(
                  context,
                  items: [
                    ProfileMenuItem(
                      icon: Icons.logout_outlined,
                      title: 'Se déconnecter',
                      subtitle: 'Fermer votre session en toute sécurité',
                      iconColor: rougeCoris,
                      titleColor: rougeCoris,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: blanc,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withAlpha(20),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF002B6B), Color(0xFF003A85)],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 36,
                  backgroundImage: AssetImage('assets/images/user_avatar.png'),
                  backgroundColor: Color(0xFFF0F4F8),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: vertAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: blanc, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: blanc,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nom de l\'utilisateur',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: bleuCoris,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'esatic@gmail.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: vertAccent.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Client Vérifié',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection(
    BuildContext context, {
    String? title,
    IconData? icon,
    required List<ProfileMenuItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withAlpha(13),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8.0),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: bleuCoris, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002B6B),
                    ),
                  ),
                ],
              ),
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: fondGris.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Page des notifications en cours de développement'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Page des paramètres en cours de développement'),
        backgroundColor: Color(0xFF002B6B),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers la modification de profil'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers la modification du mot de passe'),
        backgroundColor: Color(0xFF002B6B),
      ),
    );
  }

  void _navigateTo2FA(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers l\'authentification à deux facteurs'),
        backgroundColor: Color(0xFFF59E0B),
      ),
    );
  }

  void _navigateToDocuments(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers les documents KYC'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _showHelpAndSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.help_center_outlined, color: Color(0xFF002B6B)),
              SizedBox(width: 8),
              Text('Centre d\'Aide'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Service d\'aide et support en cours de développement'),
              SizedBox(height: 16),
              Text('Contact: support@coris.com'),
              Text('Téléphone: +225 27 20 21 22 23'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Déconnexion effectuée avec succès'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showContractDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.assignment_outlined, color: Color(0xFF002B6B)),
              SizedBox(width: 8),
              Text('Rattacher un Contrat'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Numéro de contrat',
                  hintText: 'Ex: CORIS-2024-001234',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Code de vérification',
                  hintText: 'Code reçu par SMS/Email',
                  prefixIcon: const Icon(Icons.verified_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessSnackBar(context, 'Contrat rattaché avec succès !');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Rattacher', style: TextStyle(color: blanc)),
            ),
          ],
        );
      },
    );
  }

  void _showPropositionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.description_outlined, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text('Rattacher une Proposition'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Numéro de proposition',
                  hintText: 'Ex: PROP-2024-001234',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Type d\'assurance',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'auto', child: Text('Assurance Auto')),
                  DropdownMenuItem(value: 'sante', child: Text('Assurance Santé')),
                  DropdownMenuItem(value: 'habitation', child: Text('Assurance Habitation')),
                  DropdownMenuItem(value: 'vie', child: Text('Assurance Vie')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessSnackBar(context, 'Proposition rattachée avec succès !');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Rattacher', style: TextStyle(color: blanc)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE30613),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Se déconnecter', style: TextStyle(color: blanc)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: blanc),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? ProfilPage.bleuCoris).withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? ProfilPage.bleuCoris,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}