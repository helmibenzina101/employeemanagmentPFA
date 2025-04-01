import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // For StreamSubscription

// Import App Configuration
import 'package:employeemanagment/app/config/constants.dart'; // Import for AppConstants
import 'package:employeemanagment/app/navigation/app_routes.dart';

// Import Core Providers & Enums
import 'package:employeemanagment/core/providers/auth_providers.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/enums/user_role.dart';

// Import Core Widgets
import 'package:employeemanagment/core/widgets/error_message_widget.dart';

// --- Import ALL Screen Files ---
// (Includes all screen imports as listed in the previous response)
import 'package:employeemanagment/features/auth/screens/login_screen.dart';
import 'package:employeemanagment/features/auth/screens/register_screen.dart';
import 'package:employeemanagment/features/dashboard/screens/dashboard_screen.dart';
import 'package:employeemanagment/features/profile/screens/profile_screen.dart';
import 'package:employeemanagment/features/profile/screens/edit_profile_screen.dart';
import 'package:employeemanagment/features/profile/screens/documents_screen.dart';
import 'package:employeemanagment/features/presence/screens/clock_in_out_screen.dart';
import 'package:employeemanagment/features/presence/screens/timesheet_screen.dart';
import 'package:employeemanagment/features/presence/screens/overtime_management_screen.dart';
import 'package:employeemanagment/features/leave/screens/leave_request_screen.dart';
import 'package:employeemanagment/features/leave/screens/leave_balance_screen.dart';
import 'package:employeemanagment/features/leave/screens/leave_approval_screen.dart';
import 'package:employeemanagment/features/communication/screens/announcements_screen.dart';
import 'package:employeemanagment/features/communication/screens/create_announcement_screen.dart';
import 'package:employeemanagment/features/performance/screens/performance_review_screen.dart';
import 'package:employeemanagment/features/performance/screens/create_review_screen.dart';
import 'package:employeemanagment/features/reporting/screens/absence_report_screen.dart';
import 'package:employeemanagment/features/reporting/screens/performance_report_screen.dart';
import 'package:employeemanagment/features/reporting/screens/export_data_screen.dart';
import 'package:employeemanagment/features/admin/screens/user_management_screen.dart';
import 'package:employeemanagment/features/admin/screens/edit_user_screen.dart';
import 'package:employeemanagment/features/admin/screens/admin_dashboard_screen.dart';
import 'package:employeemanagment/features/admin/screens/settings_screen.dart';
// --- End Screen Imports ---


/// Provides the configured GoRouter instance for the application.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateChanges = ref.watch(authStateChangesProvider);
  final currentUserStream = ref.watch(currentUserStreamProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) {
      // ... (redirect logic as provided previously - no changes needed here) ...
       final bool loggedIn = authStateChanges.value != null;
       final bool onAuthScreen = state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.register;
       if (!loggedIn && !onAuthScreen) return AppRoutes.login;
       if (loggedIn && onAuthScreen) return AppRoutes.dashboard;
       if (loggedIn) {
          final user = ref.read(currentUserDataProvider);
          final bool isAdminOrHR = user?.role == UserRole.admin || user?.role == UserRole.rh;
          const String adminRoutesPrefix = '/admin';
          final List<String> protectedSpecificRoutes = [
            AppRoutes.leaveApproval, AppRoutes.createAnnouncement, AppRoutes.overtime,
            AppRoutes.createReview, AppRoutes.absenceReport, AppRoutes.performanceReport,
            AppRoutes.exportData, AppRoutes.userManagement, AppRoutes.settings, AppRoutes.editUser
          ];
          final bool isAccessingProtectedRoute =
              state.matchedLocation.startsWith(adminRoutesPrefix) ||
              protectedSpecificRoutes.any((route) => state.matchedLocation.startsWith(route));
          if (isAccessingProtectedRoute && !isAdminOrHR) return AppRoutes.dashboard;
       }
       return null;
    },

    refreshListenable: GoRouterRefreshCombinedStream([
      ref.watch(authStateChangesProvider.stream),
      ref.watch(currentUserStreamProvider.stream),
    ]),

    // --- Route Definitions ---
    routes: <RouteBase>[
      // --- Public Routes ---
      GoRoute( path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute( path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),

      // --- Main App Shell ---
      ShellRoute(
          // The DashboardLayout widget defines the shell UI (e.g., BottomNav)
          builder: (context, state, child) => DashboardLayout(child: child),
          // Routes managed by the shell
          routes: [
              GoRoute( path: AppRoutes.dashboard, builder: (context, state) => const DashboardScreen()),
              GoRoute( path: AppRoutes.clockInOut, builder: (context, state) => const ClockInOutScreen()),
              GoRoute( path: AppRoutes.leaveBalance, builder: (context, state) => const LeaveBalanceScreen()),
              GoRoute( path: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),
              GoRoute( path: AppRoutes.announcements, builder: (context, state) => const AnnouncementsScreen()),
              GoRoute( path: AppRoutes.adminDashboard, builder: (context, state) => const AdminDashboardScreen()),
          ]
      ),

      // --- Other Top-Level/Pushed Routes ---
      // (Includes all GoRoute definitions for profile, presence, leave, etc. as listed previously)
      GoRoute( path: AppRoutes.editProfile, builder: (context, state) => const EditProfileScreen()),
      GoRoute( path: AppRoutes.documents, builder: (context, state) => const DocumentsScreen()),
      GoRoute( path: AppRoutes.timesheet, builder: (context, state) => const TimesheetScreen()),
      GoRoute( path: AppRoutes.overtime, builder: (context, state) => const OvertimeManagementScreen()),
      GoRoute( path: AppRoutes.leaveRequest, builder: (context, state) => const LeaveRequestScreen()),
      GoRoute( path: AppRoutes.leaveApproval, builder: (context, state) => const LeaveApprovalScreen()),
      GoRoute( path: AppRoutes.createAnnouncement, builder: (context, state) => const CreateAnnouncementScreen()),
      GoRoute( path: AppRoutes.performanceReview, builder: (context, state) => const PerformanceReviewScreen()),
      GoRoute(
        path: AppRoutes.createReview,
        builder: (context, state) {
          final employeeId = state.uri.queryParameters['employeeId'];
          return CreateReviewScreen(employeeId: employeeId);
        }
      ),
      GoRoute( path: AppRoutes.absenceReport, builder: (context, state) => const AbsenceReportScreen()),
      GoRoute( path: AppRoutes.performanceReport, builder: (context, state) => const PerformanceReportScreen()),
      GoRoute( path: AppRoutes.exportData, builder: (context, state) => const ExportDataScreen()),
      GoRoute( path: AppRoutes.userManagement, builder: (context, state) => const UserManagementScreen()),
      GoRoute( path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(
         path: '${AppRoutes.editUser}/:userId',
         builder: (context, state) {
           final userId = state.pathParameters['userId'];
           if (userId == null) {
              return const Scaffold(body: ErrorMessageWidget(message: 'ID Utilisateur manquant.'));
           }
           return EditUserScreen(userId: userId);
         },
       ),
    ],

    // --- Error Handler ---
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Non Trouvée')),
      body: Center(child: Text('Erreur 404: La route "${state.error?.message ?? state.matchedLocation}" n\'existe pas.\n${state.error}')),
    ),
  );
});


