import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zippyit/repositary/widgets/uihelper.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPaymentMethod = 'cod';
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _generateBillPdf(double total, String method) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("🧾 ZippyIt Order Bill",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            for (var item in widget.cartItems) ...[
              pw.Text("Product: ${item['name']}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.Text("Price: ₹${item['price']}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.Text("Address: ${item['address']}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
            ],
            pw.Divider(),
            pw.Text("Total: ₹$total",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Payment Method: $method"),
            pw.Text("Date: ${now.toLocal().toString().split('.')[0]}"),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final double total = _calculateTotal();
    final address = widget.cartItems[0]['address'] ?? 'Not provided';

    await _generateBillPdf(total, "Card");

    final message = Uri.encodeComponent("🧾 *Order Placed!*\n"
        "Total: ₹${total.toStringAsFixed(2)}\n"
        "Payment Mode: Card\n"
        "Delivery Address: $address\n"
        "Thanks for shopping with ZippyIt!");

    final whatsappUrl = Uri.parse("https://wa.me/918667893373?text=$message");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful! Order Confirmed.")),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment failed. Please try again.")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Selected Wallet: ${response.walletName}")),
    );
  }

  void _openRazorpayCheckout(double total) {
    var options = {
      'key': 'rzp_test_TnE7aPU7jeTOfu',
      'amount': (total * 100).toInt(),
      'name': 'ZippyIt',
      'description': 'Cart Order',
      'prefill': {
        'contact': '9876543210',
        'email': 'customer@example.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _handleConfirm(double total) async {
    final address = widget.cartItems[0]['address'] ?? 'Not provided';

    if (selectedPaymentMethod == 'card') {
      _openRazorpayCheckout(total);
    } else {
      await _generateBillPdf(total, "Cash on Delivery");

      final message = Uri.encodeComponent("🧾 *Order Placed!*\n"
          "Total: ₹${total.toStringAsFixed(2)}\n"
          "Payment Mode: Cash on Delivery\n"
          "Delivery Address: $address\n"
          "Thanks for shopping with ZippyIt!");

      final whatsappUrl = Uri.parse("https://wa.me/918667893373?text=$message");

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order Placed (COD)")),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in widget.cartItems) {
      total += double.tryParse(item['price'].toString()) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double total = _calculateTotal();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 70,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Text(
                "Checkout",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Uihelper.CustomText(
                text: "Select Payment Method",
                color: Colors.black,
                fontweight: FontWeight.bold,
                fontsize: 16),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("COD"),
                  selected: selectedPaymentMethod == 'cod',
                  onSelected: (_) =>
                      setState(() => selectedPaymentMethod = 'cod'),
                ),
                ChoiceChip(
                  label: const Text("Card"),
                  selected: selectedPaymentMethod == 'card',
                  onSelected: (_) =>
                      setState(() => selectedPaymentMethod = 'card'),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(25),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Image.asset(
                            "assets/images/${item['img']}",
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Price: ₹${item['price']}",
                                  style: const TextStyle(color: Colors.green)),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Address: ${item['address']}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Total: ₹${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _handleConfirm(total),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                    ),
                    child: const Text("Confirm Order",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
