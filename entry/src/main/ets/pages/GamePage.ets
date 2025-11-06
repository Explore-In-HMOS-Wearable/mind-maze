import { BaseViewModel } from '../viewmodel/BaseViewModel';
import { RouteName } from '../services/NavigationService';
import { HapticService } from '../services/HapticService';

type Phase = 'Idle' | 'Playback' | 'Input' | 'RoundResult' | 'GameOver';

const TILE_IDS: number[] = [0, 1, 2, 3];
const START_MS = 60000;
const TICK_MS = 1000;
const BONUS_MS = 5000;

function colorFor(id: number): Resource {
  switch (id) {
    case 0: return $r('app.color.tile_red');
    case 1: return $r('app.color.tile_green');
    case 2: return $r('app.color.tile_blue');
    case 3: return $r('app.color.tile_yellow');
    default: return $r('app.color.tile_red');
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

  private pattern: number[] = [];
  private tickId: number = -1;
  private baseStartEpoch: number = 0;
  @State remainingMsState: number = START_MS;
  @State usedSecUI: number = 0;
  @State totalSecUI: number = Math.ceil(START_MS / 1000);
  @State bonusMs: number = 0;

  aboutToAppear(): void {
    this.score = AppStorage.get('mm_score') ?? 0;
    this.best = AppStorage.get('mm_best') ?? 0;
    this.pattern = AppStorage.get('mm_pattern') ?? [];
    this.lives = 3;
    this.level = 1;
    this.combo = 0;
    if (this.pattern.length === 0) this.addStep();

    this.phase = 'Playback';
    this.userIndex = 0;
    this.baseStartEpoch = Date.now();
    this.remainingMsState = START_MS;
    void this.playPattern();
    this.startTicker();
  }

  aboutToDisappear(): void {
    this.stopTicker();
    HapticService.stop();
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
    const totalMs: number = START_MS + this.bonusMs;
    const elapsed: number = Date.now() - this.baseStartEpoch;
    let remain: number = totalMs - elapsed;
    if (remain < 0) remain = 0;

    this.remainingMsState = remain;
    this.totalSecUI = Math.ceil(totalMs / 1000);
    this.usedSecUI = Math.floor((totalMs - remain) / 1000);

    if (remain <= 0) {
      this.gameOver();
    }
  }

  private fmt(ms: number): string {
    const s = Math.max(0, Math.floor(ms / 1000));
    const m = Math.floor(s / 60);
    const ss = s % 60;
    return `${m < 10 ? '0' : ''}${m}:${ss < 10 ? '0' : ''}${ss}`;
  }

  private randTile(): number { return Math.floor(Math.random() * 4); }

  private addStep() {
    this.pattern.push(this.randTile());
    AppStorage.setOrCreate('mm_pattern', this.pattern.slice());
  }

  private async sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private async playPattern(): Promise<void> {
    this.phase = 'Playback';
    for (const id of this.pattern) {
      this.flashTile = id;
      HapticService.touch();
      await this.sleep(this.speedMs);
      this.flashTile = -1;
      await this.sleep(180);
    }
    this.userIndex = 0;
    this.phase = 'Input';
  }

  private async tap(id: number): Promise<void> {
    if (this.phase !== 'Input') return;

    const expected = this.pattern[this.userIndex];
    if (id === expected) {
      this.userIndex++;
      this.score++;
      this.combo++;
      AppStorage.setOrCreate('mm_score', this.score);

      if (this.combo > 0 && this.combo % 5 === 0) {
        this.score += 10;
        this.comboText = '🔥 COMBO!';
        HapticService.combo();
        setTimeout(() => this.comboText = '', 800);
      }

      this.bonusText = '+5s';
      setTimeout(() => this.bonusText = '', 1000);

      this.bonusMs += BONUS_MS;
      HapticService.touch();
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
        if (this.pattern.length % 3 === 0)
          this.speedMs = Math.max(350, this.speedMs - 50);
        await this.playPattern();
      }
    } else {
      HapticService.fail();
      this.lives--;
      this.combo = 0;
      if (this.lives <= 0) this.gameOver();
    }
  }

  private gameOver(): void {
    this.stopTicker();
    this.phase = 'GameOver';
    if (this.score > this.best) {
      this.best = this.score;
      AppStorage.setOrCreate('mm_best', this.best);
    }
    HapticService.alarm();
    this.vm.navigateToPage(RouteName.Result);
  }

  build() {
    Stack() {
      Progress({ value: this.usedSecUI, total: this.totalSecUI, type: ProgressType.Ring })
        .width('100%')
        .style({ strokeWidth: 10, enableSmoothEffect: true })
        .color(
          new LinearGradient([
            { color: Color.Yellow, offset: 0.3 },
            { color: Color.Orange, offset: 1.0 },
          ])
        )
        .zIndex(1)

      Column({ space: 6 }) {
        Row({ space: 4 }) {
          Text(`❤️${this.lives}`).fontSize(6).fontColor(Color.Red)
          Text(`L${this.level}`).fontSize(6).fontColor(Color.White)
          Text(`S: ${this.score}`).fontSize(6).fontColor(Color.White)
          Text(`B: ${this.best}`).fontSize(6).fontColor(Color.White)
        }.justifyContent(FlexAlign.Center)

        Text(this.comboText)
          .fontColor(Color.Orange)
          .fontSize(16)
          .fontWeight(FontWeight.Bolder)
          .opacity(this.comboText ? 1 : 0)

        Text(this.bonusText)
          .fontColor(Color.Green)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .opacity(this.bonusText ? 1 : 0)

        if (this.showLevelUp) {
          Text(`LEVEL ${this.level} ↑`)
            .fontColor(Color.Yellow)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
        }

        Text(this.fmt(this.remainingMsState))
          .fontColor(Color.White)
          .fontSize(20)
          .fontWeight(FontWeight.Bolder)
          .margin({ top: 6, bottom: 4 })

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(TILE_IDS, (id: number) => {
            Button('')
              .width(60).height(60)
              .backgroundColor(this.flashTile === id ? colorFor(id) : `${colorFor(id)}80`)
              .borderRadius(10)
              .margin({ left: 4, right: 4, bottom: 4 })
              .onClick(() => { void this.tap(id); })
          })
        }

        Button('Back')
          .type(ButtonType.Capsule)
          .width(80)
          .height(28)
          .fontSize(10)
          .onClick(() => this.vm.back())
      }
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
}
