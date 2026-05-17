abstract class LocalApiServerPlatform {
  bool get isSupported;
  bool get isRunning;
  int? get port;
  List<String> get urls;

  Future<void> start();
  Future<void> stop();
}
