import 'dart:async';
import 'dart:typed_data';
import '../models/chunk.dart';

enum BluetoothState { off, on, connected, disconnected }

class BluetoothDevice {
  final String id;
  final String name;
  final int signalStrength;
  bool isConnected;

  BluetoothDevice({
    required this.id,
    required this.name,
    required this.signalStrength,
    this.isConnected = false,
  });
}

class BluetoothService {
  BluetoothState _state = BluetoothState.off;
  final List<BluetoothDevice> _nearbyDevices = [];
  final StreamController<List<BluetoothDevice>> _devicesController =
      StreamController.broadcast();
  final StreamController<Chunk> _receivedChunkController =
      StreamController.broadcast();

  BluetoothState get state => _state;
  List<BluetoothDevice> get nearbyDevices => _nearbyDevices;
  Stream<List<BluetoothDevice>> get devicesStream =>
      _devicesController.stream;
  Stream<Chunk> get receivedChunkStream =>
      _receivedChunkController.stream;

  // تشغيل البلوتوث
  Future<bool> enable() async {
    _state = BluetoothState.on;
    return true;
  }

  // البحث عن الأجهزة القريبة
  Future<void> startScan() async {
    _nearbyDevices.clear();
    // سيتم ربطه بالبلوتوث الحقيقي لاحقاً
    _devicesController.add(_nearbyDevices);
  }

  // إيقاف البحث
  void stopScan() {}

  // الاتصال بجهاز
  Future<bool> connectToDevice(BluetoothDevice device) async {
    device.isConnected = true;
    _state = BluetoothState.connected;
    return true;
  }

  // إرسال جزء لجهاز
  Future<bool> sendChunk({
    required BluetoothDevice device,
    required Chunk chunk,
  }) async {
    if (!device.isConnected) return false;
    // سيتم ربطه بالبلوتوث الحقيقي لاحقاً
    return true;
  }

  // استقبال جزء
  void receiveChunk(Chunk chunk) {
    _receivedChunkController.add(chunk);
  }

  // قطع الاتصال
  void disconnect(BluetoothDevice device) {
    device.isConnected = false;
    _state = BluetoothState.disconnected;
  }

  void dispose() {
    _devicesController.close();
    _receivedChunkController.close();
  }
}
