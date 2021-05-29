import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Services/cache_service.dart';
import 'package:blood_share/Services/authentication.dart';
import 'package:blood_share/Services/location_service.dart';
import 'package:blood_share/Pages/home.dart';
import 'package:blood_share/Pages/login.dart';
import 'package:blood_share/Pages/about.dart';
import 'package:blood_share/Pages/signup.dart';
import 'package:blood_share/Pages/profile.dart';
import 'package:blood_share/Pages/verify_email.dart';
import 'package:blood_share/Pages/forgot_password.dart';

void main() {
  // create widget binding instance
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // color theme
  static const MaterialColor _swatch = MaterialColor(
    0xFF5704CC,
    <int, Color>{
      50: Color(0xFFDDC3FF),
      100: Color(0xFFCEACFC),
      200: Color(0xFFB086E6),
      300: Color(0xFFA771EE),
      400: Color(0xFF813ED8),
      500: Color(0xFF6D26C9),
      600: Color(0xFF5811B6),
      700: Color(0xFF4B0C9E),
      800: Color(0xFF3A0C77),
      900: Color(0xFF2A0658)
    },
  );

  final Future<FirebaseApp> _app = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    //run app in portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CacheService>(
          create: (_) => CacheService(),
          lazy: false,
        ),
        ChangeNotifierProvider<LocationService>(
          create: (_) => LocationService(),
          lazy: false,
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        StreamProvider(
          initialData: null,
          create: (_) => AuthService().firebaseUserChange,
        ),
      ],
      child: MaterialApp(
        title: 'Blood Share',
        theme: ThemeData(
          primarySwatch: _swatch,
          splashColor: Colors.purpleAccent[100],
          dividerColor: Color(0xFFDCC1FF),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "georgia",
        ),
        // make sure that firebase is initialised before rendering app ui
        home: FutureBuilder<FirebaseApp>(
            future: _app,
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Scaffold(
                  body: Center(
                    child: Text("ERROR OCCURED"),
                  ),
                );
              if (snapshot.connectionState == ConnectionState.done)
                return AppHome();
              return Scaffold(
                appBar: AppBar(
                  title: Text("Blood Share"),
                ),
                body: Center(
                  child: CustomLoader("Loading"),
                ),
              );
            }),
        // application page named routes
        routes: {
          "home": (context) => HomePage(),
          "profile": (context) => ProfilePage(),
          "login": (context) => LoginPage(),
          "signup": (context) => SignupPage(),
          "reset": (context) => ForgotPasswordPage(),
          "about": (context) => AboutPage(),
        },
      ),
    );
  }
}

class AppHome extends StatefulWidget {
  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  User user;
  Timer timer;
  AuthService _authService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = context.read<AuthService>();
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    if (this.mounted) super.setState(fn);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // cancel timer
    timer.cancel();
  }

  /// check if email is verified after link is sent
  void checkIfEmailVerified() async {
    // reload user
    await _authService.fireAuthInstace.currentUser.reload();
    if (user != null &&
        _authService.fireAuthInstace.currentUser.emailVerified) {
      // cancel timer after verification complete
      timer.cancel();
      // re-build
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch for user changes
    user = context.watch<User>();
    // if user email is not verified
    if (user != null &&
        !user.emailVerified &&
        !_authService.fireAuthInstace.currentUser.emailVerified) {
      // send verification link
      user.sendEmailVerification();
      // check if email is verified using link
      // check for every 3 seconds using timer
      timer = Timer.periodic(Duration(seconds: 3), (_) {
        checkIfEmailVerified();
      });
      // show verification page
      return VerifyEmailPage();
    }
    // show homepage if user is logged in with verified email
    if (user != null && user.uid.length == 28) return HomePage();
    // show login page
    return LoginPage();
  }
}

// if (user != null &&
//     !_authService.fireAuthInstace.currentUser.emailVerified) {
//   user.sendEmailVerification();
//   timer = Timer.periodic(Duration(seconds: 3), (_) {
//     checkIfEmailVerified();
//   });
// }
// if (user != null && !_authService.fireAuthInstace.currentUser.emailVerified)
//   return VerifyEmailPage();
