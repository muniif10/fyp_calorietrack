import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:calorie_track/image_conversion_util.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(entryPoint, _receivePort.sendPort,
        debugName: _debugName);
    _sendPort = await _receivePort.first;
  }

  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }

  image_lib.Image preprocessImage(image_lib.Image image, List<int> inputShape) {
  // Resize the image to match the input shape of the model (e.g., 512x512)
  final int targetWidth = inputShape[1];
  final int targetHeight = inputShape[2];

  // Maintain aspect ratio and resize, then pad the rest of the image
  image_lib.Image resizedImage = image_lib.copyResizeCropSquare(image, size: min(targetWidth, targetHeight));

  return resizedImage;
}

List<List<List<List<double>>>> convertImageToInputMatrix(image_lib.Image image, bool normalize) {
  // Convert image to a matrix of shape [1, height, width, channels]
  final imageMatrix = List.generate(
    image.height,
    (y) => List.generate(
      image.width,
      (x) {
        final pixel = image.getPixel(x, y);
        // Normalize the pixel values to [0, 1] or based on model requirements
        if (normalize) {
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        } else {
          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        }
      },
    ),
  );

  // Add a batch dimension to the matrix (for a single image)
  return [imageMatrix];
}

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final InferenceModel isolateModel in port) {
      image_lib.Image? img;
      if (isolateModel.isCameraFrame()) {
        img = ImageUtils.convertCameraImage(isolateModel.cameraImage!);
      } else {
        img = isolateModel.image;
      }

      // resize original image to match model shape.
      image_lib.Image imageInput = image_lib.copyResize(
        img!,
        width: isolateModel.inputShape[1],
        height: isolateModel.inputShape[2],
        maintainAspect: true,
      );

      if (Platform.isAndroid && isolateModel.isCameraFrame()) {
        imageInput = image_lib.copyRotate(imageInput, angle: 90);
      }

      // final imageMatrix = List.generate(
      //   imageInput.height,
      //   (y) => List.generate(
      //     imageInput.width,
      //     (x) {
      //       final pixel = imageInput.getPixel(x, y);
      //       return [pixel.r, pixel.g, pixel.b];
      //     },
      //   ),
      // );

      final imageMatrix = List.generate(
        imageInput.height,
        (y) => List.generate(
          imageInput.width,
          (x) {
            final pixel = imageInput.getPixel(x, y);
            // Normalize the pixel values to [0, 1] or adjust based on model requirements
            return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
          },
        ),
      );

      // Set tensor input [1, 224, 224, 3]
      final input = [imageMatrix];
      // Set tensor output [1, 1001]
      // final output = [List<int>.filled(isolateModel.outputShape[1], 0)];
      final output = [List<double>.filled(isolateModel.outputShape[1], 0.0)];

      // // Run inference
      Interpreter interpreter =
          Interpreter.fromAddress(isolateModel.interpreterAddress);
      interpreter.run(input, output);
      // Get first output tensor
      final result = output.first;
      double maxScore = result.reduce((a, b) => a + b);
      // Set classification map {label: points}
      var classification = <String, double>{};
      List<double> softmax(List<double> logits) {
        double maxLogit = logits.reduce((a, b) => a > b ? a : b);
        List<double> exps =
            logits.map((logit) => exp(logit - maxLogit)).toList();
        double sumExps = exps.reduce((a, b) => a + b);
        return exps.map((exp) => exp / sumExps).toList();
      }

      // final probabilities = softmax(result);

      for (var i = 0; i < result.length; i++) {
        if (result[i] != 0) {
          // Set label: points
          classification[isolateModel.labels[i]] =
              result[i].toDouble() / maxScore.toDouble();
        }
      }
      isolateModel.responsePort.send(classification);
    }
  }
}

class InferenceModel {
  CameraImage? cameraImage;
  image_lib.Image? image;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel(this.cameraImage, this.image, this.interpreterAddress,
      this.labels, this.inputShape, this.outputShape);

  // check if it is camera frame or still image
  bool isCameraFrame() {
    return cameraImage != null;
  }
}
