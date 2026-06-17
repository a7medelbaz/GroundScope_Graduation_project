import 'dart:math';

class CredentialsGenerator {
  static const String _domain = 'groundscope.com';

  static String supervisorEmail(String serviceTypeName) {
    final slug = _slugify(serviceTypeName);
    return 'supervisor.$slug@$_domain';
  }

  static String unitManagerEmail(String unitName) {
    final slug = _slugify(unitName);
    return 'manager.$slug@$_domain';
  }

  static String generatePassword() {
    final random = Random.secure();
    final digits = List.generate(4, (_) => random.nextInt(10)).join();
    const specials = '!@#\$%';
    final special = specials[random.nextInt(specials.length)];
    return 'GroundScope$digits$special';
  }

  static String _slugify(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
