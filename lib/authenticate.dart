import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:twisskey/timelinePage.dart';

class Authenticate extends StatelessWidget {
  const Authenticate({Key? key, required this.session}) : super(key: key);
  final String session;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: FutureBuilder<String?>(
              future: loginProcess(session,context),
              builder: (context,ss) {
                if (ss.hasData) {
                  String result = ss.data!;
                  return Text(result);
                } else {
                  return  const Text("取得に失敗しました。", style: TextStyle(fontSize: 30,),);
                }
              }
          )
      ),
    );
  }
  Future<String> loginProcess(sessionKey,context) async {
    if (kDebugMode) {
      print("LoginProcess");
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final instance = prefs.getString("host");
    final Uri uri = Uri.parse("https://$instance/api/miauth/$sessionKey/check");
    final response = await http.post(uri);
    final String res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    if (map["ok"] == true) {
      var accountPos = (prefs.getInt('counter') ?? 0);
      if (accountPos == 0) {
        prefs.setInt("counter", 1);
        prefs.setInt("selection", 1);
        prefs.setString("1", map["token"]);
      }
      Fluttertoast.showToast(msg: "ログインしました");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const TimelinePage()));
      return "";
    } else {
      //arb: failed_login
      return "ログインに失敗しました";
    }
  }
}