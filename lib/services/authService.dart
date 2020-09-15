import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shield/models/user.dart';
import 'package:shield/services/datbase.dart';

// methods to be used for user login, register and sign out
class AuthServices {

  //instance of firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //method to deactivate offline mode for Firestore
  void stopOffline() {
    Firestore _cache = Firestore.instance;
    //set as true to turn offline mode on
    // (I switched this off as some issues with cache when testing)
    _cache.settings(persistenceEnabled: false);
  }

  //create user object based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user){
    // checking the user is not equal to null before returning uid for user
    // otherwise returning null
    return user != null ? User(uid: user.uid, email: user.email, displayName: user.displayName ) : null;
  }

  //auth change user stream
  Stream<User> get user{
    //listening for a user to login or out and mapping it to the user
    // objects I have created.
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // sign in with username and pass
  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword
        (email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return e;
    }
  }

  // registerWith Email password method
  Future registerWithEmailAndPassword(String email, String password,
      String firstName, String lastName, String phoneNumber,
      ) async{
    try{
      //creating a new user account on firebase with email and password.
      AuthResult result = await _auth.createUserWithEmailAndPassword
        (email: email, password: password);
      FirebaseUser user = result.user;

      //setting display name
      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = firstName +' ' + lastName;
      await user.updateProfile(updateInfo);

      //create user on the database
      await DatabaseService(uid: user.uid)
          .updateUserInformation(firstName, lastName, email, phoneNumber);

      await _auth.signOut();


      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return e;
    }
  }

  // signOut function
  Future signOutFunction () async {
    try{
      return await _auth.signOut();
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
//reset password email
  Future resetPassword (String userEmail) async {

    try{
      return await _auth.sendPasswordResetEmail(email: userEmail);
    }
    catch (e){
      print(e);
      return e;
    }
  }






}