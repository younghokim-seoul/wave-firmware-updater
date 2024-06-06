import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:yaru/theme.dart';

class FirmwareUpdatePage extends ConsumerStatefulWidget {
  const FirmwareUpdatePage({super.key});

  @override
  ConsumerState createState() => _FirmwareUpdatePageState();
}

class _FirmwareUpdatePageState extends ConsumerState<FirmwareUpdatePage> {
  @override
  void initState() {
    Log.d("FirmwareUpdatePage initState!!");
    super.initState();
  }

  @override
  void dispose() {
    Log.d("FirmwareUpdatePage dispose!!");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(60),
            Text('WAVE Firmware Update', style: WaveTextStyles.headline4Bold),
            Gap(30),
            Column(
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    decoration: BoxDecoration(
                        color: YaruColors.kubuntuBlue,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: Offset(0.0, 4),
                            blurRadius: 4,
                          ),
                        ]),
                    child: Row(
                      children: [
                        const Gap(45),
                        SizedBox.square(
                          dimension: 50,
                          child: Assets.icons.iconWavetoolsConnection.image(),
                        ),
                        const Gap(10),
                        Text('Connection Start',
                                style: WaveTextStyles.headline4Bold
                                    .copyWith(color: Colors.white))
                            .marginOnly(bottom: 5),
                      ],
                    ),
                  ),
                ),
                Gap(38),
              ],
            )
          ],
        ),
      ),
    );
  }
}
