import 'package:firebase_database/firebase_database.dart';
import 'apo_objects.dart';

final databaseRef = FirebaseDatabase.instance.ref();

void checkBrother(String name, String email, String imageUrl) async {
  DataSnapshot snapshot = await databaseRef.child('data/brothers/$name').get();

  if (!snapshot.exists) {
    Map<String, String> brotherInfo = {'email': email, 'imageUrl': imageUrl};
    databaseRef.child('data/brothers/$name').set(brotherInfo);
  }
}

Future<Map<String, Map<String, String>>> getTotalBrothers() async {
  Map<String, Map<String, String>> result = {};
  DataSnapshot snapshot = await databaseRef.child('data/brothers').get();

  for (DataSnapshot nameLvl in snapshot.children) {
    Map<String, String> info = {};

    for (DataSnapshot infoLvl in nameLvl.children) {
      info[infoLvl.key!] = infoLvl.value as String;
    }
    result[nameLvl.key!] = info;
  }

  return result;
}