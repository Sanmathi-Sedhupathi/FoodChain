import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/donation_card.dart';
import 'map_screen.dart';

class ReceiverDashboard extends StatefulWidget {
  const ReceiverDashboard({super.key});

  @override
  State<ReceiverDashboard> createState() => _ReceiverDashboardState();
}

class _ReceiverDashboardState extends State<ReceiverDashboard> {
  String _searchQuery = '';
  double _radiusKm = 10.0;

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUserModel!;
    final locationService = context.watch<LocationService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for food...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Radius Filter
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text('Within ${_radiusKm.toInt()} km'),
                    Expanded(
                      child: Slider(
                        value: _radiusKm,
                        min: 1.0,
                        max: 50.0,
                        divisions: 49,
                        onChanged: (value) {
                          setState(() => _radiusKm = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Available Donations
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Food Near You',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<List<DonationModel>>(
                      stream: context.read<FirestoreService>().getDonationsStream(
                        status: DonationStatus.available,
                        nearLocation: locationService.currentGeoPoint,
                        radiusKm: _radiusKm,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        List<DonationModel> donations = snapshot.data ?? [];

                        // Filter by search query
                        if (_searchQuery.isNotEmpty) {
                          donations = donations.where((donation) {
                            return donation.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                   donation.description.toLowerCase().contains(_searchQuery.toLowerCase());
                          }).toList();
                        }

                        if (donations.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No food available nearby',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try expanding your search radius',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: donations.length,
                          itemBuilder: (context, index) {
                            final donation = donations[index];
                            final distance = locationService.currentGeoPoint != null
                                ? locationService.calculateDistance(
                                    locationService.currentGeoPoint!,
                                    donation.location,
                                  )
                                : null;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: DonationCard(
                                donation: donation,
                                distance: distance,
                                showRequestButton: true,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}