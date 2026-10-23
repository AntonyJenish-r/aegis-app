import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/mock_contact_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _service = MockContactService();
  List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.getContacts();
    if (mounted) setState(() => _contacts = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(_contacts[i].name),
          subtitle: Text(_contacts[i].phoneNumber),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async {
            await _service.deleteContact(_contacts[i].id);
            _load();
          }),
        ),
      ),
    );
  }
}