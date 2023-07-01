import 'package:bill_splitter/model/expenses.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../util/hexcolor.dart';

class Data extends StatefulWidget {
  final List<BillItem> itemList;
  const Data({Key? key, required this.itemList}) : super(key: key);

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
  final Color _purple = HexColor("#6908D6");
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  var db = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
        centerTitle: true,
        backgroundColor: _purple.withOpacity(0.5),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: false,
              itemCount: widget.itemList.length,
              itemBuilder: (_, int index) {
                return Card(
                  color: Colors.white10,
                  child: ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Food: ${widget.itemList[index].title}", style: const TextStyle(fontWeight: FontWeight.w600)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text("Amount: ${widget.itemList[index].amount}", style: const TextStyle(fontWeight: FontWeight.w600),),
                            Text(", Tip: ${widget.itemList[index].tip}", style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    onLongPress: () => _updateItem(widget.itemList[index], index), // Corrected
                    trailing: Listener(
                      key: Key(widget.itemList[index].title), // Corrected
                      child: const Icon(Icons.remove_circle, color: Colors.redAccent),
                      onPointerDown: (pointerEvent) => _deleteNoDo(widget.itemList[index].id, index), // Corrected
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateItem(BillItem item, int index)
  {
    var alert = AlertDialog(
      title: const Text("Update Item"),
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
          onPressed: () async {
            BillItem ItemUpdated = BillItem.fromMap(
                {
                  "title": _titleController.text,
                  "amount": _amountController.text,
                  "tip": _tipController.text,
                  "id": item.id
                });
            _handleSubmittedUpdate(index, item);
            await db.updateRecord(ItemUpdated);
            setState(() {
              _readNoDoList();
            });

            _tipController.clear();
            _titleController.clear();
            _amountController.clear();
            Navigator.pop(context);
          },
          child: const Text("Update"),
        ),
        TextButton(
          onPressed: () {
            _tipController.clear();
            _titleController.clear();
            _amountController.clear();
            Navigator.pop(context);
          },
          child: const Text("Cancel"),

        )
      ],
    );
    showDialog(context: context, builder: (_)
    {
      return alert;
    });
  }

  void _handleSubmittedUpdate(int index, BillItem item) {
    setState(() {
      widget.itemList.removeWhere((element)
      {
        return widget.itemList[index].title == item.title;
      });
    });
  }

  _readNoDoList() async
  {
    List<Map<String, Object?>>? items = await db.queryDatabase();
    items?.forEach((item) {
      setState(() {
        widget.itemList.add(BillItem.map(item));
      });
    });
  }

  void _deleteNoDo(int? id, int index) async
  {
    debugPrint("Deleted Item! $id");
    await db.deleteRecord(id!);
    setState(() {
      widget.itemList.removeAt(index);
    });
  }
}
