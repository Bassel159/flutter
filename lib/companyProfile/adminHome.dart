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
  String selectedFilter = 'الكل';

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
      case 'مقبولة':
        return isApproved == true;
      case 'مرفوضة':
        return isApproved == false;
      case 'غير محددة':
        return isApproved == null;
      default:
        return true; // الكل
    }
  }

  void showConfirmationDialog({
    required BuildContext context,
    required String userId,
    required bool isApprove,
  }) {
    String title = isApprove ? 'تأكيد القبول' : 'تأكيد الرفض';
    String message =
    isApprove
        ? 'هل أنت متأكد من قبول الشركة؟'
        : 'هل أنت متأكد من رفض الشركة؟';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('نعم'),
            onPressed: () async {
              Navigator.of(context).pop();
              if (isApprove) {
                approveCompany(userId);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('تم قبول الشركة')));
              } else {
                rejectCompany(userId);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('تم رفض الشركة')));
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
        title: const Text("لوحة تحكم الأدمن"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshPage,
            tooltip: 'تحديث',
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
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.of(context).pushReplacementNamed("home");
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.of(context).pushNamed("settings");
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
              ['الكل', 'مقبولة', 'مرفوضة', 'غير محددة']
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
                labelText: "تصفية حسب الحالة",
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
                  return Center(child: Text('لا توجد طلبات حالياً'));
                }

                final requests =
                snapshot.data!.docs.where(shouldDisplay).toList();

                if (requests.isEmpty) {
                  return Center(
                    child: Text('لا توجد طلبات حسب الفلتر المحدد'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final user = requests[index];
                    final name = user['companyName'] ?? 'بدون اسم';
                    final email = user['email'] ?? 'بدون بريد';
                    final isApproved = user['isApproved'];

                    String statusText;
                    if (isApproved == true) {
                      statusText = 'الحالة: مقبولة ✅';
                    } else if (isApproved == false) {
                      statusText = 'الحالة: مرفوضة ❌';
                    } else {
                      statusText = 'الحالة: غير محددة';
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
                              child: Text('قبول'),
                            ),
                            PopupMenuItem(
                              value: 'reject',
                              child: Text('رفض'),
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