import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const TestFlutterApp());
}

class TestFlutterApp extends StatelessWidget {
  const TestFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi TTS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeaking = false;
  String _language = 'id-ID';

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  Future<void> _setupTts() async {
    try {
      await _tts.setEngine('default');
      await _tts.setLanguage(_language);
    } catch (_) {
      // fallback ke engine default bila tidak tersedia
    }
    _tts.setCompletionHandler((String? text) async {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
    _tts.setErrorHandler((String? error) {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
  }

  Future<void> _speak() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Silakan masukkan teks yang ingin dibacakan.');
      return;
    }
    if (_isSpeaking) {
      await _tts.stop();
      return;
    }
    await _tts.stop();
    await _tts.speak(text);
    if (mounted) {
      setState(() => _isSpeaking = true);
    }
  }

  Future<void> _stop() async {
    await _tts.stop();
    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _onLanguageChanged(String? value) async {
    if (value == null) return;
    setState(() {
      _language = value;
    });
    await _tts.setLanguage(value);
    await _tts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Text-to-Speech'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Masukkan Teks',
                hintText: 'Contoh: Halo, selamat pagi!',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            DropdownButtonFormField<String>(
              value: _language,
              decoration: InputDecoration(
                labelText: 'Pilih Bahasa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'id-ID', child: Text('Bahasa Indonesia')),
                DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
                DropdownMenuItem(value: 'en-GB', child: Text('English (UK)')),
                DropdownMenuItem(value: 'ja-JP', child: Text('Bahasa Jepang')),
              ],
              onChanged: _onLanguageChanged,
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSpeaking ? null : _speak,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Bicarakan'),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSpeaking ? _stop : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Berhenti'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            Text(
              _isSpeaking ? 'Sedang berbicara...' : 'Siap',
              style: theme.textTheme.titleLarge?.copyWith(
                color: _isSpeaking ? Colors.amber : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}