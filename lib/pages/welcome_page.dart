import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const WelcomePage());
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Start Ordering Button
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/Welcome_page.jpg"),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.multiply,
                  )),
            ),
          ),

          Column(
            children: [
              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(
                    left: 0), // Adjust the left indentation
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 250,
                  child: Text(
                    'Explore the \nCulinary Wonders \nWithin Your Campus!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 0), // Adjust the left indentation
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 100,
                  child: Text(
                    'Satisfy Your Hunger, \nOn Demand, On Campus!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18, // Adjust the font size
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0), // Add space above the button
              Padding(
                padding: EdgeInsets.all(
                    50), // Adjust the margin to move the button lower
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogInPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEBBE5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      'Start Ordering!!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
