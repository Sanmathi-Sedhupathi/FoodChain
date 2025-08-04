// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/delivery_model.dart';
import '../utils/app_theme.dart';

class DeliveryCard extends StatelessWidget {
  final DeliveryModel delivery;

  const DeliveryCard({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery #${delivery.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                _buildStatusChip(delivery.status),
              ],
            ),
            const SizedBox(height: 12),

            // Pickup Location
            _buildLocationInfo(
              'Pickup',
              delivery.pickupAddress,
              Icons.restaurant,
              AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),

            // Drop Location
            _buildLocationInfo(
              'Drop-off',
              delivery.dropAddress,
              Icons.location_on,
              AppTheme.accentColor,
            ),
            const SizedBox(height: 12),

            // Timeline
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Assigned: ${DateFormat('MMM dd, HH:mm').format(delivery.assignedAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            if (delivery.pickedUpAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Picked up: ${DateFormat('MMM dd, HH:mm').format(delivery.pickedUpAt!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],

            if (delivery.deliveredAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.done_all, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Delivered: ${DateFormat('MMM dd, HH:mm').format(delivery.deliveredAt!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],

            // Action Buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (delivery.status == DeliveryStatus.assigned)
                  ElevatedButton(
                    onPressed: () => _markAsPickedUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Mark Picked Up'),
                  ),
                if (delivery.status == DeliveryStatus.pickedUp)
                  ElevatedButton(
                    onPressed: () => _markAsDelivered(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Mark Delivered'),
                  ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _openInMaps(context),
                  child: const Text('Navigate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String label, String address, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(DeliveryStatus status) {
    Color color;
    String text;

    switch (status) {
      case DeliveryStatus.assigned:
        color = AppTheme.accentColor;
        text = 'Assigned';
        break;
      case DeliveryStatus.pickedUp:
        color = Colors.blue;
        text = 'Picked Up';
        break;
      case DeliveryStatus.delivered:
        color = AppTheme.primaryColor;
        text = 'Delivered';
        break;
      case DeliveryStatus.cancelled:
        color = AppTheme.errorColor;
        text = 'Cancelled';
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

  void _markAsPickedUp(BuildContext context) {
    // TODO: Implement mark as picked up functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marked as picked up!')),
    );
  }

  void _markAsDelivered(BuildContext context) {
    // TODO: Implement mark as delivered functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marked as delivered!')),
    );
  }

  void _openInMaps(BuildContext context) {
    // TODO: Open in Google Maps for navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening in Maps...')),
    );
  }
}