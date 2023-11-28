import 'dart:math';
import 'package:flutter/services.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_akhir/models/database.dart';
import 'package:project_akhir/pages/category_page.dart';
import 'package:project_akhir/pages/home_page.dart';
import 'package:project_akhir/pages/transaction_page.dart';

import '../login.dart';
import 'news_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  final database = AppDatabase();

  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    updateView(0, DateTime.now());

    super.initState();
  }

  Future<List<Category>> getAllCategory() {
    return database.select(database.categories).get();
  }

  void showAwe() async {
    List<Category> al = await getAllCategory();
    print('PANJANG : ' + al.length.toString());
  }

  void showSuccess(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void updateView(int index, DateTime? date) {
    setState(() {
      if (date != null) {
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }

      currentIndex = index;
      _children = [
        HomePage(
          selectedDate: selectedDate,
        ),
        CategoryPage()
      ];
    });
  }

  void onTabTapped(int index) {
    setState(() {
      selectedDate =
          DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      currentIndex = index;
      _children = [
        HomePage(
          selectedDate: selectedDate,
        ),
        CategoryPage()
      ];
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Menghapus status login

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(), // Kembali ke halaman login
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Visibility(
          visible: (currentIndex == 0) ? true : false,
          child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                  builder: (context) =>
                      TransactionPage(transactionsWithCategory: null),
                ))
                    .then((value) {
                  setState(() {
                    updateView(0, DateTime.now());
                  });
                });
              },
              backgroundColor: Color(0xff80deea),
              child: Icon(Icons.add)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {
                      updateView(0, DateTime.now());
                    },
                    icon: Icon(Icons.home)),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () {
                      updateView(1, DateTime.now());
                    },
                    icon: Icon(Icons.list)),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NewsPage()
                          ),
                      );
                    },
                    icon: Icon(Icons.article)),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () {
                      _logout(context);
                    },
                    icon: Icon(Icons.logout)),
              ],
            )),
        body: _children[currentIndex],
        appBar: (currentIndex == 1)
            ? PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 36, horizontal: 16),
            ),
          ),
        )
            : CalendarAppBar(
            fullCalendar: true,
            backButton: false,
            accent: Color(0xff80deea),
            locale: 'en',
            onDateChanged: (value) {
              setState(() {
                selectedDate = value;
                updateView(0, selectedDate);
              });
            },
            lastDate: DateTime.now()));
  }
}
