import 'package:intl/intl.dart';
import 'package:twitter/twitter.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'dart:convert' show JsonDecoder;
import 'dart:async' show Future;

import 'package:imas_twitter_client/model/tweet.dart';

class TwitterApiClient {
  final JsonDecoder _decoder = JsonDecoder();
  final DateFormat _stringToDateTime = new DateFormat('yyyy EEE MMM dd HH:mm:ss Z');

  Twitter _twitter;

  TwitterApiClient(String json) {
    _init(json);
  }

  void _init(String json) {
    var keysMap = _decoder.convert(json);

    Map<String, String> oauth = {
      'consumerKey': keysMap['consumerKey'],
      'consumerSecret': keysMap['consumerSecret'],
      'accessToken': keysMap['accessToken'],
      'accessSecret': keysMap['accessSecret'],
    };

    _twitter = new Twitter.fromMap(oauth);
  }

  Future<List<Tweet>> getUserTimeLine(String screenName, { int count = 30 }) async {
    var response;
    try {
      response = await _twitter.request('GET', 'statuses/user_timeline.json?screen_name=$screenName&count=30&tweet_mode=extended');
    } catch (e) {
      print(e);
    }

    List<Tweet> tweets = [];

    if (response != null) {
      var json = _decoder.convert(response.body);

      print('RESPONSE: ');
      print(json[0]);
      json.forEach((item) {
        List splits = item['created_at'].split(' ');
        DateTime createdAt = _stringToDateTime.parse(([splits[5]] + splits.sublist(0, 5)).join(' '));

        tweets.add(
          new Tweet(
            item['user']['name'],
            item['user']['screen_name'],
            item['user']['profile_image_url_https'],
            item['full_text'],
            createdAt,
            item['retweet_count'],
            item['favorite_count'],
          )
        );
      });
    }

    return tweets;
  }
}