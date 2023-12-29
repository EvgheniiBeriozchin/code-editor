import 'package:desktop_code_editor/error_text.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'loading_animation.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController codeField = TextEditingController();
  late FocusNode focusNode;

  String output = "";
  String errorOutput = "";
  String filename = "foo.kts";
  bool isProgramRunning = false;
  List<int> previousRuntimes = [];

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  Future<void> runCode() async {
    setState(() {
      output = "";
      errorOutput = "";
      isProgramRunning = true;
    });

    final filepath = "./$filename";
    final file = File(filepath);
    file.writeAsString(codeField.text);

    DateTime startTime = DateTime.timestamp();
    final process =
        await Process.start("kotlinc", ["-script", filepath], runInShell: true);

    process.stdout.transform(utf8.decoder).forEach((element) {
      setState(() {
        output = output + element;
      });
    }).then((_) {
      DateTime endTime = DateTime.timestamp();

      setState(() {
        isProgramRunning = false;
        previousRuntimes.add(endTime.difference(startTime).inMilliseconds);
        if (previousRuntimes.length > 10) {
          previousRuntimes.removeAt(0);
        }
      });
    });

    process.stderr.transform(utf8.decoder).forEach((element) {
      setState(() {
        errorOutput = errorOutput + element;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Code Editor"),
      ),
      body: Row(
        children: [
          Column(children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                color: Colors.amber,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    focusNode: focusNode,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Insert you code here...',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    controller: codeField,
                  ),
                ),
              ),
            )
          ]),
          Column(children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isProgramRunning)
                        LoadingAnimation(
                            expectedRuntime: previousRuntimes.isEmpty
                                ? 5000
                                : previousRuntimes.reduce(
                                        (value, element) => value + element) /
                                    previousRuntimes.length),
                      Text(
                        output,
                        style: const TextStyle(color: Colors.white),
                      ),
                      ErrorText(
                          text: errorOutput,
                          code: codeField.text,
                          scriptName: filename,
                          moveToError: (position) {
                            focusNode.requestFocus();
                            codeField.selection = TextSelection.fromPosition(
                                TextPosition(offset: position));
                          })
                    ],
                  ),
                ),
              ),
            )
          ])
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: isProgramRunning ? null : runCode,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
