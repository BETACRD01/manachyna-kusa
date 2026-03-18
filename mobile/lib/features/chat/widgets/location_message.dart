import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/message_model.dart';

class LocationMessage extends StatelessWidget {
  final Message message;
  final bool isMe;

  const LocationMessage({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final latitude = message.latitude;
    final longitude = message.longitude;

    if (latitude == null || longitude == null) {
      return _buildErrorLocation(context);
    }

    return GestureDetector(
      onTap: () => _openLocationOptions(context, latitude, longitude),
      child: SizedBox(
        width: 250,
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vista previa del mapa
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? _buildWebLocationPlaceholder(latitude, longitude)
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude, longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('location'),
                            position: LatLng(latitude, longitude),
                            infoWindow: InfoWindow(
                              title: message.locationName ?? 'Ubicación',
                            ),
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                      ),
              ),
            ),

            // Información adicional
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: isMe ? Colors.white : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          message.locationName ?? 'Ubicación compartida',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  if (message.metadata?['accuracy'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Precisión: ${message.metadata!['accuracy'].toStringAsFixed(0)}m',
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLocationOptions(BuildContext context, double latitude, double longitude) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Ver en Google Maps'),
              onTap: () {
                Navigator.pop(context);
                _openGoogleMaps(latitude, longitude);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.fullscreen),
                title: const Text('Ver pantalla completa'),
                onTap: () {
                  Navigator.pop(context);
                  _openFullScreenMap(context, latitude, longitude);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openGoogleMaps(double latitude, double longitude) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir Google Maps');
    }
  }

  void _openFullScreenMap(BuildContext context, double latitude, double longitude) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMapViewer(
          latitude: latitude,
          longitude: longitude,
          locationName: message.locationName ?? 'Ubicación',
        ),
      ),
    );
  }

  Widget _buildWebLocationPlaceholder(double latitude, double longitude) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(
            'https://maps.googleapis.com/maps/api/staticmap?'
            'center=$latitude,$longitude&zoom=15&size=250x120&'
            'markers=color:red%7C$latitude,$longitude&key=AIzaSyCzX3wWlsNyCjXP9dnJ4jN3E4c_jMjnUFI',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withAlpha(77)
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 40, color: Colors.white),
              SizedBox(height: 8),
              Text(
                'Toca para ver ubicación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorLocation(BuildContext context) {
    return Container(
      width: 250,
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 32, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            'Ubicación no disponible',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ================================================
// Pantalla de mapa en pantalla completa
// ================================================
class FullScreenMapViewer extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const FullScreenMapViewer({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<FullScreenMapViewer> createState() => _FullScreenMapViewerState();
}

class _FullScreenMapViewerState extends State<FullScreenMapViewer> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.locationName)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.web, size: 64),
              const SizedBox(height: 16),
              const Text('Vista de mapa no disponible en web'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openGoogleMaps,
                child: const Text('Abrir en Google Maps'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions),
            onPressed: _openGoogleMaps,
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('location'),
            position: LatLng(widget.latitude, widget.longitude),
            infoWindow: InfoWindow(
              title: widget.locationName,
              snippet:
                  '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
            ),
          ),
        },
        onMapCreated: (controller) {
          _mapController = controller;
        },
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(widget.latitude, widget.longitude),
              16,
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  void _openGoogleMaps() async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir Google Maps');
    }
  }
}
