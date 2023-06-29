import 'package:flutter/material.dart';
import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  //Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // These futures belong to the state and are only initialized once,
  // in the initState method.
  late Future<Platform> platform;
  late Future<bool> isRelease;

  @override
  void initState() {
    super.initState();
    platform = api.platform();
    isRelease = api.rustReleaseMode();
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
            const Text("You're running on"),
            // To render the results of a Future, a FutureBuilder is used which
            // turns a Future into an AsyncSnapshot, which can be used to
            // extract the error state, the loading state and the data if
            // available.
            //
            // Here, the generic type that the FutureBuilder manages is
            // explicitly named, because if omitted the snapshot will have the
            // type of AsyncSnapshot<Object?>.
            FutureBuilder<List<dynamic>>(
              // We await two unrelated futures here, so the type has to be
              // List<dynamic>.
              future: Future.wait([platform, isRelease]),
              builder: (context, snap) {
                final style = Theme.of(context).textTheme.headlineMedium;
                if (snap.error != null) {
                  // An error has been encountered, so give an appropriate response and
                  // pass the error details to an unobstructive tooltip.
                  debugPrint(snap.error.toString());
                  return Tooltip(
                    message: snap.error.toString(),
                    child: Text('Unknown OS', style: style),
                  );
                }

                // Guard return here, the data is not ready yet.
                final data = snap.data;
                if (data == null) return const CircularProgressIndicator();

                // Finally, retrieve the data expected in the same order provided
                // to the FutureBuilder.future.
                final Platform platform = data[0];
                final release = data[1] ? 'Release' : 'Debug';
                final text = const {
                      Platform.Android: 'Android',
                      Platform.Ios: 'iOS',
                      Platform.MacApple: 'MacOS with Apple Silicon',
                      Platform.MacIntel: 'MacOS',
                      Platform.Windows: 'Windows',
                      Platform.Unix: 'Unix',
                      Platform.Wasm: 'the Web',
                    }[platform] ??
                    'Unknown OS';
                return Text('$text ($release)', style: style);
              },
            )
          ],
        ),
      ),
    );
  }
}
