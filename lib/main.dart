import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:bible/bible.dart';
import 'package:menu/menu.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Secrets.dart';
import 'RefVerse.dart';
import 'package:path/path.dart';
import 'package:reference_parser/identification.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:async';
import 'FavoritePage.dart';

void main() => runApp(
      RefBible(),
    );

class RefBible extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'welcome to Flutter',
      home: MainSection(),
      darkTheme: ThemeData.dark(),
    );
  }
}

class MainSection extends StatefulWidget {
  @override
  _MainSectionState createState() => _MainSectionState();
}

class _MainSectionState extends State<MainSection> {
  final controller = TextEditingController();
  ScrollController _scrollController = new ScrollController();
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
    if (verses.length == 0 || verses[0].reference != verse.reference) {
      setState(() {
        verses.insert(0, verse);
      });
    }
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

  Future<void> insertFavorite(RefVerse verse) async {
    final Database db = await database;

    await db.insert(
      'favorite_verses',
      verse.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void _removeFavorite(RefVerse verse) {
    verse.favorited = false;
    this.setState(() {
      favorites.removeWhere((ref) => ref.reference == verse.reference);
      favoriteRefs.remove(verse.reference);
    });
    removeFavorite(verse);
  }

  Future<void> removeFavorite(RefVerse verse) async {
    final Database db = await database;
    await db.delete(
      'favorite_verses',
      where: "reference = '${verse.reference}'",
    );
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
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFavorites(),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FavoritesSection()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.59,
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
                          controller.clear();
                        }),
                    TypeAheadField(
                        direction: AxisDirection.up,
                        textFieldConfiguration: TextFieldConfiguration(
                            controller: controller,
                            onSubmitted: (val) {
                              _getVerse(val);
                              controller.clear();
                            }),
                        suggestionsCallback: (pattern) async {
                          if (pattern.length > 2) {
                            return await identifyReference(pattern);
                          }
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            subtitle: Text(suggestion.reference.reference),
                            title: Text(suggestion.preview),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          _getVerse(suggestion.reference.reference);
                          controller.clear();
                        },
                        animationDuration: Duration(seconds: 0),
                        noItemsFoundBuilder: (context) {
                          return Text('Searching...');
                        }),
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
                              _scrollController.animateTo(
                                0.0,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                            } else {
                              _removeFavorite(verses[i]);
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
        controller: _scrollController,
        itemCount: favorites.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          return SizedBox(
            width: 200,
            child: Menu(
              child: ListTile(
                  title: Text(favorites[i].reference),
                  subtitle: Text(favorites[i].text.truncateTo(23), maxLines: 1),
                  onTap: () {
                    copyVerse(favorites[i]);
                    _addVerse(favorites[i]);
                  }),
              items: [
                MenuItem("Remove", () {
                  _removeFavorite(favorites[i]);
                }),
              ],
            ),
          );
        });
  }
}
