import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:shield/models/user.dart';
import 'package:shield/services/datbase.dart';


class FireBaseMessages extends StatefulWidget {

  static const id = 'firebaseMessage';
  @override
  _FireBaseMessagesState createState() => _FireBaseMessagesState();
}

class _FireBaseMessagesState extends State<FireBaseMessages> {


  // text controller for message textField
  TextEditingController messageController = TextEditingController();

  //Function to validate Phone number (make sure its 11 digits)
  String validateMobile(String value) {
    if (value.length < 11)
      return 'Mobile numbers must be 11 digit';
    else
      return null;
  }

  //function for TextField decoration(Just tidy to have it here)
  final textInputDecoration = InputDecoration(
    hintText: 'Type message here....',
    disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.blue,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20)),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.blue,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
        borderRadius: BorderRadius.circular(20)),
  );

  @override
  Widget build(BuildContext context) {

    //listening to stream to check if user is logged in.
    final user = Provider.of<User>(context);

      return Scaffold(appBar: AppBar(
        centerTitle: true,
        title: Text('Messages',style: TextStyle(fontSize: 24),),
      ),body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessageStream(),
              Row(
                children: <Widget>[
                  Expanded(child: TextFormField(
                      controller: messageController,
                      decoration: textInputDecoration,),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8,0,0,0),
                    child: RaisedButton(
                      padding: EdgeInsets.all(8),
                      color: Colors.blue,
                      onPressed: () async{

                        if (messageController.text.trim() != '') {
                          //function adding message to database
                          await DatabaseService(uid: user.uid)
                              .message(user.email,
                              messageController.text,false,null,null);
                          //clearing message controller
                          messageController.clear();
                        }
                      },
                      child: Text('Send', style: TextStyle
                        (color: Colors.white,fontSize: 22),),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),

      );
    }
  }

  // class for the message display on screen
class MessageStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //listening to stream to check if user is logged in.
    final user = Provider.of<User>(context);

    return StreamBuilder<QuerySnapshot>(
        stream:
        Firestore.instance.collection('Messages').orderBy('dateCreated',
            descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData){
            return Column();
          }
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];

          for (var message in messages) {
            final messageText = message.data['Message'];
            final messageSender = message.data['Sender_Email'];

            final button = message.data['Button'];
            final latitude = message.data['Latitude'];
            final longitude = message.data['Longitude'];

            final currentUser = user.email;

            final messageBubble =
            MessageBubble(sender: messageSender,
                text: messageText,
                isMe: currentUser == messageSender,button: button,
              latitude: latitude,longitude: longitude,);
            messageBubbles.add(messageBubble);


          }
          return Expanded(child: ListView(children: messageBubbles,
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),));
        });
  }
}

class MessageBubble extends StatelessWidget {

  static bool location = true;

  final String sender;
  final String text;
  final bool isMe;
  final bool button;
  final double latitude;
  final double longitude;

  MessageBubble({this.sender, this.text, this.isMe,
    this.button,this.latitude,this.longitude});

  openMapsSheet(context, double latitude, double longitude,
      String sender) async {
    try {
      final title = sender;
      final coords = Coords(latitude, longitude);
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                          description: sender + ' location',
                        ),
                        title: Text(map.mapName),
                        leading: Image(
                          image: map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          button?
          MaterialButton(
            onPressed: (){
              if (button == true){
                openMapsSheet(context,latitude,longitude,sender);
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: isMe
                  ? BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            elevation: 5.0,
            color: isMe ? Colors.blueAccent : Colors.pinkAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          )
          :  Material(
            shape: RoundedRectangleBorder(
              borderRadius: isMe
                  ? BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            elevation: 5.0,
            color: isMe ? Colors.blueAccent : Colors.pinkAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          button? Text(
            'Press for location',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.red,
            ),
          ): Text('')
        ],
      ),
    );
  }
}
