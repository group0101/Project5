import 'package:flutter/material.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Services/data_service.dart';

///Report user
///
///enter email or phone number to report
///
///enter valid report message
class ReportUserForm extends StatefulWidget {
  final DataService dataService;
  ReportUserForm({this.dataService});
  @override
  _ReportUserFormState createState() => _ReportUserFormState();
}

class _ReportUserFormState extends State<ReportUserForm> {
  String _email, _phoneNo, _msg;
  bool _isLoading = false;
  Color _primaryColor;

  @override
  void setState(fn) {
    // TODO: implement setState
    if (this.mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;

    return _isLoading
        ? CustomLoader("Reporting User")
        : Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'If you are Reciving any spam Emails, Calls or SMS Related to Blood Share, Enter the spam Email or Phone no to report the Account. strict action will be taken against such spam Accounts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (String email) {
                            _email = email.trim();
                          },
                          decoration: InputDecoration(
                            hintText: "Email",
                            labelText: "Email",
                            fillColor: Colors.white,
                            suffixIcon: Icon(
                              Icons.email,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          onChanged: (String phone) {
                            _phoneNo = phone.trim();
                          },
                          maxLength: 10,
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.phone_enabled,
                            ),
                            hintText: "Phone No",
                            labelText: "Phone No",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              gapPadding: 0,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          onChanged: (String msg) {
                            _msg = msg.trim();
                          },
                          maxLines: null,
                          maxLength: 255,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.text_fields,
                            ),
                            hintText: "Report Message",
                            labelText: " Report Message ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              gapPadding: 0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        child: FlatButton(
                          onPressed: _onPressed,
                          child: Text(
                            "Report",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          minWidth: double.infinity,
                          height: 50,
                          color: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  /// report user
  void _onPressed() async {
    bool _emailValid = false, _phoneValid = false;
    if (_email != null) {
      // regex pattern for email
      String _emailPattern = r"(\w+)@(\w+)[.](\w+)";
      // check is regex has match
      final regExpEmail = RegExp(_emailPattern);
      // create regular expression object
      _emailValid = regExpEmail.hasMatch(_email);
    }

    if (_phoneNo != null) {
      // regex pattern for phone number
      String _phonePattern = r"\d{10}";
      // create regular expression object
      final regExpPhone = RegExp(_phonePattern);
      // check is regex has match
      _phoneValid = regExpPhone.hasMatch(_phoneNo);
    }

    if ((_emailValid || _phoneValid) && _msg != null) {
      setState(() {
        _isLoading = true;
      });

      // report user if exists
      String result = await widget.dataService
              .reportUser(email: _email, phone: _phoneNo, msg: _msg),
          report;

      if (result == 'User Reported')
        report = 'Reported User account with\nentered details';
      else
        report = 'BloodShare User does not exist for\nentered details';
      // show dialog of user reported
      // or user does not exist
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              report,
              textAlign: TextAlign.center,
            ),
            actions: [
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } else {
      // if error occured
      String _content = '';
      if (!(_phoneValid || _emailValid))
        _content += 'Enter Valid Phone Number or Email\n';
      if (_msg == null || _msg.length == 0)
        _content += 'Enter proper report message';

      // show error message in dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              '$_content',
              textAlign: TextAlign.center,
            ),
            actions: [
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
