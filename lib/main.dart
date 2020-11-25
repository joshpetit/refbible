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
  final verses = <String>[];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void addVerse(String verse) {
    setState(() {
      verses.insert(0, verse);
    });
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
                  addVerse(val);
                  print(verses);
                },
              ),
              RaisedButton(
                  child: Text('Search', style: TextStyle(color: Colors.black)),
                  color: Colors.white,
                  onPressed: () {
                    addVerse(controller.text);
                  }),
              _buildList(),
            ], // Children end
          ), // Column end
        ), // Center end
      ), // Padding end
    );
  } // end

  Widget _buildList() {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: verses.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return ListTile(
            title: Text(verses[i]),
            subtitle: Text('Verse Text'),
          );
        });
  }
}
