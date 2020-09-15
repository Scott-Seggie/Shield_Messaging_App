import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shield/components/wrapper.dart';

class Uploader extends StatefulWidget {

  final File file;
  final String uid;

  Uploader({Key key, this.file, this.uid}) : super(key:key);
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {

  final FirebaseStorage _storage =
  FirebaseStorage(storageBucket: 'gs://shield-e3819.appspot.com');

  StorageUploadTask _uploadTask;

  void _startUpload(){
    String filePath = 'images/${widget.uid}.png';

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null){
      return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot){
          var event = snapshot?.data?.snapshot;

          double progressPercent = event != null ? event.bytesTransferred /
          event.totalByteCount :0 ;

          if (_uploadTask.isComplete) {
           return Column(children: <Widget>[
             LinearProgressIndicator(value: progressPercent),
             Text(
                 '${(progressPercent * 100).toStringAsFixed(2)}%'
             ),
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text('Image Upload Complete',
          style: TextStyle(color: Colors.green),),
             ),
             RaisedButton(child: Text('Okay',
               style: TextStyle(color: Colors.white),),
               color: Colors.blue, onPressed: () {
               Navigator.popAndPushNamed(context, Wrapper.id);
             },),
           ],);
          }
          else if (_uploadTask.isPaused){
            return Column(children: <Widget>[
              LinearProgressIndicator(value: progressPercent),
              Text(
                  '${(progressPercent * 100).toStringAsFixed(2)}%'
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Image Upload Paused',
                    style: TextStyle(color: Colors.grey)),
              ),
              FlatButton(child: Icon(Icons.play_arrow), onPressed:
              _uploadTask.resume),
            ],);
          }
          else
            return Column(children: <Widget>[
              LinearProgressIndicator(value: progressPercent),
              Text(
                  '${(progressPercent * 100).toStringAsFixed(2)}%'
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Image Upload in progress...',
          style: TextStyle(color: Colors.blue)),
              ),
              FlatButton(child: Icon(Icons.pause), onPressed:
              _uploadTask.pause),
            ],);
        },
      );
    }
    else{
      return FlatButton.icon(onPressed: _startUpload, icon: Icon(Icons.cloud_upload),
          label: Text('Save Image'));
    }

  }
}
