import { Injectable, computed, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { Result } from 'effect';
import { Subject, exhaustMap } from 'rxjs';
import { ErrorInfo, toErrorInfo } from '../../core/errors/errors';
import { Order } from './order.schema';
import { OrdersService } from './orders.service';

export type ListStatus = 'idle' | 'loading' | 'loaded' | 'error';

interface OrdersState {
  readonly byId: Readonly<Record<number, Order>>;
  readonly listStatus: ListStatus;
  readonly listError: ErrorInfo | null;
  readonly minTotal: number | null;
}

/** Empty or non-numeric text (including a decimal comma, "30,5") means "no filter". */
export function parseMinTotal(raw: string): number | null {
  const text = raw.trim();
  if (text === '') return null;
  const value = Number(text);
  return Number.isFinite(value) ? value : null;
}

@Injectable({ providedIn: 'root' })
export class OrdersStore {
  private readonly service = inject(OrdersService);
  private readonly state = signal<OrdersState>({ byId: {}, listStatus: 'idle', listError: null, minTotal: null });
  private readonly load$ = new Subject<void>();

  readonly listStatus = computed(() => this.state().listStatus);
  readonly listError = computed(() => this.state().listError);
  readonly minTotal = computed(() => this.state().minTotal);
  readonly orders = computed(() => Object.values(this.state().byId).sort((a, b) => a.id - b.id));
  readonly visibleOrders = computed(() => {
    const min = this.minTotal();
    return min === null ? this.orders() : this.orders().filter((o) => o.total >= min);
  });

  constructor() {
    // exhaustMap: a load requested while one is in flight is ignored.
    this.load$
      .pipe(
        exhaustMap(() => {
          this.state.update((s) => ({ ...s, listStatus: 'loading', listError: null }));
          return this.service.getOrders();
        }),
        takeUntilDestroyed(),
      )
      .subscribe((result) =>
        this.state.update((s) =>
          Result.isSuccess(result)
            ? {
                ...s,
                byId: { ...s.byId, ...Object.fromEntries(result.success.map((o) => [o.id, o])) },
                listStatus: 'loaded',
              }
            : { ...s, listStatus: 'error', listError: toErrorInfo(result.failure) },
        ),
      );
  }

  setMinTotal(raw: string): void {
    this.state.update((s) => ({ ...s, minTotal: parseMinTotal(raw) }));
  }

  load(): void {
    this.load$.next();
  }
}
