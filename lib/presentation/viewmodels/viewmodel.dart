import 'package:flutter/cupertino.dart';

class ViewModel with ChangeNotifier{
  var _ready = true;

  get ready => _ready;

  setBusy(){
    _ready = false;
    notifyListeners();
  }

  setReady(){
    _ready = true;
    notifyListeners();
  }
}