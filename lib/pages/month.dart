import 'package:flutter/material.dart';
import 'package:khodaldham_dairy/pages/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Month extends StatefulWidget {
  final String name;
  final String price;
  final String producut;
  const Month({super.key, required this.name, required this.price, required this.producut});

  @override
  State<Month> createState() => _MonthState();
}

class _MonthState extends State<Month> {
  final myController = TextEditingController();
  List<String> items = List.empty(growable: true);
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
    List<String>? nameListString = sp.getStringList(widget.name);
    if (nameListString != null) {
      items = nameListString;
      setState(() {});
    }
  }

  Future<void> addtoSp() async {
    if (myController.text.isNotEmpty) {
      if (items.contains(myController.text.toString())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Name Already Exists!"),
          ),
        );
      } else {
        setState(() {
          items.add(myController.text.toString());
        });
        await sp.setStringList(widget.name, items);
        myController.clear();
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
    sp.remove('${widget.name}${items[index]}');
    setState(() {
      items.removeAt(index);
    });
    await sp.setStringList('nameList', items);
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
            "${widget.producut}_₹${widget.price}"),
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
                      color: Colors.grey[700],
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
                              builder: (context) => Transaction(
                                name: widget.name,
                                month: items[index],
                                price:widget.price
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
                  title: const Text("Add Month"),
                  content: TextField(
                    controller: myController,
                    decoration: InputDecoration(
                      hintText: 'Enter Month (mm/yy)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    keyboardType: TextInputType.datetime,
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
