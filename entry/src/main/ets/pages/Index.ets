// entry/src/main/ets/pages/Index.ets
import { HomePage } from './HomePage';
import { GamePage } from './GamePage';
import { ResultPage } from './ResultPage';
import { TutorialPage } from './TutorialPage';
import { SettingsPage } from './SettingsPage';
import { HistoryPage } from './HistoryPage';

@Entry
@Component
struct Index {
  @StorageLink('route') route: string = 'Home';

  @Builder
  private RenderRoute() {
    if (this.route === 'Home') {
      HomePage();
    } else if (this.route === 'Game') {
      GamePage();
    } else if (this.route === 'Result') {
      ResultPage();
    } else if (this.route === 'Tutorial') {
      TutorialPage();
    } else if (this.route === 'Settings') {
      SettingsPage();
    } else if (this.route === 'History') {
      HistoryPage();
    } else {
      HomePage();
    }
  }

  build() {
    Column() {
      this.RenderRoute()
    }
    .width('100%')
    .height('100%')
  }
}
