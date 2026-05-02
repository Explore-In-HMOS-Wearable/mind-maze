import { BaseViewModel } from '../viewmodel/BaseViewModel';
import { RouteName } from '../services/NavigationService';
import { HapticService } from '../services/HapticService';
import { secureRandomIntSync } from '../utils/Random';
import { appDataService } from '../services/AppDataService';
import { AppSettings, GameMode } from '../model/AppDataTypes';

type Phase = 'Idle' | 'Playback' | 'Input' | 'RoundResult' | 'GameOver';

const TILE_IDS: number[] = [0, 1, 2, 3];
const START_MS = 60000;
const TICK_MS = 1000;
const BONUS_MS = 5000;

interface ModeRules {
  startMs: number;
  bonusMs: number;
  startLives: number;
  startSpeed: number;
  minSpeed: number;
}

function colorFor(id: number): Resource {
  switch (id) {
    case 0:
      return $r('app.color.tile_red');
    case 1:
      return $r('app.color.tile_green');
    case 2:
      return $r('app.color.tile_blue');
    case 3:
      return $r('app.color.tile_yellow');
    default:
      return $r('app.color.tile_red');
  }
}

@Component
export struct GamePage {
  vm: BaseViewModel = new BaseViewModel();
  @State phase: Phase = 'Playback';
  @State flashTile: number = -1;
  @State score: number = 0;
  @State best: number = 0;
  @State userIndex: number = 0;
  @State speedMs: number = 700;
  @State lives: number = 3;
  @State level: number = 1;
  @State combo: number = 0;
  @State comboText: string = '';
  @State bonusText: string = '';
  @State showLevelUp: boolean = false;
  @State settings: AppSettings = appDataService.getSettings();
  @State modeName: string = GameMode.Classic;
  @State remainingMsState: number = START_MS;
  @State usedSecUI: number = 0;
  @State totalSecUI: number = Math.ceil(START_MS / 1000);
  @State bonusMs: number = 0;
  private pattern: number[] = [];
  private tickId: number = -1;
  private baseStartEpoch: number = 0;
  private mistakeCount: number = 0;
  private maxCombo: number = 0;
  private correctTapCount: number = 0;
  private currentRules: ModeRules = this.rulesForMode(GameMode.Classic);

  aboutToAppear(): void {
    this.settings = appDataService.getSettings();
    this.currentRules = this.rulesForMode(this.settings.mode);
    this.modeName = this.settings.mode;

    this.score = AppStorage.get('mm_score') ?? 0;
    this.best = AppStorage.get('mm_best') ?? 0;
    this.pattern = AppStorage.get('mm_pattern') ?? [];
    this.lives = this.currentRules.startLives;
    this.level = 1;
    this.combo = 0;
    this.speedMs = this.currentRules.startSpeed;
    this.mistakeCount = 0;
    this.maxCombo = 0;
    this.correctTapCount = 0;
    if (this.pattern.length === 0) {
      this.addStep();
    }
    this.phase = 'Playback';
    this.userIndex = 0;
    this.baseStartEpoch = Date.now();
    this.remainingMsState = this.currentRules.startMs;
    this.totalSecUI = Math.ceil(this.currentRules.startMs / 1000);
    this.bonusMs = 0;
    void this.playPattern();
    this.startTicker();
  }

  aboutToDisappear(): void {
    this.stopTicker();
    HapticService.stop();
  }

