import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:blood_share/Forms/update_profile.dart';

/// custom modal bottom sheet for
///
/// initial user details on creation of
///
/// account
class CustomBottomSheet extends StatefulWidget {
  final Function update;
  final Size size;
  final Function onBackPressed;
  CustomBottomSheet({this.update, this.onBackPressed, this.size});
  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        key: Key("modalWillPop"),
        onWillPop: widget.onBackPressed,
        child: Column(
          children: [
            AppBar(
              title: Text("Update Details"),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            Expanded(
              child: _isLoading
                  ? CustomLoader("Updating")
                  : Scaffold(
                      body: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical:8.0),
                          child: SingleChildScrollView(
                            child: UpdateProfileForm(
                              onSubmit: (Map<String, String> details) async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await widget.update(details);
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
