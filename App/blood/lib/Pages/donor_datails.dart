import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_share/Pages/bloodbank_details.dart';
import 'package:blood_share/Pages/prediction_chart.dart';

// show donor details
// when clicked on donor list item
// photo, name, contact details etc,
class DonorInfoPage extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;

  //view info for donor with given document snapshot
  DonorInfoPage(this.snapshot);

  @override
  _DonorInfoPageState createState() => _DonorInfoPageState();
}

class _DonorInfoPageState extends State<DonorInfoPage> {
  double _recency, _time, _frequency;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.snapshot["Frequency"] > 0 &&
        widget.snapshot["Recency"] != null &&
        widget.snapshot["Time"] != null) {
      DateTime _now = DateTime.now();
      // calculate recency
      _recency = _now
              .difference(
                DateTime.fromMillisecondsSinceEpoch(widget.snapshot["Recency"]),
              )
              .inDays /
          30;

      // calculate first doantion time
      _time = _now
              .difference(
                DateTime.fromMillisecondsSinceEpoch(widget.snapshot["Time"]),
              )
              .inDays /
          30;

      // set donation frequency
      _frequency = double.parse(widget.snapshot["Frequency"].toString());
    } else {
      _recency = 0;
      _frequency = 0;
      _time = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color _primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text("Donor Details"),
      ),
      body: Container(
        height: double.infinity,
        margin: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 25,
              ),
              CircleAvatar(
                maxRadius: 50,
                backgroundImage: widget.snapshot["photoURL"] != null &&
                        widget.snapshot["photoURL"].startsWith("http")
                    ? NetworkImage(widget.snapshot["photoURL"])
                    : AssetImage("assets/user.jpg"),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  bottom: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 20),
                      child: Text(
                        widget.snapshot["displayName"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Flexible(
                      child: CardField(
                        field: "Email",
                        value: widget.snapshot["email"],
                        icon: Icons.email,
                      ),
                    ),
                    if (widget.snapshot["Phone"] != null)
                      Flexible(
                        child: CardField(
                          field: "Contact",
                          value: widget.snapshot["Phone"],
                          icon: Icons.phone_enabled,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: 'Blood Group : ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${widget.snapshot["Blood Group"]}',
                                    style: TextStyle(
                                      color: _primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // show donation probabilities
              if (_frequency != 0)
                MLPrediction(
                  recency: _recency,
                  frequency: _frequency,
                  time: _time,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: 'Last Donation : ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${_recency.toStringAsFixed(2)} ',
                              style: TextStyle(
                                color: _primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'months ago.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: 'Donated blood : ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${_frequency.toStringAsFixed(0)} ',
                              style: TextStyle(
                                color: _primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'times.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: 'First Donation : ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: _frequency == 1
                                  ? '${_recency.toStringAsFixed(2)} '
                                  : '${_time.toStringAsFixed(2)} ',
                              style: TextStyle(
                                color: _primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'months ago.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
