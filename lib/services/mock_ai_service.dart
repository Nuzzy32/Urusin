import '../data/mock_ai_result.dart';
import '../models/ai_result.dart';
import '../models/service_request.dart';

class MockAiService {
  const MockAiService();

  Future<AiResult> analyze(FlowState state) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return mockAiResult;
  }
}
