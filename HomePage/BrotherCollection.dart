import 'package:flutter/material.dart';
import 'package:example/Backend/database.dart';

class BrotherCollection extends StatefulWidget {
  Map<String, Map<String, String>> brothers;
  Function choose;

  BrotherCollection({required this.brothers, required this.choose, Key? key})
      : super(key: key);

  @override
  _BrotherCollectionState createState() => _BrotherCollectionState();
}

class _BrotherCollectionState extends State<BrotherCollection> {
  Text formatString(String name) {
    return Text(name,
        style: const TextStyle(
            fontSize: 14, overflow: TextOverflow.ellipsis, color: Colors.black87));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> names = widget.brothers.keys.toList();

    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 5.0,
            childAspectRatio: 0.7),
        physics: AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.brothers.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          String name = names[index];

          return Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(0, 0, 100, 0.05),
                Color.fromRGBO(0, 0, 100, 0.01)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )),
            child: OutlinedButton(
              child: Column(
                children: <Widget>[
                  Flexible(
                      flex: 4,
                      child: CircleAvatar(
                          radius: 300,
                          backgroundImage: NetworkImage(
                              widget.brothers[name]!['imageUrl']!))),
                  Flexible(
                    flex: 2,
                    child: Text(
                      name,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              onPressed: () {
                widget.choose(formatString(name));
                Navigator.pop(context);
              },
            ),
          );
        });
  }
}
