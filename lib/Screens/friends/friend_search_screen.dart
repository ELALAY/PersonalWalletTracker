import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';

class FriendSearchScreen extends StatefulWidget {
  final Person currentUser;

  const FriendSearchScreen({super.key, required this.currentUser});

  @override
  State<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {
  FirebaseDB firebaseDB = FirebaseDB();
  final TextEditingController _searchController = TextEditingController();
  String scannedQrCode = '';

  List<Person> _searchResults = [];
  bool _isLoading = false;
  final FirebaseDB _firebaseDB = FirebaseDB();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchUsers() async {
    setState(() {
      _isLoading = true;
    });

    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('persons')
        .where('email', isEqualTo: query)
        .get();

    final results = snapshot.docs
        .where((doc) => doc.id != widget.currentUser.id) // exclude self
        .map((doc) => Person.fromMap(doc.data(), doc.id))
        .toList();

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Future<void> _sendFriendRequest(Person toUser) async {
    await _firebaseDB.sendFriendRequest(
      fromUser: widget.currentUser,
      toUser: toUser,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent to ${toUser.username}')),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Email',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUsers,
                ),
              ),
              onSubmitted: (_) => _searchUsers(),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading)
              Expanded(
                child: _searchResults.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final person = _searchResults[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: person.profile_picture.isNotEmpty
                                  ? NetworkImage(person.profile_picture)
                                  : null,
                              child: person.profile_picture.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(person.username),
                            subtitle: Text(person.email),
                            trailing: ElevatedButton(
                              onPressed: () => _sendFriendRequest(person),
                              child: const Text('Add'),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
