import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../RevampLib/AppData.dart';
import '../RevampLib/EventView_HTTP.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../RevampLib/Settings.dart';
import 'Base.dart';
import 'UserData.dart';
import 'package:expandable_page_view/expandable_page_view.dart';

class EventView extends StatefulWidget {
  final EventFull event;
  final CredInfo info;

  const EventView({Key? key, required this.event, required this.info})
      : super(key: key);

  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  late Future<List<dynamic>> participantScrape;
  bool eventsModified = false;
  late Map httpTags;

  @override
  void didChangeDependencies() {
    httpTags = MainUser.of(context).data.http.getHTTPTags();
    participantScrape = getParticipants(httpTags, widget.event.link);
    MainApp.of(context).maintenance.setBuildContext(context);

    super.didChangeDependencies();
  }

  void updateParticipants() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          participantScrape = getParticipants(httpTags, widget.event.link);
        }));

    Function? refresh = MainApp.of(context).maintenance.refreshHome;
    if (refresh != null) {
      // check for if Home hasn't loaded
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            HSLColor.fromColor(widget.info.color).withLightness(0.9).toColor(),
        body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: ListView(physics: ClampingScrollPhysics(), children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.all(5),
                    height: 250,
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 12),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            widget.event.title,
                            style: TextStyle(
                                fontSize: 36,
                                color: HSLColor.fromColor(widget.info.color)
                                    .withLightness(0.3)
                                    .toColor()),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          alignment: Alignment.centerRight,
                          child: Icon(widget.info.icon,
                              size: 190,
                              color: HSLColor.fromColor(widget.info.color)
                                  .withLightness(0.6)
                                  .toColor()
                                  .withOpacity(0.3)),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                              padding: EdgeInsets.only(left: 10, top: 15),
                              onPressed: () {
                                MainApp.of(context).maintenance.setBuildContext(null);
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(FontAwesomeIcons.rotateLeft,
                                  color: Colors.black)),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25))),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 5,
                            child: Description(desc: widget.event.desc),
                          ),
                          Flexible(
                            flex: 2,
                            child: EventButtons(
                              scrape: participantScrape,
                              event: widget.event,
                              update: updateParticipants,
                            ),
                          )
                        ],
                      ),
                      EventInfo(
                          bubbleColor: widget.info.color, event: widget.event),
                      ParticipantList(scrape: participantScrape)
                    ],
                  ),
                )
              ]),
            ])));
  }
}

class Description extends StatelessWidget {
  final String desc;

  const Description({Key? key, required this.desc}) : super(key: key);

  final String copypaste =
      "You are about to get spammed with 600 dank memes. Prepare all nukes and weapons for the Great Spam War. If you can contain the amount of spam I have, you will be granted with special powers that allow you to smoke weed 200 times harder. Not only that, but you will have a laggy as fuck laptop. You know how lucky you are?????? My laptop runs at 669FPS and it never lags or is slow. YOU LUCKY SON OF A GUN. You will pay the price by me giving you a link (Which shall contain a download) which will wipe all your memory off the face of this universe and overwrite it with my own software, Memesoftlocker2.0000.0. You are so damn lucky you know that? NOT EVEN I HAVE IT SLUT. But if you were able to read up to this point congratulations, you suck. But click this link www.mymom.;;;;;;/eeeeeeee.crash; and you will be taken to a memory erase phrase. You lucky slut, but you will get the best computer software ever that makes your computer lag so bad that you can't even use it. LIKE HOW AMAZING??? Yes, I promise you this is 420% legit. But if you spread this abusive software you have EARNED I will suck you off this living universe so be careful buddy. Now, Please stop reading this message as it ends now...";

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 5),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text("Description",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 130,
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 5, bottom: 5, right: 5),
                  child: Text(desc,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14)),
                ),
              ),
            )
          ],
        ));
  }
}

class EventButtons extends StatefulWidget {
  final Future<List<dynamic>> scrape;
  final EventFull event;
  final Function update;

  const EventButtons(
      {Key? key,
      required this.scrape,
      required this.event,
      required this.update})
      : super(key: key);

  @override
  _EventButtonsState createState() => _EventButtonsState();
}

class _EventButtonsState extends State<EventButtons> {
  ButtonStyle retrieveStyle(Color color) {
    return ElevatedButton.styleFrom(
        onPrimary: HSLColor.fromColor(color).withLightness(0.65).toColor(),
        elevation: 0.0,
        shadowColor: Colors.transparent,
        alignment: Alignment.center,
        padding: EdgeInsets.all(5),
        primary: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        children: [
          SignupButton(
            scrape: widget.scrape,
            event: widget.event,
            update: widget.update,
            size: 45,
          ),
          ChairButton(
            scrape: widget.scrape,
            size: 45,
          ),
          EventButton(
            label: Image.asset('assets/googleCalendarIcon.png',
                height: 35, width: 35),
            callback: () {
              print("tapped calendar");
            },
            color: Colors.white,
            size: 45,
          )
        ],
      ),
    );
  }
}

