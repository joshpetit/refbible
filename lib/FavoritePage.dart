import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'RefVerse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'VerseView.dart';

extension StringExtension on String {
  String truncateTo(int maxLenght) =>
      (this.length <= maxLenght) ? this : '${this.substring(0, maxLenght)}...';
}

class FavoritesSection extends StatefulWidget {
  final List<RefVerse> verses;
  final Function(RefVerse) copyVerse;
  final Function(RefVerse) addFavorite;
  final Function(RefVerse) removeFavorite;

  FavoritesSection(
      this.verses, this.copyVerse, this.addFavorite, this.removeFavorite);

  @override
  _FavoritesSectionState createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {
  final controller = TextEditingController();
  var favorites = <RefVerse>[];
  Future<Database> database;

  FavoritesSection get widget => super.widget;

  @override
  void initState() {
    super.initState();
    favorites = widget.verses;
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
                    child: VerseView(favorites, widget.copyVerse,
                        widget.addFavorite, widget.removeFavorite),
                  ),
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
                              .widget
                              .verses
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
                          widget.copyVerse(suggestion);
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
}
