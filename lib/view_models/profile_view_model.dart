import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  UserProfile profile = const UserProfile(
    name: 'A. User',
    age: 26,
    heightCm: 178,
    weightKg: 72,
  );
}
