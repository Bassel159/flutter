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

String? selectedUniversity;
String? selectedMajor;
String? selectedGPA;
String? selectedYearOfStudy;
String? selectedExpectedGraduation;
String? selectedPreferredIndustry;

final List<String> universities = [
  "Ajloun National University",
  "Al al-Bayt University",
  "Al-Ahliyya Amman University",
  "Al-Balqa Applied University",
  "Al-Hussein Bin Talal University",
  "Al Hussein Technical University",
  "Al-Isra University",
  "Al-Zaytoonah University of Jordan",
  "American University of Madaba",
  "Amman Arab University",
  "Aqaba Medical Sciences University",
  "Aqaba University of Technology",
  "Applied Science Private University",
  "Arab Academy for Banking and Financial Sciences",
  "Arab Open University",
  "Columbia University: Amman Branch",
  "German-Jordanian University",
  "Hashemite University",
  "Ibn Sina University for Medical Sciences",
  "Irbid National University",
  "Jadara University",
  "Jerash Private University",
  "Jordan Academy for Maritime Studies",
  "Jordan Academy of Music",
  "Jordan Institute of Banking Studies",
  "Jordan Media Institute",
  "Jordan University of Science and Technology",
  "Luminus Technical University College",
  "Middle East University",
  "Mutah University",
  "National University College of Technology",
  "New York Institute of Technology, Madaba",
  "Petra University",
  "Philadelphia University",
  "Princess Sumaya University for Technology",
  "Queen Noor Civil Aviation Technical College",
  "Tafila Technical University",
  "The World Islamic Science & Education University (W.I.S.E)",
  "University of Jordan",
  "Yarmouk University",
  "Zarqa University",
];
final List<String> Majors = [
  "Computer Science",
  "Software Engineering",
  "Cybersecurity",
  "Data Science",
  "Artificial Intelligence",
  "Computer Engineering",
  "Computer Information Systems",
  "Game Development",
];
final List<String> GPA = [
  "Distinguished",
  "Excellent",
  "Very Good",
  "Good",
  "Fair",
];
final List<String> year = [
  "1st Year",
  "2nd Year",
  "3rd Year",
  "4th Year",
  "5th Year"
];
final List<String> gradyear = [
  "2025","2026","2027","2028","2029","2030","2031",
];
final List<String> prefind = [
  "Mobile Development",
  "Web Development",
  "Software Development",
  "Frontend Development",
  "Backend Development",
  "Full Stack Development",
  "DevOps Engineering",
  "Database Administration",
  "Network Engineering",
  "Cloud Engineering",
  "Data Science",
  "QA Engineering",
  "Cybersecurity",
];

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
    final appsSnapshot = await FirebaseFirestore.instance
        .collection('applications')
        .where('companyId', isEqualTo: companyId)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> tempList = [];

    for (var appDoc in appsSnapshot.docs) {
      final appData = appDoc.data();
      final studentId = appData['studentId'];

      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();
      final studentData = studentDoc.data() ?? {};

      tempList.add({
        'applicationId': appDoc.id,
        'studentName': studentData['studentName'] ?? 'Unknown Student',
        'email': studentData['email'] ?? '',
        'university': studentData['university'] ?? '',
        'major': studentData['major'] ?? '',
        'gpa': studentData['gpa'] ?? '',
        'yearofstudy': studentData['yearofstudy'] ?? '',
        'expectedgrad': studentData['expectedgrad'] ?? '',
        'preferredindustry': studentData['preferredindustry'] ?? '',
        'cvUrl': appData['cvUrl'] ?? '',
        'status': appData['status'] ?? 'Pending',
        'appliedAt': appData['timestamp'],
        'interviewDate': appData['interviewDate'],
        'studentId': studentId,
      });
    }

    // Remove duplicates (keep latest application per student)
    Map<String, Map<String, dynamic>> uniqueApplications = {};
    for (var app in tempList) {
      if (!uniqueApplications.containsKey(app['studentId'])) {
        uniqueApplications[app['studentId']] = app;
      }
    }

    // Convert to list
    List<Map<String, dynamic>> filteredList = uniqueApplications.values.toList();

    // Apply filters if any of the selected fields is not null
    filteredList = filteredList.where((app) {
      bool matches = true;

      if (selectedUniversity != null && selectedUniversity!.isNotEmpty) {
        matches &= app['university'] == selectedUniversity;
      }
      if (selectedMajor != null && selectedMajor!.isNotEmpty) {
        matches &= app['major'] == selectedMajor;
      }
      if (selectedGPA != null && selectedGPA!.isNotEmpty) {
        matches &= app['gpa'] == selectedGPA;
      }
      if (selectedYearOfStudy != null && selectedYearOfStudy!.isNotEmpty) {
        matches &= app['yearofstudy'] == selectedYearOfStudy;
      }
      if (selectedExpectedGraduation != null && selectedExpectedGraduation!.isNotEmpty) {
        matches &= app['expectedgrad'] == selectedExpectedGraduation;
      }
      if (selectedPreferredIndustry != null && selectedPreferredIndustry!.isNotEmpty) {
        matches &= app['preferredindustry'] == selectedPreferredIndustry;
      }

      return matches;
    }).toList();

    setState(() {
      applications = filteredList;
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

        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Text("Filter Students", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: selectedUniversity,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: 'University'),
                          items: universities.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                          onChanged: (value) => setModalState(() => selectedUniversity = value),
                        ),
                        SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          value: selectedMajor,
                          decoration: InputDecoration(labelText: 'Major'),
                          items: Majors.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                          onChanged: (value) => setModalState(() => selectedMajor = value),
                        ),
                        SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          value: selectedGPA,
                          decoration: InputDecoration(labelText: 'GPA'),
                          items: GPA.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                          onChanged: (value) => setModalState(() => selectedGPA = value),
                        ),
                        SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          value: selectedYearOfStudy,
                          decoration: InputDecoration(labelText: 'Year of Study'),
                          items: year.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                          onChanged: (value) => setModalState(() => selectedYearOfStudy = value),
                        ),
                        SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          value: selectedExpectedGraduation,
                          decoration: InputDecoration(labelText: 'Expected Graduation'),
                          items: gradyear.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                          onChanged: (value) => setModalState(() => selectedExpectedGraduation = value),
                        ),
                        SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          value: selectedPreferredIndustry,
                          decoration: InputDecoration(labelText: 'Preferred Industry'),
                          items: prefind.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                          onChanged: (value) => setModalState(() => selectedPreferredIndustry = value),
                        ),
                        SizedBox(height: 20),

                           ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary),
                            onPressed: () {
                              print("University: $selectedUniversity");
                              print("Major: $selectedMajor");
                              print("GPA: $selectedGPA");
                              print("Year of Study: $selectedYearOfStudy");
                              print("Expected Graduation: $selectedExpectedGraduation");
                              print("Preferred Industry: $selectedPreferredIndustry");
                              Navigator.of(context).pushReplacementNamed('companyhome');

                            },
                            child: Text("Apply Filters"),
                          ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary),
                          onPressed: () {
                            setState(() {
                              selectedUniversity = null;
                              selectedMajor = null;
                              selectedGPA = null;
                              selectedYearOfStudy = null;
                              selectedExpectedGraduation = null;
                              selectedPreferredIndustry = null;
                            });
                            Navigator.of(context).pushReplacementNamed('companyhome');

                          },
                          child: Text("Clear"),
                        ),

                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.filter_list),
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
                  CircleAvatar(radius: 30, child: Icon(Icons.business, size: 40)),
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
              leading: Icon(Icons.business),
              title: Text("Profile"),
              onTap: () {
                Navigator.of(context).pushNamed("companyprofile");
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
                        Text(app['university']),
                        Text(app['major']),
                        Text(app['gpa']),
                        Text(app['yearofstudy']),
                        Text(app['expectedgrad']),
                        Text(app['preferredindustry']),
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