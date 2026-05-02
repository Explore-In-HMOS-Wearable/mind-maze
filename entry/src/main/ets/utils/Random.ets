import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { BusinessError } from '@kit.BasicServicesKit';

export function secureRandomIntSync(maxExclusive: number): number {
  if (maxExclusive <= 0) {
    throw new RangeError('maxExclusive must be > 0');
  }

  let rand: cryptoFramework.Random;
  try {
    rand = cryptoFramework.createRandom();
  } catch (e) {
    const err = e as BusinessError;
    throw new Error(`secureRandomIntSync init failed: ${err.code} ${err.message}`);
  }
  const MAX_UINT32 = 0x100000000; // 2^32
  const limit = Math.floor(MAX_UINT32 / maxExclusive) * maxExclusive;

  while (true) {
    try {
      const out = rand.generateRandomSync(4);
      const b = out.data;
      const x = ((b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3]) >>> 0;
      if (x < limit) {
        return x % maxExclusive;
      }
    } catch (e) {
      const err = e as BusinessError;
      throw new Error(`secureRandomIntSync failed: ${err.code} ${err.message}`);
    }
  }
}

export async function secureRandomInt(maxExclusive: number): Promise<number> {
  if (maxExclusive <= 0) {
    throw new RangeError('maxExclusive must be > 0');
  }

  let rand: cryptoFramework.Random;
  try {
    rand = cryptoFramework.createRandom();
  } catch (e) {
    const err = e as BusinessError;
    throw new Error(`secureRandomInt init failed: ${err.code} ${err.message}`);
  }
  const MAX_UINT32 = 0x100000000;
  const limit = Math.floor(MAX_UINT32 / maxExclusive) * maxExclusive;

  for (let attempts = 0; attempts < 4; attempts++) {
    try {
      const out = await rand.generateRandom(4);
      const b = out.data;
      const x = ((b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3]) >>> 0;
      if (x < limit) {
        return x % maxExclusive;
      }
    } catch (e) {
      const err = e as BusinessError;
      throw new Error(`secureRandomInt failed: ${err.code} ${err.message}`);
    }
  }

  return 0;
}
