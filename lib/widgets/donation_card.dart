// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/donation_model.dart';
import '../utils/app_theme.dart';

class DonationCard extends StatelessWidget {
  final DonationModel donation;
  final double? distance;
  final bool showActions;
  final bool showRequestButton;

  const DonationCard({
    super.key,
    required this.donation,
    this.distance,
    this.showActions = false,
    this.showRequestButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (donation.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: donation.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        donation.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    _buildStatusChip(donation.status),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  donation.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Info Row
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${donation.quantity} servings',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Expires ${DateFormat('MMM dd, HH:mm').format(donation.expiryTime)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location and Distance
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        donation.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (distance != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${distance!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),

                // Action Buttons
                if (showActions || showRequestButton) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (showRequestButton)
                        ElevatedButton(
                          onPressed: donation.isAvailable
                              ? () => _requestFood(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('Request'),
                        ),
                      if (showActions) ...[
                        TextButton(
                          onPressed: () => _editDonation(context),
                          child: const Text('Edit'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _viewRequests(context),
                          child: const Text('View Requests'),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(DonationStatus status) {
    Color color;
    String text;

    switch (status) {
      case DonationStatus.available:
        color = AppTheme.primaryColor;
        text = 'Available';
        break;
      case DonationStatus.requested:
        color = AppTheme.accentColor;
        text = 'Requested';
        break;
      case DonationStatus.assigned:
        color = Colors.blue;
        text = 'Assigned';
        break;
      case DonationStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case DonationStatus.expired:
        color = AppTheme.errorColor;
        text = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _requestFood(BuildContext context) {
    // TODO: Implement request food functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food request sent!')),
    );
  }

  void _editDonation(BuildContext context) {
    // TODO: Navigate to edit donation screen
  }

  void _viewRequests(BuildContext context) {
    // TODO: Navigate to view requests screen
  }
}