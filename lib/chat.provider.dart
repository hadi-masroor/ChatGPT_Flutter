import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier{
  List<String> listChat =[];
  String textChat = '';
  //تابع اضافه کردن پیام به لیست چت
  void addListChat(String message){
    listChat.add(message);
    notifyListeners();
  }
}