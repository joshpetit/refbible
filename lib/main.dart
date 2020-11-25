import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(RefBible());

class RefBible extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'welcome to Flutter',
      home: PassageInput(),
    );
  }
}

class PassageInput extends StatefulWidget {
  @override
  _PassageInputState createState() => _PassageInputState();
}

class _PassageInputState extends State<PassageInput> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Flutter!'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Text('Search a verse!'),
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: 'John 3:16'),
                onSubmitted: (val) {
                  print(val);
                },
              ),
              Text('Ya'),
            ],
          ),
        ),
      ),
    );
  }
}
