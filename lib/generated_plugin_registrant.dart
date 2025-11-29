//
// Generated file. Do not edit.
//

// ignore_for_file: lines_longer_than_80_chars

// import 'package:assets_audio_player_web/web/assets_audio_player_web.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_web/firebase_auth_web.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_web/firebase_core_web.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  // AssetsAudioPlayerWebPlugin.registerWith(registrar);
  FirebaseFirestoreWeb.registerWith(registrar);
  FirebaseAuthWeb.registerWith(registrar);
  FirebaseCoreWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}
