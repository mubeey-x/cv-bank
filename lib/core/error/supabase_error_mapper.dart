import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'exceptions.dart';

Future<T> mapSupabaseErrors<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on PostgrestException catch (e) {
    throw switch (e.code) {
      '23505' => DuplicateException(e.message, code: e.code, cause: e),
      '42501' => UnauthorizedException(e.message, code: e.code, cause: e),
      'PGRST116' => NotFoundException(e.message, code: e.code),
      _ => ServerException(e.message, code: e.code, cause: e),
    };
  } on AuthException catch (e) {
    throw UnauthorizedException(e.message, code: e.statusCode, cause: e);
  } on StorageException catch (e) {
    throw FileException(e.message, code: e.statusCode, cause: e);
  } on SocketException catch (e) {
    throw NetworkException(e.message);
  } catch (e) {
    throw ServerException(e.toString(), cause: e);
  }
}
