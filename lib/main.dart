import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:bible/bible.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Secrets.dart';
import 'RefVerse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

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
  final verses = <RefVerse>[];
  final favorites = <RefVerse>[];
  final favoriteRefs = <String>{};
  Future<Database> database;

  @override
  void initState() {
    super.initState();
    initDB();
  }

  Future<void> initDB() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'refbible.db'),
      onCreate: (db, version) {
        return db.execute(
            """CREATE TABLE IF NOT EXISTS favorite_verses(id INTEGER PRIMARY KEY AUTOINCREMENT,
            reference TEXT UNIQUE,
            text TEXT,
            favorited INTEGER)""");
      },
      version: 1,
    );
    final Database db = await database;
    final List<Map<String, dynamic>> verses = await db.query('favorite_verses');
    List<String> refs = [];
    favorites.addAll(List.generate(verses.length, (i) {
      refs.add(verses[i]['reference']);
      return RefVerse(verses[i]['reference'], verses[i]['text'], true);
    }));
    this.setState(() {
      favoriteRefs.addAll(refs);
    });
  }

  Future<void> insertFavorite(RefVerse verse) async {
    final Database db = await database;

    await db.insert(
      'favorite_verses',
      verse.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _getVerse(String verse) {
    _fetchEsvAPI(verse)
        .then((x) => {
              _addVerse(RefVerse(
                  x.reference, x.passage, favoriteRefs.contains(x.reference)))
            })
        .catchError((e) => 'welp ¯\_(ツ)_/¯ ');
  }

  Future<dynamic> _fetchEsvAPI(String verse) async {
    Bible.addKeys({"esvapi": Secrets.ESV});
    var res = await Bible.queryPassage(verse);
    return res;
  }

  void _addVerse(RefVerse verse) {
    setState(() {
      verses.insert(0, verse);
    });
    FlutterClipboard.copy(" ${verse.reference}\n${verse.text}");
    Fluttertoast.showToast(msg: 'Copied to Clipboard');
  }

  void _addToFavorites(RefVerse verse) {
    setState(() {
      favorites.insert(0, verse);
    });
    insertFavorite(verse);
    verse.favorited = true;
    this.setState(() {
      favoriteRefs.add(verse.reference);
    });
  }

  void copyVerse(RefVerse v) {
    FlutterClipboard.copy("${v.reference}\n${v.text}");
    Fluttertoast.showToast(msg: 'Copied to Clipboard');
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
                  title: Text(verses[i].text),
                  subtitle: Text(verses[i].reference),
                  trailing: Column(
                    children: [
                      IconButton(
                          icon: Icon(verses[i].favorited
                              ? Icons.favorite
                              : Icons.favorite_border),
                          onPressed: () {
                            if (!verses[i].favorited) {
                              _addToFavorites(verses[i]);
                            }
                          }),
                    ],
                  ),
                  onTap: () {
                    copyVerse(verses[i]);
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
            width: 200,
            child: ListTile(
                title: Text(favorites[i].reference),
                subtitle: Text(favorites[i].text.truncateTo(23), maxLines: 1),
                onTap: () {
                  copyVerse(favorites[i]);
                }),
          );
        });
  }
}
