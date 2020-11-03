import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amane_rankers/definitions.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Amane Rankers',
        theme: new ThemeData.dark().copyWith(
            primaryColor: Colors.pink,
            accentColor: Colors.indigo,
            buttonColor: lavenderBrush,
            floatingActionButtonTheme:
                new FloatingActionButtonThemeData(backgroundColor: lightPink)),
        home: TopPage());
  }
}

class TopPage extends StatefulWidget {
  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  String _playerName = '';

  void _handleText(String e) {
    setState(() {
      _playerName = e;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('トップページ')),
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(50.0),
            child: Container(
              child: Container(
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: BoxConstraints(minWidth: 200, maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '個人戦績',
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: (new TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'プレイヤー名'),
                            enabled: true,
                            maxLengthEnforced: false,
                            style: TextStyle(color: lavenderBrush),
                            obscureText: false,
                            maxLines: 1,
                            onChanged: _handleText,
                          ))),
                      RaisedButton(
                        child: const Text('GO→'),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return PlayerStatisticsPage(
                                playerName: _playerName);
                          }));
                          print(_playerName);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                      ),
                      Text(
                        'ランキング(coming soon...)',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: (new TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'comming soon...'),
                          enabled: true,
                          maxLengthEnforced: false,
                          style: TextStyle(color: lavenderBrush),
                          obscureText: false,
                          maxLines: 1,
                          onChanged: _handleText,
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerStatisticsPage extends StatefulWidget {
  final String playerName;

  PlayerStatisticsPage({this.playerName});

  @override
  _PlayerStatisticsPageState createState() => _PlayerStatisticsPageState();
}

class _PlayerStatisticsPageState extends State<PlayerStatisticsPage> {
  List<StatisticsRowData> _data;

  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(title: const Text('個人戦績')),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, int index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
                constraints: BoxConstraints(minWidth: 150, maxWidth: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
                      child: Text(
                        _data[index].title,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
                      child: Text(
                        _data[index].value,
                        textAlign: TextAlign.end,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(title: const Text('個人戦績')),
    //   body: SingleChildScrollView(
    //     child: Container(
    //       padding: const EdgeInsets.all(50.0),
    //       child: Container(
    //         child: Container(
    //           alignment: Alignment.topCenter,
    //           child: Container(
    //             constraints: BoxConstraints(minWidth: 200, maxWidth: 500),
    //             child: ListView.builder(
    //               itemCount: _data.length,
    //               itemBuilder: (context, int index) {
    //                 return Padding(
    //                     padding: EdgeInsets.all(8.0),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text(
    //                           _data[index].title,
    //                           textAlign: TextAlign.start,
    //                         ),
    //                         Text(
    //                           _data[index].value,
    //                           textAlign: TextAlign.end,
    //                         ),
    //                       ],
    //                     ));
    //               },
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  void fetchResults() async {
    final playerName = widget.playerName;
    final url =
        "https://cksa7u26z0.execute-api.ap-northeast-1.amazonaws.com/api/results?player=$playerName&platform=huruyoni";

    http.get(url).then((response) {
      setState(() {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if (jsonResponse.containsKey('message')) {
          _data = [];
        } else {
          _data = PlayerStatistics.fromJson(jsonResponse).toList();
        }
      });
    });
  }

  @override
  void initState() {
    _data = [];
    fetchResults();

    super.initState();
  }
}

class PlayerStatistics {
  PlayerStatistics({
    this.name,
    this.gameWins,
    this.gameLoses,
    this.gameDraws,
    this.averagePlace,
    this.competitionEntries,
    this.competitionVictories,
  });

  String name;
  int gameWins;
  int gameLoses;
  int gameDraws;
  double averagePlace;
  int competitionEntries;
  int competitionVictories;

  factory PlayerStatistics.fromJson(Map<String, dynamic> json) =>
      PlayerStatistics(
        name: json["name"],
        gameWins: json["game_wins"],
        gameLoses: json["game_loses"],
        gameDraws: json["game_draws"],
        averagePlace: json["average_place"],
        competitionEntries: json["competition_entries"],
        competitionVictories: json["competition_victories"],
      );

  List<StatisticsRowData> toList() => [
        StatisticsRowData("プレイヤー名", this.name),
        StatisticsRowData("ゲーム勝利数", this.gameWins.toString()),
        StatisticsRowData("ゲーム敗北数", this.gameLoses.toString()),
        StatisticsRowData("ゲーム引分数", this.gameDraws.toString()),
        StatisticsRowData("大会参加数", this.competitionEntries.toString()),
        StatisticsRowData("大会優勝数", this.competitionVictories.toString()),
        StatisticsRowData("大会平均順位", this.averagePlace.toString()),
      ];
}

class StatisticsRowData {
  final String title;
  final String value;

  StatisticsRowData(this.title, this.value);
}
