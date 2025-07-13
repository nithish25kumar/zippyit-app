import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zippyit/repositary/screens/bottomnav/bottomnavscreen.dart';

class PaymentPage extends StatefulWidget {
  final String fileName;
  final int pageCount;

  const PaymentPage({
    Key? key,
    required this.fileName,
    required this.pageCount,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController addressController = TextEditingController();
  String selectedPaymentMethod = 'cod';
  late Razorpay _razorpay;

  double get totalAmount => widget.pageCount * 3.0;

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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful! ID: ${response.paymentId}")),
    );
    _generateBillPdf();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment failed. Please try again.")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Wallet Selected: ${response.walletName}")),
    );
  }

  void _startRazorpayPayment() {
    var options = {
      'key': 'rzp_test_TnE7aPU7jeTOfu', // Replace with your Razorpay key
      'amount': (totalAmount * 100).toInt(),
      'name': 'ZippyIt',
      'description': 'Print Order: ${widget.fileName}',
      'prefill': {
        'contact': '9876543210',
        'email': 'test@zippyit.com',
      },
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
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("ZippyIt - Print Order Bill",
                style:
                pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("File: ${widget.fileName}"),
            pw.Text("Pages: ${widget.pageCount}"),
            pw.Text("Price per page: ₹3"),
            pw.Text("Total Amount: ₹${totalAmount.toStringAsFixed(2)}"),
            pw.Text("Payment Method: $selectedPaymentMethod"),
            pw.Text("Delivery Address: ${addressController.text}"),
            pw.Text("Order Date: ${now.toLocal().toString().split('.')[0]}"),
            pw.SizedBox(height: 40),
            pw.Text("Thank you for printing with ZippyIt!",
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _startUpiPayment() async {
    final upiUrl =
        "upi://pay?pa=nithish25may2005@okicici&pn=ZippyIt&tn=Print%20Order&am=${totalAmount.toStringAsFixed(2)}&cu=INR";

    if (await canLaunchUrl(Uri.parse(upiUrl))) {
      await launchUrl(Uri.parse(upiUrl), mode: LaunchMode.externalApplication);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete payment in UPI app")),
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Confirm Payment"),
          content: const Text(
              "Did you complete the payment?\nClick 'Payment Done' to generate your bill."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _generateBillPdf();
              },
              child: const Text("Payment Done"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch UPI app")),
      );
    }
  }

  void _placeOrder() {
    if (addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter delivery address")),
      );
      return;
    }

    if (selectedPaymentMethod == 'upi') {
      _startUpiPayment();
    } else if (selectedPaymentMethod == 'razorpay') {
      _startRazorpayPayment();
    } else {
      // Cash on Delivery
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Order Confirmed"),
          content: Text(
            "Your print request has been placed for:\n${addressController.text}\n"
                "Payment Method: Cash on Delivery\n"
                "Total: ₹${totalAmount.toStringAsFixed(2)}",
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Bottomnavscreen()),
              (route) => false,
        );
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7CB45),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "ZippyIt Payment",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          size: 80, color: Colors.redAccent),
                      const SizedBox(height: 20),
                      Text(
                        widget.fileName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text("Pages: ${widget.pageCount}"),
                      Text("Total: ₹${totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Enter Delivery Address",
                          prefixIcon: const Icon(Icons.home),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Choose Payment Method:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text("Cash on Delivery"),
                        value: "cod",
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) =>
                            setState(() => selectedPaymentMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text("UPI (GPay, PhonePe, etc.)"),
                        value: "upi",
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) =>
                            setState(() => selectedPaymentMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text("Pay with Card / UPI (Razorpay)"),
                        value: "razorpay",
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) =>
                            setState(() => selectedPaymentMethod = value!),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              addressController.clear();
                              setState(() => selectedPaymentMethod = 'cod');
                            },
                            icon: const Icon(Icons.refresh, color: Colors.red),
                            label: const Text("Reset"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _placeOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Place Order"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
