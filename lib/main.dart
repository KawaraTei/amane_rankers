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
  String _rankingType = '';

  void _handlePlayerName(String e) {
    setState(() {
      _playerName = e;
    });
  }

  void _handleRankingType(String e) {
    setState(() {
      _rankingType = e;
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
                            onChanged: _handlePlayerName,
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
                        'ランキング',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: (new TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'まだ"game_win_ratio"しかないです'),
                          enabled: true,
                          maxLengthEnforced: false,
                          style: TextStyle(color: lavenderBrush),
                          obscureText: false,
                          maxLines: 1,
                          onChanged: _handleRankingType,
                        )),
                      ),
                      RaisedButton(
                        child: const Text('GO→'),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return RankingPage(
                                    rankingType: 'game_win_ratio');
                                    // rankingType: _rankingType);
                              }));
                          print(_rankingType);
                        },
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
  // データなし:0 データあり:1
  var _index = 0;

  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(title: const Text('個人戦績')),
      body: IndexedStack(
        index: _index,
        children: [
          Container(
            padding: const EdgeInsets.all(50.0),
            alignment: Alignment.topCenter,
            child: Container(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 500),
              child: Text('データが見つかりませんでした'),
            ),
          ),
          Container(
              padding: const EdgeInsets.all(50.0),
              alignment: Alignment.topCenter,
              child: Container(
                constraints: BoxConstraints(minWidth: 150, maxWidth: 500),
                child: ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, int index) {
                    return Padding(
                      padding: EdgeInsets.all(8.0),
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
                    );
                  },
                ),
              )
          ),
        ],
      )
    );
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
          _index = 0;
        } else {
          _data = PlayerStatistics.fromJson(jsonResponse).toList();
          if (_data.length > 0) {
            _index = 1;
          }
          else {
            _index = 0;
          }
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
        StatisticsRowData("マッチ勝利数", this.gameWins.toString()),
        StatisticsRowData("マッチ敗北数", this.gameLoses.toString()),
        StatisticsRowData("マッチ引分数", this.gameDraws.toString()),
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

class RankingPage extends StatefulWidget {
  final String rankingType;

  RankingPage({this.rankingType});

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List<RankingPlayerData> _data;

  // データなし:0 データあり:1
  var _index = 0;

  Widget build(BuildContext build) {
    return Scaffold(
        appBar: AppBar(title: const Text('ランキング')),
        body: IndexedStack(
          index: _index,
          children: [
            Container(
              padding: const EdgeInsets.all(50.0),
              alignment: Alignment.topCenter,
              child: Container(
                constraints: BoxConstraints(minWidth: 150, maxWidth: 500),
                child: Text('データが見つかりませんでした'),
              ),
            ),
            Container(
                padding: const EdgeInsets.all(50.0),
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: BoxConstraints(minWidth: 150, maxWidth: 500),
                  child: ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (context, int index) {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                  minWidth: 100, maxWidth: 300),
                              child: Text(
                                  (index + 1).toString(),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              constraints: BoxConstraints(
                                  minWidth: 100, maxWidth: 300),
                              child: Text(
                                _data[index].name,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
            ),
          ],
        )
    );
  }

  void fetchResults() async {
    final rankingType = widget.rankingType;
    final url = "https://cksa7u26z0.execute-api.ap-northeast-1.amazonaws.com/api/rankings?key=$rankingType&platform=huruyoni";

    http.get(url).then((response) {
      setState(() {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if (jsonResponse.containsKey('message')) {
          _data = [];
          _index = 0;
        } else {
          _data = RankingData.fromJson(jsonResponse).ranking;
          if (_data.length > 0) {
            _index = 1;
          }
          else {
            _index = 0;
          }
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

class RankingData {
  RankingData({
    this.key,
    this.ranking,
  });

  String key;
  List<RankingPlayerData> ranking;

  factory RankingData.fromJson(Map<String, dynamic> json) => RankingData(
    key: json["key"],
    ranking: List<RankingPlayerData>.from(json["ranking"].map((x) => RankingPlayerData.fromJson(x))),
  );

}

class RankingPlayerData {
  RankingPlayerData({
    this.name,
    this.gameWins,
    this.gameLoses,
    this.gameDraws,
    this.averagePlace,
    this.competitionEntries,
    this.competitionVictories,
    this.victoryRatio,
    this.gameWinRatio,
  });

  String name;
  int gameWins;
  int gameLoses;
  int gameDraws;
  double averagePlace;
  int competitionEntries;
  int competitionVictories;
  double victoryRatio;
  double gameWinRatio;

  factory RankingPlayerData.fromJson(Map<String, dynamic> json) => RankingPlayerData(
    name: json["name"],
    gameWins: json["game_wins"],
    gameLoses: json["game_loses"],
    gameDraws: json["game_draws"],
    averagePlace: json["average_place"],
    competitionEntries: json["competition_entries"],
    competitionVictories: json["competition_victories"],
    victoryRatio: json["victory_ratio"],
    gameWinRatio: json["game_win_ratio"].toDouble(),
  );
}
