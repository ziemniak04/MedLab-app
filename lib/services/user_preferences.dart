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
}