class EventButton extends StatelessWidget {
  final Widget label;
  final Function? callback;
  final Color color;
  final double size;

  const EventButton(
      {Key? key,
      required this.label,
      required this.callback,
      required this.color,
      required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: 2),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: color,
        elevation: 1.0,
        child: InkWell(
          splashColor: HSLColor.fromColor(color).withLightness(0.9).toColor(),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          onTap: callback == null
              ? null
              : () {
                  callback!();
                },
          child: Container(
            height: size,
            padding: EdgeInsets.all(2),
            alignment: Alignment.center,
            child: label,
          ),
        ),
      ),
    );
  }
}

class SignupButton extends StatefulWidget {
  final Future<List<dynamic>> scrape;
  final EventFull event;
  final Function update;
  final double size;

  const SignupButton(
      {Key? key,
      required this.scrape,
      required this.event,
      required this.update,
      required this.size})
      : super(key: key);

  @override
  _SignupButtonState createState() => _SignupButtonState();
}

class _SignupButtonState extends State<SignupButton> {
  EventButton getButton(bool signedUp) {
    if (widget.event.close != null &&
        widget.event.close!.compareTo(DateTime.now()) > 0) {
      if (signedUp) {
        if (widget.event.lock != null &&
            widget.event.lock!.compareTo(DateTime.now()) > 0) {
          return EventButton(
            label: Text("Leave",
                style: TextStyle(color: Colors.white, fontSize: 22)),
            color: Colors.red,
            callback: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => ResultDialog(
                        updateParticipants: widget.update,
                        actionName: "Leave",
                        result: removeSelf(
                            MainUser.of(context).data.http.getHTTPTags(),
                            widget.event.id),
                      ));
            },
            size: widget.size,
          );
        } else {
          return EventButton(
            label: Icon(FontAwesomeIcons.lock, color: Colors.white),
            color: Colors.grey,
            callback: null,
            size: widget.size,
          );
        }
      } else {
        return EventButton(
          label:
              Text("Join", style: TextStyle(color: Colors.white, fontSize: 22)),
          callback: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) =>
                    JoinDialog(update: widget.update, event: widget.event));
          },
          color: Colors.blue,
          size: widget.size,
        );
      }
    } else {
      return EventButton(
        label:
            Text("Closed", style: TextStyle(color: Colors.white, fontSize: 22)),
        callback: null,
        color: Colors.grey,
        size: widget.size,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: widget.scrape,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return EventButton(
              label: SizedBox.square(
                dimension: 25,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              ),
              callback: () {},
              color: Colors.blue,
              size: widget.size,
            );
          } else {
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              print(snapshot.stackTrace.toString());

              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(15),
                child: Text(
                    "An error occurred. Please refresh or close the app.",
                    style: GoogleFonts.dmSerifDisplay(fontSize: 16)),
              );
            } else if (snapshot.hasData) {
              return getButton(snapshot.data![0]);
            }
          }
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            child: Text('State: ${snapshot.connectionState}'),
          );
        });
  }
}

class ChairButton extends StatefulWidget {
  final Future<List<dynamic>> scrape;
  final double size;

  const ChairButton({Key? key, required this.scrape, required this.size})
      : super(key: key);

  @override
  _ChairButtonState createState() => _ChairButtonState();
}

class _ChairButtonState extends State<ChairButton> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: widget.scrape,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return EventButton(
              label: SizedBox.square(
                dimension: 25,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              ),
              callback: () {},
              color: Colors.blue,
              size: widget.size,
            );
          } else {
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              print(snapshot.stackTrace.toString());

              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(15),
                child: Text(
                    "An error occurred. Please refresh or close the app.",
                    style: GoogleFonts.dmSerifDisplay(fontSize: 16)),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data![1].length > 0) {
                return EventButton(
                  label: Text("Chair",
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                  callback: () {
                    print("tapped chair");
                  },
                  color: Color(0xffd0a80b),
                  size: widget.size,
                );
              } else {
                return EventButton(
                  label: Text("N/A",
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                  callback: null,
                  color: Colors.grey,
                  size: widget.size,
                );
              }
            }
          }
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            child: Text('State: ${snapshot.connectionState}'),
          );
        });
  }
}

class EventInfo extends StatelessWidget {
  final EventFull event;
  final Color bubbleColor;

  const EventInfo({Key? key, required this.bubbleColor, required this.event})
      : super(key: key);

