import 'package:flutter/material.dart';

class TrackerButtons extends StatefulWidget {
  void Function(List<int>) callback;

  TrackerButtons(this.callback);

  @override
  _TrackerButtonsState createState() => _TrackerButtonsState();
}

class _TrackerButtonsState extends State<TrackerButtons> {
  List<bool> selections = [false, false, false];
  List<int> values = [0, 0, 0];

  @override
  Widget build(BuildContext context) {
    values = [0, 0, 0];

    return ToggleButtons(
      children: <Widget>[Text('M'), Text('S'), Text('I')],
      isSelected: selections,
      constraints: BoxConstraints(minHeight: 50, minWidth: 59),
      onPressed: (int index) {
        setState(() {



          if (!selections[index]) {
            for (int i = index; i >= 0; i--) {

              if (!selections[i]) {
                selections[i] = true;
                values[i] = 1;
              }
            }
          } else {
            if (index + 1 == selections.length) {
              selections[index] = false;
              values[index] = -1;
            } else {
              for (int i = index+1; i < selections.length; i++) {

                if (selections[i]) {
                  selections[i] = false;
                  values[i] = -1;
                } else {
                  selections[i-1] = false;
                  values[i-1] = -1;
                  break;
                }
              }
            }
          }
        });
        widget.callback(values);
      },
    );
  }
}
