import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shield/components/addMessage.dart';
import 'package:shield/models/savedMessage.dart';
import 'package:shield/models/user.dart';
import 'package:shield/pages/firebaseMessages.dart';
import 'package:shield/pages/imagerCapture.dart';
import 'package:shield/pages/shake.dart';
import 'package:shield/services/authService.dart';


class HomeScreen extends StatefulWidget {
  static const id = 'home';

  final String uid;
  HomeScreen({this.uid});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Uint8List imageFile;
  StorageReference imageRef = FirebaseStorage.instance.ref().child('images');

  getImage() {
    int maxSize = 7 * 1024 * 1024;
    imageRef.child('${widget.uid}.png').getData(maxSize).then((data) {
      this.setState(() {
        imageFile = data;
      });
    }).catchError((e) {});
    //todo: handle error
    print('error');
  }

  @override
  void initState(){
    super.initState();
    getImage();
  }
  @override
  Widget build(BuildContext context) {
    //listening to stream to check if user is logged in.
    final user = Provider.of<User>(context);
    //Provider for checking if user has saved a message.
    final message = Provider.of<SavedMessage>(context);
    //instance of AuthServices to allow the use of method in the class
    final AuthServices _auth = AuthServices();

    Widget userImage(){
      if(imageFile == null) {
        return AspectRatio(
          aspectRatio: 2 / 1,
          child: GestureDetector(
            child: Image.asset('images/shield.png'),
            onTap: () {
              if (message != null) {
                Navigator.of(context).pushNamed(ShakeWrapper.id);
              }
              else {
                Navigator.of(context).pushNamed(AddMessage.id);
              }
            },
          ),
        );
      }
      else {
        return
          Center(
            child: GestureDetector(
              child: CircleAvatar(
                  radius: 60,
                  backgroundImage: Image.memory(imageFile,
                    ).image
              ),
              onTap: () {
                if (message != null) {
                  Navigator.of(context).pushNamed(ShakeWrapper.id);
                }
                else {
                  Navigator.of(context).pushNamed(AddMessage.id);
                }
              },
            ),
          );
      }
    }
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(icon: Icon(Icons.add_a_photo, color:
          Colors.pinkAccent, size: 40,), onPressed: () {
            Navigator.of(context).popAndPushNamed(ImageCapture.id);
          }),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  _auth.signOutFunction();
                },
                child: Text('Logout',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20))),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue,
          elevation: 0.0,
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[IconButton(
                icon: Icon(
                  Icons.message,
                  size: 50,
                  color: Colors.white,
                ),
                onPressed: () async {
                  Navigator.of(context).pushNamed(FireBaseMessages.id);
                }),
            ],),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.white],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          userImage(),
              Text(
                user.displayName,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }
