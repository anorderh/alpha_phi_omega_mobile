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