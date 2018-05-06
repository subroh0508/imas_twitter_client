import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:imas_twitter_client/model/tweet.dart';
import 'package:imas_twitter_client/model/twitter_account.dart';

final DateFormat _dateTimeToString = new DateFormat('yyyy-MM-dd HH:mm:ss');

class TweetCard extends StatelessWidget {
  TweetCard(this._tweet);

  final Tweet _tweet;

  SizedBox _fetchAccountIcon(String iconUrl) {
    return new SizedBox(
      height: 30.0,
      width: 30.0,
      child: new CachedNetworkImage(
        imageUrl: iconUrl,
        placeholder: new CircularProgressIndicator(),
        errorWidget: new Icon(Icons.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TwitterAccount account = _tweet.account;
    String userName = account.name + '@' + account.screenName;
    String rtCount = 'RT:' + _tweet.retweetCount.toString();
    String fvCount = ' Fav:' + _tweet.favoriteCount.toString();

    return new Center(
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _fetchAccountIcon(account.iconUrl),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new Text(userName),
                new Text(_tweet.tweet, textScaleFactor: 1.2),
                new Text(rtCount + fvCount),
                new Text('Posted: ' + _dateTimeToString.format(_tweet.createdAt)),
              ],
            ),
          ),
        ],
      )
    );
  }
}