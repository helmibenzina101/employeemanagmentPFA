/// Defines constants for named route paths used throughout the application.
///
/// Using constants helps prevent typos when navigating.
class AppRoutes {
  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password'; // Optional

  // Main Dashboard & Core Features (accessible via Shell)
  static const String dashboard = '/dashboard';          // Home / Main content
  static const String clockInOut = '/presence/clock';    // Presence / Clocking tab
  static const String leaveBalance = '/leave/balance';   // Leave / Balance tab
  static const String profile = '/profile';              // User Profile tab
  static const String announcements = '/communication/announcements'; // Info / Announcements tab

  // Profile Sub-Screens (pushed on top)
  static const String editProfile = '/profile/edit';
  static const String documents = '/profile/documents';

  // Presence Sub-Screens (pushed on top)
  static const String timesheet = '/presence/timesheet';
  static const String overtime = '/presence/overtime';     // Protected (HR/Admin)

  // Leave Sub-Screens (pushed on top)
  static const String leaveRequest = '/leave/request';
  static const String leaveApproval = '/leave/approval';   // Protected (HR/Admin)

  // Communication Sub-Screens (pushed on top)
  static const String createAnnouncement = '/communication/announcements/create'; // Protected (HR/Admin)
  // static const String chat = '/communication/chat'; // Optional

  // Performance Sub-Screens (pushed on top)
  static const String performanceReview = '/performance/review';
  static const String createReview = '/performance/review/create'; // Protected (Manager/HR/Admin)
  // static const String goals = '/performance/goals'; // Optional

  // Reporting Screens (Protected - HR/Admin)
  static const String absenceReport = '/reporting/absence';
  static const String performanceReport = '/reporting/performance'; // Placeholder
  static const String exportData = '/reporting/export';           // Placeholder

  // Admin Screens (Protected - Admin/HR)
  static const String adminDashboard = '/admin/dashboard'; // Admin tab landing
 
     // Base path for editing (ID appended)
  static const String settings = '/admin/settings'; 
  static const String userManagement = '/admin/users';
  static const String createUser = '/admin/users/create'; // Kept if separate creation needed later
  static const String userApproval = '/admin/users/approval'; // Add this line
  static const String editUser = '/admin/users/edit';        // Placeholder
}