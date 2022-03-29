import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../Backend/apo_objects.dart';

class MailList extends StatefulWidget {
  List<Mail> mail;
  ScrollPhysics scrollPhysics;

  MailList({Key? key, required this.mail, required this.scrollPhysics})
      : super(key: key);

  @override
  _MailListState createState() => _MailListState();
}

class _MailListState extends State<MailList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Map<String, dynamic> retrieveTag(Mail msg) {
    if (msg is Invite) {
      return {
        'color': Colors.green,
        'icon': const Icon(
          Icons.mail,
          color: Colors.white,
          size: 20.0,
        )
      };
    } else if (msg is Reply) {
      return {
        'color': Colors.orange,
        'icon': const Icon(
          Icons.record_voice_over,
          color: Colors.white,
          size: 20.0,
        )
      };
    } else {
      return {
        'color': Colors.blueAccent,
        'icon': const Icon(
          Icons.system_update,
          color: Colors.white,
          size: 20.0,
        )
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 5.0,
            childAspectRatio: 1),
        physics: widget.scrollPhysics,
        shrinkWrap: true,
        itemCount: widget.mail.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          Mail msg = widget.mail[index];
          Map<String, dynamic> msgTags = retrieveTag(msg);

          return Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(0, 0, 100, 0.02), Color.fromRGBO(0, 0, 100, 0.005)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )),
            child: OutlinedButton(
              child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            Flexible(
                                flex: 6,
                                child: Padding(
                                    padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 5),
                                    child: SizedBox(
                                        height: 90,
                                        child: CircleAvatar(
                                            radius: 50,
                                            backgroundImage:
                                            NetworkImage(msg.imageUrl))))),
                            Flexible(
                              flex: 3,
                              fit: FlexFit.tight,
                              child: Container(
                                  alignment: Alignment.center,
                                  child: Text('"' + msg.body + '"',
                                      style: const TextStyle(
                                          fontSize: 17, color: Colors.black87),
                                      textAlign: TextAlign.center)),
                            ),
                            Container(
                                child: Text(msg.sender.toString(),
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black54))),
                          ],
                        )),
                    Positioned(
                        right: 30,
                        bottom: 90,
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: RawMaterialButton(
                            onPressed: null,
                            fillColor: msgTags['color'],
                            child: msgTags['icon'],
                            shape: const CircleBorder(),
                          ),
                        ))
                  ],
                ),
              onPressed: () {},
            ),
          );
        });
  }
}
