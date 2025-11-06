import { RouteName } from '../services/NavigationService';
import { BaseViewModel } from '../viewmodel/BaseViewModel';
import { vibrator } from '@kit.SensorServiceKit';

@Component
export struct HomePage {
  vm: BaseViewModel = new BaseViewModel();
  @State fadeIn: number = 1.0
  @State bgShift: number = 0.0

  aboutToAppear(): void {
    setInterval(() => {
      this.bgShift = (this.bgShift + 0.01) % 1.0
    }, 120)
  }

  private handleStart(): void {
    try {
      vibrator.startVibration({ type: 'time', duration: 80 }, { id: 0, usage: 'touch' });
    } catch (_) {}

    AppStorage.setOrCreate('mm_score', 0);
    AppStorage.setOrCreate('mm_best', AppStorage.get('mm_best') ?? 0);
    AppStorage.setOrCreate('mm_pattern', [] as number[]);
    AppStorage.setOrCreate('mm_phase', 'Playback');
    this.vm.navigateToPage(RouteName.Game);
  }

  private handleTutorial(): void {
    try {
      vibrator.startVibration({ type: 'time', duration: 60 }, { id: 0, usage: 'touch' });
    } catch (_) {}
    this.vm.navigateToPage(RouteName.Game);
  }

  build() {
    Stack() {
      Stack() {}
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [
          ['#1976D2', 0.0],
          ['#F57C00', 1.0],
        ],
      })

      Scroll() {
        Column({ space:30 }) {
          Text('🧠 MindMaze')
            .fontSize(30)
            .fontWeight(FontWeight.Bolder)
            .fontColor(Color.White)
            .opacity(this.fadeIn)
            .textAlign(TextAlign.Center)
            .margin({ top: 50 })

          Text('Watch the pattern, then repeat it.')
            .opacity(0.8)
            .fontSize(12)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 80 })

          Button('Start Game')
            .type(ButtonType.Capsule)
            .width('70%').height(30)
            .fontSize(12)
            .fontColor(Color.White)
            .border({ width: 1, color: Color.White })
            .backgroundColor(Color.Orange)
            .shadow({ radius: 6, color: '#00000040' })
            .onClick(() => this.handleStart())
            .margin({ top: 50 })

          Button('How to Play')
            .type(ButtonType.Capsule)
            .width('70%').height(30)
            .fontSize(12)
            .backgroundColor('#FFC84D0B')
            .shadow({ radius: 6, color: '#00000040' })
            .fontColor(Color.White)
            .border({ width: 1, color: Color.White })
            .onClick(() => this.handleTutorial())

          Divider().width('60%').color('#ffffff30').margin({ top: 24 })

          Text(`Best Score: ${AppStorage.get('mm_best') ?? 0}`)
            .fontColor(Color.White)
            .fontSize(14)
            .opacity(0.8)
            .margin({ top: 12 })
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
