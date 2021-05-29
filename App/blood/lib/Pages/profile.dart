import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:blood_share/Services/cache_service.dart';
import 'package:blood_share/Services/data_service.dart';
import 'package:blood_share/Pages/update_profile.dart';
import 'package:blood_share/Pages/delete_account.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';

// profile page
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User _user;
  Size _size;
  DataService _dataService;
  CacheService _cacheService;
  Color _primaryColor;
  Map<String, dynamic> _userData;
  ImagePicker picker = ImagePicker();
  String _email, _name, _phone, _bloodGroup;
  bool _isLoading = false, _isUpdating = false;

  // get new profile image from camera or local storage
  Future<void> _getImage({bool camera}) async {
    PickedFile pickedFile;
    File imageFile;

    setState(() {
      _isLoading = true;
    });

    if (camera == true) {
      // camera
      pickedFile =
          await picker.getImage(source: ImageSource.camera, imageQuality: 30);
      if (pickedFile != null) imageFile = File(pickedFile.path);
    } else {
      // local storage
      pickedFile =
          await picker.getImage(source: ImageSource.gallery, imageQuality: 30);
      if (pickedFile != null) imageFile = File(pickedFile.path);
    }

    if (imageFile != null) {
      if (await _confirm(imageFile)) {
        // update profile image
        await _dataService.updateProfileImage(imageFile);
        String url = await _dataService.getProfileImageURI();
        await _user.updateProfile(photoURL: url);
        // update cached image
        await _cacheService.changeProfileImage(file: imageFile, url: url);
        // update photoUrl in user record
        await _dataService.updateUserData({"photoURL": url});
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // show pick new profile image dialog
  Future<File> _pickImage(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Pick Profile Photo",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.purple[700],
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FlatButton(
              child: Text(
                'Pick Image From Gallery',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                _getImage(camera: false);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Take Image Using Camera',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                _getImage(camera: true);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
        ],
      ),
    );
  }

  // show image confirmation dialog
  // to comfirm profile image update
  Future<bool> _confirm(File file) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Confirm Image",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.purple[700],
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                maxRadius: _size.width * 0.20,
                backgroundImage: FileImage(file),
              ),
            ],
          ),
          actions: [
            FlatButton(
              child: Text(
                'CANCEL',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    if (this.mounted) super.setState(fn);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = context.read<User>();
    _dataService = DataService(uid: _user.uid);
    _dataService.getUserData().then((userDoc) {
      _userData = userDoc.data();
    }).catchError((e) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _downloadImage();
    });
  }

  // download image if not available in local cache
  void _downloadImage() async {
    if (_cacheService.profileImage == null && _user.photoURL != null) {
      setState(() {
        _isLoading = true;
      });
      // download image file and store in cache
      await _cacheService.downloadAndCacheFile(_user.photoURL);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _primaryColor = Theme.of(context).primaryColor;
    _cacheService = context.watch<CacheService>();
    return Container(
      color: _primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: _size.height * 0.09,
                  width: double.infinity,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          blurRadius: 3,
                          color: _primaryColor,
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Color(0xE5FFFFFF),
                          Color(0xFFFFFFFF),
                          Color(0xE5FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: _size.height * 0.03,
                  width: double.infinity,
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            fullscreenDialog: true,
                            maintainState: false,
                            transitionDuration: Duration(milliseconds: 200),
                            reverseTransitionDuration:
                                Duration(milliseconds: 150),
                            pageBuilder: (context, scale, __) {
                              return ScaleTransition(
                                scale: scale,
                                child: InteractiveViewer(
                                  child: (_cacheService.profileImage != null)
                                      ? Image.file(_cacheService.profileImage)
                                      : Image.asset("assets/user.jpg"),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Hero(
                        tag: Key("ImgKey"),
                        child: CircleAvatar(
                          maxRadius: _size.width * 0.18,
                          backgroundImage: (_cacheService.profileImage != null)
                              ? FileImage(_cacheService.profileImage)
                              : AssetImage("assets/user.jpg"),
                          child:
                              _isLoading ? Center(child: CustomLoader()) : null,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, _size.width * 0.165),
                      child: IconButton(
                        tooltip: "Change Photo",
                        iconSize: 26,
                        icon: Container(
                          child: Icon(
                            // Icons.add_circle_sharp,
                            Icons.add_photo_alternate_rounded,
                            color: Color(0xFF15008A),
                          ),
                        ),
                        onPressed: () {
                          _pickImage(context);
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: _size.height * 0.02,
                ),
                FutureBuilder(
                  future: _dataService.getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && _isUpdating != true) {
                      _email = snapshot.data["email"] ?? "Email Not Registered";
                      _name =
                          snapshot.data["displayName"] ?? "Name Not Registered";
                      _bloodGroup = snapshot.data["Blood Group"] ??
                          "Blood Group Not Registered";
                      _phone = snapshot.data["Phone"] ??
                          "Phone Number Not Registered";
                      return Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: "Email",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "\n$_email",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: "Username",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "\n$_name",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: "Phone no",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "\n$_phone",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: "Blood Group",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                          text: "\n$_bloodGroup",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            FlatButton.icon(
                              label: Text(
                                "Update Location",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              icon: Icon(Icons.gps_fixed),
                              onPressed: () async {
                                LatLng location = await Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return LocationUpdate(
                                    lat: _userData["Latitude"],
                                    lon: _userData["Longitude"],
                                  );
                                }));
                                if (location != null) _updateLocation(location);
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FlatButton.icon(
                                  icon: Icon(Icons.delete_forever),
                                  label: Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  onPressed: () {
                                    _deleteAccount(context);
                                  },
                                ),
                                FlatButton.icon(
                                  label: Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  icon: Icon(Icons.settings),
                                  onPressed: () async {
                                    Map<String, String> details =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                        return UpdateProfilePage();
                                      }),
                                    );
                                    if (details != null) {
                                      setState(() {
                                        _isUpdating = true;
                                      });
                                      await _user.updateProfile(
                                          displayName: details["displayName"]);
                                      await _dataService
                                          .updateUserData(details);
                                      setState(() {
                                        _isUpdating = false;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: _size.height * 0.04,
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError)
                      return Expanded(
                        child: Center(
                          child: Text("Error Occured"),
                        ),
                      );
                    if (_isUpdating)
                      return Expanded(
                        child: Center(
                          child: CustomLoader("Updating"),
                        ),
                      );
                    return Expanded(
                      child: Center(
                        child: CustomLoader("Loading"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// update user location in database
  void _updateLocation(LatLng location) async {
    setState(() {
      _isUpdating = true;
    });
    // update location
    await _dataService.updateLocation(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    setState(() {
      _isUpdating = false;
    });
  }

  /// delete account
  void _deleteAccount(BuildContext context) async {
    try {
      // get account type,
      // password account or google sign in
      String accountType = _user.providerData[0].providerId;
      bool isCanceled = await showDialog(
        context: context,
        // show alert before deleting.
        builder: (context) => AlertDialog(
          title: Text(
            "Delete My Account",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.purple[700],
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                "!!! Warning !!!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Your account and associated data \nwill be lost permanently",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        ),
      );
      // return if deletion cancelled
      if (isCanceled) return;
      // confirm deletion by verifying email or password
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Container(
              color: _primaryColor,
              child: SafeArea(
                child: accountType.compareTo("google.com") == 0
                    ? DeleteGoogleSigninAccountPage()
                    : DeletePasswordAccountPage(),
              ),
            );
          },
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }
}
