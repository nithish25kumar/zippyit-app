import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:zippyit/repositary/screens/userprofile/userprofilescreen.dart';
import '../../widgets/uihelper.dart';
import '../productdetailscreen.dart';

//stateful widget used to perform fuctions onclick

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  //Text editing controller variable created for  the search Box
  TextEditingController searchController = TextEditingController();
  late stt.SpeechToText speech;
  bool isListening = false;

//list of grocery kitchen items with map used when  item used in the serach bar
  List<Map<String, String>> groceryKitchen = [
    {
      "img": "coffeemachine1.webp",
      "text": "Philips HD7430/90 1000W \nDrip Coffee Maker",
      "price": "2645"
    },
    {
      "img": "dryfruits.png",
      "text": "Kellogg's Crunchy Granola \nAlmonds & Cranberries",
      "price": "335"
    },
    {
      "img": "mixer.jpg",
      "text": "Mixer Grinder Kitchen \n(1200 Watt) Majestic Yellow",
      "price": "4390"
    },
    {
      "img": "mixer1.jpg",
      "text": "Mixer Grinder Kitchen \n 1200W Metallic Blue",
      "price": "4890"
    },
    {
      "img": "nescafegold.webp",
      "text": "NESCAFÉ® \nGold Blend®",
      "price": "550"
    },
    {
      "img": "tea13rose500gram.jpg",
      "text": "Brooke Bond \n3 Roses Dust Tea",
      "price": "376"
    },
    {
      "img": "sunrisecofee.jpg",
      "text": "Sunrise Instant Coffee",
      "price": "149"
    }
  ];

  //same as before

  List<Map<String, String>> secondgrocery = [
    {"img": "coffeenes1.jpeg", "text": "Nescafe coffee ", "price": "149"},
    {
      "img": "amulchocobrownie184.webp",
      "text": "Amul chocolate \n brownie",
      "price": "179"
    },
    {
      "img": "amulicecream35.webp",
      "text": "Amul icecream\nyummy!",
      "price": "35"
    },
    {
      "img": "tea13rose500gram.jpg",
      "text": "Brooke Bond \n3 Roses Dust Tea",
      "price": "376"
    },
    {
      "img": "sunfeastyippe.webp",
      "text": "Sun Feast Yippe! \n Yippe it!",
      "price": "96"
    },
    {
      "img": "Ramen54.jpg",
      "text": "Ramen Noodles\n Spicy Kimchi Veg Meal 96 g",
      "price": "54"
    },
    {
      "img": "shamelessvanilla96.webp",
      "text": "Shameless vanilla \nicecream",
      "price": "269"
    }
  ];

  List<Map<String, String>> snacksanddrinks = [
    {
      "img": "snickers Noughatand caramel 170.webp",
      "text": "Snickers Nougat \nand Caramel",
      "price": "170"
    },
    {
      "img": "pringles potatochips116.webp",
      "text": "Pringles Potato \nChips",
      "price": "116"
    },
    {
      "img": "parle melody chocolattyTofee95.jpg",
      "text": "Parle Melody\n Chocolaty Toffee",
      "price": "95"
    },
    {
      "img": "jellyandlichilime420.jpg",
      "text": "Jelly and \nLichi Lime",
      "price": "420"
    },
    {"img": "kurkur10.jpg", "text": "Kurkure", "price": "10"},
    {
      "img": "Mrbeastfeastables original269.webp",
      "text": "MrBeast Feastables \nOriginal",
      "price": "269"
    },
    {
      "img": "bingooriginalchilly38.jpg",
      "text": "Bingo Original \nChilly",
      "price": "38"
    },
    {"img": "cheetos35.webp", "text": "Cheetos", "price": "35"},
    {"img": "blndtonicwater.webp", "text": "Blnd Tonic \nWater", "price": "76"},
    {
      "img": "cadburyfuse99.webp",
      "text": "Cadbury Fuse Chocolate",
      "price": "99"
    }
  ];

  List<Map<String, String>> household = [
    {
      "img": "dettol 264.webp",
      "text": "Dettol Antiseptic \nLiquid",
      "price": "264"
    },
    {
      "img": "head and shoulders Antihairfal69.webp",
      "text": "Head & Shoulders \nAnti Hairfall",
      "price": "69"
    },
    {
      "img": "pearssoap65.jpg",
      "text": "Pears \nTransparent Soap",
      "price": "65"
    },
    {
      "img": "parkavenuebeer shampoo390.jpg",
      "text": "Park Avenue \nBeer Shampoo",
      "price": "390"
    },
    {
      "img": "Lizol cirus disinfectasnt surface 100.webp",
      "text": "Lizol Citrus Disinfectant \nSurface Cleaner",
      "price": "100"
    },
    {
      "img": "Mila beauteeconceal205.jpg",
      "text": "Mila Beautee \nConcealer",
      "price": "205"
    },
    {
      "img": "cosmetics1269.webp",
      "text": "Makeup Cosmetics \nCombo Set",
      "price": "1269"
    }
  ];
