import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';

/// Concrete implementation of [ChatRepository].
///
/// Delegates to [ChatRemoteDataSource] and maps infrastructure exceptions to
/// domain [Failure]s using [Either].
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ChatThreadEntity>> createChat() async {
    try {
      final result = await _remoteDataSource.createChat();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatThreadEntity>>> getChats() async {
    try {
      final result = await _remoteDataSource.getChats();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessages(
    String chatId,
  ) async {
    try {
      final result = await _remoteDataSource.getChatMessages(chatId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      final result = await _remoteDataSource.sendMessage(
        chatId: chatId,
        message: message,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    }
  }
}
