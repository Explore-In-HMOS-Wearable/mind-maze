class StorageService {
  private _best = 0;
  getBest(): number { return this._best; }
  setBest(v: number) { this._best = Math.max(this._best, v); }
}
export const storageService = new StorageService();
