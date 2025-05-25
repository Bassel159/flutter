import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyHome extends StatefulWidget {
  const CompanyHome({super.key});

  @override
  State<CompanyHome> createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  bool isLoading = true;
  String companyName = "";
  String email = "";
  String companyId = "";
  List<Map<String, dynamic>> applications = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null && mounted) {
        companyId = uid;
        companyName = data['companyName'] ?? 'No Name';
        email = data['email'] ?? 'No Email';
        await loadApplications();
      }
    }
  }

  Future<void> loadApplications() async {
    final appsSnapshot =
        await FirebaseFirestore.instance
            .collection('applications')
            .where('companyId', isEqualTo: companyId)
            .orderBy('timestamp', descending: true)
            .get();

    List<Map<String, dynamic>> tempList = [];

    for (var appDoc in appsSnapshot.docs) {
      final appData = appDoc.data();
      final studentId = appData['studentId'];

      final studentDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(studentId)
              .get();
      final studentData = studentDoc.data() ?? {};

      tempList.add({
        'applicationId': appDoc.id,
        'studentName': studentData['studentName'] ?? 'Unknown Student',
        'email': studentData['email'] ?? '',
        'cvUrl': appData['cvUrl'] ?? '',
        'status': appData['status'] ?? 'Pending',
        'appliedAt': appData['timestamp'],
        'interviewDate': appData['interviewDate'],
        'studentId': studentId,
      });
    }

    // هنا فلترة لإزالة الطلبات المكررة حسب studentId
    Map<String, Map<String, dynamic>> uniqueApplications = {};
    for (var app in tempList) {
      if (!uniqueApplications.containsKey(app['studentId'])) {
        uniqueApplications[app['studentId']] = app;
      }
      // إذا تحب تخلي الطلب الأحدث فقط لكل طالب، تقدر تضيف مقارنة timestamps
    }

    setState(() {
      applications = uniqueApplications.values.toList();
      isLoading = false;
    });
  }

  Future<void> acceptApplicationWithInterview(String appId) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Interview Date"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text("Choose Date"),
              ),
              ElevatedButton(
                onPressed: () async {
                  selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
                child: Text("Choose Time"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedDate != null && selectedTime != null) {
                  final interviewDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  await FirebaseFirestore.instance
                      .collection('applications')
                      .doc(appId)
                      .update({
                        'status': 'Accepted',
                        'interviewDate': Timestamp.fromDate(
                          interviewDateTime.toUtc(),
                        ),
                      });

                  final appDoc =
                      await FirebaseFirestore.instance
                          .collection('applications')
                          .doc(appId)
                          .get();
                  final studentId = appDoc['studentId'];

                  await FirebaseFirestore.instance.collection('notifications').add({
                    'studentId': studentId,
                    'title': 'Application Accepted!',
                    'body':
                        'You have been accepted by $companyName. Interview is scheduled on ${selectedDate!.toLocal().toString().split(" ")[0]} at ${selectedTime!.format(context)}.',
                    'timestamp': Timestamp.now(),
                    'read': false,
                  });

                  Navigator.pop(context);
                  await loadApplications();
                }
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateApplicationStatus(String appId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(appId)
        .update({'status': newStatus});

    final appDoc =
        await FirebaseFirestore.instance
            .collection('applications')
            .doc(appId)
            .get();
    final studentId = appDoc['studentId'];

    await FirebaseFirestore.instance.collection('notifications').add({
      'studentId': studentId,
      'title':
          newStatus == 'Rejected'
              ? 'Application Rejected'
              : 'Application Status Updated',
      'body':
          newStatus == 'Rejected'
              ? 'Your application was rejected by $companyName.'
              : 'Your application status has been updated.',
      'timestamp': Timestamp.now(),
      'read': false,
    });

    await loadApplications();
  }

  void viewCV(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot open CV')));
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Application Accepted';
      case 'rejected':
        return 'Application Rejected';
      case 'pending':
      default:
        return 'Pending Application';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,

        onPressed: () {},
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
                  SizedBox(height: 10),
                  Text(
                    companyName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    email,
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
                Navigator.of(context).pushReplacementNamed("companyhome");
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.of(context).pushNamed("companysettings");
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                Navigator.of(context).pushNamed("companyprofile");
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;

                bool isGoogleUser = false;
                if (user != null) {
                  for (final userInfo in user.providerData) {
                    if (userInfo.providerId == 'google.com') {
                      isGoogleUser = true;
                      break;
                    }
                  }
                }

                if (isGoogleUser) {
                  GoogleSignIn googleSignIn = GoogleSignIn();
                  await googleSignIn.disconnect();
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
              : applications.isEmpty
              ? Center(child: Text('No applications submitted yet.'))
              : ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  final status = app['status'].toString().toLowerCase();

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info (student name, email, status, interview date)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app['studentName'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(app['email']),
                                SizedBox(height: 6),
                                Text(
                                  getStatusMessage(status),
                                  style: TextStyle(
                                    color: statusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (app['interviewDate'] != null)
                                  Text(
                                    "Interview Date: ${(app['interviewDate'] as Timestamp).toDate().toLocal().toString().split('.')[0]}",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                              ],
                            ),
                          ),

                          // Buttons
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.picture_as_pdf),
                                onPressed: () => viewCV(app['cvUrl']),
                                tooltip: 'View CV',
                              ),
                              if (status == 'pending' || status == 'rejected')
                                IconButton(
                                  icon: Icon(
                                    Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  onPressed:
                                      () => acceptApplicationWithInterview(
                                        app['applicationId'],
                                      ),
                                  tooltip: 'Accept & Schedule Interview',
                                ),
                              if (status == 'pending' || status == 'accepted')
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  onPressed:
                                      () => updateApplicationStatus(
                                        app['applicationId'],
                                        'Rejected',
                                      ),
                                  tooltip: 'Reject Application',
                                ),
                            ],
                          ),

                          // Status chip
                          SizedBox(width: 8),
                          Chip(
                            label: Text(
                              status[0].toUpperCase() + status.substring(1),
                            ),
                            backgroundColor: statusColor(status),
                            labelStyle: Theme.of(context)
                                .primaryTextTheme
                                .labelLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
