import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:esv_api/esv_api.dart';

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
  final verses = <MapEntry<String, String>>[];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _getVerse(String verse) {
    _fetchEsvAPI(verse)
        .then((x) => {_addVerse(MapEntry(verse, x))})
        .catchError((e) => 'welp ¯\_(ツ)_/¯ ');
  }

  Future<String> _fetchEsvAPI(String verse) async {
    var esv = ESVAPI('');

    var res = await esv.getPassageText(verse,
        include_short_copyright: false, include_copyright: false);
    return res.passages.first;
  }

  void _addVerse(MapEntry<String, String> verse) {
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Search a verse!'),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: 'John 3:16'),
                  onSubmitted: (val) {
                    _getVerse(val);
                    print(verses);
                  },
                ),
                RaisedButton(
                    child:
                        Text('Search', style: TextStyle(color: Colors.black)),
                    color: Colors.white,
                    onPressed: () {
                      _getVerse(controller.text);
                    }),
                _buildList(),
              ], // Children end
            ), // Column end
          ),
        ), // Center end
      ), // Padding end
    );
  } // end

  Widget _buildList() {
    return ListView.builder(
        itemCount: verses.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return ListTile(
              title: Text(verses[i].key),
              subtitle: Text(verses[i].value),
              trailing: Icon(
                Icons.copy,
              ),
              onTap: () {
                FlutterClipboard.copy(verses[i].value);
              });
        });
  }
}
