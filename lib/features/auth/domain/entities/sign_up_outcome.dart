/// Sign-up ends in one of two places depending on whether email
/// confirmation is switched on, and the UI has to know which.
enum SignUpOutcome {
  /// A code was emailed. Go to the OTP screen.
  verificationRequired,

  /// A session already exists. Go straight to the dashboard.
  signedIn,
}
