import { RouteName } from '../services/NavigationService';
import { BaseViewModel } from '../viewmodel/BaseViewModel';
import { appDataService } from '../services/AppDataService';

interface TutorialStep {
  title: string;
  body: string;
}

const STEPS: TutorialStep[] = [
  { title: 'Watch', body: 'Memorize the tile flash order before tapping.' },
  { title: 'Repeat', body: 'Tap tiles in the same order to gain score and extend time.' },
  { title: 'Survive', body: 'Wrong taps cost lives. Timer ending or zero lives ends the run.' }
];

@Component
export struct TutorialPage {
  vm: BaseViewModel = new BaseViewModel();
  @State stepIndex: number = 0;

  private finishTutorial(): void {
    appDataService.completeTutorial();
    this.vm.resetToHome();
  }

  build() {
    Column({ space: 14 }) {
      Text('How to Play')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(`${this.stepIndex + 1}/${STEPS.length}`)
        .fontSize(11)
        .fontColor('#A3B7CE')

      Column({ space: 8 }) {
        Text(STEPS[this.stepIndex].title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFD166')
        Text(STEPS[this.stepIndex].body)
          .fontSize(12)
          .fontColor('#EAF1FF')
          .textAlign(TextAlign.Center)
      }
      .width('92%')
      .padding(14)
      .borderRadius(14)
      .backgroundColor('#1A2638')

      Row({ space: 8 }) {
        Button('Back')
          .enabled(this.stepIndex > 0)
          .type(ButtonType.Capsule)
          .width(72)
          .height(30)
          .fontSize(11)
          .backgroundColor('#324A64')
          .fontColor(Color.White)
          .onClick(() => this.stepIndex = Math.max(0, this.stepIndex - 1))

        Button(this.stepIndex === STEPS.length - 1 ? 'Finish' : 'Next')
          .type(ButtonType.Capsule)
          .width(90)
          .height(30)
          .fontSize(11)
          .backgroundColor('#FF8A3D')
          .fontColor(Color.White)
          .onClick(() => {
            if (this.stepIndex >= STEPS.length - 1) {
              this.finishTutorial();
            } else {
              this.stepIndex += 1;
            }
          })
      }

      Button('Skip')
        .type(ButtonType.Capsule)
        .width(90)
        .height(28)
        .fontSize(10)
        .backgroundColor('#2C384B')
        .fontColor('#CFE0FF')
        .onClick(() => this.finishTutorial())
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#070D16')
  }
}
