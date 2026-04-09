import { BaseViewModel } from '../viewmodel/BaseViewModel';
import { appDataService } from '../services/AppDataService';
import { AppSettings, GameMode } from '../model/AppDataTypes';

@Component
export struct SettingsPage {
  vm: BaseViewModel = new BaseViewModel();
  @State settings: AppSettings = appDataService.getSettings();

  aboutToAppear(): void {
    this.settings = appDataService.getSettings();
  }

  private persist(): void {
    appDataService.updateSettings(this.settings);
  }

  private applySettings(mode: GameMode, hapticsEnabled: boolean, showTileLabels: boolean, highContrast: boolean): void {
    this.settings = {
      mode: mode,
      hapticsEnabled: hapticsEnabled,
      showTileLabels: showTileLabels,
      highContrast: highContrast
    };
    this.persist();
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('Settings')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ top: 10 })

        Column({ space: 10 }) {
          Text('Mode')
            .fontColor('#B8C9DF')
            .fontSize(12)
          Row({ space: 8 }) {
            Button('Classic')
              .type(ButtonType.Capsule)
              .width(94)
              .height(30)
              .fontSize(11)
              .fontColor(this.settings.mode === GameMode.Classic ? '#08121F' : '#E1EDFF')
              .backgroundColor(this.settings.mode === GameMode.Classic ? '#89D1FF' : '#24384F')
              .onClick(() => this.applySettings(GameMode.Classic, this.settings.hapticsEnabled, this.settings.showTileLabels,
                this.settings.highContrast))

            Button('Practice')
              .type(ButtonType.Capsule)
              .width(94)
              .height(30)
              .fontSize(11)
              .fontColor(this.settings.mode === GameMode.Practice ? '#08121F' : '#E1EDFF')
              .backgroundColor(this.settings.mode === GameMode.Practice ? '#89D1FF' : '#24384F')
              .onClick(() => this.applySettings(GameMode.Practice, this.settings.hapticsEnabled, this.settings.showTileLabels,
                this.settings.highContrast))
          }
        }
        .width('94%')
        .padding(12)
        .backgroundColor('#1B2A3D')
        .borderRadius(12)

        Column({ space: 10 }) {
          Toggle({ type: ToggleType.Switch, isOn: this.settings.hapticsEnabled })
            .onChange((isOn: boolean) => {
              this.applySettings(this.settings.mode, isOn, this.settings.showTileLabels, this.settings.highContrast);
            })
          Text('Haptics enabled')
            .fontSize(12)
            .fontColor('#EAF3FF')

          Toggle({ type: ToggleType.Switch, isOn: this.settings.showTileLabels })
            .onChange((isOn: boolean) => {
              this.applySettings(this.settings.mode, this.settings.hapticsEnabled, isOn, this.settings.highContrast);
            })
          Text('Show tile labels')
            .fontSize(12)
            .fontColor('#EAF3FF')

          Toggle({ type: ToggleType.Switch, isOn: this.settings.highContrast })
            .onChange((isOn: boolean) => {
              this.applySettings(this.settings.mode, this.settings.hapticsEnabled, this.settings.showTileLabels, isOn);
            })
          Text('High contrast tiles')
            .fontSize(12)
            .fontColor('#EAF3FF')
        }
        .width('94%')
        .padding(12)
        .backgroundColor('#1B2A3D')
        .borderRadius(12)

        Button('Back')
          .type(ButtonType.Capsule)
          .width(96)
          .height(30)
          .fontSize(11)
          .backgroundColor('#3B4E63')
          .fontColor(Color.White)
          .onClick(() => this.vm.back())
          .margin({ bottom: 14 })
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#070D16')
  }
}
