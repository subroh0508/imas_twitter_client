import 'package:imas_twitter_client/model/twitter_account.dart';

class Tweet {
  Tweet(
    userName,
    userScreenName,
    iconUrl,
    this.entities,
    this.createdAt,
    this.retweetCount,
    this.favoriteCount,
  ) :
    account = new TwitterAccount(userName, userScreenName, iconUrl);

  final TwitterAccount account;
  final List<TweetEntity> entities;
  final DateTime createdAt;
  final int retweetCount;
  final int favoriteCount;
}

abstract class TweetEntity {
  TweetEntity(this.start, this.end);

  final int start;
  final int end;
}

class Media extends TweetEntity {
  Media(this.type, this.url, this.displayUrl, start, end) : super(start, end);

  final String type;
  final String url;
  final String displayUrl;
}

class HashTag extends TweetEntity {
  HashTag(this.text, start, end) : super(start, end);

  final String text;
}

class Url extends TweetEntity {
  Url(this.url, this.displayUrl, start, end) : super(start, end);

  final String url;
  final String displayUrl;
}

class PlainText extends TweetEntity {
  PlainText(this.text, start, end) : super(start, end);

  final String text;
}