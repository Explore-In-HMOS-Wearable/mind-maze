export enum GameMode {
  Classic = 'Classic',
  Practice = 'Practice'
}

export interface AppSettings {
  mode: GameMode;
  hapticsEnabled: boolean;
  showTileLabels: boolean;
  highContrast: boolean;
}

export interface RunSummary {
  score: number;
  level: number;
  mode: GameMode;
  durationSec: number;
  livesLeft: number;
  mistakes: number;
  maxCombo: number;
  bonusTimeSec: number;
  correctTaps: number;
  createdAt: number;
}

export interface AppData {
  tutorialCompleted: boolean;
  settings: AppSettings;
  recentRuns: RunSummary[];
  bestByMode: Record<string, number>;
}

export const DEFAULT_SETTINGS: AppSettings = {
  mode: GameMode.Classic,
  hapticsEnabled: true,
  showTileLabels: false,
  highContrast: false
};

export const EMPTY_APP_DATA: AppData = {
  tutorialCompleted: false,
  settings: DEFAULT_SETTINGS,
  recentRuns: [],
  bestByMode: {}
};
