import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/donation_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<DonationModel> _donations = [];

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  void _loadDonations() {
    final firestoreService = context.read<FirestoreService>();
    firestoreService.getDonationsStream(status: DonationStatus.available).listen((donations) {
      setState(() {
        _donations = donations;
        _updateMarkers();
      });
    });
  }

  void _updateMarkers() {
    _markers = _donations.map((donation) {
      return Marker(
        markerId: MarkerId(donation.id),
        position: LatLng(
          donation.location.latitude,
          donation.location.longitude,
        ),
        infoWindow: InfoWindow(
          title: donation.title,
          snippet: '${donation.quantity} servings • ${donation.address}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () => _showDonationDetails(donation),
      );
    }).toSet();
  }

  void _showDonationDetails(DonationModel donation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DonationBottomSheet(donation: donation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationService = context.watch<LocationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Map'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: locationService.currentPosition == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  locationService.currentPosition!.latitude,
                  locationService.currentPosition!.longitude,
                ),
                zoom: 14,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (locationService.currentPosition != null && _mapController != null) {
            await _mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(
                  locationService.currentPosition!.latitude,
                  locationService.currentPosition!.longitude,
                ),
              ),
            );
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}