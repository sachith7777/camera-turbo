import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    _controller = CameraController(_cameras[0], ResolutionPreset.max);
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      if (e is CameraException) {
        setState(() {
          _errorMessage = 'Camera error: ${e.description}';
        });
      } else {
        setState(() {
          _errorMessage = 'Unknown error: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? CameraPreview(_controller)
          : Center(
              child: _errorMessage.isEmpty
                  ? const CircularProgressIndicator()
                  : Text(_errorMessage),
            ),
    );
  }
}
