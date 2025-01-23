import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safedrive/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// <------------------ USER PREFERENCES --------------------->

final List preferences = [
  ["Show speed", true],
  ["Show sharp turns", true],
  ["Show heavy inclination", true],
  ["Dark Mode", true]
];

Future<void> savePreference(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value); // Setting the user preference
}

Future<void> loadPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for (var pref in preferences) {
    String key = pref[0];
    bool defaultValue = pref[1];
    bool value = prefs.getBool(key) ?? defaultValue;
    pref[1] = value;
  }
}

// <------------------ FIREBASE AUTH --------------------->
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void onPreferenceChanged(int index, bool newValue) {
    setState(() {
      String key = preferences[index][0];
      preferences[index][1] = newValue;
      savePreference(key, newValue);
    });
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Firebase Authorization
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _userUid() {
    return Text(user?.email ?? "User email");
  }

  Widget _signOutButton() {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            side: BorderSide(
                color: Colors.grey, width: 1), // Border color and width
            borderRadius: BorderRadius.circular(20), // Border radius
          ),
        ),
      ),
      onPressed: signOut,
      child: const Text(
        "Sign Out",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  String? errorMessage = "";
  bool isLogin = true;

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Widget _title() {
  //   return const Text("Firebase Auth");
  // }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == "" ? "" : "$errorMessage");
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? "Login" : "Register"),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? "Register Instead" : "Login Instead"),
    );
  }

// <---------------------------- Sign Up Dialog ------------------------------->
  void _showSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 300,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              // Will setup Signing in using Firebase Auth soon
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _entryField("Email", emailController),
                  _entryField("Password", passwordController),
                  _errorMessage(),
                  _submitButton(),
                  _loginOrRegisterButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// <------------------------- WIDGETS --------------------------->

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Center(
              child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.3,
            ),
          )),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  child: ListTile(
                    title: Text(
                      "Dark mode",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      value: Provider.of<ThemeProvider>(context, listen: false)
                          .isDarkMode,
                      onChanged: (value) => {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme()
                      },
                      activeTrackColor: Colors.black54,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [],
              ),
              ListTile(
                title: Center(
                  child: Text(
                    'PREFERENCES',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: preferences.length - 1,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade100.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                          child: ListTile(
                            title: Text(
                              preferences[index][0],
                              style: TextStyle(
                                color: preferences[index][1]
                                    ? Theme.of(context)
                                        .colorScheme
                                        .inversePrimary
                                    : Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                            trailing: CupertinoSwitch(
                              value: preferences[index][1],
                              onChanged: (value) {
                                setState(() {
                                  onPreferenceChanged(index, value);
                                });
                              },
                              activeTrackColor: Colors.indigo[400],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder(
                      stream: Auth().authStateChanges,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return _signOutButton();
                        } else {
                          return ElevatedButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.grey,
                                      width: 1), // Border color and width
                                  borderRadius: BorderRadius.circular(
                                      20), // Border radius
                                ),
                              ),
                            ),
                            onPressed: () {
                              _showSignUpDialog(context);
                            },
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
