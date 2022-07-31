///
/// Displays event info and options.
///

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Data/AppData.dart';
import 'EventView_HTTP.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../Internal/APOM_Objects.dart';
import '../../Internal/ErrorHandler.dart';
import '../../Internal/URLHandler.dart';
import 'package:sizer/sizer.dart';
import '../../Data/UserData.dart';
import 'package:url_launcher/url_launcher.dart';

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
    print("changed participants");
    httpTags = MainUser.of(context).data.http.getHTTPTags();
    participantScrape = getParticipants(httpTags, widget.event.link);
    MainApp.of(context).maintenance.setBuildContext(context);

    super.didChangeDependencies();
  }

  // Refresh participants if HTTP previously failed
  void refreshParticipants() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          participantScrape = getParticipants(httpTags, widget.event.link);
        }));
  }

  // Update participants if join/leave occurred
  void updateParticipants() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          participantScrape = getParticipants(httpTags, widget.event.link);
        }));

    // If Home's event have been loaded, refresh Home
    Function? refresh = MainApp.of(context).maintenance.refreshHome;
    if (refresh != null) {
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilt scaffold");

    return Scaffold(
        backgroundColor:
            HSLColor.fromColor(widget.info.color).withLightness(0.9).toColor(),
        body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: ListView(
                padding: EdgeInsets.zero,
                physics: ClampingScrollPhysics(),
                children: [
                  SafeArea(
                    bottom: false,
                    child: Container(
                      margin: EdgeInsets.all(5),
                      height: 250,
                      color: Colors.transparent,
                      child: Stack(
                        children: [
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
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                                padding: EdgeInsets.only(left: 10, top: 15),
                                onPressed: () {
                                  MainApp.of(context)
                                      .maintenance
                                      .setBuildContext(null);
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
                      width: 100.w,
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
                                    refresh: refreshParticipants),
                              )
                            ],
                          ),
                          EventInfo(
                              bubbleColor: widget.info.color,
                              event: widget.event),
                          ParticipantList(scrape: participantScrape)
                        ],
                      ))
                ])));
  }
}

class Description extends StatelessWidget {
  final String desc;

  const Description({Key? key, required this.desc}) : super(key: key);

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
              child: MediaQuery.removePadding(
                  removeTop: true,
                  removeBottom: true,
                  context: context,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: 5, bottom: 5, right: 5),
                      child: LinkableText(
                        text: desc,
                        align: TextAlign.left,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  )),
            )
          ],
        ));
  }
}

class EventButtons extends StatefulWidget {
  final Future<List<dynamic>> scrape;
  final EventFull event;
  final Function update;
  final Function refresh;

  const EventButtons(
      {Key? key,
      required this.scrape,
      required this.event,
      required this.update,
      required this.refresh})
      : super(key: key);

  @override
  _EventButtonsState createState() => _EventButtonsState();
}

class _EventButtonsState extends State<EventButtons> {
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
            refresh: widget.refresh,
            size: 45,
          ),
          CalendarButton(
            event: widget.event,
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
  final Function refresh;
  final double size;

  const SignupButton(
      {Key? key,
      required this.scrape,
      required this.event,
      required this.update,
      required this.size,
      required this.refresh})
      : super(key: key);

  @override
  _SignupButtonState createState() => _SignupButtonState();
}

class _SignupButtonState extends State<SignupButton> {

  // Varies based on...
  // 1) if Event is locked/closed and 2) if User has joined or not
  EventButton getButton(int shiftID, int shifts) {
    if (widget.event.close != null &&
        widget.event.close!.compareTo(DateTime.now()) > 0) {
      if (shiftID != -1) {
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
                            MainUser.of(context).data.http.baseURL,
                            widget.event.id,
                            shiftID),
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
                builder: (context) => JoinDialog(
                    update: widget.update, event: widget.event, count: shifts));
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

  // Decide error Dialog based on String.
  void decipherError(String error) {
    switch (error) {
      case "Unstable network":
        Future.delayed(
            Duration.zero, () => _promptDialog("Unstable network", null));
        break;
      case "Not recognized":
        Future.delayed(Duration.zero,
            () => _promptDialog("Auth. error", "Not recognized"));
        break;
      default:
        Future.delayed(
            Duration.zero, () => _promptDialog("Parse error", error));
    }
  }

  void _promptDialog(String error, String? msg) {
    if (error == 'Unstable network') {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => HTTPRefreshDialog(
                refreshScrape: widget.refresh,
              ));
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => ErrorDialog(title: error, exception: msg));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: widget.scrape.timeout(Duration(seconds: 10),
            onTimeout: () => ["Unstable network"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            // Loading button.
            return EventButton(
              label: SizedBox.square(
                dimension: 25,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              ),
              callback: null,
              color: Colors.blue,
              size: widget.size,
            );
          } else {
            if (snapshot.hasData) { // Data is not null
              if (snapshot.data!.length != 1) {
                return getButton(
                    snapshot.data![0], snapshot.data![1].keys.length);
              }
              // Non-null error.
              decipherError(snapshot.data![0]);
            } else {
              // Null error.
              decipherError("Improper reload");
            }
          }

          return EventButton(
            label: Icon(FontAwesomeIcons.triangleExclamation,
                color: Colors.orange.shade600),
            callback: null,
            color: Colors.orange.shade200,
            size: widget.size,
          );
        });
  }
}

