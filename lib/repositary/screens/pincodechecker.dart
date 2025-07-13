import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PincodeChecker extends StatefulWidget {
  const PincodeChecker({super.key});

  @override
  State<PincodeChecker> createState() => _PincodeCheckerState();
}

class _PincodeCheckerState extends State<PincodeChecker> {
  final TextEditingController pincodeController = TextEditingController();
  String place = '';
  bool isLoading = false;

  void fetchPlaceFromPincode(String pin) async {
    if (pin.length != 6) return;

    setState(() {
      isLoading = true;
      place = '';
    });

    final url = Uri.parse("https://api.postalpincode.in/pincode/$pin");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data[0]['Status'] == "Success") {
        final postOffice = data[0]['PostOffice'][0];
        final area = postOffice['Name'];
        final district = postOffice['District'];
        final state = postOffice['State'];
        setState(() {
          place = "$area, $district, $state";
        });
      } else {
        setState(() {
          place = "Invalid PIN code.";
        });
      }
    } else {
      setState(() {
        place = "Failed to fetch location.";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: pincodeController,
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Enter PIN Code",
            prefixIcon: Icon(Icons.location_pin),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.length == 6) {
              fetchPlaceFromPincode(value);
            }
          },
        ),
        const SizedBox(height: 8),
        isLoading
            ? const CircularProgressIndicator()
            : Text(
          place,
          style:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
