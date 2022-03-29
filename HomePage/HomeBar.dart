import 'package:flutter/material.dart';

class HomeBar extends StatefulWidget {
  List<bool> selections;
  Function select;

  HomeBar({Key? key, required this.selections, required this.select}) : super(key: key);

  @override
  _HomeBarState createState() => _HomeBarState();
}

class _HomeBarState extends State<HomeBar> {
  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width/3,
            child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("REQS.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            )),
        Container(
            width: MediaQuery.of(context).size.width/3,
            child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("UPCOMING\nEVENTS",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,)
            )),
        Container(
            width: MediaQuery.of(context).size.width/3,
            child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("MAIL",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)
            ))
      ],
      isSelected: widget.selections,
      color: Colors.grey,
      selectedColor: Colors.blueAccent,
      renderBorder: false,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < widget.selections.length; i++) {
            if (i == index) {
              widget.selections[i] = true;
            } else {
              widget.selections[i] = false;
            }
          }

          widget.select(index);
        });
      },
    );
  }
}