  build() {
    Stack() {
      Progress({ value: this.usedSecUI, total: this.totalSecUI, type: ProgressType.Ring })
        .width('100%')
        .style({ strokeWidth: 10, enableSmoothEffect: true })
        .color(
          new LinearGradient([
            { color: Color.Yellow, offset: 0.3 },
            { color: Color.Orange, offset: 1.0 }
          ])
        )
        .zIndex(1)

      Column() {
        Row({ space: 4 }) {
          Text(`❤️${this.lives}`).fontSize(6).fontColor(Color.Red)
          Text(this.modeName === GameMode.Practice ? 'P' : 'C').fontSize(6).fontColor('#9AD7FF')
          Text(`L${this.level}`).fontSize(6).fontColor(Color.White)
          Text(`S: ${this.score}`).fontSize(6).fontColor(Color.White)
          Text(`B: ${this.best}`).fontSize(6).fontColor(Color.White)
        }.justifyContent(FlexAlign.Center)

        Text(this.feedbackText())
          .height(22)
          .fontSize(this.showLevelUp ? 18 : 14)
          .fontWeight(this.showLevelUp ? FontWeight.Bold : FontWeight.Bolder)
          .fontColor(
            this.showLevelUp
              ? Color.Yellow
              : (this.comboText.length > 0 ? Color.Orange : Color.Green)
          )
          .opacity(this.feedbackText().trim().length > 0 ? 1 : 0)
          .margin({ top: 4 })

        Blank()

        Column({ space: 8 }) {
          Text(this.fmt(this.remainingMsState))
            .fontColor(Color.White)
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
            ForEach(
              TILE_IDS as number[],
              (id: number): void => {
                Stack() {
                  if (this.settings.showTileLabels) {
                    Text(`${id + 1}`)
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Bold)
                      .fontSize(16)
                  }
                }
                .width(60)
                .height(60)
                .backgroundColor(colorFor(id))
                .opacity(this.flashTile === id ? 1 : (this.settings.highContrast ? 0.92 : 0.62))
                .borderRadius(10)
                .border({ width: this.flashTile === id ? 3 : 0, color: Color.White })
                .scale({ x: this.flashTile === id ? 1.04 : 1, y: this.flashTile === id ? 1.04 : 1 })
                .onClick((): void => {
                  void this.tap(id);
                })
                .margin({ left: 4, right: 4, bottom: 4 })
              },
              (id: number): string => String(id)
            )
          }
        }
        .alignItems(HorizontalAlign.Center)

        Blank()

        Button('Back')
          .type(ButtonType.Capsule)
          .width(80)
          .height(28)
          .fontSize(10)
          .margin({ bottom: 8 })
          .onClick((): void => this.vm.back())
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .zIndex(3)
    }
    .width('100%').height('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [
        [$r('app.color.base_background_gradient_start'), 0.0],
        [$r('app.color.base_background_gradient_end'), 1.0]
      ]
    })
  }

  private rulesForMode(mode: GameMode): ModeRules {
    if (mode === GameMode.Practice) {
      return {
        startMs: 90000,
        bonusMs: 8000,
        startLives: 5,
        startSpeed: 850,
        minSpeed: 500
      };
    }
    return {
      startMs: START_MS,
      bonusMs: BONUS_MS,
      startLives: 3,
      startSpeed: 700,
      minSpeed: 350
    };
  }

  private startTicker(): void {
    this.stopTicker();
    this.tickId = setInterval(() => this.onTick(), TICK_MS) as number;
  }

  private stopTicker(): void {
    if (this.tickId !== -1) {
      clearInterval(this.tickId);
      this.tickId = -1;
    }
  }

  private onTick(): void {
    const totalMs: number = this.currentRules.startMs + this.bonusMs;
    const elapsed: number = Date.now() - this.baseStartEpoch;
    let remain: number = totalMs - elapsed;
    if (remain < 0) {
      remain = 0;
    }

    this.remainingMsState = remain;
    this.totalSecUI = Math.ceil(totalMs / 1000);
    this.usedSecUI = Math.floor((totalMs - remain) / 1000);

    if (remain <= 0) {
      this.gameOver();
    }
  }

  private fmt(ms: number): string {
    const totalSec = Math.max(0, Math.floor(ms / 1000));
    const minutes = Math.floor(totalSec / 60);
    const seconds = totalSec % 60;

    const mm = String(minutes).padStart(2, '0');
    const ss = String(seconds).padStart(2, '0');
    return `${mm}:${ss}`;
  }

  private randTile(): number {
    return secureRandomIntSync(4);
  }

  private addStep() {
    this.pattern.push(this.randTile());
    AppStorage.setOrCreate('mm_pattern', this.pattern.slice());
  }

  private async sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private async playPattern(): Promise<void> {
    this.phase = 'Playback';

    const pattern: number[] = this.pattern.slice();
    const speedMs: number = this.speedMs;
    const gapMs: number = 180;
    const sleepFn: (ms: number) => Promise<void> = (ms: number) => this.sleep(ms);
    const setFlash: (v: number) => void = (v: number): void => {
      this.flashTile = v;
    };

    const playStep = async (idx: number): Promise<void> => {
      if (idx >= pattern.length) {
        this.userIndex = 0;
        this.phase = 'Input';
        return;
      }

      const tileId: number = pattern[idx];
      setFlash(tileId);
      if (this.settings.hapticsEnabled) {
        HapticService.touch();
      }
      await sleepFn(speedMs);
      setFlash(-1);

      if (idx >= pattern.length - 1) {
        this.userIndex = 0;
        this.phase = 'Input';
        return;
      }

      await sleepFn(gapMs);

      await playStep(idx + 1);
    };

    await playStep(0);
  }

  private async tap(id: number): Promise<void> {
    if (this.phase !== 'Input') {
      return;
    }

    const expected = this.pattern[this.userIndex];
    if (id === expected) {
      this.userIndex++;
      this.score++;
      this.combo++;
      this.correctTapCount++;
      this.maxCombo = Math.max(this.maxCombo, this.combo);

      if (this.combo > 0 && this.combo % 5 === 0) {
        this.score += 10;
        this.comboText = '🔥 COMBO!';
        if (this.settings.hapticsEnabled) {
          HapticService.combo();
        }
        setTimeout(() => this.comboText = '', 800);
      }

      this.bonusText = `+${Math.floor(this.currentRules.bonusMs / 1000)}s`;
      setTimeout(() => this.bonusText = '', 1000);

      this.bonusMs += this.currentRules.bonusMs;
      AppStorage.setOrCreate('mm_score', this.score);
      if (this.settings.hapticsEnabled) {
        HapticService.touch();
      }
      this.flashTile = id;
      await this.sleep(100);
      this.flashTile = -1;

      if (this.userIndex >= this.pattern.length) {
        this.phase = 'RoundResult';
        await this.sleep(300);
        this.level++;
        this.showLevelUp = true;
        setTimeout(() => this.showLevelUp = false, 1000);
        this.addStep();
        if (this.pattern.length % 3 === 0) {
          this.speedMs = Math.max(this.currentRules.minSpeed, this.speedMs - 50);
        }
        await this.playPattern();
      }
    } else {
      if (this.settings.hapticsEnabled) {
        HapticService.fail();
      }
      this.lives--;
      this.mistakeCount++;
      this.combo = 0;
      if (this.lives <= 0) {
        this.gameOver();
      }
    }
  }

  private gameOver(): void {
    this.stopTicker();
    this.phase = 'GameOver';
    AppStorage.setOrCreate('mm_score', this.score);
    if (this.score > this.best) {
      this.best = this.score;
      AppStorage.setOrCreate('mm_best', this.best);
    }

    const elapsedSec: number = Math.max(0, Math.floor((Date.now() - this.baseStartEpoch) / 1000));
    appDataService.addRun({
      score: this.score,
      level: this.level,
      mode: this.settings.mode,
      durationSec: elapsedSec,
      livesLeft: this.lives,
      mistakes: this.mistakeCount,
      maxCombo: this.maxCombo,
      bonusTimeSec: Math.max(0, Math.floor(this.bonusMs / 1000)),
      correctTaps: this.correctTapCount,
      createdAt: Date.now()
    });

    if (this.settings.hapticsEnabled) {
      HapticService.alarm();
    }
    this.vm.navigateToPage(RouteName.Result);
  }

  private feedbackText(): string {
    if (this.showLevelUp) {
      return `LEVEL ${this.level} ↑`;
    }
    if (this.comboText.length > 0) {
      return this.comboText;
    }
    if (this.bonusText.length > 0) {
      return this.bonusText;
    }
    return ' ';
  }
}
