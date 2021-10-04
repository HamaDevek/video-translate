import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:video/caption_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(),
  );
  runApp(YoutubePlayerDemoApp());
}

class YoutubePlayerDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:  'Subyt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.blueAccent,
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 20.0,
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.blueAccent,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

/// Homepage
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late YoutubePlayerController _controller;
  late TextEditingController _seekToController;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  Duration currentDuration = Duration(seconds: 0);
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  String temp_raw = '';
  String kurdish = '';
  TextEditingController urlController = TextEditingController(
      text: "https://www.youtube.com/watch?v=RZ3RljSz95o");
  List<CaptionModel> _listMetaCaption = [];
  List<String> _listText = [];
  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId("${urlController.value.text}")
              .toString(),
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
        captionLanguage: 'en',
      ),
    )..addListener(listener);
    getCaption();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
        currentDuration = _controller.value.position;
        if (temp_raw !=
            _listMetaCaption
                .lastWhere(
                    (element) =>
                        Duration(
                                microseconds: (element.start * 1000000).toInt())
                            .inMicroseconds <=
                        currentDuration.inMicroseconds,
                    orElse: () =>
                        CaptionModel(text: '', start: 0.0, duration: 0.0))
                .text) {
          temp_raw = _listMetaCaption
              .lastWhere(
                  (element) =>
                      Duration(microseconds: (element.start * 1000000).toInt())
                          .inMicroseconds <=
                      currentDuration.inMicroseconds,
                  orElse: () =>
                      CaptionModel(text: '', start: 0.0, duration: 0.0))
              .text;
          getTransalte(temp_raw);
        }
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              log('Settings Tapped!');
            },
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _showSnackBar('Next Video Started!');
        },
      ),
      builder: (context, player) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.all(20),
                    child: TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'URL',
                      ),
                      onSubmitted: (text) {
                        _controller.load(
                            YoutubePlayer.convertUrlToId("$text").toString());
                        getCaption();
                      },
                    )),
                Stack(
                  children: [
                    player,
                    _listMetaCaption.isEmpty
                        ? Container()
                        : Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${_listMetaCaption.lastWhere((element) => Duration(microseconds: (element.start * 1000000).toInt()).inMicroseconds <= currentDuration.inMicroseconds, orElse: () => CaptionModel(text: '', start: 0.0, duration: 0.0)).text}',
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      background: Paint()
                                        ..color = Colors.black.withOpacity(.6)),
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '$kurdish',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // _listMetaCaption.isEmpty
                //     ? Container()
                //     : Padding(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 16, vertical: 32),
                //         child: Text(
                //           'بەتاڵە',
                //           style: TextStyle(
                //             fontSize: 24,
                //           ),
                //           softWrap: true,
                //           textAlign: TextAlign.center,
                //         ),
                //       ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }

  void getCaption() async {
    _listMetaCaption.clear();
    var response = await http.get(Uri.parse(
        "http://fdx.pythonanywhere.com/${YoutubePlayer.convertUrlToId("${urlController.value.text}").toString()}"));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        _listMetaCaption = [
          ...jsonResponse.toList().map((element) {
            return CaptionModel.fromJson(element);
          }).toList()
        ];
      });
      print('Number of books about http.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void getTransalte(String data) async {
    var response = await http
        .get(Uri.parse("https://fdx.pythonanywhere.com/translate/$data"));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        kurdish = convert
            .jsonDecode(jsonResponse)
            .first['translations']
            .first['text'];
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}

// _listMetaCaption.isEmpty
//     ? Container()
//     : Expanded(
//         child: ListView.builder(itemBuilder: (_, index) {
//           return Card(
//             color: Duration(
//                         microseconds:
//                             (_listMetaCaption[index].start *
//                                     1000000)
//                                 .toInt()) >=
//                     currentDuration
//                 ? Colors.white
//                 : Colors.amber.withOpacity(.6),
//             child: ListTile(
//               title: Text('${_listMetaCaption[index].text}'),
//               subtitle: Text(
//                   'Start in :${_listMetaCaption[index].start} ,duration :${_listMetaCaption[index].duration}'),
//               onTap: () {},
//             ),
//           );
//         }),
//       ),