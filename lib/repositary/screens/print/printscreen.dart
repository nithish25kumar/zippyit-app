import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:zippyit/repositary/widgets/uihelper.dart';
import '../paymentpage.dart';

class Printscreen extends StatefulWidget {
  const Printscreen({super.key});

  @override
  State<Printscreen> createState() => _PrintscreenState();
}

class _PrintscreenState extends State<Printscreen> {
  final TextEditingController searchcontroller = TextEditingController();
  PlatformFile? selectedFile;
  int _pageCount = 0;
  double _price = 0.0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final bytes = File(file.path!).readAsBytesSync();
      final document = PdfDocument(inputBytes: bytes);
      int pages = document.pages.count;
      document.dispose();

      setState(() {
        selectedFile = file;
        _pageCount = pages;
        _price = pages * 3.0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );
    }
  }

  void _proceedToPayment() {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file first")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          fileName: selectedFile!.name,
          pageCount: _pageCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const SizedBox(height: 30),
            Uihelper.CustomText(
              text: "Print Store",
              color: Colors.black,
              fontweight: FontWeight.bold,
              fontsize: 32,
              fontfamily: "bold",
            ),
            Uihelper.CustomText(
              text: "Zippit ensures secure prints at every stage",
              color: const Color(0xFF9C9C9C),
              fontweight: FontWeight.bold,
              fontsize: 14,
            ),
            const SizedBox(height: 40),
            _buildUploadCard(),
            if (selectedFile != null) _buildFilePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          color: Colors.red,
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Uihelper.CustomText(
                    text: "Zippyit! in",
                    color: Colors.white,
                    fontweight: FontWeight.bold,
                    fontsize: 15,
                    fontfamily: "bold",
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Uihelper.CustomText(
                    text: "Fast. Reliable. 16 mins away!",
                    color: Colors.white,
                    fontweight: FontWeight.bold,
                    fontsize: 17,
                    fontfamily: "bold",
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Uihelper.CustomText(
                    text: "Home - Where stories begin ✨ ",
                    color: Colors.black,
                    fontweight: FontWeight.bold,
                    fontsize: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 90,
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: FirebaseAuth.instance.currentUser?.photoURL !=
                        null
                    ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                    : null,
                backgroundColor: Colors.black,
                child: FirebaseAuth.instance.currentUser?.photoURL == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(height: 5),
              Text(
                FirebaseAuth.instance.currentUser?.displayName ?? 'Guest',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard() {
    return Stack(
      children: [
        Container(
          height: 180,
          width: 361,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Uihelper.CustomText(
                    text: "Documents",
                    color: Colors.black,
                    fontweight: FontWeight.bold,
                    fontsize: 14,
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Uihelper.CustomImage(img: "star.png"),
                  const SizedBox(width: 7),
                  Uihelper.CustomText(
                    text: "Price starting at rs 3/page",
                    color: const Color(0XFF9C9C9C),
                    fontweight: FontWeight.normal,
                    fontsize: 15,
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Uihelper.CustomImage(img: "star.png"),
                  const SizedBox(width: 7),
                  Uihelper.CustomText(
                    text: "Paper quality: 70 GSM",
                    color: const Color(0XFF9C9C9C),
                    fontweight: FontWeight.normal,
                    fontsize: 15,
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Uihelper.CustomImage(img: "star.png"),
                  const SizedBox(width: 7),
                  Uihelper.CustomText(
                    text: "Single side prints",
                    color: const Color(0XFF9C9C9C),
                    fontweight: FontWeight.normal,
                    fontsize: 15,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 40,
                    width: 125,
                    child: ElevatedButton(
                      onPressed: _pickFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        "Upload Files",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 40,
          child: Uihelper.CustomImage(img: "copy.png"),
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selected File",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text("Name: ${selectedFile!.name}"),
              Text(
                  "Size: ${(selectedFile!.size / 1024).toStringAsFixed(2)} KB"),
              Text("Pages: $_pageCount"),
              Text("Total: ₹${_price.toStringAsFixed(2)}"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Pay & Proceed"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
