import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shield/models/savedMessage.dart';

class DatabaseService {
  //variables and constructor
  final String uid;
  DatabaseService({this.uid});


  //------------------Saving data functions------------------------------

// instance to (reference) database record
  final CollectionReference userInfo =
  Firestore.instance.collection('User');

  //register and update user data on the database, (create new doc
  // with said values)
  Future updateUserInformation(String firstName, String lastName,
      String email, String phoneNumber) async{
    return await userInfo.document(uid).setData({
      'Name': firstName +' '+lastName,
      'Email': email,
      'Phone_Number': phoneNumber,
    });
  }

  Future updateUserSavedMessage(String message ) async{
    return await userInfo.document(uid).collection('SavedMessages')
        .document('EmergencyMessage').setData({
      'Message': message,

    });
  }

  // adding messages to user record on database to activate Function
  Future message (String senderEmail, String message, bool button, double latitude,
      double longitude) async{
    return await
    Firestore.instance.collection('Messages').document()
        .setData({
      'Sender_Email': senderEmail,
      'Message':message,
      'dateCreated': Timestamp.now(),
      'Button':button,
      'Latitude':latitude,
      'Longitude':longitude,
    });
  }

  //-------------------------Getting Data Functions --------------------------

  SavedMessage _messageFromSnapshot(DocumentSnapshot snapshot) {
    return SavedMessage(
    message: snapshot.data['Message'],
    );
  }

// stream to get user emergency message
  Stream<SavedMessage> get userMessage{
    return userInfo.document(uid).collection('SavedMessages')
        .document('EmergencyMessage').snapshots().map(_messageFromSnapshot);
  }



}
