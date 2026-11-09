import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/diary_entry.dart';

class EntryDetailScreen extends StatelessWidget {
  final DiaryEntry entry;
  const EntryDetailScreen({super.key, required this.entry});

  Future<void> _openInGoogleMaps(BuildContext context) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${entry.latitude},${entry.longitude}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir Google Maps')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: ListView(
        children: [
          if (entry.imagePath != null)
            Hero(
              tag: 'entry-image-${entry.id}',
              child: Image.file(File(entry.imagePath!),
                  height: 260, width: double.infinity, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.createdAt.toString().substring(0, 16),
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                Text(entry.content, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                if (entry.hasLocation) ...[
                  Text('Ubicación',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(entry.latitude!, entry.longitude!),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.diario_app',
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              point: LatLng(entry.latitude!, entry.longitude!),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin,
                                  color: Colors.red, size: 40),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Lat: ${entry.latitude!.toStringAsFixed(5)}, '
                          'Lng: ${entry.longitude!.toStringAsFixed(5)}'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _openInGoogleMaps(context),
                    icon: const Icon(Icons.map),
                    label: const Text('Abrir en Google Maps'),
                  ),
                ] else
                  const Text('Esta entrada no tiene ubicación guardada.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}