//list->map->string used for allProducts,filtereditem
  List<Map<String, String>> allProducts = [];
  List<Map<String, String>> filteredItems = [];

  @override
  //Initializing the state
  void initState() {
    super.initState();
    //converting speech yo text
    speech = stt.SpeechToText();

    allProducts = [
      ...groceryKitchen,
      ...secondgrocery,
      ...snacksanddrinks,
      ...household
    ];
//search controller listening the filter search
    searchController.addListener(_filterSearchResults);
  }

  //voice search logic
  void listenVoice() async {
    //if not listeningspeech
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (result) {
            setState(() {
              searchController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

//convert the query to lowercase if empty ->filtered items cleared
  void _filterSearchResults() {
    String query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredItems.clear();
      });
      return;
    }

    setState(() {
      filteredItems = allProducts.where((product) {
        final name = product["text"]?.toLowerCase() ?? "";
        return name.contains(query);
      }).toList();
    });
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
                              fontfamily: "bold"),
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
                              fontfamily: "bold")
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          Uihelper.CustomText(
                              text: "Home ",
                              color: Colors.black,
                              fontweight: FontWeight.bold,
                              fontsize: 14),
                          Uihelper.CustomText(
                              text: "- Where stories begin ✨",
                              color: Colors.black,
                              fontweight: FontWeight.bold,
                              fontsize: 14),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 90,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserProfileScreen()));
                    },
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
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 70,
                  child: SizedBox(
                    width: 250,
                    child:
                        Uihelper.CustomTextField(controller: searchController),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: GestureDetector(
                    onTap: listenVoice,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (filteredItems.isNotEmpty)
              ListView.builder(
                itemCount: filteredItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var item = filteredItems[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: Uihelper.CustomImage(img: item["img"]!),
                    ),
                    title: Text(item["text"]!),
                    subtitle: Text("₹${item["price"]}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            img: item["img"]!,
                            name: item["text"]!,
                            price: item["price"]!,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            else
              Column(
                children: [
                  sectionBuilder("Grocery & Kitchen", groceryKitchen),
                  sectionBuilder("", secondgrocery),
                  sectionBuilder("Snacks & Drinks", snacksanddrinks),
                  sectionBuilder("Body Care & Household Essentials", household,
                      showPrice: true),
                  const SizedBox(height: 30),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget sectionBuilder(String title, List<Map<String, String>> items,
      {bool showPrice = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Uihelper.CustomText(
                text: title,
                color: Colors.black,
                fontweight: FontWeight.bold,
                fontsize: 14,
                fontfamily: "bold"),
          ),
        const SizedBox(height: 10),
        SizedBox(
          height: showPrice ? 180 : 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ProductDetailScreen(
                            img: items[index]["img"]!,
                            name: items[index]["text"]!,
                            price: items[index]["price"]!,
                          );
                        }));
                      },
                      child: Container(
                        height: 120,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0XFFD9EBEB),
                        ),
                        child: Uihelper.CustomImage(img: items[index]["img"]!),
                      ),
                    ),
                  ),
                  Uihelper.CustomText(
                      text: items[index]["text"]!,
                      color: Colors.black,
                      fontweight: FontWeight.bold,
                      fontsize: 10),
                  if (showPrice)
                    Uihelper.CustomText(
                        text: "₹${items[index]["price"]}",
                        color: Colors.green,
                        fontweight: FontWeight.bold,
                        fontsize: 10),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
