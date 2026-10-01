import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';
import '../theme/app_theme.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _service = ContactService();
  List<EmergencyContact> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.getContacts();
    if (mounted) setState(() { _contacts = list; _loading = false; });
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl,
                keyboardType: TextInputType.phone, maxLength: 10,
                decoration: const InputDecoration(labelText: 'Phone', counterText: '')),
            const SizedBox(height: 12),
            TextField(controller: relCtrl,
                decoration: const InputDecoration(labelText: 'Relationship')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().length < 10) return;
              await _service.addContact(EmergencyContact(
                id: '',
                name: nameCtrl.text.trim(),
                phoneNumber: phoneCtrl.text.trim(),
                relationship: relCtrl.text.trim().isEmpty ? null : relCtrl.text.trim(),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? const Center(child: Text('No contacts yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contacts.length,
                  itemBuilder: (ctx, i) {
                    final c = _contacts[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(c.name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(c.name),
                        subtitle: Text('+91 ${c.phoneNumber}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await _service.deleteContact(c.id);
                            _load();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}