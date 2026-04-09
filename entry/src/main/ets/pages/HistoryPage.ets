import { BaseViewModel } from '../viewmodel/BaseViewModel';
import { appDataService } from '../services/AppDataService';
import { RunSummary } from '../model/AppDataTypes';

@Component
export struct HistoryPage {
  vm: BaseViewModel = new BaseViewModel();
  @State runs: RunSummary[] = [];
  @State bestClassic: number = 0;
  @State bestPractice: number = 0;

  aboutToAppear(): void {
    const data = appDataService.load();
    this.runs = data.recentRuns;
    this.bestClassic = Number(data.bestByMode.Classic ?? 0);
    this.bestPractice = Number(data.bestByMode.Practice ?? 0);
  }

  private fmtTime(ts: number): string {
    const date: Date = new Date(ts);
    const hh: string = String(date.getHours()).padStart(2, '0');
    const mm: string = String(date.getMinutes()).padStart(2, '0');
    return `${hh}:${mm}`;
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Text('Recent Runs')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ top: 10 })

        Row({ space: 8 }) {
          Text(`Classic ${this.bestClassic}`)
            .fontSize(9)
            .fontColor('#0B1E33')
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .backgroundColor('#9ED0FF')
            .borderRadius(8)
          Text(`Practice ${this.bestPractice}`)
            .fontSize(9)
            .fontColor('#132600')
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .backgroundColor('#BEEA8A')
            .borderRadius(8)
        }

        if (this.runs.length === 0) {
          Text('No finished runs yet.')
            .fontSize(12)
            .fontColor('#A5B6CB')
            .margin({ top: 8, bottom: 8 })
        } else {
          ForEach(this.runs, (run: RunSummary, index: number) => {
            Column({ space: 4 }) {
              Row() {
                Text(`#${index + 1} ${run.mode}`)
                  .fontSize(11)
                  .fontColor('#E8F2FF')
                Blank()
                Text(`S${run.score} L${run.level}`)
                  .fontSize(11)
                  .fontColor('#FFD166')
              }

              Row() {
                Text(`${run.durationSec}s • +${run.bonusTimeSec}s • X${run.mistakes}`)
                  .fontSize(9)
                  .fontColor('#A5B6CB')
                Blank()
                Text(this.fmtTime(run.createdAt))
                  .fontSize(9)
                  .fontColor('#8CA3BD')
              }
            }
            .width('94%')
            .padding(10)
            .borderRadius(10)
            .backgroundColor('#1A2738')
          }, (run: RunSummary, index: number): string => `${run.createdAt}-${index}`)
        }

        Button('Back')
          .type(ButtonType.Capsule)
          .width(96)
          .height(30)
          .fontSize(11)
          .backgroundColor('#3B4E63')
          .fontColor(Color.White)
          .onClick(() => this.vm.back())
          .margin({ bottom: 14, top: 8 })
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#070D16')
  }
}
