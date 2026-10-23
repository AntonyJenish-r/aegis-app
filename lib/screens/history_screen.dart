import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alert_model.dart';
import '../services/mock_alert_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: StreamBuilder<List<AlertModel>>(
        stream: MockAlertService().streamMyAlerts(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final alerts = snap.data!;
          if (alerts.isEmpty) return const Center(child: Text('No alerts'));
          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (ctx, i) => ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: Text(alerts[i].triggerType),
              subtitle: Text(DateFormat('MMM d, HH:mm').format(alerts[i].createdAt)),
            ),
          );
        },
      ),
    );
  }
}