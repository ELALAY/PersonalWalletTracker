import 'package:flutter/material.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';

class FriendRequestsScreen extends StatefulWidget {
  final Person currentUser;

  const FriendRequestsScreen({super.key, required this.currentUser});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final FirebaseDB _firebaseDB = FirebaseDB();

  List<Map<String, dynamic>> incomingRequests = [];
  List<Map<String, dynamic>> outgoingRequests = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);

    final incoming = await _firebaseDB.getIncomingRequests(widget.currentUser.id);
    final outgoing = await _firebaseDB.getOutgoingRequests(widget.currentUser.id);

    setState(() {
      incomingRequests = incoming;
      outgoingRequests = outgoing;
      isLoading = false;
    });
  }

  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    final fromUserId = request['fromUserId'] as String;
    final toUserId = request['toUserId'] as String;

    // Fetch full Person objects (you need to implement getPersonById in your FirebaseDB)
    final fromUser = await _firebaseDB.getPersonProfile(fromUserId);
    final toUser = await _firebaseDB.getPersonProfile(toUserId);

    await _firebaseDB.acceptFriendRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUser: fromUser!,
      toUser: toUser!,
    );

    await _loadRequests();
  }

  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    final fromUserId = request['fromUserId'] as String;
    final toUserId = request['toUserId'] as String;

    await _firebaseDB.rejectFriendRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
    );

    await _loadRequests();
  }

  Future<void> _cancelSentRequest(Map<String, dynamic> request) async {
    final fromUserId = request['fromUserId'] as String;
    final toUserId = request['toUserId'] as String;

    await _firebaseDB.cancelSentRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
    );

    await _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friend Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Incoming'),
              Tab(text: 'Outgoing'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildIncomingRequestsTab(),
                  _buildOutgoingRequestsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildIncomingRequestsTab() {
    if (incomingRequests.isEmpty) {
      return const Center(child: Text('No incoming requests'));
    }

    return ListView.builder(
      itemCount: incomingRequests.length,
      itemBuilder: (context, index) {
        final request = incomingRequests[index];
        final fromUserId = request['fromUsername'] as String;

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text('to: $fromUserId'),
          subtitle: Text('Status: ${request['status']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _acceptRequest(request),
                tooltip: 'Accept',
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _rejectRequest(request),
                tooltip: 'Reject',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOutgoingRequestsTab() {
    if (outgoingRequests.isEmpty) {
      return const Center(child: Text('No outgoing requests'));
    }

    return ListView.builder(
      itemCount: outgoingRequests.length,
      itemBuilder: (context, index) {
        final request = outgoingRequests[index];
        final toUserId = request['toUsername'] as String;         

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text('From: $toUserId'),
          subtitle: Text('Status: ${request['status']}'),
          trailing: IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => _cancelSentRequest(request),
            tooltip: 'Cancel Request',
          ),
        );
      },
    );
  }
}
