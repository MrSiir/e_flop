import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:e_flop/ui/search_bar.dart';
import 'package:e_flop/ui/game_list.dart';

void main() {
  runApp(EFlopApp());
}

class EFlopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: MaterialApp(
      title: 'eFlop',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EFlopHomePage(),
    ));
  }
}

class EFlopHomePage extends StatefulWidget {
  EFlopHomePage({Key? key}) : super(key: key);
  @override
  _EFlopHomePageState createState() => _EFlopHomePageState();
}

class _EFlopHomePageState extends State<EFlopHomePage> {
  GlobalKey<GameListState> _keyGameList = GlobalKey();
  bool _inSearch = false;
  bool _onlyDiscounts = false;

  late final FirebaseMessaging _messaging;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    registerNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_inSearch) ...{
              SearchBar(
                onChanged: (value) {
                  _keyGameList.currentState?.updateSearchTerm(value);
                },
              ),
            },
            Expanded(
                child: RefreshIndicator(
              onRefresh: () => Future.sync(
                () => _keyGameList.currentState?.refreshPagedList(),
              ),
              child: GameList(key: _keyGameList),
            )),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: new Row(
          children: <Widget>[
            IconButton(
              tooltip: 'Buscador',
              color: _inSearch ? Colors.white : Colors.grey,
              iconSize: 32.0,
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _inSearch = !_inSearch;
                  if (!_inSearch) {
                    _keyGameList.currentState?.updateSearchTerm('');
                  }
                });
              },
            ),
            Spacer(),
            Text('Solo ofertas',
                style: TextStyle(
                    color: _onlyDiscounts ? Colors.white : Colors.grey,
                    fontSize: 16.0)),
            Switch(
              value: _onlyDiscounts,
              onChanged: (value) {
                setState(() {
                  _onlyDiscounts = value;
                });
                _keyGameList.currentState?.updateDiscount(_onlyDiscounts);
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.green[200],
              inactiveTrackColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    String? _token = await _messaging.getToken();

    print("******************************************************************");
    print("FirebaseMessaging token: $_token");
    print("******************************************************************");

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        showNotification(initialMessage);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        showNotification(message);
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'launch_background',
          ),
        ),
      );
    }
  }
}

// Background
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
