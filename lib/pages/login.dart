import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shield/components/wrapper.dart';
import 'package:shield/pages/register.dart';
import 'package:shield/services/authService.dart';

class LoginScreen extends StatefulWidget {
  static const id = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //key for form validation
  final _formKey = GlobalKey<FormState>();

  //instance of AuthServices to allow the use of method in the class
  final AuthServices _auth = AuthServices();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String emailError = '';
  String passwordError = '';
  bool _autoValidate = false;
  bool _loginOkay = true;

  //Function for Textfield used multiple times
  TextFormField regTextField(TextEditingController input, String hint,
      Function validator, TextInputType keyboard, bool obscure) {
    return TextFormField(
        textAlign: TextAlign.center,
        keyboardType: keyboard,
        decoration: InputDecoration(hintText: hint),
        obscureText: obscure,
        validator: validator,
        onChanged: (String value) {
          setState(() => input.text = value.trim());
        });
  }

  Text reusableText (String text, double fontSize){
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, color: Colors.white),
    );
  }

  Text errorText(String error) {
    return Text(
      error,
      style: TextStyle(color: Colors.red),
    );
  }

  // Form validation methods
  String validateEmail(String value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+'
        r'(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.'
        r'[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value.trim()))
      return 'Enter a valid email';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.length < 6)
      return 'Invalid password format';
    else
      return null;
  }

  // method to manage the user login
  void login() async {
    //if all textFormFields are validated then call loggin method
    if (_formKey.currentState.validate()) {
      _loginOkay = true;
      //call logging method and log user in
      dynamic result =
          await _auth.signInWithEmailAndPassword(email.text, password.text);
      // if result returns an Exception check which
      if (result is PlatformException) {
        // marking login as wrong
        _loginOkay = false;
        // checking error and setting email error to show user
        if (result.code == 'ERROR_USER_NOT_FOUND') {
          passwordError = '';
          emailError = 'Email is not registered';
        }
        // checking error and setting email error to show user
        else {
          emailError = '';
          passwordError = 'Password is incorrect';
        }
      }
      // if user logs in take them to the home screen.
      if (_loginOkay) {
        Navigator.popAndPushNamed(context, Wrapper.id);
      }
    } else {
      _autoValidate = true;
    }
  }

  //method to send a password reset email
  void forgottenPassword() async {
    dynamic result = await _auth.resetPassword(email.text);
    if (result is PlatformException) {
      setState(() {
        emailError = 'Not a registed email address';
      });
    } else {
      Alert(
        context: context,
        type: AlertType.info,
        title: 'Password Reset Email Sent',
        desc: 'A password reset email has been sent. Please check your email.',
        buttons: [
          DialogButton(
            child: Text(
              'Okay',
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontFamily: 'Kalam'),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.blue,
            radius: BorderRadius.circular(20.0),
          ),
        ],
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, Wrapper.id);
              },
              icon: Icon(Icons.arrow_back_ios)),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Register.id);
                },
                child: reusableText('Register', 14),)
          ],
          title: reusableText('Account Login', 22),),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: Column(
              children: <Widget>[
                Card(
                  child: Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          regTextField(email, 'Email', validateEmail,
                              TextInputType.emailAddress, false),
                          errorText(emailError),
                          regTextField(password, 'Password', validatePassword,
                              TextInputType.text, true),
                          errorText(passwordError),
                        ],
                      )),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      child: reusableText('Login', 14),
                      color: Colors.blue,
                      onPressed: () async {
                        login();
                      },
                    ),
                    FlatButton(
                        onPressed: () {
                          forgottenPassword();
                        },
                        child: errorText('Forgetten Password'))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
