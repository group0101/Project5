import 'package:blood_share/Services/data_service.dart';
import 'package:blood_share/Services/location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

///user account logic implementation
///
///create user, delete user, sign in, sign out,
///
///reset password etc
class AuthService {
  final FirebaseAuth _fireAuthInstance = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseAuth get fireAuthInstace => _fireAuthInstance;
  Stream<User> get firebaseUserChange => _fireAuthInstance.authStateChanges();

  ///create account with email and password.
  ///
  ///create database record
  Future<String> createUser({String email, String pass}) async {
    UserCredential userCred;
    Map<String, dynamic> data;
    try {
      //create user credientials
      userCred = await _fireAuthInstance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      //get initial user location
      double _lat = 0.1;
      double _lon = 0.1;
      if (LocationService.myLocation != null) {
        _lat = LocationService.myLocation.latitude;
        _lon = LocationService.myLocation.longitude;
      }

      //temp user record
      data = {
        "uid": userCred.user.uid,
        "displayName": null,
        "Phone": null,
        "email": email,
        "photoURL": "NA",
        "Recency": null,
        "Frequency": 0,
        "Time": null,
        "Latitude": _lat,
        "Longitude": _lon,
        "disabled": false,
        "Blood Group": null,
      };

      //handle exception in account creation
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'weak password';
      } else if (e.code == 'email-already-in-use') {
        return 'user already exists';
      }
      return e.code;
    } catch (e) {
      return "Error occured";
    }

    //create user record
    await DataService(uid: userCred.user.uid).createUserData(data);

    return "User created";
  }

  ///Sign in with email and password
  Future<String> signInUser({String email, String pass}) async {
    try {
      //trigger sign in
      await _fireAuthInstance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      //handle sign in exceptions
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'user not found';
      } else if (e.code == 'wrong-password') {
        return 'wrong password';
      }
      return e.code;
    } catch (e) {
      return "Error occured";
    }
    return "Signed in";
  }

  ///Direct sign in with gmail
  Future<String> signInWithGoogle({Map<String, dynamic> userData}) async {
    UserCredential userCred;
    Map<String, dynamic> data;

    // Trigger the authentication
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      //trigger sign in with credentials created
      userCred = await _fireAuthInstance.signInWithCredential(credential);

      //initial user location
      double _lat = 0.1;
      double _lon = 0.1;
      if (LocationService.myLocation != null) {
        _lat = LocationService.myLocation.latitude;
        _lon = LocationService.myLocation.longitude;
      }

      //temp user record
      data = {
        "uid": userCred.user.uid,
        "displayName": userCred.user.displayName,
        "Phone": null,
        "email": userCred.user.email,
        "photoURL": userCred.user.photoURL,
        "Recency": null,
        "Frequency": 0,
        "Time": null,
        "Latitude": _lat,
        "Longitude": _lon,
        "disabled": false,
        "Blood Group": null,
      };

      //handle firebase exceptions
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'user not found';
      } else if (e.code == 'wrong-password') {
        return 'wrong password';
      }
      return e.code;
    } catch (e) {
      return "Error Occured";
    }

    //create databe record for user
    await DataService(uid: userCred.user.uid).createUserData(data);

    return "Signed in";
  }

  ///forgot password
  ///
  ///reset password through link sent on email
  Future<String> resetPassword({String email}) async {
    try {
      //send password reset link
      await _fireAuthInstance.sendPasswordResetEmail(
        email: email,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code.compareTo("invalid-email") == 0) return "Invalid Email";
      if (e.code.compareTo("user-not-found") == 0) return "user not found";
      return e.code;
    } catch (e) {
      return "Error Occured";
    }
    return "Link Sent";
  }

  // Future<void> signOutAndForget() async {
  //   await _googleSignIn.signOut();
  //   await _fireAuthInstance.signOut();
  // }

  /// logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _fireAuthInstance.signOut();
  }

  ///delete user
  ///
  ///delete account and database record for user
  Future<String> deleteUserAccount({String pass, String email}) async {
    try {
      //delete email and password account
      if (email == null) {
        //check account type
        if (_fireAuthInstance.currentUser.providerData[0].providerId
                .compareTo("password") !=
            0) return "Incorrect Account type chosen";

        //get uid of current user
        String uid = _fireAuthInstance.currentUser.uid;
        //get user credentials
        AuthCredential authCred = EmailAuthProvider.credential(
          email: _fireAuthInstance.currentUser.email,
          password: pass,
        );

        DataService _dataService = DataService(uid: uid);
        //clear user session data
        _dataService.flushUserData();
        //delete user database record
        await _dataService.deleteUserData();
        //reauthenticate user before deleting
        await _fireAuthInstance.currentUser
            .reauthenticateWithCredential(authCred);
        //delete user permenantly
        await _fireAuthInstance.currentUser.delete();

        //delete google sign in account
      } else if (email.compareTo(_fireAuthInstance.currentUser.email) == 0) {
        //check account type
        if (_fireAuthInstance.currentUser.providerData[0].providerId
                .compareTo("google.com") !=
            0) return "Incorrect Account type chosen";

        //get current user uid
        String uid = _fireAuthInstance.currentUser.uid;
        //get google sign in account
        GoogleSignInAccount googleUser = await _googleSignIn.signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        //get user auth credentials
        AuthCredential authCred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        DataService _dataService = DataService(uid: uid);
        //clear user session temp data
        _dataService.flushUserData();
        //reauthenticate
        await _fireAuthInstance.currentUser
            .reauthenticateWithCredential(authCred);
        //delete account
        await _fireAuthInstance.currentUser.delete();

        //delete database record
        await _dataService.deleteUserData();
      } else if (email.compareTo(_fireAuthInstance.currentUser.email) != 0) {
        return "Incorrect Email";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code.compareTo("wrong-password") == 0)
        return "Wrong Password Entered";
    } catch (e) {
      return "Error Deleting User";
      // return e.toString();
    }
    await signOut();
    return "Account Deleted";
  }
}
