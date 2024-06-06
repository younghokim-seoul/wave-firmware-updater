import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/utils/screen_util.dart';
import 'package:yaru/yaru.dart';

class ConnectionSection extends ConsumerWidget {
  const ConnectionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return YaruSection(
      headline: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Connected'),
        ],
      ),
      width: getScreenWidth(context),
      child: const YaruTile(
        title: Text('Title'),
        trailing: Icon(YaruIcons.information),
      ),
    );;
  }
}
