import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'paramcombine1.dart';

//final CollectionReference noteCollection = Firestore.instance.collection('TestLab').orderBy('TestName');
//Query noteCollection = Firestore.instance.collection("TestLab").orderBy('TestName');

class FirebaseFirestoreService {
  static final FirebaseFirestoreService _instance =
      new FirebaseFirestoreService.internal();

  factory FirebaseFirestoreService() => _instance;

  FirebaseFirestoreService.internal();

  /* Future<ParametFirestore> createNote(String TestName, String Price, String ImagePath) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
     // final DocumentSnapshot ds = await tx.get(noteCollection.document());

      final ParametFirestore note = new ParametFirestore(ds.documentID, TestName, Price, ImagePath);
     // final ParametFirestore note = new ParametFirestore(ds.documentID, TestName, Price, ImagePath);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    }; 

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return ParametFirestore.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  } */

  Stream<QuerySnapshot> getNoteList({int offset, int limit}) {
    //Stream<QuerySnapshot> snapshots = noteCollection.snapshots();
    Stream<QuerySnapshot> snapshots =
        Firestore.instance.collection("Services").orderBy('order').snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  // void updateset1(ParametFirestore note) async {
  //   // var firebaseUser = await FirebaseAuth.instance.currentUser();
  //   // firestoreInstance.collection("users").document(firebaseUser.uid).setData(
  //   /* firestoreInstance
  //       .collection("users")
  //       .document(firebaseUser.uid)
  //       .updateData({"age": 60}).then((_) {
  //     print("success!");
  //   }); */
  //   // Firestore.instance.collection("TestLab").document(note.TestName).updateData(
  //   Firestore.instance.collection("Services").document(note.name).updateData({
  //     "tag": ""
  //     /*  "age" : 50,
  //   "email" : "example@example.com",
  //   "address" : {
  //     "street" : "street 24",
  //     "city" : "new york"
  //   }*/
  //   }).then((_) {
  //     print("success!");
  //   });
  // }

  // void updateset2(ParametFirestore note) async {
  //   // var firebaseUser = await FirebaseAuth.instance.currentUser();
  //   // firestoreInstance.collection("users").document(firebaseUser.uid).setData(
  //   /* firestoreInstance
  //       .collection("users")
  //       .document(firebaseUser.uid)
  //       .updateData({"age": 60}).then((_) {
  //     print("success!");
  //   }); */
  //   Firestore.instance.collection("Services").document(note.name).updateData({
  //     "tag": "added"
  //     /*  "age" : 50,
  //   "email" : "example@example.com",
  //   "address" : {
  //     "street" : "street 24",
  //     "city" : "new york"
  //   }*/
  //   }).then((_) {
  //     print("success!");
  //   });
  // }

  Future<dynamic> updateNote(ParametFirestore note) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(
          Firestore.instance.collection("Services").document(note.TestName));

      await tx.update(ds.reference, note.toMap());
      return {'updated': true};
    };

    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  Future<dynamic> deleteNote(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(Firestore.instance.collection('Services').document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }
}
