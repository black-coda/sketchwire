import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_entry.dart';

void main() {
  runApp(ProviderScope(child: const SketchWireAppEntry()));
  
}
