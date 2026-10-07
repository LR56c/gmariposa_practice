import { TestBed } from '@angular/core/testing';
import { Result } from 'effect';
import { of } from 'rxjs';
import { Errors, ServerException } from '../../../../app/core/errors/errors';
import { OrdersService } from '../../../../app/features/orders/data/orders.service';
import { OrdersStore, parseMinTotal } from '../../../../app/features/orders/state/orders.store';

describe('parseMinTotal', () => {
  it('treats empty and non-numeric text (incl. decimal comma) as no filter', () => {
    for (const raw of ['', '  ', 'abc', '30,5']) expect(parseMinTotal(raw)).toBeNull();
  });

  it('rejects signs, hex and exponents', () => {
    for (const raw of ['-5', '+3', '0x10', '1e3', 'Infinity']) {
      expect(parseMinTotal(raw)).toBeNull();
    }
  });

  it('parses numbers', () => {
    expect(parseMinTotal('30.5')).toBe(30.5);
    expect(parseMinTotal('0')).toBe(0);
    expect(parseMinTotal(' 12 ')).toBe(12);
  });
});

describe('OrdersStore.loadOrder', () => {
  const order = { id: 7, userId: 1, total: 10, products: [] };
  const other = { id: 3, userId: 2, total: 25, products: [] };

  function setup() {
    const getById = vi.fn(() => of(Result.succeed(order)));
    const getOrders = vi.fn(() => of(Result.succeed([other])));
    TestBed.configureTestingModule({
      providers: [{ provide: OrdersService, useValue: { getById, getOrders } }],
    });
    return { store: TestBed.inject(OrdersStore), getById };
  }

  it('fetches a missing order and upserts it', () => {
    const { store, getById } = setup();
    store.loadOrder(7);
    expect(getById).toHaveBeenCalledTimes(1);
    expect(store.order(7)).toEqual(order);
    expect(store.orderStatus(7)).toBe('loaded');
  });

  it('upserts without replacing the orders already loaded', () => {
    const { store } = setup();
    store.load();
    store.loadOrder(7);
    expect(store.orders().map((o) => o.id)).toEqual([3, 7]);
  });

  it('does not fetch when the order is already loaded', () => {
    const { store, getById } = setup();
    store.loadOrder(7);
    store.loadOrder(7);
    expect(getById).toHaveBeenCalledTimes(1);
  });

  it('records a failure and clears it when a retry succeeds', () => {
    const { store, getById } = setup();
    getById.mockReturnValueOnce(
      of(Result.fail(new Errors([new ServerException(404)]))) as never,
    );

    store.loadOrder(7);
    expect(store.orderStatus(7)).toBe('error');
    expect(store.orderError(7)?.code).toBe('notFound');

    store.loadOrder(7); // retry: the next answer is the default success
    expect(store.orderStatus(7)).toBe('loaded');
    expect(store.orderError(7)).toBeNull();
  });
});
