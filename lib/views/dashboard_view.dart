import 'package:flutter/material.dart';

import '../viewmodels/dashboard_view_model.dart';
import 'nearby_facilities_view.dart';
import 'waste_report_view.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({
    required this.userName,
    required this.accessToken,
    required this.onLogout,
    super.key,
  });

  final String userName;
  final String accessToken;
  final VoidCallback onLogout;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) => Scaffold(
        body: IndexedStack(
          index: _viewModel.selectedTab,
          children: [
            HomeView(
              userName: widget.userName,
              onLogout: widget.onLogout,
              onExplore: () => _viewModel.selectTab(1),
              onReport: () => _viewModel.selectTab(2),
            ),
            const NearbyFacilitiesView(),
            WasteReportView(accessToken: widget.accessToken),
            const RecyclingGuidePage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _viewModel.selectedTab,
          onDestinationSelected: _viewModel.selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.place_outlined),
              selectedIcon: Icon(Icons.place),
              label: 'Nearby',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
              label: 'Report',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Guide',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({
    required this.userName,
    required this.onLogout,
    required this.onExplore,
    required this.onReport,
    super.key,
  });

  final String userName;
  final VoidCallback onLogout;
  final VoidCallback onExplore;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName.isEmpty
                          ? 'SMART WASTE GUIDE'
                          : 'WELCOME, ${userName.toUpperCase()}',
                      style: textTheme.labelMedium?.copyWith(
                        letterSpacing: 1.3,
                        color: const Color(0xFF527160),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Make waste count less.',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF173B2B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onLogout,
                tooltip: 'Sign out',
                icon: const Icon(Icons.logout, color: Color(0xFF216A4B)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                colors: [Color(0xFF216A4B), Color(0xFF38845E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.recycling, color: Color(0xFFD7F1D8), size: 32),
                const SizedBox(height: 16),
                Text(
                  'Small choices,\ncleaner communities.',
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Find the right place for recyclables and share local waste issues.',
                  style: TextStyle(color: Color(0xE6FFFFFF), height: 1.4),
                ),
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.near_me_outlined),
                  label: const Text('Explore nearby'),
                  style: FilledButton.styleFrom(
                    foregroundColor: const Color(0xFF174932),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Quick actions',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF173B2B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.place_outlined,
                  title: 'Find a centre',
                  subtitle: 'Recycling nearby',
                  onTap: onExplore,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.camera_alt_outlined,
                  title: 'Report waste',
                  subtitle: 'Share a local issue',
                  onTap: onReport,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Your activity',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF173B2B),
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFEAF3EC),
                child: Icon(Icons.assignment_outlined, color: Color(0xFF216A4B)),
              ),
              title: Text('No reports yet'),
              subtitle: Text('Your submitted reports will appear here.'),
            ),
          ),
          const SizedBox(height: 18),
          const Card(
            child: ListTile(
              leading: Icon(Icons.lightbulb_outline, color: Color(0xFFB47B18)),
              title: Text('Recycling tip'),
              subtitle: Text(
                'Empty and rinse containers first. Local rules can differ, so check facility guidance.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF216A4B), size: 25),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF627168),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturePage extends StatelessWidget {
  const FeaturePage({
    required this.icon,
    required this.title,
    required this.description,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: const Color(0xFFE1EEE5),
                child: Icon(icon, color: const Color(0xFF216A4B), size: 34),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF173B2B),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF627168),
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Chip(
                avatar: const Icon(Icons.auto_awesome, size: 18),
                label: Text(label),
                backgroundColor: const Color(0xFFEAF3EC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecyclingGuidePage extends StatelessWidget {
  const RecyclingGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: [
          Text(
            'Recycling guide',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF173B2B),
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quick reminders for common household materials.',
            style: TextStyle(color: Color(0xFF627168)),
          ),
          const SizedBox(height: 18),
          const _GuideCard(
            icon: Icons.local_drink_outlined,
            title: 'Plastic bottles',
            detail: 'Empty, rinse, and check whether caps are accepted locally.',
          ),
          const _GuideCard(
            icon: Icons.description_outlined,
            title: 'Paper and cardboard',
            detail: 'Keep dry and remove food-soiled sections before recycling.',
          ),
          const _GuideCard(
            icon: Icons.battery_alert_outlined,
            title: 'Batteries',
            detail: 'Use a designated collection point, not a household bin.',
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF3EC),
          child: Icon(icon, color: const Color(0xFF216A4B)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(detail),
        ),
      ),
    );
  }
}
