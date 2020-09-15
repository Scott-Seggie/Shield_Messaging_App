import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shield/models/user.dart';
import 'package:shield/services/datbase.dart';

class AddMessage extends StatelessWidget {

  static const id = 'addMessage';
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    // text controller for message textField
    TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Message',style:
        TextStyle(fontSize: 22,fontWeight: FontWeight.bold,),)
      ),
      body: Column(children: <Widget>[Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  textInputAction: TextInputAction.done,
                  controller: messageController,
                  maxLength: 200,
                  maxLines: 8,
                  decoration: InputDecoration.collapsed(hintText: "Enter message here "),
                ),
              )
          ),
        ),
      ),
        RaisedButton(
          color: Colors.blue,
          child: Text('Save', style: TextStyle(color: Colors.white),),
          onPressed: () async {
            await DatabaseService(uid: user.uid).
            updateUserSavedMessage(messageController.text);

            Navigator.pop(context);
          },)
      ],),
    );
  }
}

