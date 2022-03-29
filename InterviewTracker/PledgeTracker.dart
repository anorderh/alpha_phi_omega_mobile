import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:example/InterviewTracker/TrackerButtons.dart';

import 'TrackerInfo.dart';

class Tracker extends StatefulWidget {
  @override
  _TrackerState createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  Future<List<List<String>>> photos = Future.value([]);
  int messaged = 0;
  int scheduled = 0;
  int interviewed = 0;

  @override
  void initState() {
    photos = initPhotos();
    super.initState();
  }

  void updateCount(List<int> buttonInput) {
    setState(() {
      messaged += buttonInput[0];
      scheduled += buttonInput[1];
      interviewed += buttonInput[2];
    });
  }

  Future<List<List<String>>> initPhotos() async {
    var content = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> contentMap = jsonDecode(content);
    List<String> assets = contentMap.keys.toList();
    assets = assets.sublist(
        assets.indexWhere((element) => element.contains('TRCK_')),
        assets.lastIndexWhere((element) => element.contains('TRCK_')) + 1);

    List<List<String>> photoLinks = [];

    for (int i = 0; i < assets.length; i = i + 2) {
      if (i + 1 == assets.length) {
        photoLinks.add([assets[i]]);
      } else {
        photoLinks.add([assets[i], assets[i + 1]]);
      }
    }

    return photoLinks;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        TrackerInfo(m: messaged, s: scheduled, i: interviewed),
        FutureBuilder(
            future: photos,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState.index == 3) {
                if (snapshot.data.length == 0) {
                  return const Center(child: Text('No brother pictures found'));
                } else {
                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        List<String> list = snapshot.data[index];

                        if (list.length > 1) {
                          return Row(children: <Widget>[
                            Expanded(
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                        margin: const EdgeInsets.all(15),
                                        child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 180,
                                                  height: 180,
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Image.asset(list[0]),
                                                  ),
                                                ),
                                                Text(
                                                  list[0]
                                                      .split('.')[0]
                                                      .replaceAll(
                                                          'assets/TRCK_', '')
                                                      .replaceAll('_', ' '),
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                TrackerButtons(updateCount)
                                              ],
                                            )),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueAccent),
                                        )))),
                            Expanded(
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                        margin: const EdgeInsets.all(15),
                                        child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 180,
                                                  height: 180,
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Image.asset(list[1]),
                                                  ),
                                                ),
                                                Text(
                                                  list[1]
                                                      .split('.')[0]
                                                      .replaceAll(
                                                          'assets/TRCK_', '')
                                                      .replaceAll('_', ' '),
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                TrackerButtons(updateCount)
                                              ],
                                            )),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueAccent),
                                        ))))
                          ]);
                        } else {
                          return Align(
                              alignment: Alignment.center,
                              child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 180,
                                            height: 180,
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: Image.asset(list[0]),
                                            ),
                                          ),
                                          Text(
                                            list[0]
                                                .split('.')[0]
                                                .replaceAll('assets/TRCK_', '')
                                                .replaceAll('_', ' '),
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          TrackerButtons(updateCount)
                                        ],
                                      )),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.blueAccent),
                                  )));
                        }
                      });
                }
              } else {
                return const SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(child: CircularProgressIndicator()));
              }
            })
      ],
    ));
  }
}
