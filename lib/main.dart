import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lockers_app/providers/lockers_student_provider.dart';
import 'package:lockers_app/screens/assignation/assignation_overview_screen.dart';
import 'package:lockers_app/screens/components/side_menu_app.dart';
import 'package:lockers_app/screens/dashboard/dashboard_overview_screen.dart';
import 'package:lockers_app/screens/lockers/locker_details_screen.dart';
import 'package:lockers_app/screens/lockers/lockers_overview_screen.dart';
import 'package:lockers_app/screens/students/student_details_screen.dart';
import 'package:lockers_app/screens/students/students_overview_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'infrastructure/firebase_rtdb_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // if(kIsWeb)

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              LockerStudentProvider(FirebaseRTDBService.instance),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LockersApp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xfff5f5fd),
        ),
        routes: {
          DashboardOverviewScreen.routeName: (context) =>
              const DashboardOverviewScreen(),
          LockersOverviewScreen.routeName: (context) =>
              const LockersOverviewScreen(),
          StudentsOverviewScreen.routeName: (context) =>
              const StudentsOverviewScreen(),
          LockerDetailsScreen.routeName: (context) =>
              const LockerDetailsScreen(),
          StudentDetailsScreen.routeName: (context) =>
              const StudentDetailsScreen(),
        },
        home: const MyWidget(),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  SideMenuController sideMenuController = SideMenuController();
  PageController page = PageController();

  @override
  void initState() {
    sideMenuController.addListener((p0) {
      page.jumpToPage(p0);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenuApp(sideMenuController: sideMenuController),
          Expanded(
            child: PageView(
              controller: page,
              children: const [
                // PrepareDatabaseScreen(),
                DashboardOverviewScreen(),
                LockersOverviewScreen(),
                StudentsOverviewScreen(),
                AssignationOverviewScreen()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrepareDatabaseScreen extends StatefulWidget {
  const PrepareDatabaseScreen({super.key});

  @override
  State<PrepareDatabaseScreen> createState() => _PrepareDatabaseScreenState();
}

class _PrepareDatabaseScreenState extends State<PrepareDatabaseScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  Future<void> didChangeDependencies() async {
    if (_isInit) {
      _isLoading = true;
      await FirebaseRTDBService.instance.prepareDataBase();
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : const Center(child: Text("DataLoaded"));
  }
}
