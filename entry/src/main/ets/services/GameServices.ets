// entry/src/main/ets/services/GameService.ets
import { delay } from '../utils/Delay';
import { Phase, type GameState } from '../model/GameTypes';

export class GameService {
  newGame(): GameState {
    return {
      phase: Phase.Idle,
      pattern: [],
      userIndex: 0,
      level: 0,
      score: 0,
      best: 0,
      speedMs: 700,
      lives: 3,
      flashTile: -1,
      status: 'Ready'
    };
  }

  addStep(state: GameState): void {
    const next: number = Math.floor(Math.random() * 4);
    state.pattern.push(next);
  }

  harder(state: GameState): void {
    state.level++;
    if (state.level % 3 === 0) {
      state.speedMs = Math.max(350, state.speedMs - 50);
    }
  }

  async playPattern(state: GameState): Promise<void> {
    state.phase = Phase.Playback;
    state.status = 'Watch…';

    for (const id of state.pattern) {
      state.flashTile = id;
      await delay(state.speedMs);
      state.flashTile = -1;
      await delay(180);
    }

    state.userIndex = 0;
    state.phase = Phase.Input;
    state.status = 'Your turn!';
  }
}

export const gameService: GameService = new GameService();
