import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async' show Future;

import 'package:imas_twitter_client/utils/twitter_api_cilent.dart';
import 'package:imas_twitter_client/ui/tweet_card.dart';

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
  String _json;
  TwitterApiClient _apiClient;

  List _tweets = [];

  Widget _buildTimeLine() {
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return new Divider();

        final index = i ~/ 2;

        return _tweets.length > i ? new TweetCard(_tweets[index]) : null;
      },
    );
  }

  @override
  void initState() {
    super.initState();

    Future<String> getTwitterKeys;
    if (_json == null) {
      getTwitterKeys = rootBundle.loadString('assets/twitter_keys.json')
        .then((json) {
          _json = json;

          return json;
        });
    } else {
      getTwitterKeys = new Future.value(_json);
    }

    getTwitterKeys.then((json) {
        if (_apiClient == null) {
          _apiClient = new TwitterApiClient(json);
        }

        _apiClient.getUserTimeLine(_screenName)
          .then((tweets) => setState(() { _tweets = tweets; }));
      });
  }

  @override
  Widget build(BuildContext context) {
    return _buildTimeLine();
  }
}
