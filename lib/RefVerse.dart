class RefVerse {
  String reference;
  String text;
  bool favorited;

  RefVerse(this.reference, this.text, this.favorited);

  Map<String, dynamic> toMap() =>
      {'reference': reference, 'text': text, 'favorited': favorited ? 1 : 0};
  @override
  String toString() {
    return "${reference}\n${text}";
  }
}
