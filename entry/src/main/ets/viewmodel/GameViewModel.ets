import type { GameState } from '../model/GameTypes';
import { gameService } from '../services/GameServices';

export enum Phase {
  Playback = 'Playback',
  Input = 'Input',
  RoundResult = 'RoundResult',
  GameOver = 'GameOver'
}

export class GameViewModel {
  state: GameState = gameService.newGame();
  private readonly BONUS_MS: number = 5000;
  private readonly successMsgs: string[] = ['Great!', 'Awesome!', 'Nice!', 'Keep going!', '🔥 Combo!'];
  private readonly failMsgs: string[] = ['Oops!', 'Try again!', 'Missed!', '😬 Wrong!'];

  constructor() {
    this.loadSavedState();
  }

  private delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => setTimeout(resolve, ms));
  }

  private async flashTileOnce(id: number, ms: number = 100): Promise<void> {
    this.state.flashTile = id;
    await this.delay(ms);
    this.state.flashTile = -1;
  }

  private saveState(): void {
    try {
      const serialized: string = JSON.stringify(this.state);
      AppStorage.setOrCreate('mm_state', serialized);
    } catch (err) {
      console.warn('State save failed:', err);
    }
  }

  private loadSavedState(): void {
    const savedValue: string | undefined = AppStorage.get('mm_state') as string | undefined;

    if (savedValue && savedValue.trim().length > 0) {
      try {
        const parsed: GameState | null = JSON.parse(savedValue) as GameState | null;
        if (parsed && this.isValidGameState(parsed)) {
          this.state = parsed;
        } else {
          this.state = gameService.newGame();
        }
      } catch (err: any) {
        const errorMessage: string =
          err && typeof err === 'object' && (err as Error).message
            ? (err as Error).message
            : 'Unknown error';
        console.warn('State load failed:', errorMessage);
        this.state = gameService.newGame();
      }
    } else {
      this.state = gameService.newGame();
    }
  }

  private isValidGameState(obj: object | null): boolean {
    if (obj === null) return false;

    const test: Partial<GameState> = obj as Partial<GameState>;
    return (
      typeof test.phase === 'string' &&
      Array.isArray(test.pattern) &&
        typeof test.score === 'number'
    );
  }

  async start(): Promise<void> {
    this.state = gameService.newGame();
    this.state.phase = Phase.Playback;
    gameService.addStep(this.state);
    this.saveState();
    await gameService.playPattern(this.state);
  }

  async retry(): Promise<void> {
    await this.start();
  }

  async tap(tileId: number): Promise<void> {
    if (this.state.phase !== Phase.Input) return;

    const expected: number = this.state.pattern[this.state.userIndex];
    if (tileId === expected) {
      this.state.userIndex++;
      this.state.score++;
      this.state.bonusMs += this.BONUS_MS;
      this.state.status = this.successMsgs[Math.floor(Math.random() * this.successMsgs.length)];
      await this.flashTileOnce(tileId);

      if (this.state.userIndex >= this.state.pattern.length) {
        this.state.phase = Phase.RoundResult;
        await this.delay(400);
        gameService.addStep(this.state);
        if (this.state.score % 5 === 0) {
          gameService.harder(this.state);
        }
        this.saveState();
        await gameService.playPattern(this.state);
      }
    } else {
      this.state.phase = Phase.RoundResult;
      this.state.status = this.failMsgs[Math.floor(Math.random() * this.failMsgs.length)];
      this.state.lives = Math.max(0, this.state.lives - 1);
      await this.delay(600);

      if (this.state.lives > 0) {
        await gameService.playPattern(this.state);
      } else {
        this.state.phase = Phase.GameOver;
        if (this.state.score > this.state.best) {
          this.state.best = this.state.score;
        }
        this.saveState();
      }
    }
  }
}

export const gameVM: GameViewModel = new GameViewModel();
