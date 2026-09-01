import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dashboard_card.dart';

const double kWideBreakpoint = 700;

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          Semantics(
            label: 'Toggle dark mode',
            child: Row(
              children: [
                Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                const SizedBox(width: 4),
                CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profil Mahasiswa
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.person,
                        size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mohammad Al Hafis Hidayatulloh',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NIM: 254107023005',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Semester 5 · D4 Teknik Informatika',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Grid Dashboard Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Academic Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= kWideBreakpoint ? 2 : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.6,
                  children: const [
                    DashboardCard(
                      title: 'Assignments',
                      value: '8',
                      icon: Icons.assignment,
                    ),
                    DashboardCard(
                      title: 'Attendance',
                      value: '92%',
                      icon: Icons.check_circle,
                    ),
                    DashboardCard(
                      title: 'Portfolio',
                      value: 'Ready',
                      icon: Icons.folder_special,
                    ),
                    DashboardCard(
                      title: 'Current Week',
                      value: '02',
                      icon: Icons.calendar_today,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