  String deriveEventDuration() {
    String result = "";

    if (event.start != null && event.end != null) {
      result = DateFormat("h:mm a").format(event.start!) +
          " - " +
          DateFormat("h:mm a").format(event.end!) +
          ", ";
    }

    result += DateFormat("EEEE").format(event.date) +
        DateFormat("\nMMMM d").format(event.date) +
        ordinalGen(event.date.day);

    return result;
  }

  String lockInfo(DateTime? date) {
    if (date == null) {
      return "Signups are currently LOCKED";
    } else {
      return "Locks @ " +
          DateFormat('h:mm a, MMMM d').format(date) +
          ordinalGen(date.day);
    }
  }

  String closeInfo(DateTime? date) {
    if (date == null) {
      return "Signups are currently CLOSED";
    } else {
      return "Closes @ " +
          DateFormat('h:mm a, MMMM d').format(date) +
          ordinalGen(date.day);
    }
  }

  String ordinalGen(int number) {
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      child: Column(
        children: [
          InfoPanel(
              icon: Icon(
                FontAwesomeIcons.locationDot,
                color: Colors.red,
                size: 20.0,
              ),
              text: event.loc,
              color: bubbleColor),
          InfoPanel(
              icon: Icon(
                FontAwesomeIcons.calendarDays,
                color: Colors.green.shade700,
                size: 20,
              ),
              text: deriveEventDuration(),
              color: bubbleColor),
          InfoPanel(
              icon: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.yellow.shade300,
                size: 20,
              ),
              text: event.cred,
              color: bubbleColor),
          InfoPanel(
              icon: Icon(
                FontAwesomeIcons.userLarge,
                color: Colors.blue,
                size: 18,
              ),
              text: event.creator,
              color: bubbleColor),
          InfoPanel(
              icon: Icon(
                FontAwesomeIcons.lock,
                color: Colors.blueGrey,
                size: 18,
              ),
              text: lockInfo(event.lock) + "\n" + closeInfo(event.close),
              color: bubbleColor)
        ],
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  final Icon icon;
  final String text;
  final Color color;

  const InfoPanel(
      {Key? key, required this.icon, required this.text, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Container(
              height: 40,
              child: icon,
              decoration: BoxDecoration(
                  color: HSLColor.fromColor(color).withLightness(0.9).toColor(),
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 2,
                      color: HSLColor.fromColor(color)
                          .withLightness(0.3)
                          .toColor())),
            ),
          ),
          Flexible(
            flex: 7,
            child: Container(
              alignment: Alignment.center,
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

class ParticipantList extends StatefulWidget {
  final Future<List<dynamic>> scrape;

  const ParticipantList({Key? key, required this.scrape}) : super(key: key);

  @override
  _ParticipantListState createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  Color tileColor = Colors.white;

  Widget retrieveCarIcon(Participant participant) {
    if (participant.canDrive != null) {
      return Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.blue.shade300, width: 2)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.all(2),
                  child:
                      Icon(FontAwesomeIcons.car, color: Colors.blue.shade700)),
              Container(
                padding: EdgeInsets.all(2),
                child: Text(participant.canDrive.toString(),
                    style: TextStyle(fontSize: 18)),
              )
            ],
          ));
    } else {
      return Container();
    }
  }

  List<Widget> retrieveTiles(List<Participant> participants) {
    List<Widget> tiles = [];
    Row tileContent;

    if (participants.isEmpty) {
      tiles.add(Container(
          alignment: Alignment.center,
          height: 50,
          padding: EdgeInsets.only(left: 10, right: 10),
          color: tileColor,
          child: Text(
            "No participants!",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          )));
    } else {
      for (int i = 0; i < participants.length; i++) {
        tileColor = (i % 2 == 0) ? Colors.blue.shade50 : Colors.white;

        if (i % 2 == 0) {
          tileColor = Colors.blue.shade50;
        } else {
          tileColor = Colors.white;
        }

        tileContent = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                // color: Colors.red,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(participants[i].name,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(participants[i].number!,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54))
                      ],
                    ),
                    retrieveCarIcon(participants[i])
                  ],
                )),
            Flexible(
              child: Container(
                width: 135,
                alignment: Alignment.centerRight,
                child: participants[i].comment != null
                    ? Text(participants[i].comment!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold))
                    : Container(),
              ),
            )
          ],
        );

        if (i == participants.length - 1) {
          tiles.add(Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15)),
                  color: tileColor),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: tileContent));
        } else {
          tiles.add(Container(
              height: 50,
              padding: EdgeInsets.only(left: 10, right: 10),
              color: tileColor,
              child: tileContent));
        }
      }
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: widget.scrape,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.blue,
                ),
              ),
            );
          } else {
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              print(snapshot.stackTrace.toString());

              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(15),
                child: Text(
                    "An error occurred. Please refresh or close the app.",
                    style: GoogleFonts.dmSerifDisplay(fontSize: 16)),
              );
            } else if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15))),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(10),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("Participants",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                  Column(
                    children: retrieveTiles(snapshot.data![1].values.toList()),
                  )
                ],
              );
            }
          }
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            child: Text('State: ${snapshot.connectionState}'),
          );
        });
  }
}

