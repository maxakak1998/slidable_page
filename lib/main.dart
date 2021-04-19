import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'slidable_page/slidable_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var data = [
  "https://i.imgur.com/tY3sbBZ.jpg",
  "https://cdn.shopify.com/s/files/1/0969/9128/products/Art_Poster_-_Sicario_-_Tallenge_Hollywood_Collection_47b4ca39-2fb6-45a2-9e85-d9ef34016e8a.jpg?v=1505078993",
  "https://m.media-amazon.com/images/M/MV5BMTU2NjA1ODgzMF5BMl5BanBnXkFtZTgwMTM2MTI4MjE@._V1_.jpg",
  "https://cdn-images-1.medium.com/max/1600/1*H-WYYsGMF4Wu6R0iPzORGg.png",
  "https://static01.nyt.com/images/2017/09/24/arts/24movie-posters1/24movie-posters1-jumbo.jpg",
];

double CHILD_ITEM_ASPECT_RATIO = 27.0 / 41.0;

double CHILD_ITEM_WRAPPER_ASPECT_RATIO = CHILD_ITEM_ASPECT_RATIO * 1.2;

class _MyHomePageState extends State<MyHomePage> {
  double currentPage = data.length - 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: PagerGestureDetector(
          pageCount: (data.length - 1).toDouble(),
          interval:new Duration(seconds: 2),
          builder: (currentPage) {
            return SlideWrapper<String>(
              data,
              currentPage,
              builder: (String value) => Image.network(
                value,
                fit: BoxFit.cover,
              ),
            );
          }),
    ));
  }
}

