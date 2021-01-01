import 'package:flutter/material.dart';
import 'package:menu/menu.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'Settings.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatefulWidget {
  final Function(String, dynamic) setSetting;
  Map<String, dynamic> settings;
  Settings(this.setSetting, this.settings);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final availableVersions = ['ASV', 'AKJV', 'NET', 'WEB'];

  Settings get widget => super.widget;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SettingsList(sections: [
        SettingsSection(
          title: 'Section',
          tiles: [
            SettingsTile(
              title: 'Bible Version',
              subtitle: widget.settings['version'].toUpperCase(),
              leading: Icon(Icons.article_sharp),
              onPressed: (BuildContext context) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                          title: Text("Versions"),
                          children: availableVersions
                              .map((x) => SimpleDialogOption(
                                  child: Text(x),
                                  onPressed: () {
                                    widget.settings['version'] = x;
                                    setState(() {});
                                    widget.setSetting('version', x);
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg:
                                            'Version Changed to ${x.toUpperCase()}');
                                  }))
                              .toList());
                    });
              },
            ),
          ],
        ),
      ]),
    );
  }
}
