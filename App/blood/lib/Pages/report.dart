import 'package:blood_share/Forms/report_user.dart';
import 'package:blood_share/Services/data_service.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  final DataService dataService;
  ReportPage({this.dataService});
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          child: Center(
            child: SingleChildScrollView(
              // report user
              child: ReportUserForm(dataService: widget.dataService),
            ),
          ),
        ),
      ),
    );
  }
}
