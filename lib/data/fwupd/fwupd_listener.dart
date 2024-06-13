import 'package:wave_desktop_installer/data/fwupd/fwupd_service.dart';

typedef PercentageMessage = void Function(double percentage);
typedef DownloadMessage = void Function(FwupdStatus state);

class FirmWareChannelListener {
  const FirmWareChannelListener({
    this.onPercentageChanged,
    this.onDownloadStateChanged,
  });

  final PercentageMessage? onPercentageChanged;
  final DownloadMessage? onDownloadStateChanged;

}