import 'dart:io';
// import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

class Transaction extends StatefulWidget {
  final String name;
  final String month;
  final String price;

  const Transaction(
      {super.key,
      required this.name,
      required this.month,
      required this.price});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final literController = TextEditingController();
  final amountController = TextEditingController();
  List<String> transactions = List.empty(growable: true);
  late SharedPreferences sp;
  bool credit = true;
  var total = 0.0;
  var anotherAmount = 0;

  @override
  void initState() {
    super.initState();
    getSharedPreference();
  }

  getSharedPreference() async {
    sp = await SharedPreferences.getInstance();
    readFromSp();
  }

  readFromSp() {
    List<String>? nameListString =
        sp.getStringList('${widget.name}${widget.month}');
    int? amount = sp.getInt('${widget.name}${widget.month}amount');
    if (nameListString != null) {
      transactions = nameListString;
      if (amount != null) {
        anotherAmount = amount;
      }
      setState(() {});
    }
    sum();
  }

  saveAmount() async {
    if (amountController.text.isNotEmpty) {
      anotherAmount = int.parse(amountController.text);
      String key = '${widget.name}${widget.month}amount';
      await sp.setInt(key, anotherAmount);
      setState(() {});
      sum();
      amountController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Amount."),
        ),
      );
    }
  }

  deleteAmount() {
    sp.remove("${widget.name}${widget.month}amount");
    anotherAmount = 0;
    sum();
    setState(() {});
  }

  saveIntoSp() {
    if (literController.text.isNotEmpty) {
      setState(() {
        transactions.add(literController.text.toString());
      });
      sp.setStringList('${widget.name}${widget.month}', transactions);
      literController.clear();
      sum();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a Liter."),
        ),
      );
    }
  }

  Future<void> deleteFromSp(int index) async {
    setState(() {
      transactions.removeAt(index);
    });
    await sp.setStringList('${widget.name}${widget.month}', transactions);
    sum();
  }

  sum() {
    total = 0.0;
    for (var transaction in transactions) {
      total += (double.tryParse(transaction) ?? 0.0) *
          (double.tryParse(widget.price) ?? 0.0);
    }
    total = total + anotherAmount;
    setState(() {});
  }

  @override
  void dispose() {
    literController.dispose();
    super.dispose();
  }

  Future<void> _createAndSharePdf() async {
    final pdfDocument = pw.Document();
    final robotoRegularFont = await PdfGoogleFonts.robotoRegular();

    // Split transactions into two lists
    List<String> firstHalfTransactions = transactions.take(15).toList();
    List<String> secondHalfTransactions = transactions.skip(15).toList();

    pdfDocument.addPage(
      // final Uint8List fontData = File('arial.ttf').readAsBytesSync();
      // final PdfFont font = PdfTrueTypeFont(fontData, 12);
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Khodaldham Dairy",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  )),
              pw.SizedBox(height: 10),
              pw.Text("Name: ${widget.name}",
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text("Month: ${widget.month}",
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildTransactionTable(
                      firstHalfTransactions, robotoRegularFont),
                  _buildTransactionTable(
                      secondHalfTransactions, robotoRegularFont,
                      startIndex: 16),
                ],
              ),
              pw.SizedBox(height: 20),
              anotherAmount >= 0
                  ? pw.Text(
                      "Jama: $anotherAmount",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    )
                  : pw.Text(
                      "Upad: ${anotherAmount * -1}",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
              pw.Text(
                "Total Amount: ${total.floor()}",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red600,
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/transactions.pdf");
    await file.writeAsBytes(await pdfDocument.save());

    await _sharePdf(file);
  }

  Future<void> _sharePdf(File pdfFile) async {
    try {
      // Use platform-specific APIs for sharing
      await Printing.sharePdf(
        bytes: await pdfFile.readAsBytes(),
        filename: 'transactions.pdf',
      );
    } catch (e) {
      // Handle any exceptions that occur during sharing
      // print('Error sharing PDF: $e');
    }
  }

  pw.Widget _buildTransactionTable(List<String> transactions, pw.Font font,
      {int startIndex = 1}) {
    return pw.Expanded(
      child: pw.Table(
        border: pw.TableBorder.all(),
        children: [
          pw.TableRow(children: [
            pw.Text("     Date.",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple500,
                )),
            pw.Text("     Liters",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green,
                )),
            pw.Text("     Amount",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green,
                )),
          ]),
          ...transactions.asMap().entries.map((entry) {
            return _buildTransactionRow(
                startIndex + entry.key, entry.value, font);
          }),
        ],
      ),
    );
  }

  pw.TableRow _buildTransactionRow(
      int index, String transaction, pw.Font font) {
    final amount = double.parse(transaction);
    final totalAmount = amount * double.parse(widget.price);
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(4.0),
        child: pw.Text('     ${index.toString()}'),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(4.0),
        child: pw.Text("     $transaction L"),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(4.0),
        child: pw.Text("     $totalAmount"),
      ),
    ]);
  }

  addTranscation() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Add Amount"),
            content: TextField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: 'Enter Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              keyboardType: const TextInputType.numberWithOptions(signed: true),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  saveAmount();
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${widget.name}_${widget.month}_₹${widget.price}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _createAndSharePdf,
          ),
          IconButton(
            onPressed: () {
              addTranscation();
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: transactions.isNotEmpty
                  ? Row(
                      children: [
                        SizedBox(
                          width: screenwidth * .5,
                          child: ListView.builder(
                            itemCount: transactions.length > 15
                                ? 15
                                : transactions.length,
                            itemBuilder: (context, index) {
                              final transaction =
                                  double.parse(transactions[index]);
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${index + 1}.',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              132, 255, 255, 255),
                                        ),
                                      ),
                                      Text(
                                        '${transaction}L',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '₹${(transaction * double.parse(widget.price)).toString()}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                        ),
                                      ),
                                      GestureDetector(
                                        child: const Icon(
                                          Icons.more_vert,
                                          color: Colors.grey,
                                        ),
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Delete Account?"),
                                                  content: const Text(
                                                      "You will delete this permanently."),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteFromSp(index);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: screenwidth * .5,
                          child: ListView.builder(
                            itemCount: transactions.length > 15
                                ? transactions.length - 15
                                : 0,
                            itemBuilder: (context, index) {
                              final transaction =
                                  double.parse(transactions[index]);
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${index + 16}.',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              132, 255, 255, 255),
                                        ),
                                      ),
                                      Text(
                                        '${transaction}L',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '₹${(transaction * double.parse(widget.price)).toString()}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                        ),
                                      ),
                                      GestureDetector(
                                        child: const Icon(
                                          Icons.more_vert,
                                          color: Colors.grey,
                                        ),
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Delete Account?"),
                                                  content: const Text(
                                                      "You will delete this permanently."),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteFromSp(index);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text("No Transaction"),
                    ),
            ),
            if (anotherAmount != 0)
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    anotherAmount > 0
                        ? Text('Credit: $anotherAmount')
                        : Text('Debit: $anotherAmount'),
                    InkWell(
                      onTap: deleteAmount,
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                        size: 18,
                      ),
                    )
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(15.0),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Total Amount: ₹${total.floor()}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Enter Details"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: literController,
                          decoration: InputDecoration(
                            hintText: 'Enter Liter',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.deepPurple),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        saveIntoSp();
                      },
                      child: const Text("Add"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
