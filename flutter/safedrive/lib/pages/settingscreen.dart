import 'package:flutter/material.dart';
import 'package:safedrive/main.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';

// User preferences -- might add more later
final List<String> preferences = [
  'Show speed',
  'Show sharp turns',
  'Show heavy inclination',
];

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  // Sign Up Dialog
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
              height: 370,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              // Will setup Signing in using Firebase Auth soon
              child: Column(
                children: [
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      label: Text("Email"),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      label: Text("Username"),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      label: Text("Password"),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await createUserWithEmailAndPassword();
                      Navigator.of(context).pop();
                    },
                    child: Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print(userCredential);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: darkBlue,
        appBar: AppBar(
          title: Center(
              child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
            ),
          )),
          backgroundColor: darkBlue,
          foregroundColor: lightGray,
        ),
        body: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Border color (grey)
                      width: 3.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 64,
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(
                        () {
                          _showSignUpDialog(context); // Toggle visibility
                        },
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text('Preferences',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.arrow_drop_down_outlined),
              title: Text('Show speed'),
              trailing: ToggleSwitch(
                customWidths: [50.0, 50.0],
                cornerRadius: 10.0,
                activeBgColors: [
                  [Colors.green.shade300],
                  [Colors.redAccent]
                ],
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                labels: ['', ''],
                icons: [Icons.check, Icons.close],
                onToggle: (index) {
                  // print('switched to: $index');
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.arrow_drop_down_outlined),
              title: Text('Show sharp turns'),
              trailing: ToggleSwitch(
                customWidths: [50.0, 50.0],
                cornerRadius: 10.0,
                activeBgColors: [
                  [Colors.green.shade300],
                  [Colors.redAccent]
                ],
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                // labels: ['', ''],
                icons: [Icons.check, Icons.close],
                onToggle: (index) {
                  // print('switched to: $index');
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.arrow_drop_down_outlined),
              title: Text('Show heavy inclinations'),
              trailing: ToggleSwitch(
                customWidths: [50.0, 50.0],
                cornerRadius: 10.0,
                activeBgColors: [
                  [Colors.green.shade300],
                  [Colors.redAccent]
                ],
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                labels: ['', ''],
                icons: [Icons.check, Icons.close],
                onToggle: (index) {
                  // print('switched to: $index');
                },
              ),
            )
          ],
        ));
  }
}





// class SettingScreen extends StatelessWidget {
//   const SettingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // backgroundColor: darkBlue,
//         appBar: AppBar(
//           title: Center(
//               child: Text(
//             'Settings',
//             style: TextStyle(
//               fontSize: 20,
//             ),
//           )),
//           backgroundColor: darkBlue,
//           foregroundColor: lightGray,
//         ),
//         body: ListView(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(10),
//                   margin: EdgeInsets.all(20.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.black, // Border color (grey)
//                       width: 3.0, // Border width
//                     ),
//                     borderRadius: BorderRadius.circular(100.0),
//                   ),
//                   child: Icon(
//                     Icons.person,
//                     size: 64,
//                   ),
//                 ),
//                 Center(
//                   child: ElevatedButton(
//                     // style: ,
//                     onPressed: () {},
//                     child: Container(
//                       // padding: EdgeInsets.only(
//                       //     left: 30, right: 30, top: 10, bottom: 10),
//                       margin: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         // color: Colors.blue[100],
//                       ),
                      
//                       child: Text('Sign Up'),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             ListTile(
//               title: Text('Preferences',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             ListTile(
//               leading: Icon(Icons.arrow_drop_down_outlined),
//               title: Text('Show speed'),
//               trailing: ToggleSwitch(
//                 customWidths: [90.0, 50.0],
//                 cornerRadius: 20.0,
//                 activeBgColors: [
//                   [Colors.green.shade300],
//                   [Colors.redAccent]
//                 ],
//                 activeFgColor: Colors.white,
//                 inactiveBgColor: Colors.grey,
//                 inactiveFgColor: Colors.white,
//                 totalSwitches: 2,
//                 labels: ['', ''],
//                 icons: [Icons.check, Icons.close],
//                 onToggle: (index) {
//                   // print('switched to: $index');
//                 },
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.arrow_drop_down_outlined),
//               title: Text('Show sharp turns'),
//               trailing: ToggleSwitch(
//                 customWidths: [90.0, 50.0],
//                 cornerRadius: 20.0,
//                 activeBgColors: [
//                   [Colors.green.shade300],
//                   [Colors.redAccent]
//                 ],
//                 activeFgColor: Colors.white,
//                 inactiveBgColor: Colors.grey,
//                 inactiveFgColor: Colors.white,
//                 totalSwitches: 2,
//                 labels: ['', ''],
//                 icons: [Icons.check, Icons.close],
//                 onToggle: (index) {
//                   // print('switched to: $index');
//                 },
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.arrow_drop_down_outlined),
//               title: Text('Show heavy inclinations'),
//               trailing: ToggleSwitch(
//                 customWidths: [90.0, 50.0],
//                 cornerRadius: 20.0,
//                 activeBgColors: [
//                   [Colors.green.shade300],
//                   [Colors.redAccent]
//                 ],
//                 activeFgColor: Colors.white,
//                 inactiveBgColor: Colors.grey,
//                 inactiveFgColor: Colors.white,
//                 totalSwitches: 2,
//                 labels: ['', ''],
//                 icons: [Icons.check, Icons.close],
//                 onToggle: (index) {
//                   // print('switched to: $index');
//                 },
//               ),
//             )
//           ],
//         ));
//   }
// }
