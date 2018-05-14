import 'package:flutter/material.dart';

import 'package:imas_twitter_client/utils/config_loader.dart';
import 'package:imas_twitter_client/ui/timelines.dart';

class Home extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'IM@S Twitter Client',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _contents = [];
  List<TimeLines> _timeLines = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    new ConfigLoader().load('contents')
      .then((contents) {
        _contents = contents;
        _timeLines = _createTimeLineContainers();

        setState(() {
          _currentIndex = 0;
        });
      });
  }

  List<TimeLines> _createTimeLineContainers() {
    return _contents.map((content) {
      List<String> screenNames = [];
      content['twitter_accounts'].forEach((account) {
        screenNames.add(account.toString());
      });

      return new TimeLines(content['title'], screenNames);
    }).toList();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ListTile> _titleList = [];

    for (int i = 0; i < _contents.length; i++) {
      var content = _contents[i];

      _titleList.add(
        new ListTile(
          leading: new Image.asset('images/${content['icon']}'),
          title: new Text(
            content['title'],
            style: new TextStyle(
              fontSize: 16.0,
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _onTap(i);
          },
        )
      );
    }

    TimeLines _currentTimeLines
      = _timeLines.length > _currentIndex
        ? _timeLines[_currentIndex] : null;
    String _title
      = _timeLines.length > _currentIndex
        ? _contents[_currentIndex]['title'] : 'Project IM@S';

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_title),
      ),
      drawer: new Drawer(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            new ListTile(
              title: new Text(
                'コンテンツ一覧',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            new Divider(),
          ] + _titleList,
        ),
      ),
      body: new Center(
        child: _currentTimeLines,
      ),
    );
  }
}