class CalendarButton extends StatelessWidget {
  final double size;
  final EventFull event;

  const CalendarButton({Key? key, required this.size, required this.event})
      : super(key: key);

  // Google Calendar URL with event data.
  String retrieveURL() {
    String url = 'https://calendar.google.com/calendar/u/0/r/eventedit?' +
        'text=${event.title.replaceAll(" ", "+")}';

    String dateText;
    if (event.start == null) {
      // If all day
      url += '&dates=${formatDateForCalendar(event.date)}' +
          '/${formatDateForCalendar(event.date.add(Duration(days: 1)))}';
    } else {
      url += '&dates=${formatDateForCalendar(event.start!)}' +
          '/${formatDateForCalendar(event.end!)}';
    }

    url += '&details=${encodeText(event.desc)}';
    url += '&location=${encodeText(event.loc)}';

    return url;
  }

  String formatDateForCalendar(DateTime date) {
    String text = date.toUtc().toString();
    text = text.substring(0, text.length - 5) + 'Z';

    return text.replaceAll('-', '').replaceAll(':', '').replaceAll(' ', 'T');
  }

  String encodeText(String input) {
    return input
        .replaceAll('\n', '%0D%0A')
        .replaceAll('"', '%26quot;')
        .replaceAll(' ', '+');
  }

  @override
  Widget build(BuildContext context) {
    return EventButton(
      label:
          Image.asset('assets/googleCalendarIcon.png', height: 35, width: 35),
      callback: () async {
        String url = retrieveURL();

        // Open link outside app.
        if (!await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $url';
        }
      },
      color: Colors.white,
      size: 45,
    );
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
                child: SelectableText(text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold))),
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

  bool listsAreEmpty(List<dynamic> lists) {
    for (List<dynamic> list in lists) {
      if (list.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  // H: Translate scrape into varying shift blocks.
  Widget retrieveShift(
      String title, Map<String, List<Participant>> participants) {
    List<String> titleParts = title.split(" ");

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 3)
          ]),
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15))),
            width: 100.w,
            padding: EdgeInsets.all(10),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(titleParts.sublist(0, 2).join(" "),
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  Text(titleParts.sublist(2).join(" "),
                      style: TextStyle(color: Colors.white, fontSize: 20))
                ],
              ),
            ),
          ),
          Column(
            children: retrieveTiles(participants),
          )
        ],
      ),
    );
  }

  // H: Translate scrape into varying participant tiles.
  List<Widget> retrieveTiles(Map<String, List<Participant>> participants) {
    List<Widget> tiles = [];

    if (listsAreEmpty(participants.values.toList())) {
      // No participants present.
      tiles.add(Container(
          padding: EdgeInsets.all(15),
          alignment: Alignment.center,
          child: Text(
            "No participants!",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15)),
              color: Colors.blue.shade50)));
    } else {
      List<Participant> active = participants['active']!;
      List<Participant>? waitlist = participants['waitlist'];

      // Add participants - Actives, then waitlist.
      if (waitlist == null) {
        // No indicator needed.
        for (int i = 0; i < active.length; i++) {
          tileColor = (i % 2 == 0) ? Colors.blue.shade50 : Colors.white;
          bool isRounded = (i == active.length - 1);

          tiles.add(ParticipantTile(
              contents: retrieveTileContent(active[i]),
              rounded: isRounded,
              color: tileColor));
        }
      } else {
        for (int i = 0; i < active.length; i++) {
          tileColor = (i % 2 == 0) ? Colors.blue.shade50 : Colors.white;

          tiles.add(ParticipantTile(
              contents: retrieveTileContent(active[i]),
              rounded: false,
              color: tileColor));
        }

        // Waitlist indicator.
        tiles.add(ParticipantTile(
            contents: getWaitlistContent(),
            rounded: waitlist.length == 0,
            color: Colors.grey.shade300));

        for (int i = 0; i < waitlist.length; i++) {
          tileColor = (i % 2 == 0) ? Colors.blue.shade50 : Colors.white;
          bool isRounded = (i == waitlist.length - 1);

          tiles.add(ParticipantTile(
              contents: retrieveTileContent(waitlist[i]),
              rounded: isRounded,
              color: tileColor));
        }
      }
    }

    return tiles;
  }

  // H: Format participant data in tile.
  Widget retrieveTileContent(Participant person) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(person.number!,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))
                  ],
                ),
                retrieveCarIcon(person)
              ],
            )),
        Flexible(
          child: Container(
            width: 135,
            alignment: Alignment.centerRight,
            child: person.comment != null
                ? Text(person.comment!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                : Container(),
          ),
        )
      ],
    );
  }

  // Waitlist indicator appearance.
  Widget getWaitlistContent() {
    return Row(
      children: [
        Text("Waitlist",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Container(
            padding: EdgeInsets.only(left: 15, right: 5),
            child: Icon(FontAwesomeIcons.triangleExclamation,
                color: Colors.deepOrangeAccent)),
        Flexible(
          child: Container(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Text(
                  "This event is full!\nSign up to be added to the waitlist.",
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54))),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: widget.scrape
          ..timeout(Duration(seconds: 10),
              onTimeout: () => ["Unstable network"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            // Loading screen.
            return Container(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.blue,
                ),
              ),
            );
          } else if (snapshot.hasData) { // Data is not null
            if (snapshot.data!.length != 1) {
              List<Widget> shifts = [];
              List<String> keys = snapshot.data![1].keys.toList();

              // If shifts are present, populate screen!
              if (keys.isNotEmpty) {
                for (int i = 0; i < keys.length; i++) {
                  String key = keys[i];
                  shifts.add(retrieveShift(key, snapshot.data![1][key]));
                }

                return Column(children: shifts);
              }
            }
          }
          return Container(
            height: 10.h,
            alignment: Alignment.center,
            child: Text(
              "No shifts found.",
              style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold),
            ),
          );
        });
  }
}

