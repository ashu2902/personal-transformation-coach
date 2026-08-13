import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCva9A5bTS-IYMXOld8JPImJvKyZU6yOms',
    appId: '1:1023571340286:web:2d982561964ecc887baeaf',
    messagingSenderId: '1023571340286',
    projectId: 'aura-coach-ashu-7',
    authDomain: 'aura-coach-ashu-7.firebaseapp.com',
    storageBucket: 'aura-coach-ashu-7.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIXn2a39hbggPXjDek_bvVrJ4G5fLr3lc',
    appId: '1:1023571340286:android:59f8735dd1739bd07baeaf',
    messagingSenderId: '1023571340286',
    projectId: 'aura-coach-ashu-7',
    storageBucket: 'aura-coach-ashu-7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAvtsfDw_wr73R16Zm2pLFbQWtNCITwyHY',
    appId: '1:1023571340286:ios:61d7fc0b812278bd7baeaf',
    messagingSenderId: '1023571340286',
    projectId: 'aura-coach-ashu-7',
    storageBucket: 'aura-coach-ashu-7.firebasestorage.app',
    iosBundleId: 'com.ashu2902.auracoach',
  );
}
