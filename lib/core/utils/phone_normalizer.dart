class PhoneNormalizer {
  const PhoneNormalizer._();

  static const String _countryCode = '234';

  /// Digits only, nothing else.
  static String digits(String raw) => raw.replaceAll(RegExp(r'\D'), '');

  /// The comparison key. Last 10 digits, so all of these collapse to
  /// the same value: 08031234567, +2348031234567, 234 803 123 4567,
  /// 8031234567.
  ///
  static String key(String raw) {
    final d = digits(raw);
    return d.length <= 10 ? d : d.substring(d.length - 10);
  }

  /// Two numbers the user typed differently, same person.
  static bool sameNumber(String a, String b) {
    final ka = key(a);
    return ka.isNotEmpty && ka == key(b);
  }

  /// 0803 123 4567 — how it is written in Nigeria.
  static String display(String raw) {
    final k = key(raw);
    if (k.length != 10) return raw.trim();
    return '0${k.substring(0, 3)} ${k.substring(3, 6)} ${k.substring(6)}';
  }

  /// +2348031234567 — for tel: links and WhatsApp.
  static String e164(String raw) {
    final k = key(raw);
    if (k.length != 10) return raw.trim();
    return '+$_countryCode$k';
  }

  /// https://wa.me/2348031234567
  static Uri? whatsAppUri(String raw, {String? message}) {
    final k = key(raw);
    if (k.length != 10) return null;
    return Uri.parse(
      'https://wa.me/$_countryCode$k'
      '${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
    );
  }

  static Uri? telUri(String raw) {
    final k = key(raw);
    return k.length == 10 ? Uri.parse('tel:+$_countryCode$k') : null;
  }

  /// Looks like a complete Nigerian mobile number.
  ///
  /// Deliberately permissive. Use it to WARN, never to block a save.
  static bool looksValid(String raw) => key(raw).length == 10;

  /// Stricter, for a hint under the field rather than a hard stop.
  static bool looksLikeMobile(String raw) {
    final k = key(raw);
    if (k.length != 10) return false;
    return const {
      '70',
      '71',
      '80',
      '81',
      '90',
      '91',
    }.contains(k.substring(0, 2));
  }
}
