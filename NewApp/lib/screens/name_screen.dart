import 'package:best_todo_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameCaptureScreen extends StatefulWidget {
  const NameCaptureScreen({Key? key}) : super(key: key);

  @override
  _NameCaptureScreenState createState() => _NameCaptureScreenState();
}

class _NameCaptureScreenState extends State<NameCaptureScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              'assets/purple background.jpg',
              fit: BoxFit.fill,
            )),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      String userName = _nameController.text.trim();

                      if (userName.isNotEmpty) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('userName', userName);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      } else {
                        print('Enter your name');
                      }
                    },
                    child: const Text('Save'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
