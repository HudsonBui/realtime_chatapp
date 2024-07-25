import 'package:flutter/material.dart';
import 'package:realtime_chatapp/pages/dashboard/db_content.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return const DashboardContent();
  }
}
