import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class ContactsSetupScreen extends StatefulWidget {
  const ContactsSetupScreen({super.key});

  @override
  State<ContactsSetupScreen> createState() => _ContactsSetupScreenState();
}

class _ContactsSetupScreenState extends State<ContactsSetupScreen> {
  final _contacts = <EmergencyContact>[];
  final _contactService = ContactService();
  final _auth = AuthService();
  bool _saving = false;

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Emergency Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Mom'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(labelText: 'Phone', hintText: '98765 43210', counterText: ''),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relCtrl,
                decoration: const InputDecoration(labelText: 'Relationship (optional)', hintText: 'e.g. Mother'),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().length < 10) return;
              setState(() {
                _contacts.add(EmergencyContact(
                  id: '',
                  name: nameCtrl.text.trim(),
                  phoneNumber: phoneCtrl.text.trim(),
                  relationship: relCtrl.text.trim().isEmpty ? null : relCtrl.text.trim(),
                  priority: _contacts.length,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _finish() async {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one contact')),
      );
      return;
    }

    setState(() => _saving = true);
    final uid = Supabase.instance.client.auth.currentUser!.id;

    try {
      for (final c in _contacts) {
        await _contactService.addContact(c);
      }
      await _auth.updateUserProfile(uid, {'contacts_setup_complete': true});

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.contacts, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 24),
              Text('Add your trusted contacts', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('These people will be alerted if you send an SOS. Add at least one.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              if (_contacts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.person_add_alt, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text('No contacts yet', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('Tap the button below to add one',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _contacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final c = _contacts[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(c.name[0].toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  Text('+91 ${c.phoneNumber}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: AppColors.textSecondary),
                              onPressed: () => setState(() => _contacts.removeAt(i)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _contacts.length >= 5 ? null : _showAddDialog,
                icon: const Icon(Icons.add),
                label: Text(_contacts.isEmpty ? 'Add First Contact' : 'Add Another'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saving ? null : _finish,
                child: _saving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save & Continue'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}