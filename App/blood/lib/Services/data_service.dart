import 'dart:io';
import 'package:blood_share/Services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_share/Services/cache_service.dart';
import 'package:blood_share/Services/location_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:firebase_database/firebase_database.dart';

/// Database Service
class DataService {
  final String uid;
  final CacheService _cacheService = CacheService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("Users");
  final CollectionReference reportsCollection =
      FirebaseFirestore.instance.collection("SpamReports");
  final CollectionReference bloodbanksCollection =
      FirebaseFirestore.instance.collection("Bloodbanks");
  final firebase_storage.FirebaseStorage firebaseStorageInsatnce =
      firebase_storage.FirebaseStorage.instance;
  static DocumentSnapshot userDoc;
  static String userName;
  static QuerySnapshot nearbyBloodBanks, nearbyDonors, _donations;
  static bool isUserDataStreamInitialised = false;

  DataService({this.uid});

  // Stream<DocumentSnapshot> get userDataStream =>
  // userCollection.doc(uid).snapshots();
  Stream<QuerySnapshot> get userCollectionStream => userCollection.snapshots();

  Future<DocumentSnapshot> get userData => userCollection.doc(uid).get();
  Future<QuerySnapshot> get userCollectionData => userCollection.get();

  // DatabaseReference get databaseRef =>
  //     FirebaseDatabase.instance.reference().child("Reprts");

  /// listen to changes in user database record
  void initUserDataStream() {
    isUserDataStreamInitialised = true;
    Stream<DocumentSnapshot> stream = userCollection.doc(uid).snapshots();
    stream.listen((DocumentSnapshot doc) {
      // sign out user if diasbled by admin
      if (doc.data()['disabled']) signOut();
      // update local user record
      userDoc = doc;
    });
  }

  /// fetch user record from database or return local
  /// if available
  Future<DocumentSnapshot> getUserData() async {
    if (!isUserDataStreamInitialised && this.uid != null) {
      userDoc = await userData;
      while (!userDoc.exists) {
        await Future.delayed(Duration(seconds: 3), () async {
          userDoc = await userData;
        });
      }
      initUserDataStream();
      return userDoc;
    } else {
      return userDoc;
    }
  }

  /// create user record if not exist
  Future<void> createUserData(Map<String, dynamic> data) async {
    try {
      DocumentSnapshot userDoc = await userData;
      // return if user record already exists
      if (userDoc.exists) return;
      // creaate record
      await userCollection.doc(uid).set(data);
    } catch (e) {}
  }

  /// update user default location
  Future<void> updateLocation(
      {@required double latitude, @required double longitude}) async {
    try {
      await userCollection
          .doc(uid)
          .update({"Latitude": latitude, "Longitude": longitude});
      userDoc = await userData;
    } catch (e) {}
  }

