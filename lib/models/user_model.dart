class AppUser {
  final int id;
  final String email;
  final String nom;
  final String prenom;
  final String civilite;
  final String role;

  AppUser({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.civilite,
    required this.role,
  });

  factory AppUser.fromLoginMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['user']['id'],
      email: map['user']['email'],
      nom: map['user']['nom'] ?? '',
      prenom: map['user']['prenom'] ?? '',
      civilite: map['user']['civilite'] ?? '',
      role: map['role'],
    );
  }
}
