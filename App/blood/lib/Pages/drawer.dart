import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blood_share/Services/cache_service.dart';
import 'package:blood_share/Services/authentication.dart';
import 'package:blood_share/Services/data_service.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Custom_Widgets/app_logo_animation.dart';

// App drawer
// profile page, name or email,
// logout button
class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  User _user;
  Size _size;
  bool _isLoading = false;
  AuthService _authService;
  DataService _dataService;
  CacheService _cacheService;
  Color _primaryColor;

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
    _authService = context.read<AuthService>();
    _dataService = DataService(uid: _user.uid);

    // run after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _downloadImage();
    });
  }

  void _downloadImage() async {
    // if image not available locally,
    // download from firebase storage
    // if available
    if (_cacheService.profileImage == null && _user.photoURL != null) {
      setState(() {
        _isLoading = true;
      });
      // download image and save into cache
      await _cacheService.downloadAndCacheFile(_user.photoURL);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _cacheService = context.watch<CacheService>();
    _size = MediaQuery.of(context).size;
    _primaryColor = Theme.of(context).primaryColor;
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: _size.height * 0.1,
          ),
          GestureDetector(
            onTap: () async {
              Navigator.of(context).push(
                PageRouteBuilder(
                  fullscreenDialog: true,
                  maintainState: false,
                  transitionDuration: Duration(milliseconds: 200),
                  reverseTransitionDuration: Duration(milliseconds: 150),
                  pageBuilder: (context, scale, __) {
                    return ScaleTransition(
                      scale: scale,
                      // view image in interactive viewer
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
            child: CircleAvatar(
              maxRadius: _size.width * 0.17,
              backgroundImage: (_cacheService.profileImage != null)
                  ? FileImage(_cacheService.profileImage)
                  : AssetImage("assets/user.jpg"),
              child: _isLoading ? Center(child: CustomLoader()) : null,
            ),
          ),
          SizedBox(
            height: _size.height * 0.025,
          ),
          Text(
            DataService.userName != null
                ? DataService.userName
                : _user.displayName != null
                    ? _user.displayName
                    : _user.email,
            style: TextStyle(
              fontSize: 18,
              color: _primaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Center(
                    child: Opacity(
                      opacity: 0.38,
                      child: SizedBox(
                        height: _size.height * 0.1,
                        child: RiveAnimation(),
                      ),
                    ),
                  ),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.logout),
                  label: Text(
                    'logout',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      bool _logout = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Confirm'),
                            content: Text('Do you want to logout ?'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('NO'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); //Will not Logout
                                },
                              ),
                              FlatButton(
                                child: Text('YES'),
                                onPressed: () {
                                  Navigator.of(context).pop(true); //Will Logout
                                },
                              )
                            ],
                          );
                        },
                      );
                      if (!_logout) return;
                      _dataService.flushUserData();
                      await _cacheService.emptyCache();
                      await _authService.signOut();
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                ),
                SizedBox(
                  height: _size.height * 0.05,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
