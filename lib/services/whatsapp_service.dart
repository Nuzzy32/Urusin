import '../models/worker.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  const WhatsappService();

  Uri buildWaLink({required Worker worker, required String message}) {
    return Uri.https('wa.me', '/${worker.phone}', {'text': message});
  }

  Future<bool> openChat({
    required Worker worker,
    required String message,
  }) async {
    final uri = buildWaLink(worker: worker, message: message);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
