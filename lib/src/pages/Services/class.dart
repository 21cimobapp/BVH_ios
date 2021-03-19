/// The [dart:async] is neccessary for using streams
import 'dart:async';
import 'paramcombine1.dart';
import 'package:flutter/material.dart';
import 'Firebase_firestore_service.dart';

class CartItemsBloc with ChangeNotifier {
  //List<ParametFirestore> allData = [];

  FirebaseFirestoreService db =
      new FirebaseFirestoreService(); ////firestore services accessible by creating object
  //List<Need> allData;
  List<ParametFirestore> items = new List();

  /// important step for tag to update on homepage

  //  var value1="";

  List<ParametFirestore> allData1 = [];

  /// The [cartStreamController] is an object of the StreamController class
  /// .broadcast enables the stream to be read in multiple screens of our app
  final cartStreamController = StreamController.broadcast();

  /// The [getStream] getter would be used to expose our stream to other classes
  Stream get getStream => cartStreamController.stream;

  var total; //// to add the cost of tests

  addToCart(item) {
    //allItems['shop items'].remove(item);
    allData1.add(item);
    //db.updateset2(item); //// will update to firestoreDB
    //totalCount++;
    cartStreamController.sink.add(allData1);
  }

  void removeFromCart(item) {
    allData1.remove(item);
    //db.updateset1(item);
    // totalCount--;
    //allItems['shop items'].add(item);
    cartStreamController.sink.add(allData1);
    notifyListeners();
  }

  List<String> empdata = [
    'data',
    'data',
    'dfg',
    'da',
    'fg',
    'df',
    'fdg',
    'fdg',
    'gfd',
  ];

  /// The [dispose] method is used
  /// to automatically close the stream when the widget is removed from the widget tree
  void dispose() {
    cartStreamController.close(); // close our StreamController
  }

//int sum=0;
//_onChanged()
  List storedat = [];
  var count = -1;
  var i;
  bool isVisible = false;
  _onChanged() {
    if (bloc.allData1 != null) {
      for (i = 0; i < bloc.allData1.length; i++) {
        if (items[i] == allData1[i]) {
          //  setState(() // =>
          //    {
          count = i;
          // if(count==j){
          //_value = 'added';
          //visiblecheck(j);
          // isVisible = true;
          //}

          //});
        }
      }
    }
  }

  void pressFavorite(item) {
    if (isSaved(item)) {
      //  sum=0;
      // allData1.clear();
      // totalCount++;
      // _onChanged();
      //allData1.remove(item);
      allData1.removeWhere((element) => element.id == item.id);
      //swap(item);

      // isVisible=false;
      // _onChanged1();
      // _onChanged();
      // for (i = 0; i < bloc.allData1.length; i++) {
      /* if (item) {
      isVisible=false;
      }  */
      // }
      // db.updateset2(item);
      //db.updateNote(item);
    } else {
      //totalCount--;
      //  _onChanged();
      allData1.add(item);
      //swap(item);

      //  isVisible=true;
      //  _onChanged();
      // allData1.add(isVisible);
      //  for (i = 0; i < bloc.allData1.length; i++) {
      /*  if (item) {
      isVisible=true;
      } */
      // }
      // db.updateset1(item);

    }
  }

//var i;
  var flag = 0;

  // void pressFavorite1(item) {
  //   if (isSaved(item)) {
  //     //  sum=0;
  //     // allData1.clear();
  //     // totalCount++;
  //     // allData1.remove(item);
  //     db.updateset2(item);
  //     //db.updateNote(item);
  //   } else {
  //     //totalCount--;
  //     // allData1.add(item);
  //     db.updateset1(item);
  //   }
  // }

  bool isSaved(selectedItem) {
    final item = bloc.allData1
        .firstWhere((element) => element.id == selectedItem.id, orElse: () {
      return null;
    });
    if (item == null)
      return false;
    else
      return true;
  }
}

final bloc = CartItemsBloc();
