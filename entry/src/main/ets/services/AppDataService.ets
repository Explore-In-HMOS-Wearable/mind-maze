import { AppData, AppSettings, DEFAULT_SETTINGS, EMPTY_APP_DATA, GameMode, RunSummary } from '../model/AppDataTypes';

const APP_DATA_KEY: string = 'mm_app_data';
const MAX_RUNS: number = 12;

class AppDataService {
  private initialized: boolean = false;

  private ensureInit(): void {
    if (this.initialized) {
      return;
    }
    PersistentStorage.persistProp(APP_DATA_KEY, JSON.stringify(EMPTY_APP_DATA));
    this.initialized = true;
  }

  private readRaw(): string {
    this.ensureInit();
    return String(AppStorage.get(APP_DATA_KEY) ?? JSON.stringify(EMPTY_APP_DATA));
  }

  private write(data: AppData): void {
    this.ensureInit();
    AppStorage.setOrCreate(APP_DATA_KEY, JSON.stringify(data));
  }

  private normalize(data: Partial<AppData> | null): AppData {
    if (!data) {
      return {
        tutorialCompleted: false,
        settings: {
          mode: DEFAULT_SETTINGS.mode,
          hapticsEnabled: DEFAULT_SETTINGS.hapticsEnabled,
          showTileLabels: DEFAULT_SETTINGS.showTileLabels,
          highContrast: DEFAULT_SETTINGS.highContrast
        },
        recentRuns: [],
        bestByMode: {}
      };
    }

    const sourceSettings: Partial<AppSettings> | undefined = data.settings;
    const modeRaw: string = String(sourceSettings?.mode ?? DEFAULT_SETTINGS.mode);
    const safeMode: GameMode = modeRaw === GameMode.Practice ? GameMode.Practice : GameMode.Classic;

    const safeSettings: AppSettings = {
      mode: safeMode,
      hapticsEnabled: sourceSettings?.hapticsEnabled !== false,
      showTileLabels: sourceSettings?.showTileLabels === true,
      highContrast: sourceSettings?.highContrast === true
    };

    const safeRecent: RunSummary[] = Array.isArray(data.recentRuns)
      ? data.recentRuns
        .filter((run: RunSummary): boolean => typeof run.score === 'number' && typeof run.level === 'number')
        .map((run: RunSummary): RunSummary => {
          return {
            score: Number(run.score ?? 0),
            level: Number(run.level ?? 1),
            mode: run.mode === GameMode.Practice ? GameMode.Practice : GameMode.Classic,
            durationSec: Number(run.durationSec ?? 0),
            livesLeft: Number(run.livesLeft ?? 0),
            mistakes: Number(run.mistakes ?? 0),
            maxCombo: Number(run.maxCombo ?? 0),
            bonusTimeSec: Number(run.bonusTimeSec ?? 0),
            correctTaps: Number(run.correctTaps ?? 0),
            createdAt: Number(run.createdAt ?? Date.now())
          };
        })
        .slice(0, MAX_RUNS)
      : [];

    return {
      tutorialCompleted: data.tutorialCompleted === true,
      settings: safeSettings,
      recentRuns: safeRecent,
      bestByMode: typeof data.bestByMode === 'object' && data.bestByMode !== null ? data.bestByMode : {}
    };
  }

  load(): AppData {
    try {
      const parsed: Partial<AppData> = JSON.parse(this.readRaw()) as Partial<AppData>;
      const normalized: AppData = this.normalize(parsed);
      this.write(normalized);
      return normalized;
    } catch (_) {
      const fallback: AppData = this.normalize(null);
      this.write(fallback);
      return fallback;
    }
  }

  getSettings(): AppSettings {
    return this.load().settings;
  }

  updateSettings(next: AppSettings): void {
    const data: AppData = this.load();
    data.settings = this.normalize({ settings: next }).settings;
    this.write(data);
  }

  completeTutorial(): void {
    const data: AppData = this.load();
    data.tutorialCompleted = true;
    this.write(data);
  }

  addRun(run: RunSummary): void {
    const data: AppData = this.load();
    const nextRuns: RunSummary[] = [run];
    for (let i = 0; i < data.recentRuns.length && i < MAX_RUNS - 1; i++) {
      nextRuns.push(data.recentRuns[i]);
    }
    data.recentRuns = nextRuns;
    const currentBest: number = Number(data.bestByMode[run.mode] ?? 0);
    if (run.score > currentBest) {
      data.bestByMode[run.mode] = run.score;
    }
    this.write(data);
  }
}

export const appDataService: AppDataService = new AppDataService();
