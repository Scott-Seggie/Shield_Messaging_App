
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:shield/components/uploader.dart';
import 'package:shield/components/wrapper.dart';
import 'package:shield/models/user.dart';

class ImageCapture extends StatefulWidget {

  static const id = 'camera';
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {

  File _imageFile;

  Future _pickImage(ImageSource source)async{

    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });

  }

  Future _cropImage() async{

    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,);

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void _clear (){
    setState(() {
       _imageFile = null; 
    });
  }
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.popAndPushNamed(context, Wrapper.id);
        }),
       title: Text('Add Image',style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar:
        BottomAppBar(
          color: Colors.blue,
          child: Row(children: <Widget>[IconButton
            (icon: Icon(Icons.camera,color: Colors.white, size: 30,), onPressed: (){
            _pickImage(ImageSource.camera);
          }),IconButton(icon: Icon(Icons.photo_library,color:
          Colors.white,size: 30,), onPressed: (){
            _pickImage(ImageSource.gallery);
          })],),
        ),
      body: ListView(
        children: <Widget>[if (_imageFile != null)...[
          Container(height: 400,
              child: Image.file(_imageFile)),
          
          Row(
            children: <Widget>[
              FlatButton(child: Icon(Icons.crop),
                  onPressed: _cropImage,),
              FlatButton(child: Icon(Icons.refresh),
                onPressed: _clear,)
            ],
          ),

          Uploader(file: _imageFile, uid: user.uid,),
        ]],
      ),
    );
  }
}

