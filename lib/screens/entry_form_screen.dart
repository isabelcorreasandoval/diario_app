import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../data/diary_repository.dart';
import '../models/diary_entry.dart';
import '../services/image_service.dart';
import '../services/location_service.dart';

class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({super.key});

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  final DiaryRepository _repo = SqliteDiaryRepository();
  final ImageService _imageService = ImageService();
  final LocationService _locationService = LocationService();
  final SpeechToText _speech = SpeechToText();

  String? _imagePath;
  bool _speechAvailable = false;
  bool _listening = false;
  bool _saving = false;
  String _textBeforeListening = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (s) {
          if (s == 'done' || s == 'notListening') {
            if (mounted) setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
    if (mounted) setState(() {});
  }

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pickImage(ImageSource source) async {
    try {
      final path = await _imageService.pick(source);
      if (path != null) setState(() => _imagePath = path);
    } catch (e) {
      _msg('No se pudo obtener la imagen: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      _msg('Dictado no disponible (revisa permisos del micrófono).');
      return;
    }
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    _textBeforeListening = _contentCtrl.text;
    setState(() => _listening = true);
    await _speech.listen(
      localeId: 'es_MX',
      onResult: (result) {
        final sep = _textBeforeListening.isEmpty ? '' : ' ';
        _contentCtrl.text = '$_textBeforeListening$sep${result.recognizedWords}';
        _contentCtrl.selection =
            TextSelection.collapsed(offset: _contentCtrl.text.length);
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    double? lat;
    double? lng;
    try {
      final pos = await _locationService.getCurrentPosition();
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (e) {
      _msg('Se guardará sin ubicación: $e');
    }

    try {
      await _repo.insert(DiaryEntry(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        imagePath: _imagePath,
        latitude: lat,
        longitude: lng,
        createdAt: DateTime.now(),
      ));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _msg('$e');
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva entrada')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Título', border: OutlineInputBorder()),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Escribe un título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: '¿Cómo estuvo tu día?',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_listening ? Icons.mic : Icons.mic_none,
                        color: _listening ? Colors.red : null),
                    tooltip: 'Dictar',
                    onPressed: _toggleListening,
                  ),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Escribe o dicta algo' : null,
              ),
              const SizedBox(height: 16),
              if (_imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_imagePath!),
                      height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Guardando...' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}