import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final _firestore = FirebaseFirestore.instance;

class RegistrationScreen extends StatefulWidget {
  static String id = 'register_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email = '';
  String password = '';
  String name = '';
  bool registerError = false;
  String errorText = 'An error occurred';
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final nameTextController = TextEditingController();

  bool checkIfEmpty() {
    // print('$email,$name,$password');
    if (email == '' || name == '' || password == '') {
      setState(() {
        registerError = true;
        errorText = 'All fields are required';
      });
      return true;
    }
    return false;
  }

  registerUser() async {
    if (checkIfEmpty()) {
      return;
    }
    setState(() {
      showSpinner = true;
    });
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (newUser != null) {
        emailTextController.clear();
        passwordTextController.clear();
        nameTextController.clear();
        _firestore.collection('users').add({
          'email': email,
          'userName': name,
          'status': 'Hey there, I am using Flash Chat !',
        }).then((val) {
          setState(() {
            showSpinner = false;
            registerError = false;
          });
          Navigator.pushNamed(context, LoginScreen.id);
        }).catchError((error) {
          print("Failed to add user: $error");
          setState(() {
            showSpinner = false;
            registerError = true;
          });
        });
      }
    } on FirebaseAuthException catch (e) {
      var error = 'An error occurred. Please try again';
      if (e.code == 'weak-password') {
        error = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        error = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        error = 'The email id is invalid.';
      }
      setState(() {
        showSpinner = false;
        registerError = true;
        errorText = error;
      });
    } catch (e) {
      setState(() {
        showSpinner = false;
        registerError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              registerError
                  ? Text(
                      errorText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    )
                  : Container(),
              registerError
                  ? SizedBox(
                      height: 8.0,
                    )
                  : Container(),
              TextField(
                controller: emailTextController,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: passwordTextController,
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: nameTextController,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  name = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your username',
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                colour: Colors.blueAccent,
                buttonText: 'Register',
                onPress: () {
                  registerUser();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
