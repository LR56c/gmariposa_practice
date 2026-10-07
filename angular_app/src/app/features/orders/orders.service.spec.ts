import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { Result } from 'effect';
import { ServerException } from '../../core/errors/errors';
import { OrdersService, orderUrl } from './orders.service';

describe('OrdersService.getById', () => {
  it('maps a 404 to ServerException(404)', () => {
    TestBed.configureTestingModule({ providers: [provideHttpClient(), provideHttpClientTesting()] });
    const http = TestBed.inject(HttpTestingController);
    let out: unknown;
    TestBed.inject(OrdersService).getById(99999).subscribe((r) => (out = r));
    http.expectOne(orderUrl(99999)).flush({}, { status: 404, statusText: 'Not Found' });
    const result = out as Result.Result<unknown, { exceptions: unknown[] }>;
    expect(Result.isFailure(result)).toBe(true);
    if (Result.isFailure(result)) {
      const first = result.failure.exceptions[0];
      expect(first).toBeInstanceOf(ServerException);
      expect((first as ServerException).status).toBe(404);
    }
  });
});
