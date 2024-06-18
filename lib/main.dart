import 'package:flutter/material.dart';
import 'package:khodaldham_dairy/pages/month.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khodaldham Dairy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final priceController = TextEditingController();
  final productController = TextEditingController();
  final myController = TextEditingController();
  List<String> items = List.empty(growable: true);
  List<String> prices = List.empty(growable: true);
  List<String> product = List.empty(growable: true);
  late SharedPreferences sp;

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
    List<String>? nameListString = sp.getStringList("nameList");
    List<String>? priceListString = sp.getStringList("priceList");
    List<String>? productListString = sp.getStringList("productList");
    if (nameListString != null &&
        priceListString != null &&
        productListString != null) {
      items = nameListString;
      prices = priceListString;
      product = productListString;
      setState(() {});
    }
  }

  Future<void> addtoSp() async {
    if (myController.text.isNotEmpty && priceController.text.isNotEmpty) {
      if (items.contains(myController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Name Already Exists!"),
          ),
        );
      } else {
        setState(() {
          items.add(myController.text);
          prices.add(priceController.text);
          product.add(productController.text);
        });
        await sp.setStringList("nameList", items);
        await sp.setStringList("priceList", prices);
        await sp.setStringList("productList", product);
        myController.clear();
        priceController.clear();
        productController.clear();
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a name."),
        ),
      );
    }
  }

  Future<void> deleteItem(int index) async {
    sp.remove(items[index]);
    List<String>? nameListString = sp.getStringList(items[index]);
    if (nameListString != null) {
      for (var month in nameListString) {
        sp.remove('${items[index]}$month');
      }
    }
    setState(() {
      items.removeAt(index);
      prices.removeAt(index);
      product.removeAt(index);
    });
    await sp.setStringList('nameList', items);
    await sp.setStringList('priceList', prices);
    await sp.setStringList('productList', product);
  }

  @override
  void dispose() {
    myController.dispose();
    priceController.dispose();
    productController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Khodaldham Dairy'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: items.isNotEmpty
            ? ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.deepPurple[400],
                      child: ListTile(
                        title: Text(
                          items[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: InkWell(
                          child: const Icon(
                            Icons.more_vert,
                            color: Color.fromARGB(169, 255, 255, 255),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Delete Account?"),
                                  content: const Text(
                                      "You will delete this permanently."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        deleteItem(index);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Month(
                                name: items[index],
                                price: prices[index],
                                producut: product[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text(
                  'No items',
                  style: TextStyle(fontSize: 18),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Add a person"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: myController,
                          decoration: InputDecoration(
                            hintText: 'Enter name',
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
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: productController,
                          decoration: InputDecoration(
                            hintText: 'Enter product name',
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
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: priceController,
                          decoration: InputDecoration(
                            hintText: 'Enter Price',
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
                        addtoSp();
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
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
