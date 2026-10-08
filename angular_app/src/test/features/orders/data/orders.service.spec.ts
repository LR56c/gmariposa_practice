import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { Result } from 'effect';
import {
  NetworkException,
  ParseException,
  ServerException,
} from '../../../../app/core/errors/errors';
import {
  ORDERS_URL,
  OrdersService,
  orderUrl,
} from '../../../../app/features/orders/data/orders.service';

describe('OrdersService.getById', () => {
  it('maps a 404 to ServerException(404)', () => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    const http = TestBed.inject(HttpTestingController);
    let out: unknown;
    TestBed.inject(OrdersService)
      .getById(99999)
      .subscribe((r) => (out = r));
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

describe('OrdersService', () => {
  const order = { id: 1, userId: 2, total: 10, products: [] };

  function setup() {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    const http = TestBed.inject(HttpTestingController);
    afterEach(() => http.verify());
    return { http, service: TestBed.inject(OrdersService) };
  }

  function firstFailure(result: unknown): unknown {
    if (!Result.isResult(result) || !Result.isFailure(result)) {
      throw new Error('expected a failure');
    }
    return (result.failure as { exceptions: unknown[] }).exceptions[0];
  }

  it('getOrders returns the decoded orders', () => {
    const { http, service } = setup();
    let out: unknown;
    service.getOrders().subscribe((r) => (out = r));
    http.expectOne(ORDERS_URL).flush({ carts: [order] });
    expect(out).toEqual(Result.succeed([order]));
  });

  it('getById returns the decoded order', () => {
    const { http, service } = setup();
    let out: unknown;
    service.getById(1).subscribe((r) => (out = r));
    http.expectOne(orderUrl(1)).flush(order);
    expect(out).toEqual(Result.succeed(order));
  });

  it('maps a 500 to ServerException(500)', () => {
    const { http, service } = setup();
    let out: unknown;
    service.getOrders().subscribe((r) => (out = r));
    http.expectOne(ORDERS_URL).flush({}, { status: 500, statusText: 'Server Error' });
    const first = firstFailure(out);
    expect(first).toBeInstanceOf(ServerException);
    expect((first as ServerException).status).toBe(500);
  });

  it('maps a connection failure (status 0) to NetworkException', () => {
    const { http, service } = setup();
    let out: unknown;
    service.getOrders().subscribe((r) => (out = r));
    http.expectOne(ORDERS_URL).error(new ProgressEvent('error'));
    expect(firstFailure(out)).toBeInstanceOf(NetworkException);
  });

  it('maps a body with the wrong shape to ParseException', () => {
    const { http, service } = setup();
    let out: unknown;
    service.getOrders().subscribe((r) => (out = r));
    http.expectOne(ORDERS_URL).flush({ carts: [{ id: 'one' }] });
    expect(firstFailure(out)).toBeInstanceOf(ParseException);
  });
});
