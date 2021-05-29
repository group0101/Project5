import 'package:flutter/material.dart';

/// update profile data
///
/// enter name, mobile no, blood group
class UpdateProfileForm extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;
  UpdateProfileForm({this.onSubmit});
  @override
  _UpdateProfileFormState createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<UpdateProfileForm> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNo = "", _bloodGroup, _name;
  Color _primaryColor;
  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;

    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.name,
                onSaved: (String name) {
                  _name = name;
                },
                validator: (String name) {
                  if (name != null) name = name.trim();
                  if (name.length > 0) return null;
                  return "Enter Name";
                },
                decoration: InputDecoration(
                  hintText: "Name",
                  labelText: "Name",
                  fillColor: Colors.white,
                  suffixIcon: Icon(
                    Icons.text_fields_outlined,
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.phone,
                onSaved: (String phone) {
                  _phoneNo = phone;
                },
                validator: (String phone) {
                  phone = phone.trim();
                  // regex pattern for phone no
                  String p = r"\d{10}";
                  // regex for phone no
                  final regExp = RegExp(p);
                  // check if regex has match
                  if (regExp.hasMatch(phone)) return null;
                  return "Enter valid Phone Number";
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
              child: DropdownButtonFormField<String>(
                icon: Icon(Icons.local_hospital_rounded),
                hint: Text("Select Blood Group"),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (String s) {
                  if (_bloodGroup == null) return "Please Select Blood Group";
                  return null;
                },
                onChanged: (String bg) {
                  _bloodGroup = bg;
                },
                onSaved: (String bg) {
                  _bloodGroup = bg;
                },
                items: [
                  DropdownMenuItem(
                    value: "O+",
                    child: Center(
                      child: Text("O+"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "O-",
                    child: Center(
                      child: Text("O-"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "A+",
                    child: Center(
                      child: Text("A+"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "A-",
                    child: Center(
                      child: Text("A-"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "B+",
                    child: Center(
                      child: Text("B+"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "B-",
                    child: Center(
                      child: Text("B-"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "AB+",
                    child: Center(
                      child: Text("AB+"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "AB-",
                    child: Center(
                      child: Text("AB-"),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              child: FlatButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    Map<String, String> details = {
                      "displayName": _name,
                      "Phone": _phoneNo,
                      "Blood Group": _bloodGroup,
                    };
                    // submit new details
                    widget.onSubmit == null
                        ? Navigator.of(context).pop(details)
                        : widget.onSubmit(details);
                  }
                },
                child: Text(
                  "Submit",
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
    );
  }
}
