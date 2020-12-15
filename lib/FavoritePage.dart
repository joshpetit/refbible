import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'RefVerse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:async';

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
    favorites.addAll(List.generate(verses.length, (i) {
      return RefVerse(verses[i]['reference'], verses[i]['text'], true);
    }));
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * 0.70,
                    child: _buildFavorites()),
                Container(
                  height: MediaQuery.of(context).size.height * 0.10,
                  child: TextField(),
                ),
              ]),
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
                    _removeFavorite(favorites[i]);
                  }),
            ),
          );
        });
  }
}
