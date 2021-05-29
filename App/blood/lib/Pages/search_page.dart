import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_share/Services/data_service.dart';
import 'package:blood_share/Pages/donors.dart';
import 'package:blood_share/Pages/bloodbanks_list.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';

class SearchPage extends StatefulWidget {
  final bool searchBloodbanks;
  SearchPage({@required this.searchBloodbanks});
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchParam;
  DataService _dataService;
  String _value;
  User _user;
  bool _isLoading = false;
  Color _primary;
  bool _searchBloodbanks;

  List<String> _dropDownBloodbankItems = [
    "DISTRICT",
    "CITY",
    "PINCODE",
    "STATE"
  ];
  List<String> _dropDownDonorItems = [
    "O+",
    "O-",
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchBloodbanks = widget.searchBloodbanks;
    _searchParam = _searchBloodbanks ? "DISTRICT" : "O+";
    _user = context.read<User>();
    _dataService = DataService(uid: _user.uid);
  }

  /// search blood banks or donors
  void _search() async {
    setState(() {
      _isLoading = true;
    });
    // search bloodbanks for selected criteria
    if (_searchBloodbanks) {
      List<QueryDocumentSnapshot> queryResult =
          await _dataService.getBloodbanks(param: _searchParam, value: _value);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Container(
              color: _primary,
              child: SafeArea(
                child: BloodBanksListPage(queryResult),
              ),
            );
          },
        ),
      );
    } else {
      // get and render list of nearby donors
      // compatible for selected bloodgroup
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Container(
              color: _primary,
              child: SafeArea(
                child: DonorsListView(
                  bloodGroup: _searchParam,
                ),
              ),
            );
          },
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  /// create dropdowm menu
  Widget _dropDownMenu() {
    return _searchBloodbanks
        ? DropdownButtonHideUnderline(
            // dropdown menu for blood banks
            child: DropdownButton<String>(
              style: TextStyle(
                color: Colors.black,
              ),
              icon: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.more_vert,
                  color: _primary,
                ),
              ),
              onChanged: (String sp) {
                setState(() {
                  _searchParam = sp;
                });
              },
              items: _dropDownBloodbankItems
                  .map(
                    (String item) => DropdownMenuItem(
                      value: item,
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        : DropdownButtonHideUnderline(
            // dropdown menu for bloodgroups
            child: DropdownButton<String>(
              style: TextStyle(
                color: Colors.black,
              ),
              icon: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.more_vert,
                  color: _primary,
                ),
              ),
              onChanged: (String sp) {
                setState(() {
                  _searchParam = sp;
                });
              },
              items: _dropDownDonorItems
                  .map(
                    (String item) => DropdownMenuItem(
                      value: item,
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    _primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title:
            _searchBloodbanks ? Text("Search Bloodbank") : Text("Search Donor"),
        actions: [
          Switch(
            activeColor: Colors.white,
            inactiveTrackColor: Color(0xFFB086E6),
            activeTrackColor: Color(0xFFB086E6),
            onChanged: (bool switched) {
              setState(() {
                _searchBloodbanks = switched;
                _searchParam = switched ? "DISTRICT" : "O+";
              });
            },
            value: _searchBloodbanks,
          )
        ],
      ),
      body: _isLoading
          ? CustomLoader("Searching")
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: _searchBloodbanks
                  ? Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              autofocus: true,
                              textInputAction: TextInputAction.done,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (String val) {
                                if (val.trim().isNotEmpty) return null;
                                return "Enter Valid Input";
                              },
                              onChanged: (String val) {
                                _value = val.trim();
                              },
                              decoration: InputDecoration(
                                suffixIcon: _dropDownMenu(),
                                hintText: "Search by $_searchParam",
                                labelText: _searchParam,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Transform.scale(
                              scale: 0.5,
                              child: Container(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Image.asset("assets/bloodbank.png"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.black,
                                        )),
                                    child: Center(
                                        child: RichText(
                                      text: TextSpan(
                                          text: "Search Donors for ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "$_searchParam ?",
                                              style: TextStyle(
                                                color: _primary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ]),
                                    )),
                                  ),
                                ),
                                _dropDownMenu(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Transform.scale(
                              scale: 0.5,
                              child: Container(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Image.asset("assets/donor.png"),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.search,
          color: Colors.white,
        ),
        onPressed: () {
          if (_searchBloodbanks && _value.isNotEmpty) _search();
          if (!_searchBloodbanks && _searchParam != null) _search();
        },
        tooltip: "Search",
      ),
    );
  }
}
