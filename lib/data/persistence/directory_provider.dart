import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

abstract class DirectoryProvider {
  Future<Directory> getApplicationSupportDirectory();
}

class DefaultDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() {
    return path_provider.getApplicationSupportDirectory();
  }
}
