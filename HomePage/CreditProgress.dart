import 'package:flutter/material.dart';

class CreditProgress extends StatelessWidget {
  Map<String, List<double>> progress;

  CreditProgress({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> credits = progress.keys.toList();

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(25)),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: Text(
              "Requirement Progress",
              style: TextStyle(fontSize: 20),
            ),
          ),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: credits.length,
              itemBuilder: (context, index) {
                List<double> credBounds = progress[credits[index]]!;

                return Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(credits[index]),
                        subtitle: Text('${credBounds[0]} of ${credBounds[1]}'),
                      ),
                      LinearProgressIndicator(
                          value: credBounds[0] / credBounds[1],
                          minHeight: 10,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple),
                          backgroundColor: Colors.blueGrey)
                    ],
                  ),
                );
              })
        ],
      ),
    );
  }
}
