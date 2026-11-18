import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/ai_repository.dart';
import '../../domain/usecases/send_chat_message_usecase.dart';
import 'ai_local_stores.dart';
import 'groq_ai_repository.dart';

final apiKeyStoreProvider = Provider((ref) => ApiKeyStore());

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final keyStore = ref.watch(apiKeyStoreProvider);
  return GroqAiRepository(readApiKey: keyStore.read);
});

final aiQuotaStoreProvider = Provider<AiQuotaStore>((ref) => PrefsQuotaStore());

final aiResponseCacheProvider = Provider<AiResponseCache>(
  (ref) => PrefsResponseCache(),
);

final sendChatMessageUseCaseProvider = Provider((ref) {
  return SendChatMessageUseCase(
    repository: ref.watch(aiRepositoryProvider),
    quota: ref.watch(aiQuotaStoreProvider),
    cache: ref.watch(aiResponseCacheProvider),
  );
});

/// Status API key untuk halaman Pengaturan (true = sudah tersimpan).
final hasApiKeyProvider = FutureProvider<bool>((ref) async {
  final key = await ref.watch(apiKeyStoreProvider).read();
  return key != null && key.isNotEmpty;
});

final aiQuotaUsedProvider = FutureProvider<int>(
  (ref) => ref.watch(aiQuotaStoreProvider).usedToday(),
);
