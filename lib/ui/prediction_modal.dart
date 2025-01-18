import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class ImagePageWidget extends StatefulWidget {
  final String imagePath;
  final Function(List<Offset> coordinates)? onCoordinatesSelected;



  const ImagePageWidget({
    super.key,
    required this.imagePath,
    this.onCoordinatesSelected,
  });

  @override
  State<ImagePageWidget> createState() => _ImagePageWidgetState();
}

class _ImagePageWidgetState extends State<ImagePageWidget> {
  double _xInImage = 0;
  double _yInImage = 0;

  final List<Offset> selectedPoints = []; // Stores the selected points

  final _keyImage = GlobalKey();
  late double _originalWidth;
  late double _originalHeight;
  bool _imageLoaded = false; // Flag to track if dimensions are loaded

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    final image = FileImage(File(widget.imagePath));
    const config = ImageConfiguration();
    final completer = Completer<void>();

    image.resolve(config).addListener(
      ImageStreamListener((ImageInfo info, _) {
        _originalWidth = info.image.width.toDouble();
        _originalHeight = info.image.height.toDouble();
        setState(() {
          _imageLoaded = true;
        });
        completer.complete();
      }),
    );

    await completer.future;
    setState(() {}); // Trigger rebuild with image dimensions loaded
  }

  void _onTapDown(TapDownDetails details) {
    RenderBox imageRenderBox =
        _keyImage.currentContext!.findRenderObject() as RenderBox;

    final position = imageRenderBox.localToGlobal(Offset.zero);
    final relativeX = details.globalPosition.dx - position.dx;
    final relativeY = details.globalPosition.dy - position.dy;

    final scaleX = _originalWidth / imageRenderBox.size.width;
    final scaleY = _originalHeight / imageRenderBox.size.height;

    _xInImage = relativeX * scaleX;
    _yInImage = relativeY * scaleY;

    selectedPoints.add(Offset(_xInImage, _yInImage));

    // Trigger the callback

    // if (selectedPoints.length < 2) {
    //   selectedPoints.add(Offset(_xInImage, _yInImage));
    // } else {
    //   selectedPoints.clear();
    //   selectedPoints.add(Offset(_xInImage, _yInImage));
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (!_imageLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTapDown: _onTapDown,
              child: Center(
                child: Container(
                  key: _keyImage,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          // Container(
          //   color: Colors.grey[200],
          //   padding: const EdgeInsets.all(16.0),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text(
          //         'Coordinates Inside Image:',
          //         style: TextStyle(fontWeight: FontWeight.bold),
          //       ),
          //       Text(
          //           'X: ${_xInImage.toStringAsFixed(2)}, Y: ${_yInImage.toStringAsFixed(2)}'),
          //     ],
          //   ),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    selectedPoints.clear();
                  },
                  child: const Text("Clear selections")),
              ElevatedButton(
                  onPressed: () {
                    if (selectedPoints.length < 2) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text("You did not select at least two points"),
                          content: Text(
                              "Select the thumb first and then select any number of points of the food."),
                        ),
                      );
                      return;
                    } else {
                      // widget.onCoordinatesSelected!(selectedPoints);
                      Navigator.of(context).pop(selectedPoints);
                    }
                  },
                  child: const Text("Confirm")),
            ],
          )
        ],
      ),
    );
  }
}
