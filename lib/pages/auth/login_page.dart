import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book/helper/helper_asset.dart';
import 'package:flutter_book/helper/helper_function.dart';
import 'package:flutter_book/pages/home_page.dart';
import 'package:flutter_book/service/auth_service.dart';
import 'package:flutter_book/service/database_service.dart';
import 'package:flutter_book/widgets/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "App Book",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Login now in real book"),
                        Image.asset(HelperAsset.imageLogin),
                        TextFormField(
                            decoration: textInputDecoration.copyWith(
                                labelText: "Email",
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColor,
                                )),
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },

                            // check validation
                            validator: (val) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val!)
                                  ? null
                                  : "Please enter a valid email";
                            }),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                              )),
                          validator: (val) {
                            if (val!.length < 6) {
                              return "Password must be at least 6 characters";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                login();
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Don't have an account?",
                            style:
                                TextStyle(color: Colors.black, fontSize: 14)),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: Register,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child:
                                          Image.asset(HelperAsset.imageGoogle),
                                    ),
                                    const Text(
                                      "Continue with google",
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
    );
  }

  Future<void> Register() async {
    try {
      // show information user
      // await _googleSignIn.signIn();
      // update information email in auth google firebase
      await signInWithGoogle();
    } catch (e) {
      print('Error signing in $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Create an instance of the firebase auth and google signin
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    //Triger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    //Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    //Create a new credentials
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    //Sign in the user with the credentials
    final UserCredential userCredential =
        await auth.signInWithCredential(credential);
    register(googleUser);
    return null;
  }

  register(user) async {
    // if (formKey.currentState!.validate()) {
    //   setState(() {
    //     _isLoading = true;
    //   });
    print("value ${user.displayName}");

    await authService
        .registerUserWithEmailandPassword(user.displayName, user.email, user.id)
        .then((value) async {
      if (value == true) {

        // saving the shared preference state
        // await HelperFunctions.saveUserLoggedInStatus(true);
        // await HelperFunctions.saveUserEmailSF(user.email);
        // await HelperFunctions.saveUserNameSF(user.name);
        nextScreenReplace(context, HomePage());
      } else {
        showSnackbar(context, Colors.red, value);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithUserNameandPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);

          // saving the values to our shared preferences;
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
