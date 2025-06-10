import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class adminHome extends StatefulWidget {
  const adminHome({super.key});

  @override
  State<adminHome> createState() => _adminHomeState();
}

class _adminHomeState extends State<adminHome> {
  bool isLoading = false;
  String selectedFilter = 'All';

  void approveCompany(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'userType': 'Company',
      'isApproved': true,
    });
  }

  void rejectCompany(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isApproved': false,
    });
  }

  void refreshPage() {
    setState(() {});
  }

  bool shouldDisplay(DocumentSnapshot doc) {
    final isApproved = doc['isApproved'];
    switch (selectedFilter) {
      case 'Approved':
        return isApproved == true;
      case 'Rejected':
        return isApproved == false;
      case 'Pending':
        return isApproved == null;
      default:
        return true;
    }
  }

  void showConfirmationDialog({
    required BuildContext context,
    required String userId,
    required bool isApprove,
  }) {
    String title = isApprove ? 'Confirm Approval' : 'Confirm Rejection';
    String message =
        isApprove
            ? 'Are you sure you want to approve this company?'
            : 'Are you sure you want to reject this company?';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (isApprove) {
                    approveCompany(userId);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Company approved')));
                  } else {
                    rejectCompany(userId);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Company rejected')));
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshPage,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
                  SizedBox(height: 10),
                  Text(
                    "Admin",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.of(context).pushReplacementNamed("adminhome");
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.of(context).pushNamed("adminsettings");
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              onTap: () async {
                GoogleSignIn googleSignIn = GoogleSignIn();
                googleSignIn.disconnect();
                await FirebaseAuth.instance.signOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil("login", (route) => false);
              },
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedFilter,
                      items:
                          ['All', 'Approved', 'Rejected', 'Pending']
                              .map(
                                (label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedFilter = value;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Filter by Status",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('users')
                              .where('userType', isEqualTo: 'Company')
                              .where('requestedCompany', isEqualTo: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No requests currently'));
                        }

                        final requests =
                            snapshot.data!.docs.where(shouldDisplay).toList();

                        if (requests.isEmpty) {
                          return Center(
                            child: Text('No requests matching selected filter'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final user = requests[index];
                            final name = user['companyName'] ?? 'No Name';
                            final email = user['email'] ?? 'No Email';
                            final isApproved = user['isApproved'];

                            String statusText;
                            if (isApproved == true) {
                              statusText = 'Status: Approved ✅';
                            } else if (isApproved == false) {
                              statusText = 'Status: Rejected ❌';
                            } else {
                              statusText = 'Status: Pending';
                            }

                            return Card(
                              elevation: 4,
                              child: ListTile(
                                title: Text(name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(email),
                                    Text(
                                      statusText,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'approve') {
                                      showConfirmationDialog(
                                        context: context,
                                        userId: user.id,
                                        isApprove: true,
                                      );
                                    } else if (value == 'reject') {
                                      showConfirmationDialog(
                                        context: context,
                                        userId: user.id,
                                        isApprove: false,
                                      );
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          value: 'approve',
                                          child: Text('Approve'),
                                        ),
                                        PopupMenuItem(
                                          value: 'reject',
                                          child: Text('Reject'),
                                        ),
                                      ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
