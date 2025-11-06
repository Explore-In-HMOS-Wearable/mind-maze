// entry/src/main/ets/services/NavigationService.ets
export enum RouteName {
  Home = 'Home',
  Game = 'Game',
  Result = 'Result'
}

export class NavigationService {
  private static _inst: NavigationService | undefined;

  private constructor() {
    const cur: string | undefined = AppStorage.get('route');
    if (cur === undefined || cur === null) {
      AppStorage.setOrCreate('route', RouteName.Home);
    }
  }

  static getInstance(): NavigationService {
    if (!NavigationService._inst) {
      NavigationService._inst = new NavigationService();
    }
    return NavigationService._inst;
  }

  go(name: RouteName): void {
    AppStorage.setOrCreate('route', name);
  }

  reset(name: RouteName): void {
    AppStorage.setOrCreate('route', name);
  }

  back(): void {
    AppStorage.setOrCreate('route', RouteName.Home);
  }
}
