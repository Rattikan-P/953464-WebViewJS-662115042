import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView JS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'RATTIKAN WebView JS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _controller;
  String totalFromJS = ""; // Store data received from JS

  @override
  void initState() {
    super.initState();
    
    // 1: Setup WebView and load HTML
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      
      // 2: Receive JS through FlutterChannel
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            totalFromJS = message.message;
          });
        },
      )
      ..loadFlutterAsset('assets/challenge_webview.html');
  }

  // 3: Send data to JS
  void sendDataToJS() {
    if (totalFromJS.isNotEmpty) {
      int currentTotal = int.parse(totalFromJS);
      int newTotal = currentTotal + 100;
      _controller.runJavaScript('updateTotalFromFlutter($newTotal)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // WebView Area
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          
          // 2: Show data received from JS
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[200],
            width: double.infinity,
            child: Center(
              child: Text(
                'Received from JS: ${totalFromJS.isEmpty ? "-" : "\$$totalFromJS"}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          // 3: Button to send data to JS
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.blue[50],
            width: double.infinity,
            child: ElevatedButton(
              onPressed: totalFromJS.isEmpty ? null : sendDataToJS,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Send +100 total from Flutter to JS',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}