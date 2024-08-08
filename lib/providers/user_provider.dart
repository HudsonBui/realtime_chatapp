import 'package:realtime_chatapp/models/user_models.dart';
import 'package:realtime_chatapp/services/user_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

@riverpod
Future<UserModel> getCurrentUserInformation(ref) {
  return ref.watch(userServicesProvider).getCurrentUserInformation();
}
