import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'dart:math' as math;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SetState Delay Inconsistency',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController animation;
  int delayMs = 12;
  List<DateTime> buildTimes = [];

  @override
  Widget build(BuildContext context) {
    buildTimes.add(DateTime.now());
    if (buildTimes.length > 5) {
      buildTimes.removeAt(0);
    }
    final differences = buildTimes.sublist(1).mapIndexed((index, element) => element.difference(buildTimes[index]).inMilliseconds);
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: List.generate(
                20,
                (xi) => List.generate(
                  100,
                  (yi) => Positioned(
                    left: ((w / 15) * xi + animation.value * w) % w - 10,
                    top: ((h / 20) * yi) % h,
                    child: const Icon(
                      Icons.ac_unit,
                      color: Colors.red,
                    ),
                  ),
                ).toList(),
              ).flattened.toList().cast<Widget>() +
              <Widget>[
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(32),
                  child: Material(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => setState(() => delayMs--),
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${delayMs}ms',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () => setState(() => delayMs++),
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${differences.min}ms',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          '${differences.max}ms',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    animation = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animation.repeat();
    animation.addListener(() {
      Future.delayed(Duration(milliseconds: delayMs)).then(
        (value) => setState(() {}),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    animation.dispose();
  }
}
