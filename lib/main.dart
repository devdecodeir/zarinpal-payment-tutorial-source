import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zarinpal/zarinpal.dart';
import 'package:zarinpalt/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  PaymentRequest paymentRequest = PaymentRequest();
  late StreamSubscription sub;
  String recievedLink = '';

  @override
  void initState() {
    super.initState();

    sub = linkStream.listen((String? link) {
      recievedLink = link!;
      if (recievedLink.toLowerCase().contains('status')) {
        // https://devdecode.ir/?Authority=000000000000000000000000000001042590&Status=OK
        String status = recievedLink.split('=').last;
        String authority =
            recievedLink.split('?')[1].split('&')[0].split('=')[1];
        ZarinPal().verificationPayment(status, authority, paymentRequest,
            (isPaymentSuccess, refID, paymentRequest) {
          if (isPaymentSuccess) {
            debugPrint('Success');
          } else {
            debugPrint('Error');
          }
        });
      }
    }, onError: (err) {
      debugPrint(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          paymentRequest
            ..setIsSandBox(true)
            ..setAmount(10000)
            ..setDescription('payment description')
            ..setMerchantID(MERCHENTID)
            ..setCallbackURL('https://devdecode.ir');
          ZarinPal().startPayment(paymentRequest,
              (int? status, String? paymentGatewayUri) {
            if (status == 100) {
              launchUrl(Uri.parse(paymentGatewayUri!),
                  mode: LaunchMode.externalApplication);
            }
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
