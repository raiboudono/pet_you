import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

final confettiPlayProvider =
    Provider((ref) => ConfettiController(duration: const Duration(seconds: 5)));

class Confetti extends ConsumerStatefulWidget {
  const Confetti({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ConfettiState();
}

class ConfettiState extends ConsumerState<Confetti> {
  late ConfettiController _controllerCenter;
  // late ConfettiController _controllerCenterRight;
  // late ConfettiController _controllerCenterLeft;
  // late ConfettiController _controllerTopCenter;
  // late ConfettiController _controllerBottomCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ref.read(confettiPlayProvider);
    // _controllerCenterRight =
    //     ConfettiController(duration: const Duration(seconds: 10));
    // _controllerCenterLeft =
    //     ConfettiController(duration: const Duration(seconds: 10));
    // _controllerTopCenter =
    //     ConfettiController(duration: const Duration(seconds: 10));
    // _controllerBottomCenter =
    //     ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    // _controllerCenter.dispose();
    // _controllerCenterRight.dispose();
    // _controllerCenterLeft.dispose();
    // _controllerTopCenter.dispose();
    // _controllerBottomCenter.dispose();
    super.dispose();
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      // displayTarget: false,
      gravity: 0.05,
      confettiController: _controllerCenter,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      colors: [
        Colors.greenAccent.shade100,
        Colors.blueAccent.shade100,
        Colors.pinkAccent.shade100,
        Colors.orangeAccent.shade100,
        Colors.purpleAccent.shade100
      ],
      createParticlePath: drawStar,
    );
  }
}
