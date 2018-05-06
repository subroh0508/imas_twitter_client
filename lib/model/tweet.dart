import 'package:imas_twitter_client/model/twitter_account.dart';

class Tweet {
  Tweet(userName, userScreenName, iconUrl, this.tweet, this.createdAt, this.retweetCount, this.favoriteCount)
    : account = new TwitterAccount(userName, userScreenName, iconUrl);

  final TwitterAccount account;
  final String tweet;
  final DateTime createdAt;
  final int retweetCount;
  final int favoriteCount;
}