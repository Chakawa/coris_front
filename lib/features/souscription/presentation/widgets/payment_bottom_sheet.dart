// lib/features/souscription/presentation/widgets/payment_bottom_sheet.dart
// class PaymentBottomSheet extends StatelessWidget {
//   final Function(String) onPayNow;

//   const PaymentBottomSheet({required this.onPayNow});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text('Choisissez votre méthode de paiement', style: TextStyle(fontSize: 18)),
//           SizedBox(height: 20),
//           _buildPaymentOption('Wave', Icons.mobile_friendly, () => onPayNow('wave')),
//           _buildPaymentOption('Orange Money', Icons.phone_android, () => onPayNow('orange_money')),
//           _buildPaymentOption('Carte Bancaire', Icons.credit_card, () => onPayNow('carte')),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentOption(String title, IconData icon, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.blue),
//       title: Text(title),
//       onTap: onTap,
//     );
//   }
// }