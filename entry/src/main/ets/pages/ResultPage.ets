import { RouteName } from '../services/NavigationService';
import { BaseViewModel } from '../viewmodel/BaseViewModel';

@Component
export struct ResultPage {
  vm: BaseViewModel = new BaseViewModel();

  @State score: number = 0;
  @State best: number = 0;
  @State isNewRecord: boolean = false;
  @State displayScore: number = 0;

  aboutToAppear(): void {
    const s = Number(AppStorage.get('mm_score') ?? 0);
    const b = Number(AppStorage.get('mm_best')  ?? 0);

    this.score = s;
    this.best  = b;

    if (this.score > this.best) {
      this.isNewRecord = true;
      AppStorage.setOrCreate('mm_best', this.score);
    }

    this.animateScore();
  }

  private async animateScore(): Promise<void> {
    this.displayScore = 0;
    const steps = 20;
    const increment = Math.ceil(this.score / steps);

    for (let i = 0; i < steps; i++) {
      await new Promise<void>((resolve: () => void) => setTimeout(resolve, 30));
      this.displayScore = Math.min(this.score, this.displayScore + increment);
    }
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

      Column({ space: 18 }) {
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
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .padding(16)
    }
  }
}
