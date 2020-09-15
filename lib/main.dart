
import 'package:flutter/material.dart';
import 'package:shield/components/addMessage.dart';
import 'package:shield/components/wrapper.dart';
import 'package:shield/models/user.dart';
import 'package:shield/pages/firebaseMessages.dart';
import 'package:shield/pages/homeScreen.dart';
import 'package:shield/pages/imagerCapture.dart';
import 'package:shield/pages/login.dart';
import 'package:shield/pages/register.dart';
import 'package:provider/provider.dart';
import 'package:shield/pages/shake.dart';
import 'package:shield/services/authService.dart';



void main() => runApp(Shield());


class Shield extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    //Material app is wrapped in StreamProivder so app can listen for users logged in
    // and users logging out using Provider.of
    return StreamProvider<User>.value(
      // the Stream the app is listening for
      value: AuthServices().user,
      child: MaterialApp(
        // routes to get to each page
          initialRoute:Wrapper.id,
          routes: {
            Wrapper.id: (context) => Wrapper(),
            LoginScreen.id: (context) => LoginScreen(),
            Register.id: (context) => Register(),
            HomeScreen.id: (context) => HomeScreen(),
            FireBaseMessages.id: (context) => FireBaseMessages(),
            ShakeWrapper.id: (context) => ShakeWrapper(),
            AddMessage.id: (context) => AddMessage(),
            ImageCapture.id: (context) => ImageCapture(),

          }
      ),
    );
  }
}


