import { hilog } from '@kit.PerformanceAnalysisKit';
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';

const DOMAIN: number = 0x1101;
const TAG: string = 'MindMazeBackup';

interface BackupPayload {
  best: number;
}

async function exportGameData(): Promise<BackupPayload> {
  const best: number = 0;
  return { best };
}

async function importGameData(_data: BackupPayload): Promise<void> {
  return;
}

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup(): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, 'onBackup started');
      const payload: BackupPayload = await exportGameData();
      hilog.info(DOMAIN, TAG, 'onBackup ok payload=%{public}s', JSON.stringify(payload));
    } catch (err) {
      const msg: string = err instanceof Error ? err.message : String(err);
      hilog.error(DOMAIN, TAG, 'onBackup error %{public}s', msg);
    }
  }

  async onRestore(bundleVersion: BundleVersion): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, 'onRestore bundle=%{public}s', JSON.stringify(bundleVersion));
      const payload: BackupPayload = { best: 0 };
      await importGameData(payload);
      hilog.info(DOMAIN, TAG, 'onRestore ok');
    } catch (err) {
      const msg: string = err instanceof Error ? err.message : String(err);
      hilog.error(DOMAIN, TAG, 'onRestore error %{public}s', msg);
    }
  }
}
