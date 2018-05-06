import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:imas_twitter_client/model/tweet.dart';
import 'package:imas_twitter_client/model/twitter_account.dart';

final DateFormat _dateTimeToString = new DateFormat('yyyy-MM-dd HH:mm:ss');

class TweetCard extends StatelessWidget {
  TweetCard(this._tweet);

  final Tweet _tweet;

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new _AccountInfo(_tweet.account),
          new _TweetSummary(_tweet),
        ],
      )
    );
  }
}

class _AccountInfo extends StatelessWidget {
  _AccountInfo(this._account);

  final TwitterAccount _account;

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.only(right: 12.0),
            child: new SizedBox(
              height: 40.0,
              width: 40.0,
              child: new CachedNetworkImage(
                imageUrl: _account.iconUrl,
                placeholder: new CircularProgressIndicator(),
                errorWidget: new Icon(Icons.error),
              ),
            ),
          ),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  _account.name,
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                new Text(
                    '@' + _account.screenName
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TweetSummary extends StatelessWidget {
  _TweetSummary(this._tweet);

  final Tweet _tweet;

  @override
  Widget build(BuildContext context) {
    String rtCount = 'RT:' + _tweet.retweetCount.toString();
    String fvCount = ' Fav:' + _tweet.favoriteCount.toString();

    return new Padding(
      padding: new EdgeInsets.only(left: 52.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new _TweetContent(_tweet.entities),
          new Text(rtCount + fvCount),
          new Text('Posted: ' + _dateTimeToString.format(_tweet.createdAt)),
        ],
      ),
    );
  }
}

class _TweetContent extends StatelessWidget {
  _TweetContent(this._entities);

  final List<TweetEntity> _entities;

  List<Widget> _entityWidgets(context) {
    List<Media> media = [];
    _entities.where((entity) => entity is Media)
      .forEach((entity) => media.add(entity as Media));

    List<TextSpan> spans = [];
    List<Widget> widgets = [];

    _entities.forEach((entity) {
      switch (entity.runtimeType) {
        case PlainText:
          spans.add(
            new TextSpan(
              text: (entity as PlainText).text,
              style: DefaultTextStyle.of(context).style.apply(
                fontSizeFactor: 1.2,
              ),
            )
          );
          break;
        case HashTag:
          spans.add(
            new TextSpan(
              text: '#' + (entity as HashTag).text + ' ',
              style: DefaultTextStyle.of(context).style.apply(
                color: Colors.cyan,
                fontSizeFactor: 1.2,
              ),
            )
          );
          break;
        case Url:
          Url url = entity as Url;
          TapGestureRecognizer recognizer = new TapGestureRecognizer()
            ..onTap = (() {
              canLaunch(url.url)
                .then((ok) {
                  if (!ok) {
                    throw 'Could not launch ${url.url}';
                  }
                })
                .then((_) => launch(url.url));
            });

          spans.add(
            new TextSpan(
              text: (entity as Url).displayUrl,
              style: new TextStyle(
                color: Colors.cyan,
                decoration: TextDecoration.underline,
                decorationColor: Colors.cyan,
                decorationStyle: TextDecorationStyle.solid,
              ),
              recognizer: recognizer,
            )
          );
          break;
      }
    });

    widgets.add(
        new RichText(
          text: new TextSpan(
            text: '',
            style: DefaultTextStyle.of(context).style,
            children: spans,
          ),
        )
    );

    media.forEach((medium) {
      switch (medium.type) {
        case 'photo':
          widgets.add(
              new CachedNetworkImage(
                imageUrl: medium.url,
                placeholder: new CircularProgressIndicator(),
                errorWidget: new Icon(Icons.error),
              )
          );
          break;
      }
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _entityWidgets(context),
    );
  }
}