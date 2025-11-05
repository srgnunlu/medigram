class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gereklidir';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir email adresi giriniz';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }

    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }

    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gereklidir';
    }

    if (value.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalıdır';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Sadece harf, rakam ve alt çizgi kullanabilirsiniz';
    }

    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }
    return null;
  }

  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }

    if (value.length < min) {
      return '$fieldName en az $min karakter olmalıdır';
    }

    return null;
  }

  static String? maxLength(String? value, int max, String fieldName) {
    if (value != null && value.length > max) {
      return '$fieldName en fazla $max karakter olabilir';
    }

    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gereklidir';
    }

    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }
}
