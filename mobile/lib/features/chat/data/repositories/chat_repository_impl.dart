import 'package:injectable/injectable.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../medication_and_adherence/data/datasources/medication_local_data_source.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/gemini_remote_data_source.dart';
import '../models/chat_message_model.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;
  final GeminiRemoteDataSource remoteDataSource;
  final AuthLocalDataSource? authLocalDataSource;
  final MedicationLocalDataSource? medicationLocalDataSource;

  ChatRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    this.authLocalDataSource,
    this.medicationLocalDataSource,
  });

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    final models = await localDataSource.getChatHistory();
    return models;
  }

  Future<String?> _buildPatientContext() async {
    try {
      final authLocal = authLocalDataSource ??
          (sl.isRegistered<AuthLocalDataSource>()
              ? sl<AuthLocalDataSource>()
              : null);
      final medLocal = medicationLocalDataSource ??
          (sl.isRegistered<MedicationLocalDataSource>()
              ? sl<MedicationLocalDataSource>()
              : null);

      final parts = <String>[];

      if (authLocal != null) {
        final session = await authLocal.getUserSession();
        if (session != null && session.firstName.isNotEmpty) {
          final profileBuffer = StringBuffer(
              'Patient Name: ${session.firstName} ${session.lastName}'.trim());
          if (session.dateOfBirth.isNotEmpty) {
            profileBuffer.write(', DOB: ${session.dateOfBirth}');
          }
          if (session.sex.isNotEmpty) {
            profileBuffer.write(', Sex: ${session.sex}');
          }
          parts.add(profileBuffer.toString());
        }
      }

      if (medLocal != null) {
        try {
          final prescriptions = await medLocal.getCachedPrescriptions();
          if (prescriptions.isNotEmpty) {
            final medList = prescriptions
                .map((p) =>
                    '• ${p.medicationName} ${p.dose} (Frequency: ${p.frequency}, Duration: ${p.duration}) - Instructions: ${p.instructions}')
                .join('\n');
            parts.add('Active Prescriptions in Afya app:\n$medList');
          }
        } catch (_) {
          // If no cached prescriptions, continue gracefully
        }
      }

      if (parts.isNotEmpty) {
        return parts.join('\n\n');
      }
    } catch (_) {
      // Gracefully continue without patient context
    }
    return null;
  }

  @override
  Future<ChatMessage> sendMessage(
      String text, List<ChatMessage> history) async {
    // 1. Save user message locally
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    await localDataSource.saveMessage(ChatMessageModel.fromEntity(userMessage));

    // 2. Prepare context for Gemini
    final historyPayload = history
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.content,
            })
        .toList();

    final patientContext = await _buildPatientContext();

    // 3. Generate response
    final responseText = await remoteDataSource.generateHealthResponse(
      text,
      historyPayload,
      patientContext: patientContext,
    );
    final aiMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
    await localDataSource.saveMessage(ChatMessageModel.fromEntity(aiMessage));
    return aiMessage;
  }

  @override
  Future<void> clearHistory() async {
    await localDataSource.clearHistory();
  }
}
