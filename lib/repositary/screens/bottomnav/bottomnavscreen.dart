import 'package:flutter/material.dart';
import 'package:zippyit/repositary/screens/cart/cartscreen.dart';
import 'package:zippyit/repositary/screens/category/categoryscreen.dart';
import 'package:zippyit/repositary/screens/home/homescreen.dart';
import 'package:zippyit/repositary/screens/print/printscreen.dart';

//Stateful widget used here because the selected tab (currentIndex) changes when users tap different icons.
//it can change overtime one screen to another
class Bottomnavscreen extends StatefulWidget {
  const Bottomnavscreen({super.key});

  @override
  State<Bottomnavscreen> createState() => _BottomnavscreenState();
}

class _BottomnavscreenState extends State<Bottomnavscreen> {
  //tracks the currently selected tab
  //default is 0 which is homescreen
  int currentIndex = 0;
  List<Widget> pages = [
    //It is the list of widgets presenting the different screens accessible from the bottom nav.

    Homescreen(),
    CategoryScreen(),
    Printscreen(),
    Cartscreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // basic layout structure.

      // it shows only the widget at the currentIndex
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        //it allows the user to navigate between the pages
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.print),
            label: "Printer",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Cart",
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          //on one tap state will be changed to the current index
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
