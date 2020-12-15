import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NativeLinkState {}

class NativeLinkInitial extends NativeLinkState {}

class NativeLinkEmited extends NativeLinkState {
  final NativeLink link;

  NativeLinkEmited(this.link);
}

class NativeLink {
  final String path;
  final bool isFile;
  NativeLink({
    @required this.path,
    @required this.isFile,
  });

  factory NativeLink.fromMap(Map<dynamic, dynamic> map) {
    return NativeLink(
      isFile: map['isFile'],
      path: map['path'],
    );
  }
}

class NativeLinksCubit extends Cubit<NativeLinkState> {
  static const stream = const EventChannel('link_events');
  static const platform = const MethodChannel('link_channel');

  NativeLinksCubit() : super(NativeLinkInitial()) {
    _start();
    stream
        .receiveBroadcastStream()
        .listen((map) => _onRedirected(NativeLink.fromMap(map)));
  }

  _onRedirected(NativeLink nativeLink) {
    emit(NativeLinkEmited(nativeLink));
  }

  Future<void> _start() async {
    try {
      final Map initialMap = await platform.invokeMethod('initialLink');
      _onRedirected(NativeLink.fromMap(initialMap));
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }
}
