import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // For StreamSubscription (though listener is removed)

// Import App Configuration & Routes
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/app/navigation/app_routes.dart';

// Import Core Providers & Enums
import 'package:employeemanagment/core/providers/auth_providers.dart'; // Provides authStateChangesProvider
import 'package:employeemanagment/core/providers/user_providers.dart'; // Provides currentUserDataProvider
import 'package:employeemanagment/core/enums/user_role.dart';

// Import Core Widgets
import 'package:employeemanagment/core/widgets/error_message_widget.dart';

// --- Import ALL Screen Files ---
// (Includes all screen imports as listed previously)
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
import 'package:employeemanagment/features/admin/screens/create_user_screen.dart';
import 'package:employeemanagment/features/admin/screens/edit_user_screen.dart';
import 'package:employeemanagment/features/admin/screens/admin_dashboard_screen.dart';
import 'package:employeemanagment/features/admin/screens/settings_screen.dart';
// --- End Screen Imports ---


/// Provides the configured GoRouter instance for the application.
final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state changes to trigger route evaluation when needed.
  final authStateChanges = ref.watch(authStateChangesProvider);
  // Watch user data too, as redirect logic depends on it.
  final currentUserData = ref.watch(currentUserDataProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,

    // --- SIMPLIFIED Redirect Logic ---
    // This logic primarily handles forcing users to login and basic role checks
    // AFTER they are already logged in AND have valid Firestore data.
    // The check for pending/inactive users after login is moved to DashboardScreen.
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIntoAuth = authStateChanges.value != null; // Check current auth state
      final user = currentUserData; // Get current user data state (UserModel?)

      final String currentLocation = state.matchedLocation;
      final bool onAuthScreen = currentLocation == AppRoutes.login ||
                                currentLocation == AppRoutes.register;

      print("[Redirect Check V4] Location: $currentLocation, LoggedIntoAuth: $loggedIntoAuth, User Status: ${user?.status}, User Active: ${user?.isActive}");

      // 1. Not Logged In
      if (!loggedIntoAuth) {
        return onAuthScreen ? null : AppRoutes.login; // Go to login if not logged in and not on auth page
      }

      // 2. Logged In
      else {
        // A) On Auth Screen (Login/Register) -> ALWAYS redirect to Dashboard
        // The Dashboard will handle verification if the user is actually valid (active/approved)
        if (onAuthScreen) {
          print("[Redirect V4] To Dashboard (Auth OK, leaving Auth screen)");
          return AppRoutes.dashboard;
        }
        // B) Not on Auth Screen (Already inside the app)
        else {
          // If user data is suddenly null/invalid WHILE INSIDE the app, force logout/login
          // This handles cases like admin deactivating the account remotely.
          if (user == null || !user.isActive || user.status != 'active') {
             print("[Redirect V4] To Login (User data became invalid/unavailable inside app)");
             // Consider triggering logout *here* as well for immediate effect, using fire-and-forget
             // ref.read(authServiceProvider).signOut().catchError((_){ print("Error signing out in redirect"); });
             return AppRoutes.login; // Force back to login
          }

          // Role-Based Checks (Only if user is valid and inside the app)
          final bool isAdminOrHR = user.role == UserRole.admin || user.role == UserRole.rh;
          const String adminRoutesPrefix = '/admin';
          final List<String> protectedSpecificRoutes = [
             AppRoutes.leaveApproval, AppRoutes.createAnnouncement, AppRoutes.overtime,
             AppRoutes.createReview, AppRoutes.absenceReport, AppRoutes.performanceReport,
             AppRoutes.exportData, AppRoutes.userManagement, AppRoutes.settings,
             AppRoutes.createUser, AppRoutes.editUser,
          ];
          final bool isAccessingProtectedRoute =
              currentLocation.startsWith(adminRoutesPrefix) ||
              protectedSpecificRoutes.any((route) => currentLocation.startsWith(route));

          if (isAccessingProtectedRoute && !isAdminOrHR) {
              print("[Redirect V4] To Dashboard (Unauthorized access attempt to $currentLocation)");
              return AppRoutes.dashboard;
          }
          // --- End Role-Based Checks ---

          // No redirect needed if valid, authorized, and not on auth screen
          print("[Redirect V4] No redirect needed for $currentLocation");
          return null;
        }
      }
    },
    // --- End SIMPLIFIED Redirect ---

    // --- refreshListenable REMOVED ---

    // --- Route Definitions ---
    routes: <RouteBase>[
       // Define all GoRoute and ShellRoute entries as previously listed
       // Public
       GoRoute( path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
       GoRoute( path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
       // Shell
       ShellRoute(
           builder: (context, state, child) => DashboardLayout(child: child),
           routes: [ /* ... all shell routes ... */
               GoRoute( path: AppRoutes.dashboard, builder: (context, state) => const DashboardScreen()),
               GoRoute( path: AppRoutes.clockInOut, builder: (context, state) => const ClockInOutScreen()),
               GoRoute( path: AppRoutes.leaveBalance, builder: (context, state) => const LeaveBalanceScreen()),
               GoRoute( path: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),
               GoRoute( path: AppRoutes.announcements, builder: (context, state) => const AnnouncementsScreen()),
               GoRoute( path: AppRoutes.adminDashboard, builder: (context, state) => const AdminDashboardScreen()),
           ]
       ),
       // Other Features (Pushed)
       GoRoute( path: AppRoutes.editProfile, builder: (context, state) => const EditProfileScreen()),
       GoRoute( path: AppRoutes.documents, builder: (context, state) => const DocumentsScreen()),
       GoRoute( path: AppRoutes.timesheet, builder: (context, state) => const TimesheetScreen()),
       GoRoute( path: AppRoutes.overtime, builder: (context, state) => const OvertimeManagementScreen()),
       GoRoute( path: AppRoutes.leaveRequest, builder: (context, state) => const LeaveRequestScreen()),
       GoRoute( path: AppRoutes.leaveApproval, builder: (context, state) => const LeaveApprovalScreen()),
       GoRoute( path: AppRoutes.createAnnouncement, builder: (context, state) => const CreateAnnouncementScreen()),
       GoRoute( path: AppRoutes.performanceReview, builder: (context, state) => const PerformanceReviewScreen()),
       GoRoute( path: AppRoutes.createReview, builder: (context, state) => CreateReviewScreen(employeeId: state.uri.queryParameters['employeeId'])),
       GoRoute( path: AppRoutes.absenceReport, builder: (context, state) => const AbsenceReportScreen()),
       GoRoute( path: AppRoutes.performanceReport, builder: (context, state) => const PerformanceReportScreen()),
       GoRoute( path: AppRoutes.exportData, builder: (context, state) => const ExportDataScreen()),
       GoRoute( path: AppRoutes.userManagement, builder: (context, state) => const UserManagementScreen()),
       GoRoute( path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
       GoRoute( path: AppRoutes.createUser, builder: (context, state) => const CreateUserScreen()),
       GoRoute(
          path: '${AppRoutes.editUser}/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId'];
            if (userId == null) return const Scaffold(body: ErrorMessageWidget(message: 'ID Utilisateur manquant.'));
            return EditUserScreen(userId: userId);
          },
        ),
    ],

    // --- Error Handler ---
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Non Trouvée')),
      body: Center(child: Text('Erreur 404: Route "${state.error?.message ?? state.matchedLocation}" non trouvée.\n${state.error}')),
    ),
  );
});

