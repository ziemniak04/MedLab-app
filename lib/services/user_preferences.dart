import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences instance = UserPreferences._init();
  SharedPreferences? _prefs;

  UserPreferences._init();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User name
  Future<void> setUserName(String name) async {
    await _prefs?.setString('userName', name);
  }

  String? getUserName() {
    return _prefs?.getString('userName');
  }

  // First launch
  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs?.setBool('isFirstLaunch', isFirst);
  }

  bool isFirstLaunch() {
    return _prefs?.getBool('isFirstLaunch') ?? true;
  }

  // Mock data
  Future<void> setMockDataAdded(bool added) async {
    await _prefs?.setBool('mockDataAdded', added);
  }

  bool isMockDataAdded() {
    return _prefs?.getBool('mockDataAdded') ?? false;
  }

  // User age
  Future<void> setUserAge(int age) async {
    await _prefs?.setInt('userAge', age);
  }

  int? getUserAge() {
    return _prefs?.getInt('userAge');
  }

  // User gender
  Future<void> setUserGender(String gender) async {
    await _prefs?.setString('userGender', gender);
  }

  String? getUserGender() {
    return _prefs?.getString('userGender');
  }

  // User email
  Future<void> setUserEmail(String email) async {
    await _prefs?.setString('userEmail', email);
  }

  String? getUserEmail() {
    return _prefs?.getString('userEmail');
  }

  // User phone
  Future<void> setUserPhone(String phone) async {
    await _prefs?.setString('userPhone', phone);
  }

  String? getUserPhone() {
    return _prefs?.getString('userPhone');
  }
}
