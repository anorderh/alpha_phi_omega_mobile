import 'package:flutter/material.dart';
import 'BrotherCollection.dart';
import 'package:example/Backend/database.dart';

class BrotherSelection extends StatefulWidget {
  Map<String, Map<String, String>> info;
  Function choose;

  BrotherSelection({required this.info, required this.choose, Key? key}) : super(key: key);

  @override
  _BrotherSelectionState createState() => _BrotherSelectionState();
}

class _BrotherSelectionState extends State<BrotherSelection> {
  late TextEditingController search;
  late Map<String, Map<String, String>> foundBrothers;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    search = TextEditingController();
    foundBrothers = widget.info;
  }

  void filterQuery(String input) {
    Map<String, Map<String, String>> temp = Map.from(widget.info);
    print(temp);


    if (search.text != '') {
      for (String name in temp.keys.toList()) {
        if (!name.toLowerCase().startsWith(input.toLowerCase())) {
          temp.remove(name);
        }
      }
    }

    setState(() {
      foundBrothers = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: null,
          )
        ],
        backgroundColor: Colors.blueAccent,
        title: TextField(
          onSubmitted: filterQuery,
          controller: search,
          decoration: const InputDecoration(
            hintText: "Search a brother's name...",
            hintStyle: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
            border: InputBorder.none,
          ),
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: BrotherCollection(brothers: foundBrothers, choose: widget.choose,),
    );
  }
}
