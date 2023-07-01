class BillItem {
  BillItem(this._title, this._amount, this._tip);

  late String _title;
  late int _tip;
  late int _amount;
  int? _id;

  User({int? id}) {
    _id = id;
  }

  BillItem.map(dynamic obj) {
    this._title = obj["title"];
    this._amount = int.parse(obj["amount"]);
    this._tip = int.parse(obj["tip"]);
    this._id = obj["id"];
  }

  String get title => _title;

  int get amount => _amount;

  int get tip => _tip;

  int? get id => _id;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["title"] = _title;
    map["amount"] = _amount;
    map["tip"] = _tip;
    if (_id != null) {
      map["id"] = _id;
    }
    return map;
  }

  BillItem.fromMap(Map<String, dynamic> map) {
    this._title = map["title"];
    this._amount = int.parse(map["amount"]);
    this._tip = int.parse(map["tip"]);
    this._id = map["id"];
  }
}
