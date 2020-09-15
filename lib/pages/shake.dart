import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:sensors/sensors.dart';
import 'package:shield/models/user.dart';
import 'package:shield/pages/firebaseMessages.dart';
import 'package:shield/services/datbase.dart';


class ShakeWrapper extends StatelessWidget {

  static const id = 'Shake';

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return Shake(user: user,);
  }
}

class Shake extends StatefulWidget {

  final User user;
  Shake({this.user});

  @override
  _ShakeState createState() => _ShakeState(user: user);
}
class _ShakeState extends State<Shake> {

  final User user;
  _ShakeState({this.user});

  // variables only for this page
  bool loading = false;
  bool test = true;
  //function for getting emergency message from database,
  void _getMessage() async {

    setState(() {
      loading = true;
    });

    try {
      //finding the users location latitude and longitude
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        loading = false;
      });

      // Getting message from database
      final messages = await Firestore.instance.collection('User')
          .document(user.uid).collection('SavedMessages').getDocuments();
      //mapping the string from the data to a variable to use.
      for (var message in messages.documents ) {
        final String emergencyMessage = message.data['Message'];

        if (test == true) {
          setState(() {
            test = false;
          });

          //function adding message to database
          await DatabaseService(uid: user.uid)
              .message(user.email, emergencyMessage
              ,true, position.latitude,position.longitude);

          Navigator.popAndPushNamed(context, FireBaseMessages.id);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        if (event.x > 25.0) {
          setState(() async {
            _getMessage();
          });
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Emergency Message',style: TextStyle(fontSize: 22),),
          backgroundColor: Colors.blue,
        ),body:
    ModalProgressHUD(
        inAsyncCall: loading,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text('Shake to Send Emergency Message')),
          ],
        )));
  }
}
