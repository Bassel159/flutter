import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  bool isLoading = true;
  String studentId = "";
  List<Map<String, dynamic>> applications = [];

  @override
  void initState() {
    super.initState();
    loadApplications();
  }

  Future<void> loadApplications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    studentId = uid;

    final appsSnapshot =
        await FirebaseFirestore.instance
            .collection('applications')
            .where('studentId', isEqualTo: studentId)
            .orderBy('timestamp', descending: true)
            .get();

    Map<String, Map<String, dynamic>> latestApplicationsByCompany = {};

    for (var appDoc in appsSnapshot.docs) {
      final appData = appDoc.data();
      final companyId = appData['companyId'] as String;

      // Add only the latest application per company (since apps are ordered descending)
      if (!latestApplicationsByCompany.containsKey(companyId)) {
        final companyDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(companyId)
                .get();
        final companyData = companyDoc.data() ?? {};

        latestApplicationsByCompany[companyId] = {
          'applicationId': appDoc.id,
          'companyId': companyId,
          'companyName': companyData['companyName'] ?? 'Unknown Company',
          'status': appData['status'] ?? 'Pending',
          'cvUrl': appData['cvUrl'] ?? '',
          'appliedAt': appData['timestamp'],
          'interviewDate': appData['interviewDate'],
        };
      }
    }

    setState(() {
      applications = latestApplicationsByCompany.values.toList();
      isLoading = false;
    });
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
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
      appBar: AppBar(
        title: Text('My Applications'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : applications.isEmpty
              ? Center(child: Text('You have not applied to any company yet.'))
              : ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  final status = app['status'];
                  String date2 =
                      app['interviewDate'] != null
                          ? DateFormat(
                            'yyyy-MM-dd hh:mm a',
                          ).format((app['interviewDate'] as Timestamp).toDate())
                          : 'Unknown Date';
                  final date =
                      app['appliedAt'] != null
                          ? DateFormat(
                            'yyyy-MM-dd hh:mm a',
                          ).format((app['appliedAt'] as Timestamp).toDate())
                          : 'Unknown Date';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(app['companyName']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getStatusMessage(status),
                            style: TextStyle(
                              color: statusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text("Applied on: $date"),
                          if (date2 != null)
                            Text(
                              "Interview Date: $date2",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                        ],
                      ),

                      trailing: Chip(
                        label: Text(status),
                        backgroundColor: statusColor(status),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // Optionally add application details here
                      },
                    ),
                  );
                },
              ),
    );
  }
}
