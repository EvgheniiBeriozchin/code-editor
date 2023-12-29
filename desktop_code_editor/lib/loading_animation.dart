import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key, required this.expectedRuntime});

  final double expectedRuntime;

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool controllerRanOnce = false;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.expectedRuntime.toInt() + 1),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double numSeconds =
        ((1 - controller.value) * widget.expectedRuntime / 1000);
    if (numSeconds - 0 <= 0.01) {
      setState(() {
        controllerRanOnce = true;
      });
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: controller.value,
              semanticsLabel: 'Loading buttons',
              color: Colors.amber,
            ),
            Text(
              "Estimated time remaining: ${controllerRanOnce ? 0 : numSeconds.toStringAsFixed(3)} s",
              style: const TextStyle(color: Colors.amber),
            )
          ],
        ),
      ),
    );
  }
}
