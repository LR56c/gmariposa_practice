import { parseMinTotal } from './orders.store';

describe('parseMinTotal', () => {
  it('treats empty and non-numeric text (incl. decimal comma) as no filter', () => {
    for (const raw of ['', '  ', 'abc', '30,5']) expect(parseMinTotal(raw)).toBeNull();
  });

  it('parses numbers', () => {
    expect(parseMinTotal('30.5')).toBe(30.5);
    expect(parseMinTotal('0')).toBe(0);
  });
});
