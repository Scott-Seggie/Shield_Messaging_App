import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shield/models/savedMessage.dart';
import 'package:shield/models/user.dart';
import 'package:shield/pages/homeScreen.dart';
import 'package:shield/pages/login.dart';
import 'package:shield/services/datbase.dart';

class Wrapper extends StatelessWidget {

  static const id = 'wrapper';
  @override
  Widget build(BuildContext context) {
    //listening to stream to check if user is logged in.
    final user = Provider.of<User>(context);


    //if user is not logged in go to the Login screen
    if (user == null){
      return LoginScreen();
    }
    //else go to the homeScreen
    else {
      return StreamProvider<SavedMessage>.value(
    value: DatabaseService(uid: user.uid).userMessage,
          catchError: (_, __) => null,
    child: HomeScreen(uid: user.uid ));
    }
  }
}
