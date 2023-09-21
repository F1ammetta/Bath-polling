import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:html';

bool voted = document.cookie!.isNotEmpty;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

const brandColor = Color(0XFF3BDFEB);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // set the dark color scheme
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: brandColor,
        secondary: brandColor,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return MaterialApp(
      title: 'Hueleobo',
      theme: darkTheme,
      home: const MyHomePage(title: 'Hueleobo'),
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

  var selected_date = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    String date = DateTime.now().toString().substring(0, 10);
    checkIfDocExists(date).then((value) => {
      if (!value) {
        FirebaseFirestore.instance
            .collection('stats')
            .doc(date)
            .set({'si': 0, 'no': 0, 'balde': 0})
      }
    });
  }


  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('stats');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  void update_stats_si() {
    String date = DateTime.now().toString().substring(0, 10);
    if (document.cookie!.contains(date)) {
      setState(() {
        voted = true;
      });
      return;
    }

    checkIfDocExists(date).then((value) => {
      if (value) {
        FirebaseFirestore.instance
            .collection('stats')
            .doc(date)
            .update({'si': FieldValue.increment(1)})
      } else {
        FirebaseFirestore.instance
            .collection('stats')
            .doc(date)
            .set({'si': 1})
      }
    });
    document.cookie = '$date=si; $document.cookie';

  }

  void update_stats_no() {
    String date = DateTime.now().toString().substring(0, 10);
    if (document.cookie!.contains(date)) {
      setState(() {
        voted = true;
      });
      return;
    }

    checkIfDocExists(date).then((value) => {
      if (value) {
        FirebaseFirestore.instance
            .collection('stats')
            .doc(date)
            .update({'no': FieldValue.increment(1)})
      } else {
        FirebaseFirestore.instance
            .collection('stats')
            .doc(date)
            .set({'no': 1})
      }
    });
        document.cookie = '$date=no; $document.cookie';
  }
  Widget calendarButton(){
    return IconButton(
        onPressed: () => {
        showDatePicker(
            context: context,
            initialDate: selected_date,
            firstDate: DateTime(2021),
            lastDate: DateTime(2024),
            // builder: (context, child) {
            //   return Center(
            //     child: child,
            //   );
            // },
            ).then((value) => {
              if (value != null)
              {
              setState(() {
                  selected_date = value;
                  }),
              Navigator.pop(context),
              show_stats(context)
              }
              })

        }, icon: const Icon(Icons.calendar_today),
      );
  }
void show_stats(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('stats').doc(selected_date.toString().substring(0, 10)).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data!.data() == null) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    calendarButton(),
                    const SizedBox(height: 20),
                   Text(
                    'No hay datos para este día',
                    style: Theme.of(context).textTheme.headlineSmall ??
                        const TextStyle(
                          fontFamily: 'arial',
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ],
                ),
              );
            }
            var doc = snapshot.data!.data()!;
            return Container(
              height: 250,
              child: Column(
                children: doc.isNotEmpty ? [
                  const SizedBox(height: 20),
                  calendarButton(),
                  const SizedBox(height: 20),
                  Text(
                    'Si: ${doc['si']}',
                    style: Theme.of(context).textTheme.headlineSmall ??
                        const TextStyle(
                          fontFamily: 'arial',
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No: ${doc['no']}',
                    style: Theme.of(context).textTheme.headlineSmall ??
                        const TextStyle(
                          fontFamily: 'arial',
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Balde: ${doc['balde']}',
                    style: Theme.of(context).textTheme.headlineSmall ??
                        const TextStyle(
                          fontFamily: 'arial',
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                ]: [
                  const Text('No hay datos'),
                ],
              ),
            );
          },
        );
      });
}

  void update_stats_balde() {
    String date = DateTime.now().toString().substring(0, 10);
    if (document.cookie!.contains(date)) {
      setState(() {
        voted = true;
      });
      return;
    }
    checkIfDocExists(date).then((value) => {
      if (value) {
        FirebaseFirestore.instance
            .collection('stats')
            .doc(date)
            .update({'balde': FieldValue.increment(1)})
      } else {
        FirebaseFirestore.instance
            .collection('stats')
            .doc(date)
            .set({'balde': 1})
      }
    });
        document.cookie = '$date=balde; $document.cookie';
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 200),
              Center(
                child: Text(
                  'Te bañaste hoy?',
                  style: Theme.of(context).textTheme.headlineMedium ??
                      const TextStyle(
                        fontFamily: 'arial',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => update_stats_si(),
                    child: const Text('Si'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => update_stats_no(),
                    child: const Text('No'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => update_stats_balde(),
                  child: const Text('Con balde'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  voted ? 'Ya votaste' : '',
                  style: Theme.of(context).textTheme.headlineSmall ??
                      const TextStyle(
                        fontFamily: 'arial',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => show_stats(context),
            tooltip: 'stats',
            child: const Icon(Icons.bar_chart)));
  }
}

