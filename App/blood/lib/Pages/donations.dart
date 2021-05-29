import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Services/data_service.dart';

// user donation history page
class Donations extends StatefulWidget {
  @override
  _DonationsState createState() => _DonationsState();
}

class _DonationsState extends State<Donations> {
  User _user;
  DataService _dataService;
  Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = context.read<User>();
    _dataService = DataService(uid: _user.uid);
    _future = _dataService.getUserDonations();
  }

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text("My Donations"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> _donations = snapshot.data;
            if (_donations.length == 0)
              return Center(
                child: Text("No Donations"),
              );
            // render list of past donations
            // time of doantion, recepient id etc.
            return ListView.builder(
              itemCount: _donations.length,
              itemBuilder: (context, index) {
                DateTime _time = DateTime.fromMillisecondsSinceEpoch(
                        _donations[index]["Time"])
                    .toLocal();
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(
                    top: 8.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Donation No : ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: "${_donations[index]["dno"]}",
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Donation ID : ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: "${_donations[index]["did"]}",
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Recepient UID : ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: "${_donations[index]["recepient_uid"]}",
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Recepient Email : ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: "${_donations[index]["recepient_email"]}",
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Donation Time : ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: "$_time",
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          if (snapshot.hasError)
            return Center(
              child: Text("Error Occured"),
            );

          return Center(
            child: CustomLoader("Loading"),
          );
        },
      ),
    );
  }
}