  /// update user database record with new data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      await userCollection.doc(uid).update(data);
      userDoc = await userData;
      userName = userDoc.data()["displayName"];
    } catch (e) {}
  }

  /// clear local user data and signout
  void signOut() async {
    // clear static data
    flushUserData();
    // clear cache
    await _cacheService.emptyCache();
    // signout
    await AuthService().signOut();
  }

  /// get donation history of user
  Future<List<Map<String, dynamic>>> getUserDonations(
      {bool refresh = false}) async {
    if (userDoc["Frequency"] > 0) {
      try {
        // fetch user donations
        if (_donations == null || refresh)
          _donations = await userCollection
              .doc(uid)
              .collection("Donations")
              .orderBy("dno")
              .get();
        // create map from document snapshot
        return _donations.docs.map((QueryDocumentSnapshot snapshot) {
          Map<String, dynamic> snap = snapshot.data();
          snap.addAll({
            "did": snapshot.id,
          });
          return snap;
        }).toList();
      } catch (e) {
        print(e.toString());
      }
    }
    return [];
  }

  /// clear static data of current user
  void flushUserData() {
    isUserDataStreamInitialised = false;
    userName = null;
    userDoc = null;
  }

  /// delete user record from database
  Future<void> deleteUserData() async {
    try {
      QuerySnapshot snap =
          await userCollection.doc(uid).collection("Donations").get();
      // delete users donation history
      snap.docs.forEach((QueryDocumentSnapshot q) async {
        print(q.id);
        await userCollection
            .doc(uid)
            .collection("Donations")
            .doc(q.id)
            .delete();
      });
      // delete users data from database
      await userCollection.doc(uid).delete();
      // clear cache
      await _cacheService.emptyCache();
      // delete profile image from database
      await firebaseStorageInsatnce
          .ref()
          .child("Users Storage")
          .child("User $uid")
          .child("profile_image")
          .delete();
    } catch (e) {
      print(e.toString());
    }
  }

  /// get bloodbanks for given info
  Future<List<QueryDocumentSnapshot>> getBloodbanks(
      {String param, String value}) async {
    value = value.toUpperCase();

    // fetch available bloodbanks from database
    QuerySnapshot querySnapshot =
        await bloodbanksCollection.where(param, isEqualTo: value).get();

    return querySnapshot.docs.where((QueryDocumentSnapshot doc) {
      return doc["LATITUDE"] > 1 && doc["LONGITUDE"] > 1;
    }).toList();
  }

  /// get profile image url from firebase storage
  Future<String> getProfileImageURI() async {
    String downloadURL;
    try {
      // fetch url
      downloadURL = await firebaseStorageInsatnce
          .ref()
          .child("Users Storage")
          .child("User $uid")
          .child("profile_image")
          .getDownloadURL();
    } on FirebaseException catch (e) {
      return e.code;
    } catch (e) {
      return "Error";
    }
    return downloadURL;
  }

  /// update profile image in firebase storage
  Future<String> updateProfileImage(File file) async {
    try {
      // store new image in firebase storage
      await firebaseStorageInsatnce
          .ref()
          .child("Users Storage")
          .child("User $uid")
          .child("profile_image")
          .putFile(file);
    } on FirebaseException catch (e) {
      return e.code;
    } catch (e) {
      return "Error";
    }
    return "Success";
  }

  /// check if user is valid for QR code verifiction
  Future<bool> isValidUser({String recepientUID, String recepientEmail}) async {
    DocumentSnapshot recepient = await userCollection.doc(recepientUID).get();
    if (recepient.exists && recepient.data()["email"] == recepientEmail)
      return true;
    return false;
  }

  /// run transaction to update doantion history of user
  Future<String> donateBlood({
    String recepientEmail,
    String recepientUID,
  }) async {
    try {
      // run firebase transaction
      return await firestore.runTransaction(
        (transaction) async {
          // get user document reference
          DocumentReference userDataRef = userCollection.doc(uid);
          // get fresh document snapshot
          DocumentSnapshot snapshot = await transaction.get(userDataRef);
          if (!snapshot.exists) {
            throw Exception("User does not exist!");
          }

          int _now = DateTime.now().millisecondsSinceEpoch;
          int _frequency = snapshot.data()["Frequency"];
          DocumentReference userDonationRef =
              userCollection.doc(uid).collection("Donations").doc();

          if (_frequency == 0) {
            transaction.update(userDataRef, {
              'Time': _now,
              'Recency': _now,
              'Frequency': _frequency + 1,
            });
          } else {
            transaction.update(userDataRef, {
              'Recency': _now,
              'Frequency': _frequency + 1,
            });
          }

          // insert new donation record
          userDonationRef.set({
            "dno": _frequency + 1,
            "recepient_uid": recepientUID,
            "recepient_email": recepientEmail,
            "Time": _now,
          });

          // update local static  data
          userDoc = await userData;
          _donations = await userCollection
              .doc(uid)
              .collection("Donations")
              .orderBy("dno")
              .get();

          return "Success";
        },
        timeout: Duration(seconds: 20),
      );
    } catch (e) {
      return "Failed";
    }
  }

  /// get nearby bloodbanks using user location co-ordinates
  Future<List<QueryDocumentSnapshot>> getNearbyBloodbanks() async {
    if (LocationService.hasLocationPermission) {
      // get nearby bloodbanks within range of 1 degree lantitude and longitude
      double latitude = LocationService.myLocation.latitude;
      if (nearbyBloodBanks == null)
        nearbyBloodBanks = await bloodbanksCollection
            .where("LATITUDE", isGreaterThanOrEqualTo: latitude - 1)
            .where("LATITUDE", isLessThanOrEqualTo: latitude + 1)
            .get();

      // convert and return document snapshots to dart list of hashmaps
      return nearbyBloodBanks.docs.where((bloodbankDocument) {
        return bloodbankDocument.data()["LONGITUDE"] >
                LocationService.myLocation.longitude - 1 &&
            bloodbankDocument.data()["LONGITUDE"] <
                LocationService.myLocation.longitude + 1;
      }).toList();
    }
    return [];
  }

  /// get nearby donors from users curent location and
  ///
  /// location of users in database
  Future<List<QueryDocumentSnapshot>> getNearbyDonors(
      {bool refresh = false}) async {
    if (LocationService.hasLocationPermission) {
      double latitude = LocationService.myLocation.latitude;
      double longitude = LocationService.myLocation.longitude;

      if (refresh) {
        // get users in 0.5 degree latitude and longitude range
        nearbyDonors = await userCollection
            .where("Latitude", isGreaterThanOrEqualTo: latitude - 0.5)
            .where("Latitude", isLessThanOrEqualTo: latitude + 0.5)
            .get();
        return null;
      }
      if (nearbyDonors == null)
        nearbyDonors = await userCollection
            .where("Latitude", isGreaterThanOrEqualTo: latitude - 0.5)
            .where("Latitude", isLessThanOrEqualTo: latitude + 0.5)
            .get();

      int _ninetyDaysAgo =
          DateTime.now().subtract(Duration(days: 90)).millisecondsSinceEpoch;

      // convert and return document snapshots to dart list of hashmaps
      return nearbyDonors.docs.where((donorDocument) {
        return donorDocument.data()["Frequency"] == 0 ||
            donorDocument.data()["uid"] != uid &&
                donorDocument.data()["Longitude"] > longitude - 0.5 &&
                donorDocument.data()["Longitude"] < longitude + 0.5 &&
                donorDocument.data()["Recency"] <= _ninetyDaysAgo;
      }).toList();
    }
    return [];
  }

  /// report user using email or phone number
  Future<String> reportUser({String email, String phone, String msg}) async {
    QuerySnapshot emailRecords, phoneRecords;
    Map<String, dynamic> reportRecord = {
      'message': msg,
      'reportedBy': uid,
    };

    if (email != null && email.length > 0) {
      emailRecords =
          await userCollection.where('email', isEqualTo: email).get();
      reportRecord['spamEmail'] = email;
    }
    if (phone != null && phone.length > 0) {
      phoneRecords =
          await userCollection.where('Phone', isEqualTo: phone).get();
      reportRecord['spamPhoneNo'] = phone;
    }
    // reportRecord['message'] = msg;
    // reportRecord['reportedBy'] = uid;

    // check is user exists for entered details
    if ((emailRecords != null && emailRecords.size > 0) ||
        (phoneRecords != null && phoneRecords.size > 0)) {
      await reportsCollection.doc().set(reportRecord);
      return 'User Reported';
    }

    return 'User does not exist';
  }
}
