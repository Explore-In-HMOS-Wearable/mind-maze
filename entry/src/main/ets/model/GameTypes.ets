// entry/src/main/ets/model/GameTypes.ets
export enum Phase {
  Idle = 'Idle',
  Playback = 'Playback',
  Input = 'Input',
  RoundResult = 'RoundResult',
  GameOver = 'GameOver'
}

export interface TileDef {
  id: number;
  color: Resource;
  label: string;
}

export interface GameState {
  phase: Phase;
  pattern: number[];
  userIndex: number;
  level: number;
  score: number;
  best: number;
  speedMs: number;
  lives: number;
  flashTile: number;
  status: string;
  bonusMs: number;
}
