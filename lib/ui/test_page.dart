import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(Daggot());

class Daggot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageTouchScreen(),
    );
  }
}

class ImageTouchScreen extends StatefulWidget {
  @override
  _ImageTouchScreenState createState() => _ImageTouchScreenState();
}

class _ImageTouchScreenState extends State<ImageTouchScreen> {
  Offset? firstPoint;
  Offset? secondPoint;
  GlobalKey imageKey = GlobalKey();
  String imagePath = 'assets/images/image.jpeg'; // Replace with your image path

  /// Maps touch position to image coordinates, considering scaling and padding
  Future<Offset?> _getNormalizedPosition(TapDownDetails details) async {
    final RenderBox? renderBox = imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final Size widgetSize = renderBox.size; // Rendered size of the image widget
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    // Calculate the actual image rendering size
    final ImageProvider imageProvider = AssetImage(imagePath);
    final ImageStream imageStream = imageProvider.resolve(ImageConfiguration.empty);
    final Completer<Size> completer = Completer();

    imageStream.addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;

    // Calculate scaling factors
    final double scale = widgetSize.aspectRatio > imageSize.aspectRatio
        ? widgetSize.height / imageSize.height
        : widgetSize.width / imageSize.width;

    // Calculate blank space (padding) around the image
    final double dxPadding = (widgetSize.width - imageSize.width * scale) / 2;
    final double dyPadding = (widgetSize.height - imageSize.height * scale) / 2;

    // Normalize the coordinates to the image space
    final double normalizedX = (localPosition.dx - dxPadding) / scale;
    final double normalizedY = (localPosition.dy - dyPadding) / scale;

    if (normalizedX < 0 ||
        normalizedY < 0 ||
        normalizedX > imageSize.width ||
        normalizedY > imageSize.height) {
      return null; // Touch is outside the visible image
    }

    return Offset(normalizedX, normalizedY);
  }

  void showCoordinatesModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Selected Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Image.asset(imagePath, key: GlobalKey(), fit: BoxFit.contain),
                if (firstPoint != null)
                  Positioned(
                    left: firstPoint!.dx - 5,
                    top: firstPoint!.dy - 5,
                    child: Icon(Icons.circle, color: Colors.red, size: 10),
                  ),
                if (secondPoint != null)
                  Positioned(
                    left: secondPoint!.dx - 5,
                    top: secondPoint!.dy - 5,
                    child: Icon(Icons.circle, color: Colors.blue, size: 10),
                  ),
              ],
            ),
            SizedBox(height: 20),
            if (firstPoint != null)
              Text('First Point: (${firstPoint!.dx.toStringAsFixed(2)}, ${firstPoint!.dy.toStringAsFixed(2)})'),
            if (secondPoint != null)
              Text('Second Point: (${secondPoint!.dx.toStringAsFixed(2)}, ${secondPoint!.dy.toStringAsFixed(2)})'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Touch Points')),
      body: Center(
        child: GestureDetector(
          onTapDown: (TapDownDetails details) async {
            final Offset? normalizedOffset = await _getNormalizedPosition(details);

            if (normalizedOffset != null) {
              setState(() {
                if (firstPoint == null) {
                  firstPoint = normalizedOffset;
                } else if (secondPoint == null) {
                  secondPoint = normalizedOffset;
                } else {
                  firstPoint = normalizedOffset;
                  secondPoint = null; // Reset second point for new selection
                }
              });
            }
          },
          child: Image.asset(
            imagePath,
            key: imageKey,
            fit: BoxFit.contain,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (firstPoint != null && secondPoint != null) {
            showCoordinatesModal(context);
          }
        },
        child: Icon(Icons.info),
      ),
    );
  }
}
