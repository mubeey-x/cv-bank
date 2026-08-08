class AppRoutes {
  AppRoutes._();

  // ----- Splash & Onboarding -----
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // ----- Authentication -----
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';

  // ===== APP SHELL: tabs =====
  static const String dashboard = '/home';
  static const String people = '/people';
  static const String categories = '/categories';
  static const String profile = '/profile';

  // ===== PEOPLE =====
  // Literal paths are declared before parameterised ones on purpose.
  static const String peopleCreate = '/people/create';
  static const String peopleDetail = '/people/:id';
  static const String peopleEdit = '/people/:id/edit';
  static const String peopleDocument = '/people/:id/document/:documentId';

  static String peopleDetailPath(String id) => '/people/$id';
  static String peopleEditPath(String id) => '/people/$id/edit';
  static String peopleDocumentPath(String id, String documentId) =>
      '/people/$id/document/$documentId';

  /// Intake opened from inside a category, so the chip is pre-selected.
  static String peopleCreateInCategory(String categoryId) =>
      '$peopleCreate?categoryId=$categoryId';

  // ===== CATEGORIES =====
  // Create and rename are bottom sheets, not routes.
  static const String categoryDetail = '/categories/:id';

  static String categoryDetailPath(String id) => '/categories/$id';

  // ===== PROFILE =====
  static const String profileEdit = '/profile/edit';
}
