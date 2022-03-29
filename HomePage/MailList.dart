import 'package:flutter/material.dart';
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

  ColorSwatch<int> retrieveColor(Mail msg) {
    if (msg is Invite) {
      return Colors.green;
    } else if (msg is Reply) {
      return Colors.orange;
    } else {
      return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        physics: widget.scrollPhysics,
        itemCount: widget.mail.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Mail msg = widget.mail[index];
          ColorSwatch<int> iconColor = retrieveColor(msg);

          if (index % 2 == 0) {
            if (index + 1 != widget.mail.length) {} else {}
          }

          return OutlinedButton(
            child: Column(
              children: <Widget>[
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(
                              msg.imageUrl),
                          fit: BoxFit.cover)),
                ),
                ListTile(
                  leading: Icon(
                    Icons.wysiwyg_sharp,
                    color: iconColor,
                    size: 15,
                  ),
                  title: Text(msg.title),
                  subtitle: Text(msg.sender.toString()),
                )
              ],
            ),
            onPressed: () {},
          );
        });
  }
}
