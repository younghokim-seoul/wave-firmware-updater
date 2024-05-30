import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/feature/page_items.dart';
import 'package:yaru/icons.dart';
import 'package:yaru/widgets.dart';

class DashboardPage extends StatelessWidget {

  DashboardPage({super.key, required List<PageItem> pageItems}) : pageItems = pageItems.toList();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final List<PageItem> pageItems;

  @override
  Widget build(BuildContext context) {
    return YaruMasterDetailPage(
      navigatorKey: _navigatorKey,
      length: pageItems.length,
      breakpoint: 0,
      tileBuilder: (context, index, selected, availableWidth) => YaruMasterTile(
        leading: pageItems[index].iconBuilder(context, selected),
        title: Text(pageItems[index].title),
      ),
      pageBuilder: (context, index) => pageItems[index].pageBuilder(context),
      bottomBar: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: YaruMasterTile(
          leading: Icon(YaruIcons.information),
          title: Text('Ver.1.0.0'),
        ),
      ),
    );
  }
}
