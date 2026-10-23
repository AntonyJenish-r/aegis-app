import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/mock_contact_service.dart';
import '../services/mock_auth_service.dart';

import 'home_screen.dart';

class ContactsSetupScreen extends StatefulWidget {
  const ContactsSetupScreen({super.key});
  @override
  State<ContactsSetupScreen> createState() => _ContactsSetupScreenState();
}

class _ContactsSetupScreenState extends State<ContactsSetupScreen> {
  final List<EmergencyContact> _contacts = [];
  final _contactService = MockContactService();
  final _auth = MockAuthService();
  bool _saving = false;

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Contact'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
        TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, maxLength: 10, decoration: const InputDecoration(labelText: 'Phone', counterText: '')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (nameCtrl.text.isNotEmpty && phoneCtrl.text.length >= 10) {
            setState(() => _contacts.add(EmergencyContact(id: '', name: nameCtrl.text, phoneNumber: phoneCtrl.text)));
            Navigator.pop(ctx);
          }
        }, child: const Text('Add')),
      ],
    ));
  }

  Future<void> _finish() async {
    if (_contacts.isEmpty) return;
    setState(() => _saving = true);
    for (var c in _contacts) { await _contactService.addContact(c); }
    await _auth.updateUserProfile(_auth.mockUserId, {'contactsSetupComplete': true});
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text('Add Trusted Contacts', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Expanded(
                child: _contacts.isEmpty
                    ? const Center(child: Text('No contacts added'))
                    : ListView.builder(itemCount: _contacts.length, itemBuilder: (ctx, i) => ListTile(
                        title: Text(_contacts[i].name),
                        subtitle: Text(_contacts[i].phoneNumber),
                      )),
              ),
              OutlinedButton(onPressed: _showAddDialog, child: const Text('Add Contact')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _saving ? null : _finish, child: const Text('Save & Continue')),
            ],
          ),
        ),
      ),
    );
  }
}