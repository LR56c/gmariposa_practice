import { AmountPipe } from './amount.pipe';

describe('AmountPipe', () => {
  const pipe = new AmountPipe();

  it('uses two decimals, a dot, no thousands separator and no symbol', () => {
    expect(pipe.transform(1234.5)).toBe('1234.50');
    expect(pipe.transform(0)).toBe('0.00');
  });
});
