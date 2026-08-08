// ignore_for_file: constant_identifier_names

class AppAssets {
  const AppAssets._();

  // --- Base Paths ---
  static const String _images = 'assets/images';

  static const String _icons = 'assets/icons';

  // <---------------------- Icons ------------------------------------>
  // (App Icon)
  static const String app_icon = '$_icons/cv_app_icon.svg';

  // Tab Icons
  static const String TAB_DASHBOARD = '$_icons/cv_dashboard_tab_icon.svg';
  static const String TAB_PEOPLE = '$_icons/cv_people_tab_icon.svg';
  static const String TAB_CATEGORIES = '$_icons/cv_categories_tab_icon.svg';
  static const String TAB_PROFILE = '$_icons/cv_profile_tab_icon.svg';

  // <----------------------- Images ------------------------------------>
  // (Splash)
  static const String SPLASH_BACKGROUND =
      '$_images/splash_screen_background_pic.webp';

  // (Onboarding)
  static const String ONBOARDING_ONE = '$_images/onboarding_picture_one.webp';
  static const String ONBOARDING_TWO = '$_images/onboarding_picture_two.webp';
  static const String ONBOARDING_THREE =
      '$_images/onboarding_picture_three.webp';
}
