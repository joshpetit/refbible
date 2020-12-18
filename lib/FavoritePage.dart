import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'RefVerse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

extension StringExtension on String {
  String truncateTo(int maxLenght) =>
      (this.length <= maxLenght) ? this : '${this.substring(0, maxLenght)}...';
}

class FavoritesSection extends StatefulWidget {
  @override
  _FavoritesSectionState createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {
  final controller = TextEditingController();
  final favorites = <RefVerse>[];
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
    this.setState(() {
      favorites.addAll(List.generate(verses.length, (i) {
        return RefVerse(verses[i]['reference'], verses[i]['text'], true);
      }));
    });
  }

  void _removeFavorite(RefVerse verse) {
    verse.favorited = false;
    this.setState(() {});
    removeFavorite(verse);
  }

  Future<void> removeFavorite(RefVerse verse) async {
    final Database db = await database;
    await db.delete(
      'favorite_verses',
      where: "reference = '${verse.reference}'",
    );
  }

  void _addToFavorites(RefVerse verse) {
    verse.favorited = true;
    setState(() {});
    insertFavorite(verse);
  }

  Future<void> insertFavorite(RefVerse verse) async {
    final Database db = await database;

    await db.insert(
      'favorite_verses',
      verse.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height * 0.73,
                      child: _buildFavorites()),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: TypeAheadField(
                        direction: AxisDirection.up,
                        textFieldConfiguration: TextFieldConfiguration(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: "Filter Favorites",
                            ),
                            onSubmitted: (val) {
                              controller.clear();
                            }),
                        suggestionsCallback: (pattern) {
                          return this
                              .favorites
                              .where((x) => x
                                  .toString()
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            subtitle: Text(suggestion.reference),
                            title: Text(suggestion.text),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          controller.clear();
                        },
                        animationDuration: Duration(seconds: 0),
                        noItemsFoundBuilder: (context) {
                          return Text('Searching...');
                        }),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildFavorites() {
    return ListView.builder(
        itemCount: favorites.length,
        reverse: true,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          return GestureDetector(
            child: ListTile(
              title: Text(favorites[i].text),
              subtitle: Text(favorites[i].reference),
              trailing: IconButton(
                  icon: Icon(favorites[i].favorited
                      ? Icons.favorite
                      : Icons.favorite_border),
                  onPressed: () {
                    if (favorites[i].favorited) {
                      _removeFavorite(favorites[i]);
                    } else {
                      _addToFavorites(favorites[i]);
                    }
                  }),
            ),
          );
        });
  }
}
