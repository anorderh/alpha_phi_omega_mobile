import 'package:flutter/material.dart';
import 'dart:ui';

class ProfileHeader extends StatelessWidget {
  String name;
  String position;
  String imageURL;

  ProfileHeader(
      {Key? key,
      required this.name,
      required this.position,
      required this.imageURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Colors.lightBlue, Colors.blueAccent.shade200],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.5, 0.9],
        )),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
                child: ClipRRect(
                    child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Image.asset(
                          'assets/apoCrest.png',
                          fit: BoxFit.cover,
                          color: const Color.fromRGBO(255, 255, 255, 0.7),
                          colorBlendMode: BlendMode.modulate,
                        )))),
            FittedBox(
                fit: BoxFit.contain,
                child: Row(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                            child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                      imageURL),
                                  fit: BoxFit.cover)),
                        ))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        child: Column(children: <Widget>[
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(position,
                              style: const TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                fontSize: 20,
                              ))
                        ])),
                  ],
                ))
          ],
        ));
  }
}
