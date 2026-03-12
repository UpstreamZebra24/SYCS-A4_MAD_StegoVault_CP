import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const StegovaultApp());
}

class StegovaultApp extends StatelessWidget {
  const StegovaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stegovault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// --- HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stegovault')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_outline),
              label: const Text('Hide a Message (Encode)'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EncodeScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_open),
              label: const Text('Reveal a Message (Decode)'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DecodeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- ENCODE SCREEN ---
class EncodeScreen extends StatefulWidget {
  const EncodeScreen({super.key});

  @override
  State<EncodeScreen> createState() => _EncodeScreenState();
}

class _EncodeScreenState extends State<EncodeScreen> {
  File? _image;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encode Message')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              color: Colors.grey[200],
              child: _image == null
                  ? const Center(child: Text('No image selected.'))
                  : Image.file(_image!, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Select Image from Gallery'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Enter Secret Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                // TODO: Member 4 (Integration Lead) will connect the LSB encoding logic here.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UI Shell: Ready for encoding logic!')),
                );
              },
              child: const Text('Encode & Save Image'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DECODE SCREEN ---
class DecodeScreen extends StatefulWidget {
  const DecodeScreen({super.key});

  @override
  State<DecodeScreen> createState() => _DecodeScreenState();
}

class _DecodeScreenState extends State<DecodeScreen> {
  File? _image;
  String _decodedMessage = "Your revealed message will appear here.";
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _decodedMessage = "Image loaded. Ready to decode.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decode Message')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              color: Colors.grey[200],
              child: _image == null
                  ? const Center(child: Text('No image selected.'))
                  : Image.file(_image!, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Select Encoded Image'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                // TODO: Member 4 (Integration Lead) will connect the LSB decoding logic here.
                setState(() {
                  _decodedMessage = "UI Shell: Ready for decoding logic!";
                });
              },
              child: const Text('Decode Image'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _decodedMessage,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}