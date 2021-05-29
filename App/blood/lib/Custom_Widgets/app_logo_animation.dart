import 'package:rive/rive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Rive artboard
class RiveAnimation extends StatefulWidget {
  final bool paused;

  const RiveAnimation({Key key, this.paused = false}) : super(key: key);
  @override
  _RiveAnimationState createState() => _RiveAnimationState();
}

class _RiveAnimationState extends State<RiveAnimation> {
  Artboard _riveArtboard;
  RiveAnimationController _controller;
  void initState() {
    super.initState();
    // Load the animation file from the bundle
    rootBundle.load('assets/blood_donation.riv').then(
      (data) async {
        final file = RiveFile();

        // Load the RiveFile from the binary data.
        if (file.import(data)) {
          final artboard = file.mainArtboard;
          // add controller to rive artboard
          artboard.addController(_controller = SimpleAnimation('idle'));
          setState(() {
            _riveArtboard = artboard;
          });
        }
        if (widget.paused) _controller.isActive = false;
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _riveArtboard == null
        ? const CircularProgressIndicator()
        : Rive(artboard: _riveArtboard);
  }
}
