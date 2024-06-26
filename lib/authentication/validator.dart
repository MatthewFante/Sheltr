// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// this class describes validator methods used for validating user input in the registration form

class Validator {
  static String? validateName({required String name}) {
    if (name.isEmpty) {
      return 'Name can\'t be empty';
    }

    return null;
  }

  static String? validateEmail({required String email}) {
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (email.isEmpty) {
      return 'Email can\'t be empty';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Enter a correct email';
    }

    return null;
  }

  static String? validatePassword({required String password}) {
    if (password.isEmpty) {
      return 'Password can\'t be empty';
    } else if (password.length < 6) {
      return 'Enter a password with length at least 6';
    }

    return null;
  }

  static String? validatePhoneNum({required String phoneNum}) {
    if (phoneNum.isEmpty) {
      return 'Phone number can\'t be empty';
    } else if (phoneNum.length != 10) {
      return 'Enter a ten-digit phone number';
    }

    return null;
  }
}
