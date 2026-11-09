import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Captura/selecciona imagen y la copia a una carpeta permanente de la app.
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Devuelve la ruta guardada, o null si el usuario canceló.
  Future<String?> pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final name = '${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
    final saved = await File(picked.path).copy(p.join(dir.path, name));
    return saved.path;
  }
}