import 'package:wave_desktop_installer/data/fwupd/fwupd_service.dart';

typedef PercentageMessage = void Function(double percentage);

class FirmWareChannelListener {
  const FirmWareChannelListener({
    this.onPercentageChanged,
  });

  final PercentageMessage? onPercentageChanged;


}