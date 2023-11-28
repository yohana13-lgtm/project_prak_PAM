import 'dart:math';

import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:project_akhir/models/database.dart';
import 'package:project_akhir/models/transaction_with_category.dart';
import 'package:project_akhir/pages/category_page.dart';
import 'package:project_akhir/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase database = AppDatabase();
  int totalIncome = 0;
  int totalExpense = 0;

  @override
  void initState() {
    super.initState();
    fetchTotals(); // Memanggil fetchTotals saat halaman dimuat
  }

  Future<void> fetchTotals() async {
    final income = await database.getTotalIncome();
    final expense = await database.getTotalExpense();

    setState(() {
      totalIncome = income;
      totalExpense = expense;
    });
  }

  Future<void> saveTransaction() async {
    bool isTransactionSaved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(
          transactionsWithCategory: null, // Gunakan null jika menambahkan transaksi baru
        ),
      ),
    );

    if (isTransactionSaved != null && isTransactionSaved) {
      fetchTotals(); // Update totals after adding/editing a transaction
    }
  }
  // page controller

  @override
  Widget build(BuildContext context) {
    Stream<List<TransactionWithCategory>>? transactionsStream;

    @override
    void initState() {
      super.initState();
      fetchTotals();
      transactionsStream =
          database.getTransactionByDateRepo(widget.selectedDate);
    }

    List<Transaction> transactionsList = [];

    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.download,
                                    color: Colors.greenAccent[400],
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Income',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.white)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text('Rp ${totalIncome.toString()}',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14, color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.upload,
                                    color: Colors.redAccent[400],
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Expense',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.white)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text('Rp ${totalExpense.toString()}',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14, color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Transactions",
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getTransactionByDateRepo(widget.selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () async {
                                            await database.deleteTransactionRepo(
                                                snapshot.data![index].transaction.id
                                            );
                                            fetchTotals(); // Update totals after deleting a transaction
                                          },
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () async {
                                            var editedItem = await Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => TransactionPage(
                                                transactionsWithCategory: snapshot.data![index],
                                              ),
                                            ));
                                            if (editedItem != null) {
                                              // Dapatkan nilai-nilai yang diedit dari halaman edit

                                              int id = editedItem.id; // Ganti dengan cara untuk mendapatkan ID dari editedItem
                                              int amount = editedItem.amount; // Ganti dengan cara untuk mendapatkan amount dari editedItem
                                              int categoryId = editedItem.categoryId; // Ganti dengan cara untuk mendapatkan categoryId dari editedItem
                                              DateTime transactionDate = editedItem.transactionDate; // Ganti dengan cara untuk mendapatkan transactionDate dari editedItem
                                              String description = editedItem.description; // Ganti dengan cara untuk mendapatkan description dari editedItem

                                              // Panggil fungsi updateTransactionRepo untuk memperbarui data
                                              await database.updateTransactionRepo(id, amount, categoryId, transactionDate, description);

                                              // Refresh halaman atau dapatkan ulang data setelah perubahan
                                              fetchTotals(); // Misalnya, panggil fungsi fetchData() untuk memperbarui data
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                    subtitle: Text(
                                        snapshot.data![index].category.name),
                                    leading: Container(
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(8)),
                                        child: (snapshot.data![index].category
                                            .type ==
                                            1)
                                            ? Icon(
                                          Icons.download,
                                          color: Colors.greenAccent[400],
                                        )
                                            : Icon(
                                          Icons.upload,
                                          color: Colors.red[400],
                                        )),
                                    title: Text(
                                      snapshot.data![index].transaction.amount
                                          .toString(),
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else {
                        return Center(
                          child: Column(children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text("Belum ada transaksi",
                                style: GoogleFonts.montserrat()),
                          ]),
                        );
                      }
                    } else {
                      return Center(
                        child: Text("Belum ada transaksi"),
                      );
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}
