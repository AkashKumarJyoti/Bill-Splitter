import 'package:bill_splitter/ui/authentication.dart';
import 'package:bill_splitter/ui/data.dart';
import 'package:bill_splitter/database/database_helper.dart';
import 'package:bill_splitter/model/expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../util/hexcolor.dart';

class BillSplitter extends StatefulWidget {
  final String name;
  const BillSplitter({Key? key, required this.name}) : super(key: key);
  @override
  State<BillSplitter> createState() => _BillSplitterState();
}

class _BillSplitterState extends State<BillSplitter> {
  var db = DatabaseHelper();
  final List<BillItem> _itemList = <BillItem>[];
  int _tipPercentage = 0;
  int _personCounter = 1;
  double _billAmount = 0.0;
  final Color _purple = HexColor("#6908D6");

  bool _isDarkMode = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  void _showFormDialog() {
    var alert = AlertDialog(
      content: Column(
        children: <Widget>[
          Expanded(child: TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Title",
                hintText: "eg. Chowmein",
            ),
          )),
          Expanded(child: TextField(
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true),
            controller: _amountController,
            autofocus: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Amount",
            ),
          )),
          Expanded(child: TextField(
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true),
            controller: _tipController,
            autofocus: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Tip",
            ),
          )),
        ],
      ),
      actions: <Widget>[
        TextButton(
            onPressed: ()
            {
              _handleSubmit(_titleController.text, int.parse(_amountController.text), int.parse(_tipController.text));
              Navigator.pop(context);
            },
            child: const Text("Save")
        ),
        TextButton(
            onPressed: ()
            {
              Navigator.pop(context);
            },
            child: const Text("Cancel")
        )
      ],
    );
    showDialog(context: context, builder: (_)
    {
      return alert;
    });
  }
  _readNoDoList() async
  {
    List<Map<String, Object?>>? items = await db.queryDatabase();
    items?.forEach((item) {
      setState(() {
        _itemList.add(BillItem.map(item));
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readNoDoList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bill Splitter",
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hi, ${widget.name}", style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black,
          )),
          backgroundColor: _isDarkMode ? Colors.black : Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                _logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                );
              },
              icon: Icon(Icons.logout, color: _isDarkMode ? Colors.white : Colors.black),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: "Add Your Expenses",
          backgroundColor: _purple.withOpacity(0.1),
          onPressed: () {
            _showFormDialog();
          },
          child: Icon(Icons.add, color: _purple, size: 28.0,)
        ),
        body: Container(
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20.5),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Container(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 70.0),
                        child: Text(
                          "Dark Mode",
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Icon(_isDarkMode ? Icons.nightlight_round: Icons.wb_sunny,
                        color: _isDarkMode ? Colors.white : Colors.black,),
                      Expanded(
                        child: SwitchListTile(
                          value: _isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              _isDarkMode = value;
                            });
                          },
                          inactiveThumbColor: Colors.red,
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 30),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      color: _purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Total Per Person",
                        style: TextStyle(
                            color: _purple,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "\$ ${calculateTotalPerPerson(_billAmount, _personCounter, _tipPercentage)}",
                          style: TextStyle(
                              color: _purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 34.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueGrey.shade100,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: TextStyle(color: _purple),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Enter the bill",
                            prefixText: "Bill Amount: ",
                            prefixIcon: Icon(Icons.attach_money)),
                        onChanged: (String value) {
                          try {
                            _billAmount = double.parse(value);
                          } catch (exception) {
                            _billAmount = 0.0;
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Split",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          Row(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (_personCounter > 1) {
                                      _personCounter--;
                                    } else {}
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7.0),
                                    color: _purple.withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "-",
                                      style: TextStyle(
                                          color: _purple,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17.0),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                "$_personCounter",
                                style: TextStyle(
                                    color: _purple, fontSize: 17.0),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _personCounter++;
                                  });
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  margin: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: _purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "+",
                                      style: TextStyle(
                                          color: _purple,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Tip",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              "\$ ${(calculateTotalTip(_billAmount, _personCounter, _tipPercentage)).toStringAsFixed(2)}",
                              style: TextStyle(
                                  color: _purple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "$_tipPercentage%",
                            style: TextStyle(
                                color: _purple,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Slider(
                              min: 0,
                              max: 100,
                              activeColor: _purple,
                              inactiveColor: Colors.grey,
                              divisions: 10,
                              value: _tipPercentage.toDouble(),
                              onChanged: (double value) {
                                setState(() {
                                  _tipPercentage = value.round();
                                });
                              })
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Data(itemList: _itemList),
                      ),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(45.0), // Border radius
                          side: const BorderSide(color: Colors.black, width: 1.0), // Border color and width
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 23.0),
                          child: Icon(Icons.money, color: _purple.withOpacity(0.5))
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Center(
                            child: Text("View Your Expenses", style: TextStyle(
                                color: _isDarkMode ? Colors.white : Colors.black,
                                fontSize: 20
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  calculateTotalPerPerson(
      double billAmount, int splitBy, int tipPercentage) {
    var totalPerPerson =
        (calculateTotalTip(billAmount, splitBy, tipPercentage) + billAmount) /
            splitBy;
    return totalPerPerson.toStringAsFixed(2);
  }

  calculateTotalTip(double billAmount, int splitBy, int tipPercentage) {
    double totalTip = 0.0;
    if (billAmount < 0 || billAmount.toString().isEmpty) {
    } else {
      totalTip = (billAmount * tipPercentage) / 100;
    }
    return totalTip;
  }

  _logout() {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    deleteFirstUserData();
    setState(() {
      googleSignIn.signOut();
    });
  }

  void _handleSubmit(String text, int amount, int tip) async {
    _tipController.clear();
    _amountController.clear();
    _titleController.clear();
    BillItem billItem = BillItem(text, amount, tip);
    int? savedItemId = await db.insertRecord(billItem);
    // debugPrint("Saved");
    BillItem? addedItem = await db.getItem(savedItemId!);
    setState(() {
      _itemList.insert(0, addedItem!);
    });
  }

  Future<void> deleteFirstUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get();
      String documentId = snapshot.docs[0].id;
      await FirebaseFirestore.instance.collection('users').doc(documentId).delete();
    } catch (e) {
      print("Error deleting Firestore document: $e");
    }
  }
}