class ParticipantTile extends StatelessWidget {
  final Widget contents;
  final Color color;
  final bool rounded;

  ParticipantTile(
      {Key? key,
      required this.contents,
      required this.rounded,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        decoration: rounded
            ? BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15)),
                color: color)
            : BoxDecoration(color: color),
        padding: EdgeInsets.only(left: 10, right: 10),
        child: contents);
  }
}

class JoinDialog extends StatefulWidget {
  final Function update;
  final EventFull event;
  final int count;

  const JoinDialog(
      {Key? key,
      required this.update,
      required this.event,
      required this.count})
      : super(key: key);

  @override
  _JoinDialogState createState() => _JoinDialogState();
}

class _JoinDialogState extends State<JoinDialog> {
  TextEditingController controller = TextEditingController();
  late CupertinoTextField commentField;
  bool isDriving = false;
  Widget visibleSlider = Container();
  double canDrive = 0;
  int curShift = 0;

  @override
  void initState() {
    commentField = getCommentField();
    super.initState();
  }

  CupertinoTextField getCommentField() {
    return CupertinoTextField(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (commentField.selectionEnabled) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Container(
        color: Colors.transparent,
        width: 100.w,
        height: 100.h,
        child: AlertDialog(
          scrollable: true,
          contentPadding:
              EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
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
                widget.count > 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              width: 150,
                              child: Text(
                                "Which shift are you joining?",
                                maxLines: 2,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: DropdownButton2<int>(
                              dropdownWidth: 100,
                              dropdownOverButton: true,
                              scrollbarAlwaysShow: true,
                              dropdownMaxHeight: 150,
                              offset: Offset(-10, 50),
                              value: curShift,
                              underline: Container(
                                height: 2,
                                color: Colors.blue,
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  curShift = newValue!;
                                });
                              },
                              items: Iterable.generate(widget.count, (count) {
                                return DropdownMenuItem<int>(
                                  value: count,
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    child: Text(
                                      "Shift ${count + 1}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      )
                    : Container(),
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
                    height: 100, margin: EdgeInsets.all(5), child: commentField)
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
                                      MainUser.of(context)
                                          .data
                                          .http
                                          .getHTTPTags(),
                                      MainUser.of(context).data.http.baseURL,
                                      widget.event.id,
                                      controller.text,
                                      isDriving ? 1 : 0,
                                      canDrive.toInt(),
                                      curShift),
                                ));
                      },
                      size: 55,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ResultDialog extends StatefulWidget {
  final Function updateParticipants;
  final String actionName;
  final Future<String> result;

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

  Widget initCloseButton() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(15)),
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
            child: FutureBuilder<String>(
                future: widget.result.timeout(Duration(seconds: 10),
                    onTimeout: () => 'Unstable network'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.grey,
                      ),
                    );
                  } else {
                    String title, content;

                    if (snapshot.hasData) {
                      if (snapshot.data == 'success') {
                        title = "Success! ";
                        content =
                            "Your request has been successfully executed.";
                        widget.updateParticipants();
                      } else {
                        title = "Failure. ";

                        if (snapshot.data == 'Unstable network') {
                          content =
                              "Your request has failed due to an unstable network." +
                                  "Refresh to re-establish connection.";
                        } else {
                          content =
                              "Your request has failed. This may be due to the event" +
                                  " recently locking, closing, or reaching max capacity";
                        }
                      }
                    } else {
                      title = "Uncaught exception";
                      content = "The error could not be identified.";
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
                }),
          )
        ],
      ),
    );
  }
}
