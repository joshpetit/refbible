import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:bible/bible.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Secrets.dart';
import 'package:sqflite/sqflite.dart';

extension StringExtension on String {
  String truncateTo(int maxLenght) =>
      (this.length <= maxLenght) ? this : '${this.substring(0, maxLenght)}...';
}

void main() => runApp(
      RefBible(),
    );

class RefBible extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'welcome to Flutter',
      home: PassageInput(),
      darkTheme: ThemeData.dark(),
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
  final favorites = <MapEntry<String, String>>[
    MapEntry("Favorite", "Text Stuff Longer longer Longer"),
    MapEntry("Favorite", "Text Stuff Longer Longer Longer"),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _getVerse(String verse) {
    _fetchEsvAPI(verse)
        .then((x) => {_addVerse(MapEntry(x.reference, x.passage))})
        .catchError((e) => 'welp ¯\_(ツ)_/¯ ');
  }

  Future<dynamic> _fetchEsvAPI(String verse) async {
    Bible.addKeys({"esvapi": Secrets.ESV});
    var res = await Bible.queryPassage(verse);
    return res;
  }

  void _addVerse(MapEntry<String, String> verse) {
    setState(() {
      verses.insert(0, verse);
    });
    FlutterClipboard.copy(verse.value);
    Fluttertoast.showToast(msg: 'Copied to Clipboard');
  }

  void _addToFavorites(String ref, String text) {
    setState(() {
      favorites.insert(0, MapEntry(ref, text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RefBible'),
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: _buildFavorites(),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.60,
                  child: _buildList(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RaisedButton(
                        child: Text('Search',
                            style: TextStyle(color: Colors.black)),
                        color: Colors.grey,
                        onPressed: () {
                          _getVerse(controller.text);
                        }),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'John 3:16',
                      ),
                      onSubmitted: (val) {
                        _getVerse(val);
                      },
                    ),
                  ],
                ),
              ], // Children end
            ), // Column end
          ),
        ), // Padding end
      ),
    );
  } // end

  Widget _buildList() {
    return ListView.builder(
        itemCount: verses.length,
        reverse: true,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          return GestureDetector(
              child: ListTile(
                  title: Text(verses[i].key),
                  subtitle: Text(verses[i].value),
                  trailing: Column(
                    children: [
                      IconButton(
                          icon: Icon(Icons.favorite),
                          onPressed: () {
                            _addToFavorites(verses[i].key, verses[i].value);
                          }),
                    ],
                  ),
                  onTap: () {
                    FlutterClipboard.copy(verses[i].value);
                    Fluttertoast.showToast(msg: 'Copied to Clipboard');
                  }));
        });
  }

  Widget _buildFavorites() {
    return ListView.builder(
        itemCount: favorites.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          return SizedBox(
            width: 150,
            child: ListTile(
                title: Text(favorites[i].key),
                subtitle: Text(favorites[i].value.truncateTo(15), maxLines: 1),
                onTap: () {
                  FlutterClipboard.copy(favorites[i].value);
                  Fluttertoast.showToast(msg: 'Copied to Clipboard');
                }),
          );
        });
  }
}
