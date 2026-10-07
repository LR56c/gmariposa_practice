import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Result, Schema } from 'effect';
import { Observable, catchError, map, of } from 'rxjs';
import { Errors, NetworkException, ParseException, ServerException } from '../../core/errors/errors';
import { Order, OrderSchema, OrdersResponseSchema } from './order.schema';

export const ORDERS_URL = 'https://dummyjson.com/carts?limit=0';
export const orderUrl = (id: number) => `https://dummyjson.com/carts/${id}`;

const decode = Schema.decodeUnknownResult(OrdersResponseSchema);
const decodeOrder = Schema.decodeUnknownResult(OrderSchema);

const toFailure = (e: HttpErrorResponse) =>
  of(
    Result.fail(new Errors([e.status === 0 ? new NetworkException() : new ServerException(e.status)])),
  );

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
      catchError(toFailure),
    );
  }

  getById(id: number): Observable<Result.Result<Order, Errors>> {
    return this.http.get<unknown>(orderUrl(id)).pipe(
      map((body) => {
        const decoded = decodeOrder(body);
        return Result.isSuccess(decoded)
          ? Result.succeed(decoded.success)
          : Result.fail(new Errors([new ParseException(decoded.failure.message)]));
      }),
      catchError(toFailure),
    );
  }
}
