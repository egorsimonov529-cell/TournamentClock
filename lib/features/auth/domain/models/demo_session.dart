import '../../../../core/models/user.dart';

enum DemoSessionStatus { initializing, anonymous, authenticated }

class DemoSession {
  final DemoSessionStatus status;
  final User? user;

  const DemoSession._(this.status, [this.user]);

  const DemoSession.initializing() : this._(DemoSessionStatus.initializing);
  const DemoSession.anonymous() : this._(DemoSessionStatus.anonymous);
  const DemoSession.authenticated(User user)
    : this._(DemoSessionStatus.authenticated, user);

  bool get isAuthenticated => status == DemoSessionStatus.authenticated;
  String? get role => user?.role;
}
