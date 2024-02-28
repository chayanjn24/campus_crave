import 'package:flutter/material.dart';
// import 'package:campus_crave/pages/home_page.dart';
import 'signup_page.dart';

void main() {
  runApp(const LogInPage());
}

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  var isHide = true;
  bool isStrongPassword = true;
  TextEditingController passwordController = TextEditingController();

  bool checkStrongPassword(String password) {
    // Define patterns for each requirement
    RegExp capitalLetterRegex = RegExp(r'[A-Z]');
    RegExp smallLetterRegex = RegExp(r'[a-z]');
    RegExp numberRegex = RegExp(r'[0-9]');
    RegExp specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    // Check if the password meets all requirements
    bool hasCapitalLetter = capitalLetterRegex.hasMatch(password);
    bool hasSmallLetter = smallLetterRegex.hasMatch(password);
    bool hasNumber = numberRegex.hasMatch(password);
    bool hasSpecialChar = specialCharRegex.hasMatch(password);

    return isStrongPassword = password.length >= 8 &&
        hasCapitalLetter &&
        hasSmallLetter &&
        hasNumber &&
        hasSpecialChar;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: screenHeight / 20,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter your institute email id",
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.greenAccent,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: isHide,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    errorText: !isStrongPassword ? "Password is weak" : null,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,
                        color: Color(0xFFEBBE5A),
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isHide ? Icons.visibility_sharp : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () {
                            isHide = !isHide;
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (isStrongPassword) {
                      Navigator(
                        // context,
                        // MaterialPageRoute(
                          // builder: (context) => HomeScreen(),
                        // ),
                      );
                    } else {
                      // Handle the case when the password is not strong
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text("Please make sure your password meets the requirements."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEBBE5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Divider(
                  color: Colors.black,
                  thickness: 0.7,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEBBE5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7F6F4),
    );
  }
}
