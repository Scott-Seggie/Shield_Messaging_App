const functions = require('firebase-functions');
const admin = require('firebase-admin');
 
admin.initializeApp(functions.config().functions);
 
var newData;
 
exports.messageTrigger = functions
.firestore.document('User/{userId}/Device/{deviceId}/Initial_Messages/{messageId}')
.onCreate(async (snapshot, context) => {

    if (snapshot.empty) {
        console.log('No Devices');
        return;
    }

    //saving message from snapshot of firestore
    newData = snapshot.data();

    //creating a tokens array for device tokens (ID's)
    //getting Device list from database then adding them to the token array 
    //var tokens = [];
    //const deviceTokens = await admin.firestore().collection('Device_List').get()
    //for (var token of deviceTokens.docs){
      //  tokens.push(token.data().Device_ID);
    //}
 var payload = {notification: {title: newData.Sender_Name, body: newData.Message, sound: 'default'},
 data: { click_action: 'FLUTTER_NOTIFICATION_CLICK', message: newData.Sender_ID},
};
try {
    const response = await admin.messaging().sendToDevice(newData.Receiver_ID, payload);

    console.log('Notification send okay')
} catch (err){
    console.log('error send notification')

}
});