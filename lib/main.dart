import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFFFF6688),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildTextButton(String title, bool isOnLight) {
    return FlatButton(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: isOnLight ? Theme.of(context).primaryColor : Colors.white),
      ),
      onPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          actions: <Widget>[_buildTextButton('settings'.toUpperCase(), true)],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  _buildTextButton('more', false),
                  Expanded(
                    child: Container(),
                  ),
                  _buildTextButton('stats', false)
                ],
              ),
            )
          ],
        ));
  }
}
