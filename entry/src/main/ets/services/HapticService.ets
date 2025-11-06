import { vibrator } from '@kit.SensorServiceKit';

export enum HapticUsage {
  Alarm = 'alarm',
  Touch = 'touch',
  Notification = 'notification',
  Ring = 'ring',
  Unknown = 'unknown'
}

export class HapticService {
  static touch() {
    try {
      vibrator.startVibration(
        { type: 'preset', effectId: 'haptic.effect.click', count: 1 },
        { usage: HapticUsage.Touch }
      );
    } catch (_) {}
  }

  static combo() {
    try {
      vibrator.startVibration(
        { type: 'preset', effectId: 'haptic.effect.soft', count: 1 },
        { usage: HapticUsage.Touch }
      );
    } catch (_) {}
  }

  static fail() {
    try {
      vibrator.startVibration(
        { type: 'time', duration: 300 },
        { id: 0, usage: HapticUsage.Alarm }
      );
    } catch (_) {}
  }

  static alarm() {
    try {
      vibrator.startVibration(
        { type: 'preset', effectId: 'haptic.clock.timer', count: 1 },
        { usage: HapticUsage.Alarm }
      );
    } catch (_) {}
  }

  static stop() {
    try {
      vibrator.stopVibration();
    } catch (_) {}
  }
}
