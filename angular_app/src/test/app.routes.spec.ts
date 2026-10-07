import { TestBed } from '@angular/core/testing';
import { ActivatedRouteSnapshot, convertToParamMap } from '@angular/router';
import { orderId } from '../app/app.routes';

describe('orderId resolver', () => {
  function resolve(id: string | null): unknown {
    const route = { paramMap: convertToParamMap(id === null ? {} : { id }) };
    return TestBed.runInInjectionContext(() =>
      orderId(route as ActivatedRouteSnapshot, { url: '' } as never),
    );
  }

  it('parses a positive integer once', () => {
    expect(resolve('7')).toBe(7);
  });

  it('turns anything else into null so no request is made', () => {
    for (const raw of ['abc', '0', '-5', '1.5', '0x10', '1e0', ' 1', '']) {
      expect(resolve(raw)).toBeNull();
    }
    expect(resolve(null)).toBeNull();
  });
});
