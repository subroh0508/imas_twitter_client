import 'package:intl/intl.dart';
import 'package:twitter/twitter.dart';
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

        List<TweetEntity> entities = _extractEntities(item['full_text'], item['entities']);

        tweets.add(
          new Tweet(
            item['user']['name'],
            item['user']['screen_name'],
            item['user']['profile_image_url_https'],
            entities,
            createdAt,
            item['retweet_count'],
            item['favorite_count'],
          )
        );
      });
    }

    return tweets;
  }

  List<TweetEntity> _extractEntities(String fullText, var entities) {
    List hashTags = entities['hashtags'];
    List urls = entities['urls'];
    List media = entities['media'];

    List<TweetEntity> entityList = [];

    if (hashTags != null) {
      hashTags.forEach((hashTag) {
        entityList.add(
            new HashTag(
              hashTag['text'],
              hashTag['indices'][0],
              hashTag['indices'][1],
            )
        );
      });
    }

    if (urls != null) {
      urls.forEach((url) {
        entityList.add(
            new Url(
              url['expanded_url'],
              url['display_url'],
              url['indices'][0],
              url['indices'][1],
            )
        );
      });
    }

    if (media != null) {
      media.forEach((medium) {
        entityList.add(
            new Media(
              medium['type'],
              medium['media_url_https'],
              medium['display_url'],
              medium['indices'][0],
              medium['indices'][1],
            )
        );
      });
    }

    if (entityList.isEmpty) {
      return [new PlainText(fullText, 0, fullText.length - 1)];
    }

    entityList.sort((a, b) => a.start.compareTo(b.start));

    List<PlainText> plains = [];
    Runes runes = fullText.runes;
    int offset = entityList.first.start == 0 ? 1 : 0;
    int loopCount = entityList.last.end == runes.length - 1 ? entityList.length : entityList.length + 1;

    for (int i = offset; i < loopCount; i++) {
      int start = i - 1 < 0 ? 0 : entityList[i - 1].end + 1;
      int end = i >= entityList.length ? runes.length - 1 : entityList[i].start;

      if (start < end) {
        String text = String.fromCharCodes(runes.toList().getRange(start, end));
        
        plains.add(new PlainText(text, start, end));
      }
    }

    entityList.addAll(plains);

    entityList.sort((a, b) => a.start.compareTo(b.start));

    return entityList;
  }
}