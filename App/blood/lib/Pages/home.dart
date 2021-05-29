import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_share/Services/qrcode.dart';
import 'package:blood_share/Services/data_service.dart';
import 'package:blood_share/Services/location_service.dart';
import 'package:blood_share/Pages/map.dart';
import 'package:blood_share/Pages/about.dart';
import 'package:blood_share/Pages/report.dart';
import 'package:blood_share/Pages/drawer.dart';
import 'package:blood_share/Pages/profile.dart';
import 'package:blood_share/Pages/home_tab.dart';
import 'package:blood_share/Pages/info_tab.dart';
import 'package:blood_share/Pages/search_page.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Custom_Widgets/bottom_sheet.dart';
import 'package:blood_share/Custom_Widgets/app_logo_animation.dart';
import 'package:blood_share/Custom_Widgets/bottom_app_bar_item.dart';
import 'package:blood_share/Custom_Widgets/app_bar_dropdown_menu.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User _user;
  Size _size;
  Color _primaryColor;
  int _currentIndex = 0;
  DataService _dataService;
  bool _isLoading = false, _checking = false;
  List titlesList = <String>[
    "Blood Share",
    "Info",
    "Map",
    "Chat",
  ];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = context.read<User>();
    _dataService = DataService(uid: _user.uid);

    // run after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // get user data from database
      DocumentSnapshot doc = await _dataService.getUserData();
      // parse to dart hashmap
      Map<String, dynamic> data = doc.data();
      // show bottom sheet for updating details if
      // details are not available
      if (data["displayName"] == null ||
          data["Phone"] == null ||
          data["Blood Group"] == null) _showBottomSheet();
    });
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;
    _size = MediaQuery.of(context).size;
    double _bottomAppBarHeight = _size.height * 0.065;

    return WillPopScope(
      key: Key("homeWillPop"),
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(titlesList[_currentIndex]),
          actions: [
            AppBarDropDownMenu(
              scanQRCode: _scanQRCode,
              showQRCode: _showQRCode,
              showAboutPage: _showAboutPage,
              showReportPage: _showReportPage,
            )
          ],
        ),
        drawer: DrawerPage(),
        body: _isLoading
            ? CustomLoader("Updating Donation\nRecord")
            : _checking
                ? CustomLoader("Checking")
                : CurrentTab(
                    currentIndex: _currentIndex,
                    scanQRCode: _scanQRCode,
                    showQRCode: _showQRCode,
                    showAboutPage: _showAboutPage,
                  ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: (_currentIndex != 0)
            ? SizedBox(
                height: _bottomAppBarHeight,
                width: _bottomAppBarHeight,
                child: FloatingActionButton(
                  tooltip: "Search",
                  backgroundColor: _primaryColor,
                  child: Icon(
                    Icons.search,
                    size: _bottomAppBarHeight * 3 / 7,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SearchPage(
                            searchBloodbanks: false,
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            : null,
        bottomNavigationBar: BottomAppBar(
          color: _primaryColor,
          shape: CircularNotchedRectangle(),
          notchMargin: 2,
          child: Container(
            height: _bottomAppBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomBottomAppBarItem(
                  label: "Home",
                  icon: Icons.home,
                  changeTab: _changeTab,
                  currentIndex: _currentIndex,
                  index: 0,
                ),
                CustomBottomAppBarItem(
                  label: "Info",
                  icon: Icons.bar_chart,
                  changeTab: _changeTab,
                  currentIndex: _currentIndex,
                  index: 1,
                ),
                SizedBox(
                  width: _bottomAppBarHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: (_currentIndex != 0)
                        ? null
                        : GestureDetector(
                            onTap: () {
                              _showAboutPage();
                            },
                            child: Tooltip(
                              message: "Blood Share",
                              child: RiveAnimation(),
                            ),
                          ),
                  ),
                ),
                CustomBottomAppBarItem(
                  label: "Map",
                  icon: Icons.map,
                  changeTab: _changeTab,
                  currentIndex: _currentIndex,
                  index: 2,
                ),
                CustomBottomAppBarItem(
                  label: "Profile",
                  icon: Icons.account_circle_rounded,
                  changeTab: _changeTab,
                  currentIndex: _currentIndex,
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// on back button pressed
  Future<bool> _onBackPressed() async {
    // go to homepage
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
    // or ask to exit application
    bool exit = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Do you want to exit the App ?'),
          actions: <Widget>[
            FlatButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop(false); //Will not exit the App
              },
            ),
            FlatButton(
              child: Text('YES'),
              onPressed: () {
                Navigator.of(context).pop(true); //Will exit the App
              },
            )
          ],
        );
      },
    );
    if (exit) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return true;
    }
    return exit;
  }

  /// show modal bootom sheet for
  ///
  /// updating user details
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          clipBehavior: Clip.hardEdge,
          height: _size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: CustomBottomSheet(
            size: _size,
            onBackPressed: _onBackPressed,
            update: _updateDetails,
          ),
        );
      },
    );
  }

  /// update user details in firebase
  void _updateDetails(Map<String, String> details) async {
    await _user.updateProfile(displayName: details["displayName"]);
    if (LocationService.myLocation != null) {
      // create user data hashmap
      // with location update
      Map<String, dynamic> data = {
        "displayName": details["displayName"],
        "Phone": details["Phone"],
        "Blood Group": details["Blood Group"],
        "Latitude": LocationService.myLocation.latitude,
        "Longitude": LocationService.myLocation.longitude
      };
      // update into database
      await _dataService.updateUserData(data);
      return;
    }
    await _dataService.updateUserData(details);
  }

  /// show QR code for blood donation
  ///
  /// details update
  void _showQRCode() async {
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        maintainState: false,
        barrierColor: Colors.white,
        transitionDuration: Duration(milliseconds: 200),
        reverseTransitionDuration: Duration(milliseconds: 150),
        pageBuilder: (context, scale, _) {
          return ScaleTransition(
            scale: scale,
            // QR code viewer
            child: QRCodeView(),
          );
        },
      ),
    );
  }

  /// scan QR code
  void _scanQRCode() async {
    setState(() {
      _checking = true;
    });
    // get recency of last doantion in days
    int _recency = (await _dataService.getUserData()).data()["Recency"];
    setState(() {
      _checking = false;
    });

    // if last donation id less than 90 days ago
    // the user cannot donate
    if (_recency != null &&
        _recency >
            DateTime.now()
                .subtract(
                  Duration(days: 90),
                )
                .millisecondsSinceEpoch) {
      int _days = DateTime.now()
          .difference(
            DateTime.fromMillisecondsSinceEpoch(_recency),
          )
          .inDays;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Your last donation\n",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: "was ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: "$_days days",
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text: " ago",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text:
                              "\n\nBlood Share does not recommend\nDonating blood in less than\n",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: "90 Days Interval",
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
      return;
    }

    // if last doantion is more than 90 days ago then
    // open OR code scanner to update database
    String _result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return QRCodeScan();
        },
      ),
    );
    List<String> _resList;
    bool _validQRCode = false;

    // check QR code validity
    if (_result.contains(" ")) {
      _resList = _result.split(" ");
      if (_resList.length == 2) {
        String uidPattern = r"(\w){28}";
        final uidRegExp = RegExp(uidPattern);
        String emailPattern = r"(\w+)@(\w+)[.](\w+)";
        final emailRegExp = RegExp(emailPattern);

        bool _validUID = _resList[0].length == 28 &&
            _resList[0] != _user.uid &&
            uidRegExp.hasMatch(_resList[0]);
        bool _validEmail = emailRegExp.hasMatch(_resList[1]);
        if (_validUID && _validEmail) _validQRCode = true;
      }
    }
    setState(() {
      _isLoading = true;
    });

    // check user validity
    if (_validQRCode &&
        await _dataService.isValidUser(
          recepientUID: _resList[0],
          recepientEmail: _resList[1],
        )) {
      // donate and update donation details in databse
      String res = await _dataService.donateBlood(
        recepientUID: _resList[0],
        recepientEmail: _resList[1],
      );
      print(res);
      if (res == "Success")
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Donated to User\n\n",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: _resList[1],
                      style: TextStyle(
                        color: _primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
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
      else
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Failed to Update\n\n",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    "Please try again",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
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
    } else
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              "Invalid QR Code",
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
  }

  /// show About page
  void _showAboutPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AboutPage();
        },
      ),
    );
  }

  /// show report user page
  void _showReportPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ReportPage(
            dataService: _dataService,
          );
        },
      ),
    );
  }
}

// render current tab on homepage
class CurrentTab extends StatelessWidget {
  final int currentIndex;
  final Function showQRCode;
  final Function scanQRCode;
  final Function showAboutPage;
  CurrentTab({
    this.currentIndex,
    this.scanQRCode,
    this.showAboutPage,
    this.showQRCode,
  });
  @override
  Widget build(BuildContext context) {
    switch (currentIndex) {
      case 0:
        return HomeTab(
          showQRCode: showQRCode,
          scanQRCode: scanQRCode,
          showAboutPage: showAboutPage,
        );
        break;
      case 1:
        return InfoTab();
        break;
      case 2:
        return MapView();
        break;
      case 3:
        return ProfilePage();
        break;
      default:
        return Scaffold(
          appBar: AppBar(
            title: Text("Error"),
          ),
          body: Center(child: Text("Error")),
        );
    }
  }
}