// --- Helper class for GoRouter refresh listening (Can be removed) ---
class GoRouterRefreshCombinedStream extends ChangeNotifier { /* ... */ }


// Add this at the bottom of the file

// --- DashboardLayout Widget ---
class DashboardLayout extends ConsumerStatefulWidget {
  final Widget child;
  const DashboardLayout({required this.child, Key? key}) : super(key: key);
  
  @override
  ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout> {
  final List<String> _bottomNavRoutes = [
    AppRoutes.dashboard,
    AppRoutes.clockInOut,
    AppRoutes.leaveBalance,
    AppRoutes.profile,
    AppRoutes.announcements,
    AppRoutes.adminDashboard
  ];
  
  int _calculateSelectedIndex(BuildContext context, bool isAdminOrHR) {
    final String location = GoRouterState.of(context).matchedLocation;
    final List<String> activeRoutes = List.from(_bottomNavRoutes);
    if (!isAdminOrHR) activeRoutes.remove(AppRoutes.adminDashboard);
    
    int index = activeRoutes.indexWhere((route) => location.startsWith(route) && route.length > 1);
    if (index == -1 && location == AppRoutes.dashboard) index = activeRoutes.indexOf(AppRoutes.dashboard);
    return index != -1 ? index : 0;
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider);
    final bool showAdminTab = user?.role == UserRole.admin || user?.role == UserRole.rh;
    final int selectedIndex = _calculateSelectedIndex(context, showAdminTab);
    
    final List<BottomNavigationBarItem> bottomNavItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Accueil'),
      const BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), activeIcon: Icon(Icons.timer), label: 'Pointage'),
      const BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Congés'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      const BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'Infos'),
      if (showAdminTab) const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
    ];
    
    final List<String> activeNavRoutes = List.from(_bottomNavRoutes);
    if (!showAdminTab) activeNavRoutes.remove(AppRoutes.adminDashboard);
    
    int validSelectedIndex = selectedIndex;
    if (validSelectedIndex >= bottomNavItems.length) validSelectedIndex = 0;
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavItems,
        currentIndex: validSelectedIndex,
        onTap: (index) {
          if (index >= 0 && index < activeNavRoutes.length) {
            context.go(activeNavRoutes[index]);
          }
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

