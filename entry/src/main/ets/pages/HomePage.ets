import { RouteName } from '../services/NavigationService';
import { BaseViewModel } from '../viewmodel/BaseViewModel';
import { vibrator } from '@kit.SensorServiceKit';
import { appDataService } from '../services/AppDataService';
import { AppSettings, RunSummary } from '../model/AppDataTypes';

@Component
export struct HomePage {
  vm: BaseViewModel = new BaseViewModel();
  static FADE_IN: number = 1.0;
  static BG_SHIFT: number = 0.0;
  @State bestScore: number = 0;
  @State settings: AppSettings = appDataService.getSettings();
  @State tutorialCompleted: boolean = false;
  @State runsPlayed: number = 0;
  @State lastRunText: string = 'No runs yet';
  @State bestClassic: number = 0;
  @State bestPractice: number = 0;
  private bgShiftTimerId: number = -1;

  aboutToAppear(): void {
    const appData = appDataService.load();
    this.settings = appData.settings;
    this.tutorialCompleted = appData.tutorialCompleted;
    this.bestScore = Number(AppStorage.get('mm_best') ?? 0);
    this.runsPlayed = appData.recentRuns.length;
    this.bestClassic = Number(appData.bestByMode.Classic ?? 0);
    this.bestPractice = Number(appData.bestByMode.Practice ?? 0);

    if (appData.recentRuns.length > 0) {
      const latest: RunSummary = appData.recentRuns[0];
      this.lastRunText = `${latest.mode} • S${latest.score} • L${latest.level}`;
    } else {
      this.lastRunText = 'No runs yet';
    }

    if (this.bgShiftTimerId !== -1) {
      clearInterval(this.bgShiftTimerId);
    }
    this.bgShiftTimerId = setInterval(() => {
      HomePage.BG_SHIFT = (HomePage.BG_SHIFT + 0.01) % 1.0
    }, 120) as number;
  }

  aboutToDisappear(): void {
    if (this.bgShiftTimerId !== -1) {
      clearInterval(this.bgShiftTimerId);
      this.bgShiftTimerId = -1;
    }
  }

  private handleStart(): void {
    if (this.settings.hapticsEnabled) {
      try {
      vibrator.startVibration({ type: 'time', duration: 80 }, { id: 0, usage: 'touch' });
      } catch (_) {}
    }

    AppStorage.setOrCreate('mm_score', 0);
    AppStorage.setOrCreate('mm_best', AppStorage.get('mm_best') ?? 0);
    AppStorage.setOrCreate('mm_pattern', [] as number[]);
    AppStorage.setOrCreate('mm_phase', 'Playback');
    this.vm.navigateToPage(RouteName.Game);
  }

  private handleTutorial(): void {
    this.vm.navigateToPage(RouteName.Tutorial);
  }

  build() {
    Stack() {
      Stack() {}
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [
          ['#1976D2', 0.0],
          ['#F57C00', 1.0]
        ]
      })

      Scroll() {
        Column({ space:30 }) {
          Text('🧠 MindMaze')
            .fontSize(30)
            .fontWeight(FontWeight.Bolder)
            .fontColor(Color.White)
            .opacity(HomePage.FADE_IN)
            .textAlign(TextAlign.Center)
            .margin({ top: 50 })

          Text('Watch the pattern, then repeat it.')
            .opacity(0.8)
            .fontSize(12)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 14 })

          Text(`Mode: ${this.settings.mode}`)
            .fontColor('#FFE3A6')
            .fontSize(12)

          if (!this.tutorialCompleted) {
            Text('New? Start with How to Play.')
              .fontColor('#A4D1FF')
              .fontSize(10)
          }

          Button('Start Game')
            .type(ButtonType.Capsule)
            .width('70%').height(30)
            .fontSize(12)
            .fontColor(Color.White)
            .border({ width: 1, color: Color.White })
            .backgroundColor(Color.Orange)
            .shadow({ radius: 6, color: '#00000040' })
            .onClick(() => this.handleStart())
            .margin({ top: 10 })

          Button('How to Play')
            .type(ButtonType.Capsule)
            .width('70%').height(30)
            .fontSize(12)
            .backgroundColor('#FFC84D0B')
            .shadow({ radius: 6, color: '#00000040' })
            .fontColor(Color.White)
            .border({ width: 1, color: Color.White })
            .onClick(() => this.handleTutorial())

          Button('Settings')
            .type(ButtonType.Capsule)
            .width('70%').height(30)
            .fontSize(12)
            .backgroundColor('#1F2F44')
            .shadow({ radius: 6, color: '#00000040' })
            .fontColor(Color.White)
            .border({ width: 1, color: '#8DB5DE' })
            .onClick(() => this.vm.navigateToPage(RouteName.Settings))

          Button('History')
            .type(ButtonType.Capsule)
            .width('70%').height(30)
            .fontSize(12)
            .backgroundColor('#1A2536')
            .shadow({ radius: 6, color: '#00000040' })
            .fontColor(Color.White)
            .border({ width: 1, color: '#6D8AAA' })
            .onClick(() => this.vm.navigateToPage(RouteName.History))

          Divider().width('60%').color('#ffffff30').margin({ top: 24 })

          Text(`Best Score: ${this.bestScore}`)
            .fontColor(Color.White)
            .fontSize(14)
            .opacity(0.8)
            .margin({ top: 12 })

          Column({ space: 5 }) {
            Text(`Runs logged: ${this.runsPlayed}`)
              .fontColor('#CFE4FF')
              .fontSize(10)
            Text(this.lastRunText)
              .fontColor('#A4D1FF')
              .fontSize(10)
              .textAlign(TextAlign.Center)

            Row({ space: 6 }) {
              Text(`C ${this.bestClassic}`)
                .fontSize(9)
                .fontColor('#0B1E33')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor('#9ED0FF')
                .borderRadius(8)
              Text(`P ${this.bestPractice}`)
                .fontSize(9)
                .fontColor('#132600')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor('#BEEA8A')
                .borderRadius(8)
            }
          }
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .padding({ bottom: 80 })
      }
      .width('100%').height('100%')
    }
    .width('100%').height('100%')
  }
}
