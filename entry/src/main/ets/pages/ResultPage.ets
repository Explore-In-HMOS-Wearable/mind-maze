import { RouteName } from '../services/NavigationService';
import { BaseViewModel } from '../viewmodel/BaseViewModel';
import { appDataService } from '../services/AppDataService';
import { RunSummary } from '../model/AppDataTypes';

@Component
export struct ResultPage {
  vm: BaseViewModel = new BaseViewModel();

  private score: number = 0;
  @State best: number = 0;
  @State isNewRecord: boolean = false;
  @State displayScore: number = 0;
  @State runMode: string = 'Classic';
  @State levelReached: number = 1;
  @State durationText: string = '0s';
  @State mistakeCount: number = 0;
  @State maxCombo: number = 0;
  @State bonusTimeSec: number = 0;
  @State accuracy: number = 0;

  aboutToAppear(): void {
    const s = Number(AppStorage.get('mm_score') ?? 0);
    const b = Number(AppStorage.get('mm_best')  ?? 0);
    const recent: RunSummary[] = appDataService.load().recentRuns;
    const latestRun: RunSummary | undefined = recent.length > 0 ? recent[0] : undefined;

    this.score = latestRun ? Number(latestRun.score) : s;
    this.best  = b;
    this.runMode = latestRun ? latestRun.mode : 'Classic';
    this.levelReached = latestRun ? latestRun.level : 1;
    this.durationText = `${latestRun ? latestRun.durationSec : 0}s`;
    this.mistakeCount = latestRun ? latestRun.mistakes : 0;
    this.maxCombo = latestRun ? latestRun.maxCombo : 0;
    this.bonusTimeSec = latestRun ? latestRun.bonusTimeSec : 0;

    const totalAttempts: number = (latestRun ? latestRun.correctTaps : 0) + this.mistakeCount;
    this.accuracy = totalAttempts > 0
      ? Math.round(((latestRun ? latestRun.correctTaps : 0) * 100) / totalAttempts)
      : 0;

    if (this.score > this.best) {
      this.isNewRecord = true;
      this.best = this.score;
      AppStorage.setOrCreate('mm_best', this.best);
    } else {
      this.isNewRecord = false;
    }

    this.animateScore();
  }

  private async animateScore(): Promise<void> {
    const target: number = this.score;
    const steps: number = 20;

    if (target <= 0) {
      this.displayScore = 0;
      return;
    }

    const increment: number = Math.max(1, Math.ceil(target / steps));
    const sleep: (ms: number) => Promise<void> =
      (ms: number) => new Promise<void>((resolve: () => void) => setTimeout(resolve, ms));

    const step = async (current: number): Promise<void> => {
      if (current >= target) {
        this.displayScore = target;
        return;
      }
      await sleep(30);
      const next: number = Math.min(target, current + increment);
      this.displayScore = next;
      await step(next);
    };

    await step(0);
  }

  build() {
    Stack() {
      Column() {
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [
          [$r('app.color.base_background_gradient_start'), 0.0],
          [$r('app.color.base_background_gradient_end'), 1.0]
        ]
      })

      Scroll() {
      Column({ space: 14 }) {
        Text(this.isNewRecord ? '🎉 New High Score!' : 'Game Over')
          .fontSize(22)
          .fontWeight(FontWeight.Bolder)
          .fontColor(this.isNewRecord ? Color.Yellow : Color.White)
          .textAlign(TextAlign.Center)

        Text(`Score: ${this.displayScore}`)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
        Text(`Best: ${this.best}`)
          .fontSize(18)
          .fontColor(Color.Gray)

        Text(`Mode: ${this.runMode}`)
          .fontSize(12)
          .fontColor('#9CCBFF')

        Column({ space: 4 }) {
          Text(`Level: ${this.levelReached}`)
            .fontSize(11)
            .fontColor('#F0F6FF')
          Text(`Duration: ${this.durationText}`)
            .fontSize(11)
            .fontColor('#F0F6FF')
          Text(`Mistakes: ${this.mistakeCount}  •  Max combo: ${this.maxCombo}`)
            .fontSize(11)
            .fontColor('#F0F6FF')
          Text(`Bonus time: +${this.bonusTimeSec}s  •  Accuracy: ${this.accuracy}%`)
            .fontSize(11)
            .fontColor('#CDE6FF')
            .textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
        .padding(10)
        .borderRadius(10)
        .backgroundColor('#1A2538')

        if (this.isNewRecord) {
          Text('🏅 Congratulations! You broke your record!')
            .fontSize(12)
            .fontColor(Color.Orange)
        }

        Column({ space: 8 }) {
          Button('Retry')
            .type(ButtonType.Capsule)
            .width('80%').height(44)
            .backgroundColor(Color.Green)
            .fontColor(Color.White)
            .fontSize(14)
            .onClick(() => {
              AppStorage.setOrCreate('mm_score', 0);
              AppStorage.setOrCreate('mm_pattern', [] as number[]);
              AppStorage.setOrCreate('mm_phase', 'Playback');
              this.vm.navigateToPage(RouteName.Game);
            })

          Button('Home')
            .type(ButtonType.Capsule)
            .width('80%').height(40)
            .backgroundColor(Color.Gray)
            .fontColor(Color.White)
            .fontSize(14)
            .onClick(() => this.vm.resetToHome())
        }
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .padding({ left: 16, right: 16, top: 24, bottom: 36 })
      }
      .width('100%')
      .height('100%')
    }
  }
}
