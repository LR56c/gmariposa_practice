import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Result, Schema } from 'effect';
import { Observable, catchError, map, of } from 'rxjs';
import { Errors, NetworkException, ParseException, ServerException } from '../../core/errors/errors';
import { Order, OrdersResponseSchema } from './order.schema';

export const ORDERS_URL = 'https://dummyjson.com/carts?limit=0';

const decode = Schema.decodeUnknownResult(OrdersResponseSchema);

@Injectable({ providedIn: 'root' })
export class OrdersService {
  private readonly http = inject(HttpClient);

  getOrders(): Observable<Result.Result<ReadonlyArray<Order>, Errors>> {
    return this.http.get<unknown>(ORDERS_URL).pipe(
      map((body) => {
        const decoded = decode(body);
        return Result.isSuccess(decoded)
          ? Result.succeed(decoded.success.carts)
          : Result.fail(new Errors([new ParseException(decoded.failure.message)]));
      }),
      catchError((e: HttpErrorResponse) =>
        of(
          Result.fail(
            new Errors([e.status === 0 ? new NetworkException() : new ServerException(e.status)]),
          ),
        ),
      ),
    );
  }
}