// --- Helper class for GoRouter refresh listening ---
class GoRouterRefreshCombinedStream extends ChangeNotifier {
  late final List<StreamSubscription<dynamic>> _subscriptions;
  GoRouterRefreshCombinedStream(List<Stream<dynamic>> streams) {
    notifyListeners();
    _subscriptions = streams.map((stream) =>
      stream.asBroadcastStream().listen((_) => notifyListeners(), onError: (_) => notifyListeners())
    ).toList();
  }
  @override
  void dispose() {
    for (final subscription in _subscriptions) { subscription.cancel(); }
    super.dispose();
  }
}


// --- DashboardLayout Widget ---
// TODO: Move this class to its own file: lib/features/dashboard/widgets/dashboard_layout.dart
class DashboardLayout extends ConsumerStatefulWidget {
 final Widget child;
 const DashboardLayout({required this.child, super.key});

 @override
 ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout> {
 // Routes corresponding to bottom nav items (order matters!)
 final List<String> _bottomNavRoutes = [
   AppRoutes.dashboard, AppRoutes.clockInOut, AppRoutes.leaveBalance,
   AppRoutes.profile, AppRoutes.announcements, AppRoutes.adminDashboard,
 ];

 // Calculate selected index based on current route location
 int _calculateSelectedIndex(BuildContext context, bool isAdminOrHR) {
    final String location = GoRouterState.of(context).matchedLocation;
    // Create list of active routes based on role
    final List<String> activeRoutes = List.from(_bottomNavRoutes);
    if (!isAdminOrHR) {
       activeRoutes.remove(AppRoutes.adminDashboard); // Remove admin route if not admin/HR
    }
    // Find the best match (handles sub-routes)
    int index = activeRoutes.indexWhere((route) => location.startsWith(route) && route != '/');
    // Default to 0 if no match
    return index != -1 ? index : 0;
  }

 @override
 Widget build(BuildContext context) {
   final user = ref.watch(currentUserDataProvider);
   final bool showAdminTab = user?.role == UserRole.admin || user?.role == UserRole.rh;
   final int selectedIndex = _calculateSelectedIndex(context, showAdminTab);

   // Define BottomNavigationBar items conditionally
   final List<BottomNavigationBarItem> bottomNavItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Accueil'),
      const BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), activeIcon: Icon(Icons.timer), label: 'Pointage'),
      const BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Congés'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      const BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'Infos'),
      if (showAdminTab) // Conditionally add Admin item
        const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
   ];

   // Create list of routes active in the current BottomNav state
   final List<String> activeNavRoutes = List.from(_bottomNavRoutes);
   if (!showAdminTab) {
     activeNavRoutes.remove(AppRoutes.adminDashboard);
   }

   return Scaffold(
     body: widget.child, // Display the screen corresponding to the current route
     bottomNavigationBar: BottomNavigationBar(
       items: bottomNavItems, // Use the conditionally built list
       currentIndex: selectedIndex, // Highlight the correct tab
       onTap: (index) { // Navigate when a tab is tapped
           if (index >= 0 && index < activeNavRoutes.length) {
              context.go(activeNavRoutes[index]); // Navigate to the route for the tapped index
           }
       },
       type: BottomNavigationBarType.fixed, // Keep labels visible
       // Styles inherit from AppTheme
     ),
   );
 }
}