import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';
import 'friend_requests_screen.dart';
import 'friend_search_screen.dart';

class MyFriendsScreen extends StatefulWidget {
  final Person currentUser;

  const MyFriendsScreen({super.key, required this.currentUser});

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  FirebaseDB firebaseDB = FirebaseDB();
  List<Person> friends = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getFriends();
    isLoading = false;
  }

  void reload() {
    isLoading = true;
    getFriends();
    isLoading = false;
  }

  Future<void> getFriends() async {
    List<Person> friendstemp = await firebaseDB.getFriends(
      widget.currentUser.id,
    );
    debugPrint('friends: ${friendstemp.length.toString()}');

    setState(() {
      friends = friendstemp;
    });
  }

  Future<void> removeFriend(String friendId) async {
    debugPrint(friendId);
    await firebaseDB.removeFriend(
      userId: widget.currentUser.id,
      friendId: friendId,
    );
    reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FriendRequestsScreen(currentUser: widget.currentUser),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LiquidPullToRefresh(
              onRefresh: () async {
                debugPrint('reloading...');
                reload();
                debugPrint('reloaded!');
              },
              backgroundColor: Colors.deepPurple.shade200,
              showChildOpacityTransition: false,
              color: Colors.deepPurple,
              height: 100.0,
              animSpeedFactor: 1,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        Person friend = friends[index];
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    debugPrint('remove Friend to ');
                                    removeFriend(friend.id);
                                    debugPrint('Friend to remove ${friend.id}');
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Remove',
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    friend.profile_picture.isNotEmpty
                                    ? NetworkImage(friend.profile_picture)
                                    : null,
                                child: friend.profile_picture.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(friend.username),
                              subtitle: Text('id ${friend.id}'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  FriendSearchScreen(currentUser: widget.currentUser),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_alt),
      ),
    );
  }
}
