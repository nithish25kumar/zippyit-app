import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart' show rootBundle;

import 'package:zippyit/repositary/widgets/uihelper.dart';
import 'package:zippyit/repositary/screens/welcomescreen.dart';
import '../productdetailscreen.dart';
import '../userprofile/userprofilescreen.dart';

//stateful widget used when UI changes based on user interaction
class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  TextEditingController searchcontroller =
      TextEditingController(); //Text editing controller created for searchbox
  late stt.SpeechToText _speech; //Initiating the speech to text
  bool _isListening = false; //initiating islistening to false

  //creating the list each item in the list is a map (key-value pair) where both values are strings
  List<Map<String, String>> data = [];
  List<Map<String, String>> category = [];
  List<Map<String, String>> grocerykitchen = [];
  List<Map<String, String>> filteredCategory = [];
  List<Map<String, String>> allItems = [];

  @override
  void initState() {
    super.initState();
    //speech to text initialized
    _speech = stt.SpeechToText();
    //loads products from the local json file
    loadLocalJson();
    //attaching listener to the seachcontroller
    searchcontroller.addListener(() {
      //when user types filter is called and results are shown
      filterSearchResults(searchcontroller.text);
    });
  }

  Future<void> loadLocalJson() async {
    //loads the data.json file stored
    final String jsonString = await rootBundle.loadString('assets/data.json');

    //it has key and value pair
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      data = List<Map<String, String>>.from(
        jsonData["data"].map((item) => Map<String, String>.from(item)),
      );
      category = List<Map<String, String>>.from(
        jsonData["category"].map((item) => Map<String, String>.from(item)),
      );
      grocerykitchen = List<Map<String, String>>.from(
        jsonData["grocerykitchen"]
            .map((item) => Map<String, String>.from(item)),
      );
      allItems = [...category, ...grocerykitchen];
      filteredCategory = List.from(allItems);
    });
  }

//function for filtering the results
  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCategory = List.from(allItems);
      });
    } else {
      setState(() {
        filteredCategory = allItems
            .where((item) =>
                item["text"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

//permissioin for voice in the mobile
  void _listen() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }

    //speech not listen
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Speech status: \$val'),
        onError: (val) => print('Speech error: \$val'),
      );
      //speech listen
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              searchcontroller.text = val.recognizedWords;
              filterSearchResults(val.recognizedWords);
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    searchcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Stack(
              children: [
                Container(
                  height: 190,
                  width: double.infinity,
                  color: const Color(0XFFEC0505),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Uihelper.CustomText(
                          text: "Zippyit! in",
                          color: Colors.white,
                          fontweight: FontWeight.bold,
                          fontsize: 15,
                          fontfamily: "bold",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Uihelper.CustomText(
                          text: "Fast. Reliable. 16 mins away!",
                          color: Colors.white,
                          fontweight: FontWeight.bold,
                          fontsize: 17,
                          fontfamily: "bold",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Uihelper.CustomText(
                          text: "Home - Where stories begin ✨",
                          color: Colors.black,
                          fontweight: FontWeight.bold,
                          fontsize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                //logout symbol positioned

                //userprofile screen positioned
                Positioned(
                  right: 5,
                  bottom: 110,
                  //onclick screen profile
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfileScreen()),
                      );
                    },
                    //child->column->children->circleavatar
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: FirebaseAuth
                                      .instance.currentUser?.photoURL !=
                                  null
                              ? NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!)
                              : null,
                          backgroundColor: Colors.black,
                          child: FirebaseAuth.instance.currentUser?.photoURL ==
                                  null
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ??
                              'Guest',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //search box position
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Uihelper.CustomTextField(
                          controller: searchcontroller,
                        ),
                      ),
                      //used icon btn
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                        ),
                        onPressed: _listen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            //design line
            Container(height: 1, width: double.infinity, color: Colors.white),
            //new container  created
            Container(
              height: 196,
              width: double.infinity,
              color: const Color(0XFFEC0505),
              // child->column->mainAxisAlignment->children->row
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Uihelper.CustomImage(img: "image 60.png"),
                      Uihelper.CustomImage(img: "image 55.png"),
                      Uihelper.CustomText(
                        text: "Mega Diwali Sale",
                        color: Colors.white,
                        fontweight: FontWeight.bold,
                        fontsize: 20,
                        fontfamily: "bold",
                      ),
                      Uihelper.CustomImage(img: "image 55.png"),
                      Image.asset(
                        "assets/images/image 61.png",
                        width: 30,
                      )
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      //adding listview builder
                      child: ListView.builder(
                        itemCount: data.length, //datalength
                        scrollDirection: Axis.horizontal, //scroll direction
                        itemBuilder: (context, index) {
                          //item builder
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            //container craeted for the image and text
                            child: Container(
                              width: 130,
                              decoration: BoxDecoration(
                                color: const Color(0XFFFF6F61),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: Uihelper.CustomImage(
                                      img: data[index]["img"]
                                          .toString(), //tostring()
                                      height: 60,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Uihelper.CustomText(
                                    text: data[index]["text"].toString(),
                                    color: Colors.white,
                                    fontweight: FontWeight.bold,
                                    fontsize: 14,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: filteredCategory.isEmpty
                    ? const Center(
                        child: Text(
                          "No items found",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredCategory.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    name: filteredCategory[index]["text"]!,
                                    img: filteredCategory[index]["img"]!,
                                    price: filteredCategory[index]["price"]!,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Uihelper.CustomImage(
                                      img: filteredCategory[index]["img"]!,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Uihelper.CustomText(
                                    text: filteredCategory[index]["text"]!,
                                    color: Colors.black,
                                    fontweight: FontWeight.bold,
                                    fontsize: 8,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(right: 40),
                                  child: Row(
                                    children: [
                                      Uihelper.CustomImage(img: "timer 2.png"),
                                      Uihelper.CustomText(
                                        text: " 16 MINS",
                                        color: const Color(0XFF9C9C9C),
                                        fontweight: FontWeight.normal,
                                        fontsize: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(right: 60),
                                  child: Row(
                                    children: [
                                      Uihelper.CustomText(
                                        text:
                                            "₹${filteredCategory[index]['price']}",
                                        color: Colors.black,
                                        fontweight: FontWeight.bold,
                                        fontsize: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 20),
                Uihelper.CustomText(
                  text: "Grocery & Kitchen",
                  color: Colors.black,
                  fontweight: FontWeight.bold,
                  fontsize: 14,
                  fontfamily: "bold",
                )
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: grocerykitchen.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              name: grocerykitchen[index]["text"]!,
                              img: grocerykitchen[index]["img"]!,
                              price: grocerykitchen[index]["price"]!,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Column(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0XFFD9EBEB),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Uihelper.CustomImage(
                                  img: grocerykitchen[index]["img"]!,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 71,
                              child: Text(
                                grocerykitchen[index]["text"]!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
