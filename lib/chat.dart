import 'package:chatgpt/chat.provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {  
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController scrollController = ScrollController();
  TextEditingController controllerTextField =TextEditingController();
  double sizeChat = 0.60;
  double sizeText = 0.07;

  @override
  void initState() {
    super.initState();
    // اسکرول به انتها هنگام بارگذاری اولیه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  void sendMessageNormal() {
    context.read<ChatProvider>().addListChat(controllerTextField.text);
    controllerTextField.clear();
    // اسکرول به انتها پس از افزودن آیتم جدید
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
  ///////////////////////////////////////////////////////////////////////////////////////
  
  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;
    context.read<ChatProvider>().addListChat(message);
    controllerTextField.clear();


    // ارسال پیام به API
    final response = await fetchGPTResponse(message);
    context.read<ChatProvider>().addListChat(response);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }


Future<String> fetchGPTResponse(String prompt) async {
  const apiKey = 'API-KEY'; //  جایگزین با مقدار اصلی API Key 
  const url = 'https://api.openai.com/v1/chat/completions';
  Dio dio = Dio(); // ایجاد نمونه Dio
    try {
      // ارسال درخواست POST با استفاده از Dio
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'تو یک دستیار فارسی هستی و باید پاسخ‌هایت را به زبان فارسی بدهی.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );
      // بررسی وضعیت موفقیت آمیز بودن درخواست
      if (response.statusCode == 200) {
        final data = response.data;
        return data['choices'][0]['message']['content'].toString();
      } else {
        throw Exception('خطا در دریافت پاسخ از API');
      }
    } catch (e) {
      // مدیریت خطاها
      print('Error: $e');
      return 'خطا در برقراری ارتباط با سرور.';
    }
}
  ////////////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        
        appBar: AppBar(
          title: Text('ChatGpt'),
          backgroundColor: Colors.orange.withOpacity(0.3),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            children: [
              SizedBox(height: 4),
              Container(
                height: MediaQuery.of(context).size.height * sizeChat,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red.withOpacity(0.7),
                  border: Border.all(width: 2, color: Colors.yellow),
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: context.watch<ChatProvider>().listChat.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.white),
                        child:
                         Text(
                          textAlign: TextAlign.end, // یا TextAlign.center یا TextAlign.end
                          context.watch<ChatProvider>().listChat[index],
                          style: TextStyle(fontSize: 18),
                          softWrap: true,  // فعال کردن رفتن به خط بعدی
                          overflow: TextOverflow.visible,  // نمایش متن در صورتی که فضای کافی باشد
                          maxLines: null,  // اجازه می‌دهد متن بیشتر از یک خط باشد
                                                     ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 4),
              Container(
                height: MediaQuery.of(context).size.height * sizeText,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green.withOpacity(0.3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline, // استفاده از دکمه "Enter" برای افزودن خط جدید
                        controller: controllerTextField,
                        decoration: InputDecoration(
                          hintText: 'Send Message..',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.chat,color: Colors.black.withOpacity(0.8),),
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      //onPressed: () => sendMessageNormal(), //حالت اول: استفاده از هوش مصنوعی
                      onPressed: () => sendMessageNormal(),  // حالت دوم: چت بدون هوش مصنوعی
                      icon: Icon(Icons.send,color: Colors.black.withOpacity(0.8),),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
