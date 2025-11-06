import { BaseViewModel } from '../viewmodel/BaseViewModel';
import { RouteName } from '../services/NavigationService';

@Component
export struct GameOverPage {
  vm: BaseViewModel = new BaseViewModel();

  @State score: number = 0;
  @State best: number = 0;

  aboutToAppear(): void {
    this.score = AppStorage.get('mm_score') ?? 0;
    this.best = AppStorage.get('mm_best') ?? 0;
  }

  build() {
    Column({ space: 6 }) {
      Text('Game Over')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Bolder)

      Text(`Score: ${this.score}`)
        .fontColor(Color.White)
        .fontSize(10)

      Text(`Best: ${this.best}`)
        .fontColor(Color.White)
        .fontSize(10)
        .margin({ bottom: 6 })

      Button('Retry')
        .type(ButtonType.Capsule)
        .width(80)
        .height(24)
        .fontSize(9)
        .onClick(() => {
          AppStorage.setOrCreate('mm_score', 0);
          AppStorage.setOrCreate('mm_pattern', [] as number[]);
          this.vm.navigateToPage(RouteName.Game);
        })

      Button('Home')
        .type(ButtonType.Capsule)
        .width(80)
        .height(24)
        .fontSize(9)
        .onClick(() => this.vm.resetToHome())
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .padding(8)
    .backgroundColor(Color.Black)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [
        [$r('app.color.base_background_gradient_start'), 0.0],
        [$r('app.color.base_background_gradient_end'), 1.0],
      ],
    })
  }
}
