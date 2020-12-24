class RefVerse {
  String reference;
  String text;
  String version;
  bool favorited;

  RefVerse(this.reference, this.text, this.version, this.favorited);

  Map<String, dynamic> toMap() => {
        'reference': reference,
        'text': text,
        'favorited': favorited ? 1 : 0,
        'version': version
      };
  @override
  String toString() {
    return "${reference} (${version})\n${text}";
  }
}
