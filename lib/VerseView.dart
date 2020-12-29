import 'package:flutter/material.dart';
import 'RefVerse.dart';

class VerseView extends StatefulWidget {
  final List<RefVerse> verses;
  final Function(RefVerse) copyVerse;
  final Function(RefVerse) addFavorite;
  final Function(RefVerse) removeFavorite;

  VerseView(this.verses, this.copyVerse, this.addFavorite, this.removeFavorite);

  @override
  _VerseViewState createState() => _VerseViewState();
}

class _VerseViewState extends State<VerseView> {
  VerseView get widget => super.widget;

  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.verses.length,
        reverse: true,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          return GestureDetector(
              child: ListTile(
                  title: Text(widget.verses[i].text),
                  subtitle: Text(
                      "${widget.verses[i].reference} (${widget.verses[i].version.toUpperCase()})"),
                  trailing: Column(
                    children: [
                      IconButton(
                          icon: Icon(widget.verses[i].favorited
                              ? Icons.favorite
                              : Icons.favorite_border),
                          onPressed: () {
                            if (!widget.verses[i].favorited) {
                              widget.addFavorite(widget.verses[i]);
                            } else {
                              widget.removeFavorite(widget.verses[i]);
                              setState(() {});
                            }
                          }),
                    ],
                  ),
                  onTap: () {
                    widget.copyVerse(widget.verses[i]);
                  }));
        });
  }
}
