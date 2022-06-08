import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isCurrentUser;
  final String imageUrl;

  ChatBubble({
    Key? key,
    required this.imageUrl,
    required this.text,
    required this.isCurrentUser,
  }) : super(key: key);

  TextEditingController inputBubble = TextEditingController();
  Widget userProfile = SizedBox.shrink();
  Widget senderProfile = SizedBox.shrink();

  Widget chatWidget(BuildContext context) {
    if (!isCurrentUser) {
      return Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: Colors.black87),
      );
    } else {
      return TextField(
        controller: inputBubble,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: Colors.white),
        decoration: const InputDecoration(
            border: InputBorder.none, fillColor: Colors.transparent),
      );
    }
  }

  Widget msgProfile() {
    if (isCurrentUser) {
      return Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
        child:
            CircleAvatar(radius: 300, backgroundImage: NetworkImage(imageUrl)),
      );
    } else {
      return Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: CircleAvatar(
              radius: 300, backgroundImage: NetworkImage(imageUrl)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return Padding(
          // asymmetric padding
          padding: EdgeInsets.fromLTRB(64, 4, 16, 4),
          child: Row(
            children: <Widget>[
              Align(
                // align the child within the container
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: DecoratedBox(
                  // chat bubble decoration
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: inputBubble,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.white),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          fillColor: Colors.transparent),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: CircleAvatar(
                      radius: 300, backgroundImage: NetworkImage(imageUrl)))
            ],
          ));
    } else {
      return Padding(
        // asymmetric padding
        padding: const EdgeInsets.fromLTRB(16, 4, 64, 4),
        child: Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: CircleAvatar(
                    radius: 300, backgroundImage: NetworkImage(imageUrl))),
            Align(
              // align the child within the container
              alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: DecoratedBox(
                // chat bubble decoration
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: chatWidget(context),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
