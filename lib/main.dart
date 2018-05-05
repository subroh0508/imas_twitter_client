import 'package:flutter/material.dart';
import 'package:twitter/twitter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' show JsonDecoder;
import 'dart:async' show Future;

void main() => runApp(new MyApp());

const String CONSUMER_KEY = 'aHqDDLQUT7s8f3FZH96SI4M2k';
const String CONSUMER_SECRET = 'tRIKuccCQM16LtCz7PpbuivYIAZ4vhCGPYh8HGQiR5AvOuaKAY';
const String ACCESS_TOKEN = '298698577-8QLwaGykDiTz111D1iuabdOy6dv2qcfwyqDbW7Sx';
const String ACCESS_TOKEN_SECRET = 'k2F7u4Q5dlMJC3raanVdA5XQwbHQElIKA0LWdroSPgq2M';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
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
      home: new TimeLinePage(title: 'Twitter TimeLine'),
    );
  }
}

class TimeLinePage extends StatefulWidget {
  TimeLinePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _TimeLinePageState createState() => new _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List _tweets = [];
  DateFormat _stringToDateTime = new DateFormat('yyyy EEE MMM dd HH:mm:ss Z');
  DateFormat _dateTimeToString = new DateFormat('yyyy-MM-dd HH:mm:ss');
  JsonDecoder _decoder = new JsonDecoder();

  void _fetchTweets() async {
    var keys;
    try {
      keys = await rootBundle.loadString('assets/twitter_keys.json');
    } catch (e) {
      print(e);
    }

    var keysMap = _decoder.convert(keys);

    Map<String, String> oauth = {
      'consumerKey': keysMap['consumerKey'],
      'consumerSecret': keysMap['consumerSecret'],
      'accessToken': keysMap['accessToken'],
      'accessSecret': keysMap['accessSecret'],
    };

    Twitter twitter = new Twitter.fromMap(oauth);

    var response;
    try {
      response = await twitter.request('GET', 'statuses/user_timeline.json?screen_name=imassc_official&count=30');
    } catch (e) {
      print(e);
    }

    if (response != null) {
      var json = _decoder.convert(response.body);

      print('RESPONSE: ');
      print(json[0]);

      setState(() {
        _tweets = json.map((item) {
          List splits = item['created_at'].split(' ');
          String createdAt = ([splits[5]] + splits.sublist(0, 5)).join(' ');

          return Tweet(
            item['user']['name'],
            item['user']['screen_name'],
            item['text'],
            createdAt,
            item['retweet_count'],
            item['favorite_count'],
          );
        }).toList();
      });
    }
  }

  Widget _buildTimeLine() {
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return new Divider();

        final index = i ~/ 2;

        return _tweets.length > i ? _buildTweetItem(_tweets[index]) : null;
      },
    );
  }

  Widget _buildTweetItem(Tweet tweet) {
    String userName = tweet.userName + '@' + tweet.userScreenName;
    String rtCount = 'RT:' + tweet.retweetCount.toString();
    String fvCount = ' Fav:' + tweet.favoriteCount.toString();
    DateTime createdAt = _stringToDateTime.parse(tweet.createdAt);

    return new Center(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(userName),
          new Text(tweet.tweet, textScaleFactor: 1.2),
          new Text(rtCount + fvCount),
          new Text('Posted: ' + _dateTimeToString.format(createdAt)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: _buildTimeLine(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _fetchTweets,
        tooltip: 'Fetch Tweets',
        child: new Icon(Icons.update),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Tweet {
  Tweet(this.userName, this.userScreenName, this.tweet, this.createdAt, this.retweetCount, this.favoriteCount);

  final String userName;
  final String userScreenName;
  final String tweet;
  final String createdAt;
  final int retweetCount;
  final int favoriteCount;
}
