import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';


class DynamicLinkService {
  static Future<Uri> createDynamicLink({
    required String uid,
    required String postId,
  }) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://algrinova.page.link', // ⚠️ à configurer dans Firebase
      link: Uri.parse('https://algrinova.com/post?uid=$uid&postId=$postId'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.algrinova',
        minimumVersion: 1,
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.example.algrinova',
        minimumVersion: '1.0.0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Découvre ce post sur Algrinova !',
        description: 'Un post inspirant dans le domaine agricole 🌿',
      ),
    );

    final ShortDynamicLink shortLink =
    await FirebaseDynamicLinks.instance.buildShortLink(parameters);
return shortLink.shortUrl;

  }
}
