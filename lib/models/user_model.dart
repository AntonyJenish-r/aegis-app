class AppUser {
  final String uid;
  final String phoneNumber;
  final String? name;
  final bool contactsSetupComplete;

  AppUser({
    required this.uid,
    required this.phoneNumber,
    this.name,
    this.contactsSetupComplete = false,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'phoneNumber': phoneNumber,
        'name': name,
        'contactsSetupComplete': contactsSetupComplete,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
        name: map['name'],
        contactsSetupComplete: map['contactsSetupComplete'] ?? false,
      );

  AppUser copyWith({String? name, bool? contactsSetupComplete}) => AppUser(
        uid: uid,
        phoneNumber: phoneNumber,
        name: name ?? this.name,
        contactsSetupComplete: contactsSetupComplete ?? this.contactsSetupComplete,
      );
}