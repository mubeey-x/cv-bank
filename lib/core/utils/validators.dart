class Validators {
  const Validators._();

  static final _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static bool isEmail(String value) => _email.hasMatch(value.trim());

  static bool isPassword(String value) => value.length >= 8;

  static bool isNotBlank(String value) => value.trim().isNotEmpty;
}
