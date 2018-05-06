import 'package:flutter/material.dart';
import 'package:twitter/twitter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' show JsonDecoder;
import 'dart:async' show Future;

class TimeLines extends StatefulWidget {
  TimeLines(this._title, this._screenNames) : super(key: new Key(_title.hashCode.toString()));

  final String _title;
  final List<String> _screenNames;

  @override
  _TimeLinesState createState() => new _TimeLinesState(_screenNames);
}

class TimeLinePage extends StatefulWidget {
  TimeLinePage(this._screenName);

  final String _screenName;

  @override
  _TimeLinePageState createState() => new _TimeLinePageState(_screenName);
}

class _TimeLinesState extends State<TimeLines> with SingleTickerProviderStateMixin {
  _TimeLinesState(this._screenNames);

  final List<String> _screenNames;
  TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: _screenNames.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new TabBar(
          labelColor: Colors.blue,
          controller: _tabController,
          isScrollable: true,
          tabs: _screenNames.map((name) => new Tab(text: '@' + name)).toList(),
        ),
        new Expanded(
          child: new TabBarView(
            controller: _tabController,
            children: _screenNames.map((name) => new TimeLinePage(name)).toList(),
          ),
        ),
      ],
    );
  }
}

class _TimeLinePageState extends State<TimeLinePage> {
  _TimeLinePageState(this._screenName);

  final String _screenName;
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
      response = await twitter.request('GET', 'statuses/user_timeline.json?screen_name=$_screenName&count=30');
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
  void initState() {
    super.initState();
    _fetchTweets();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTimeLine();
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