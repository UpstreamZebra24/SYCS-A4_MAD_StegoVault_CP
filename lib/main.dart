import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'services/stego_service.dart';
import 'services/auth_service.dart';
import 'services/secure_storage_service.dart';
import 'core/steganography/image_capacity_calculator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StegovaultApp());
}

final ValueNotifier<bool> developerMode = ValueNotifier<bool>(false);

class StegovaultApp extends StatelessWidget {
  const StegovaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Tool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep Indigo for a premium secure feel
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Clean professional font
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const LockScreen(),
    );
  }
}

// Lock Screen Logic
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;
  final TextEditingController _masterPassController = TextEditingController();

  Future<void> _handleUnlock() async {
    setState(() => _isAuthenticating = true);
    final bool authenticated = await AuthService.authenticate();
    if (!mounted) return;
    setState(() => _isAuthenticating = false);

    if (authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Set or Verify Master Password
  Future<void> _setupMasterPassword() async {
    final existing = await SecureStorageService.getMasterPassword();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'Initialize Your Vault' : 'Vault Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('The Master Password is encrypted and stored in your device\'s Secure Enclave.'),
            const SizedBox(height: 10),
            TextField(
              controller: _masterPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Master Password', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (_masterPassController.text.isNotEmpty) {
                await SecureStorageService.saveMasterPassword(_masterPassController.text);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vault Identity Secured!')));
              }
            },
            child: const Text('Save to Hardware'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade900],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security_rounded, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'STEGOVAULT',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
            const SizedBox(height: 10),
            const Text('Hardware-Backed Offline Security', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 60),
            if (_isAuthenticating)
              const CircularProgressIndicator(color: Colors.white)
            else ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('UNLOCK VAULT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueGrey.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: _handleUnlock,
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                icon: const Icon(Icons.settings_applications),
                label: const Text('Manage Secure Identity', style: TextStyle(color: Colors.white70)),
                onPressed: _setupMasterPassword,
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Stegovault', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: developerMode,
            builder: (context, isDev, child) {
              return IconButton(
                icon: Icon(isDev ? Icons.terminal : Icons.terminal_outlined),
                color: isDev ? Colors.orange : Colors.grey,
                onPressed: () => developerMode.value = !isDev,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HomeCard(
              icon: Icons.enhanced_encryption_rounded,
              label: 'Hide a Message',
              description: 'Embed encrypted data into an image.',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EncodeScreen())),
            ),
            const SizedBox(height: 20),
            _HomeCard(
              icon: Icons.no_encryption_gmailerrorred_rounded,
              label: 'Reveal a Message',
              description: 'Extract hidden secrets from an image.',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DecodeScreen())),
            ),
            const SizedBox(height: 60),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Secure Lock'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LockScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  const _HomeCard({required this.icon, required this.label, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Encode Screen
class EncodeScreen extends StatefulWidget {
  const EncodeScreen({super.key});
  @override
  State<EncodeScreen> createState() => _EncodeScreenState();
}

