// entry/src/main/ets/viewmodel/BaseViewModel.ets
import { NavigationService, RouteName } from '../services/NavigationService';

export class BaseViewModel {
  nav: NavigationService = NavigationService.getInstance();

  navigateToPage(name: RouteName): void {
    this.nav.go(name);
  }

  back(): void {
    this.nav.back();
  }

  resetToHome(): void {
    this.nav.reset(RouteName.Home);
  }
}
