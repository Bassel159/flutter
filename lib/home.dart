import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  final String userType;

  const Home({Key? key, required this.userType}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  String studentName = "";
  String email = "";
  String studentId = "";
  String cvUrl = "";

  List<Map<String, dynamic>> companies = [];
  Map<String, Map<String, dynamic>> appliedApplications = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchAppliedCompanies().then((_) {
      setState(() {});
    });
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        studentId = uid;
        studentName = data['studentName'] ?? 'No Name';
        email = data['email'] ?? 'No Email';
        cvUrl = data['cv_url'] ?? '';
        await fetchCompanies();
        await fetchAppliedCompanies();
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchCompanies() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('userType', isEqualTo: 'Company')
              .where('isApproved', isEqualTo: true)
              .where('requestedCompany', isEqualTo: true)
              .get();

      companies =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'cName': data['companyName'] ?? 'Unnamed Company',
              'email': data['email'] ?? '',
              'industry': data['industry'] ?? '',
              'isApproved': data['isApproved'] ?? false,
              'requestedCompany': data['requestedCompany'] ?? false,
            };
          }).toList();
    } catch (e) {
      print('Error fetching companies: $e');
    }
  }

  Future<void> fetchAppliedCompanies() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('applications')
              .where('studentId', isEqualTo: studentId)
              .get();

      appliedApplications = {
        for (var doc in snapshot.docs)
          doc['companyId'] as String: {
            'applicationId': doc.id,
            'status': doc['status'] ?? 'pending',
          },
      };
    } catch (e) {
      print('Error fetching applied companies: $e');
    }
  }

  Future<void> applyToCompany(String companyId) async {
    if (cvUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No CV link available. Please upload your CV first.'),
        ),
      );
      return;
    }

    if (appliedApplications.containsKey(companyId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already applied to this company.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('applications').add({
        'studentId': studentId,
        'companyId': companyId,
        'cvUrl': cvUrl,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await fetchAppliedCompanies();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submitted successfully.')),
      );
    } catch (e) {
      print('Error submitting application: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit application. Please try again.'),
        ),
      );
    }
  }

  Future<void> cancelApplication(String companyId) async {
    if (!appliedApplications.containsKey(companyId)) return;

    final applicationId =
        appliedApplications[companyId]!['applicationId'] as String;

    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({'status': 'cancelled'});

      await fetchAppliedCompanies();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application cancelled successfully.')),
      );
    } catch (e) {
      print('Error cancelling application: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel application. Please try again.'),
        ),
      );
    }
  }

  void viewCV() async {
    if (cvUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No CV uploaded.')));
      return;
    }
    final uri = Uri.parse(cvUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open CV link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: viewCV,
        tooltip: 'View CV',
        child: Icon(Icons.picture_as_pdf),
      ),
      appBar: AppBar(
        title: Text("Home", style: textTheme.titleLarge),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: colorScheme.onPrimary),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
                  SizedBox(height: 10),
                  Text(
                    studentName,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.home, "Home", "home"),
            _drawerItem(Icons.settings, "Settings", "settings"),
            _drawerItem(Icons.person, "Profile", "profile"),
            _drawerItem(Icons.work, "Applications", "applications"),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                final providerId = user?.providerData.first.providerId;

                if (providerId == 'google.com') {
                  GoogleSignIn googleSignIn = GoogleSignIn();
                  try {
                    await googleSignIn.disconnect();
                  } catch (e) {
                    print('Google disconnect failed: $e');
                  }
                }

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
              : companies.isEmpty
              ? Center(child: Text('No companies available.'))
              : ListView.builder(
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  final company = companies[index];
                  final companyId = company['id'];
                  final isApplied = appliedApplications.containsKey(companyId);
                  final applicationStatus =
                      isApplied
                          ? appliedApplications[companyId]!['status']
                          : null;

                  String statusText = 'Not Applied';
                  Color statusColor = Colors.grey;

                  switch (applicationStatus) {
                    case 'accepted':
                      statusText = 'Accepted';
                      statusColor = Colors.green;
                      break;
                    case 'rejected':
                      statusText = 'Rejected';
                      statusColor = Colors.red;
                      break;
                    case 'pending':
                      statusText = 'Pending Review';
                      statusColor = Colors.orange;
                      break;
                    case 'cancelled':
                      statusText = 'Cancelled';
                      statusColor = Colors.grey;
                      break;
                  }

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  company['cName'] ?? 'Unknown Company',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  company['industry'] ?? '',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                if (isApplied)
                                  Text(
                                    'Status: $statusText',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isApplied)
                                ElevatedButton(
                                  onPressed: () => applyToCompany(companyId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                  ),
                                  child: Text("Apply"),
                                )
                              else if (applicationStatus != 'cancelled') ...[
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: statusColor,
                                    disabledForegroundColor: Colors.white,
                                  ),
                                  child: Text(statusText),
                                ),
                                if (applicationStatus == 'pending') ...[
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed:
                                        () => cancelApplication(companyId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text("Cancel Application"),
                                  ),
                                ],
                              ] else
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    disabledForegroundColor: Colors.white,
                                  ),
                                  child: Text("Application Cancelled"),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pushReplacementNamed(routeName);
      },
    );
  }
}
