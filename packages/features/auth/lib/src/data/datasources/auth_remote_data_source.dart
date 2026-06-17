import 'package:network/network.dart';

import '../models/change_password_request.dart';
import '../models/refresh_token_request.dart';
import '../models/register_request.dart';
import '../models/sign_in_request.dart';
import '../models/sign_in_response.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio, {String baseUrl}) =
      _AuthRemoteDataSource;

  @POST('/api/auth/change-password')
  Future<void> changePassword(@Body() ChangePasswordRequest body);

  @POST('/api/auth/register')
  Future<SignInResponse> register(@Body() RegisterRequest body);

  @POST('/api/auth/sign-in')
  Future<SignInResponse> signIn(@Body() SignInRequest body);

  @POST('/api/auth/sign-out')
  Future<void> signOut(@Body() RefreshTokenRequest body);

  @DELETE('/api/auth/account')
  Future<void> deleteAccount();
}
