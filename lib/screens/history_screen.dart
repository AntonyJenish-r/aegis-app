import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert History')),
      body: StreamBuilder<List<AlertModel>>(
        stream: AlertService().streamMyAlerts(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final alerts = snap.data ?? [];
          if (alerts.isEmpty) {
            return const Center(child: Text("No alerts yet — you're safe!"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (ctx, i) {
              final a = alerts[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: AppColors.danger),
                        const SizedBox(width: 8),
                        Text(a.triggerType.replaceAll('_', ' '),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM d, yyyy • HH:mm').format(a.createdAt),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    if (a.latitude != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '📍 ${a.latitude!.toStringAsFixed(4)}, ${a.longitude!.toStringAsFixed(4)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}