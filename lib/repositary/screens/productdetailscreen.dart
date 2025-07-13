import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cart/cartscreen.dart';
import 'pincodechecker.dart';

class ProductDetailScreen extends StatefulWidget {
  final String name;
  final String img;
  final String price;

  const ProductDetailScreen({
    super.key,
    required this.name,
    required this.img,
    required this.price,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController addressController = TextEditingController();
  String selectedPaymentMethod = 'cod';
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadLastSavedAddress();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _generateBillPdf();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful!")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Failed!")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Wallet: ${response.walletName}")),
    );
  }

  void _openRazorpayCheckout() {
    var options = {
      'key': 'rzp_test_TnE7aPU7jeTOfu',
      'amount': int.parse(widget.price) * 100,
      'name': 'ZippyIt',
      'description': widget.name,
      'prefill': {'contact': '', 'email': ''},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _generateBillPdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("ZippyIt - Order Bill",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Product: ${widget.name}"),
            pw.Text("Price: ₹${widget.price}"),
            pw.Text("Payment Method: $selectedPaymentMethod"),
            pw.Text("Address: ${addressController.text}"),
            pw.Text("Date: ${now.toLocal().toString().split('.')[0]}"),
            pw.SizedBox(height: 40),
            pw.Text("Thank you for shopping with ZippyIt!",
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _startUpiPayment() async {
    final upiUrl =
        "upi://pay?pa=nithish25may2005@okicici&pn=ZippyIt&tn=Order&am=${widget.price}&cu=INR";

    if (await canLaunchUrl(Uri.parse(upiUrl))) {
      await launchUrl(Uri.parse(upiUrl), mode: LaunchMode.externalApplication);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete payment in UPI app")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch UPI app")),
      );
    }
  }

  void _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please login first."), backgroundColor: Colors.red),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .add({
      'name': widget.name,
      'img': widget.img,
      'price': widget.price,
      'address': addressController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Cartscreen(),
      ),
    );
  }

  Future<void> _saveAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    final address = addressController.text.trim();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please log in to save address"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Address cannot be empty"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .add({
        'address': address,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Address saved successfully"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error saving address: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadLastSavedAddress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          addressController.text = snapshot.docs.first['address'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
                Center(
                  child: Container(
                    height: 220,
                    width: 260,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 12)
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset("assets/images/${widget.img}",
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(widget.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("₹${widget.price}",
                    style: const TextStyle(fontSize: 20, color: Colors.green)),
                const SizedBox(height: 10),
                const PincodeChecker(),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Delivery Address",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                TextButton.icon(
                  onPressed: _saveAddress,
                  icon: const Icon(Icons.save, color: Colors.blue),
                  label: const Text("Save Address",
                      style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(height: 20),
                const Text("Select Payment Method",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
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
                    ChoiceChip(
                      label: const Text("UPI"),
                      selected: selectedPaymentMethod == 'upi',
                      onSelected: (_) =>
                          setState(() => selectedPaymentMethod = 'upi'),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey, width: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (addressController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter address"),
                                backgroundColor: Colors.red),
                          );
                          return;
                        }
                        _addToCart();
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("Add to Cart"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (addressController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter address"),
                                backgroundColor: Colors.red),
                          );
                          return;
                        }

                        if (selectedPaymentMethod == 'card') {
                          _openRazorpayCheckout();
                        } else if (selectedPaymentMethod == 'upi') {
                          await _startUpiPayment();
                        } else {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Order Placed"),
                              content: Text(
                                  "Your order has been placed to:\n${addressController.text}\nPayment Method: Cash on Delivery"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _generateBillPdf();
                                  },
                                  child: const Text("Download Bill"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Buy Now"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
