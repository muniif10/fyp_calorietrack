import 'package:logger/logger.dart';

class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  // Static instance of Logger
  static final Logger _instance = Logger();

  // Public getter to access the logger instance
  static Logger get instance => _instance;
}
