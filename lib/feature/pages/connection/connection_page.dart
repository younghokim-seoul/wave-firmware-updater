import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
//
// class ConnectionPage extends StatelessWidget {
//   const ConnectionPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       color: Colors.green,
//     );
//   }
// }

class ConnectionPage extends ConsumerStatefulWidget {
  const ConnectionPage({super.key});

  @override
  ConsumerState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends ConsumerState<ConnectionPage> {
  @override
  void initState() {
    super.initState();
    Log.d('ConnectionPage init');
  }
  @override
  Widget build(BuildContext context) {
    Log.d('ConnectionPage build');
    return Container(
      color: Colors.green,
    );
  }
}