class JoinDialog extends StatefulWidget {
  final Function update;
  final EventFull event;

  const JoinDialog({Key? key, required this.update, required this.event})
      : super(key: key);

  @override
  _JoinDialogState createState() => _JoinDialogState();
}

class _JoinDialogState extends State<JoinDialog> {
  TextEditingController controller = TextEditingController();
  bool isDriving = false;
  Widget visibleSlider = Container();
  double canDrive = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      contentPadding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      title: Text(
        "Optional",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: Container(
        width: 250,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "Are you driving?",
                style: TextStyle(fontSize: 14),
              ),
              Container(
                child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.all(Colors.blue),
                    value: isDriving,
                    onChanged: (newValue) {
                      setState(() {
                        isDriving = newValue!;
                      });
                    }),
              )
            ]),
            isDriving
                ? Column(
                    children: [
                      Text(
                        "How many besides yourself can you drive?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        canDrive.toInt().toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(
                          width: 300,
                          child: CupertinoSlider(
                            thumbColor: Colors.blue,
                            min: 0,
                            max: 8,
                            value: canDrive,
                            onChanged: (newRating) {
                              setState(() {
                                canDrive = newRating;
                              });
                            },
                          ))
                    ],
                  )
                : Container(),
            Text(
              "Leave a comment?",
              style: TextStyle(fontSize: 14),
            ),
            Container(
                height: 100,
                margin: EdgeInsets.all(5),
                child: CupertinoTextField(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  style: GoogleFonts.dmSerifDisplay(fontSize: 16),
                  maxLines: 2,
                  maxLength: 41,
                  controller: controller,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade100.withOpacity(0.5),
                      border: Border.all(width: 1, color: Colors.black)),
                ))
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(right: 4),
                child: EventButton(
                  label: Icon(
                    FontAwesomeIcons.circleXmark,
                    color: Colors.red.shade900,
                    size: 30,
                  ),
                  color: Colors.red,
                  callback: () {
                    Navigator.pop(context, false);
                  },
                  size: 55,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 4),
                child: EventButton(
                  label: Icon(FontAwesomeIcons.check,
                      color: Colors.green.shade800, size: 30),
                  color: Colors.lightGreenAccent.shade700,
                  callback: () {
                    Navigator.of(context).pop();
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => ResultDialog(
                              updateParticipants: widget.update,
                              actionName: "Join",
                              result: addSelf(
                                  MainUser.of(context).data.http.getHTTPTags(),
                                  widget.event.id,
                                  controller.text,
                                  isDriving ? 1 : 0,
                                  canDrive.toInt()),
                            ));
                  },
                  size: 55,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class ResultDialog extends StatefulWidget {
  final Function updateParticipants;
  final String actionName;
  final Future<bool> result;

  const ResultDialog(
      {Key? key,
      required this.actionName,
      required this.result,
      required this.updateParticipants})
      : super(key: key);

  @override
  _ResultDialogState createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> {
  late Widget close;

  @override
  void initState() {
    close = initCloseButton();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget initCloseButton() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        // padding: EdgeInsets.all(0),
        child: Ink(
            width: 150,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 3)
              ],
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Text("Close",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white))),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.lightBlue[50],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      title: Text(
        "Attempting \"${widget.actionName}\"",
        textAlign: TextAlign.center,
        style:
            TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: FutureBuilder<bool>(
                future: widget.result,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      ),
                    );
                  } else {
                    if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      print(snapshot.stackTrace.toString());

                      return Column(
                        children: [
                          Text(
                              "An error occurred. Please report this for debugging and close the app",
                              style: GoogleFonts.dmSerifDisplay(fontSize: 16)),
                          close
                        ],
                      );
                    } else if (snapshot.hasData) {
                      String title, content;

                      if (snapshot.data == true) {
                        title = "Success! ";
                        content =
                            "Your request has been successfully executed.";
                        widget.updateParticipants();
                      } else {
                        title = "Failure. ";
                        content =
                            "Your request has failed. This may be due to the event" +
                                " recently locking, closing, or reaching max capacity";
                      }

                      return Column(
                        children: [
                          RichText(
                              text: TextSpan(
                                  text: (title),
                                  style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 20, color: Colors.black),
                                  children: [
                                TextSpan(
                                    text: content,
                                    style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 16, color: Colors.black))
                              ])),
                          close
                        ],
                      );
                    }
                  }
                  return Text('State: ${snapshot.connectionState}');
                }),
          )
        ],
      ),
    );
  }
}