class _EncodeScreenState extends State<EncodeScreen> {
  File? _image;
  Uint8List? _imageBytes;
  img.Image? _decodedImg;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final StegoService _stegoService = StegoService();
  bool _isProcessing = false;
  bool _obscurePassphrase = true;
  int _maxChars = 0;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() => setState(() {}));
    _passphraseController.addListener(() => setState(() {}));
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (!mounted) return;
        debugPrint("Image bytes read: ${bytes.length}");
        
        // Use the image package to decode
        final decoded = img.decodeImage(bytes);
        
        setState(() {
          _image = File(pickedFile.path);
          _imageBytes = bytes;
          _decodedImg = decoded;
          _maxChars = decoded != null ? CapacityCalculator.calculateMaxCharacters(decoded) : 0;
          if (decoded == null) {
            debugPrint("StegoVault Error: 'image' package failed to decode the selected file.");
          }
        });
      }
    } catch (e) {
      debugPrint("StegoVault Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canEncode = _imageBytes != null && _messageController.text.isNotEmpty && _messageController.text.length <= _maxChars;
    final double usage = (_decodedImg != null && _maxChars > 0) 
        ? CapacityCalculator.getUsagePercent(_decodedImg!, _messageController.text.length)
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Encode Message')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                _ImagePreview(bytes: _imageBytes),
                if (_imageBytes != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton.filled(
                      icon: const Icon(Icons.hub_outlined),
                      onPressed: _showHeatmap,
                      tooltip: 'Show Bit Scattering Pattern',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Select Image from Gallery'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 16),
            const Card(
              color: Color(0xFFE3F2FD),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(child: Text('Warning: To ensure the payload survives, share the output file as a "Document" or "Lossless PNG".', style: TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            ),
            if (_image != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: usage,
                color: usage > 0.9 ? Colors.red : Colors.green,
                backgroundColor: Colors.grey[300],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('Capacity: ${_messageController.text.length} / $_maxChars characters',
                  style: TextStyle(fontSize: 12, color: usage > 0.9 ? Colors.red : Colors.grey[700]),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Secret Message', border: OutlineInputBorder(), prefixIcon: Icon(Icons.message)),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passphraseController,
              obscureText: _obscurePassphrase,
              decoration: InputDecoration(
                labelText: 'Encryption Passphrase',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.password),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassphrase ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassphrase = !_obscurePassphrase),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: !canEncode || _isProcessing ? null : _handleEncode,
              child: _isProcessing 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Encode & Save to Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEncode() async {
    setState(() => _isProcessing = true);
    final path = await _stegoService.encode(_messageController.text, _image!.path, passphrase: _passphraseController.text);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Downloads/stego_image.png')));
    }
  }

  void _showHeatmap() async {
    if (_decodedImg == null) return;
    
    final heatmapBytes = await _stegoService.generateHeatmap(
      _decodedImg!.width, 
      _decodedImg!.height, 
      _messageController.text.length,
      passphrase: _passphraseController.text
    );

    if (heatmapBytes != null && mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Bit Scattering Map'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('White pixels indicate where secret bits are hidden based on your encryption entropy.', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              Image.memory(heatmapBytes, fit: BoxFit.contain, height: 300),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
        ),
      );
    }
  }
}

// Decode Screen
class DecodeScreen extends StatefulWidget {
  const DecodeScreen({super.key});
  @override
  State<DecodeScreen> createState() => _DecodeScreenState();
}

class _DecodeScreenState extends State<DecodeScreen> {
  Uint8List? _imageBytes;
  final TextEditingController _passphraseController = TextEditingController();
  String _decodedMessage = "Revealed message will appear here.";
  bool _isProcessing = false;
  bool _obscurePassphrase = true;
  final StegoService _stegoService = StegoService();
  final ImagePicker _picker = ImagePicker();
  String? _lastPickedPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decode Message')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ImagePreview(bytes: _imageBytes),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Select Encoded Image'),
              onPressed: () async {
                final file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  final bytes = await file.readAsBytes();
                  if (!mounted) return;
                  setState(() {
                    _lastPickedPath = file.path;
                    _imageBytes = bytes;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passphraseController,
              obscureText: _obscurePassphrase,
              decoration: InputDecoration(
                labelText: 'Decryption Passphrase',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.password),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassphrase ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassphrase = !_obscurePassphrase),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _imageBytes == null || _isProcessing ? null : _handleDecode,
              child: _isProcessing 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Decode Image'),
            ),
            const SizedBox(height: 24),
            _ResultBox(message: _decodedMessage),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDecode() async {
    if (_lastPickedPath == null) return;
    setState(() { _isProcessing = true; _decodedMessage = "Extracting Bits..."; });
    
    // Simulate progress feedback for the presentation
    await Future.delayed(const Duration(milliseconds: 800));
    
    final result = await _stegoService.decode(_lastPickedPath!, passphrase: _passphraseController.text);
    
    if (!mounted) return;

    setState(() { 
      _isProcessing = false; 
      _decodedMessage = result ?? "Authentication Failed: Incorrect passphrase or corrupted image."; 
    });

    // Security: Passive Clipboard Guardian
    if (result != null && result.isNotEmpty) {
      Timer(const Duration(seconds: 60), () async {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        if (data?.text == result) {
          await Clipboard.setData(const ClipboardData(text: ""));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Security: Clipboard wiped to protect your data.'))
          );
        }
      });
    }
  }
}

class _ImagePreview extends StatelessWidget {
  final Uint8List? bytes;
  const _ImagePreview({this.bytes});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: bytes == null 
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_search_rounded, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text('No image selected', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
            ],
          ) 
        : ClipRRect(
            borderRadius: BorderRadius.circular(20), 
            child: Image.memory(
              bytes!, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Invalid image format.\nDetails: $error', 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                );
              },
            ),
          ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String message;
  const _ResultBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300), 
        borderRadius: BorderRadius.circular(12), 
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Result:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const Divider(),
          Text(message, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
