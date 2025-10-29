// // Dans souscription_epargne.dart - Remplacer SuccessDialog
// class SuccessDialog extends StatelessWidget {
//   final bool isPaid;
//   const SuccessDialog({super.key, required this.isPaid});

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withAlpha(26),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: isPaid ? const Color(0xFF10B981).withAlpha(26) : const Color(0xFFF59E0B).withAlpha(26),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isPaid ? Icons.check_circle : Icons.schedule,
//                 color: isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
//                 size: 40,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               isPaid ? 'Souscription Réussie!' : 'Proposition Enregistrée!',
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF002B6B),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               isPaid
//                 ? 'Félicitations! Votre contrat est maintenant actif.'
//                 : 'Votre proposition a été enregistrée. Vous pouvez la consulter et payer plus tard.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Color(0xFF64748B),
//                 fontSize: 14,
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Fermer tous les dialogs et aller vers Mes Propositions
//                   Navigator.of(context).popUntil((route) => route.isFirst);
//                   Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     '/mes-propositions',
//                     (route) => false,
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF002B6B),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Voir mes propositions',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }