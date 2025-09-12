import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class ShowSnackBar{
  Future<void> success({String title = '', String message = '', BuildContext? context}) async {
    Padding(padding: EdgeInsets.all(16),
    child: SizedBox(width: 200,
    child: 
    await Flushbar(
          backgroundColor: Colors.green,
          title: title,
          message: message,
          icon: Icon(Icons.check, color: Colors.white,),
          flushbarPosition: FlushbarPosition.TOP,
          borderRadius: BorderRadius.circular(20),
          duration: Duration(seconds: 3),
          maxWidth: MediaQuery.of(context!).size.width - 50 ,
          boxShadows: [
            BoxShadow(
              blurRadius: 1,
              spreadRadius: 1,
              color: Colors.black.withValues(alpha: 0.2)
            )
          ],
          
        ).show(context)));
  }
  Future<void> warning({String title = '', String message = '', BuildContext? context}) async {
    Padding(padding: EdgeInsets.all(16),
    child: 
    await Flushbar(
          backgroundColor: Colors.red,
          title: title,
          message: message,
          icon: Icon(Icons.dangerous, color: Colors.white,),
          flushbarPosition: FlushbarPosition.TOP,
          borderRadius: BorderRadius.circular(20),
          duration: Duration(seconds: 3),
          maxWidth: MediaQuery.of(context!).size.width - 50 ,
          boxShadows: [
            BoxShadow(
              blurRadius: 1,
              spreadRadius: 1,
              color: Colors.black.withValues(alpha: 0.2)
            )
          ],
        ).show(context));
  }
}