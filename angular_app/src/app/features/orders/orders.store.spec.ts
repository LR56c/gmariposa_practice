import { TestBed } from '@angular/core/testing';
import { Result } from 'effect';
import { of } from 'rxjs';
import { OrdersService } from './orders.service';
import { OrdersStore, parseMinTotal } from './orders.store';

describe('parseMinTotal', () => {
  it('treats empty and non-numeric text (incl. decimal comma) as no filter', () => {
    for (const raw of ['', '  ', 'abc', '30,5']) expect(parseMinTotal(raw)).toBeNull();
  });

  it('parses numbers', () => {
    expect(parseMinTotal('30.5')).toBe(30.5);
    expect(parseMinTotal('0')).toBe(0);
  });
});

describe('OrdersStore.loadOrder', () => {
  const order = { id: 7, userId: 1, total: 10, products: [] };

  function setup() {
    const getById = vi.fn(() => of(Result.succeed(order)));
    TestBed.configureTestingModule({ providers: [{ provide: OrdersService, useValue: { getById, getOrders: vi.fn() } }] });
    return { store: TestBed.inject(OrdersStore), getById };
  }

  it('fetches a missing order and upserts it without touching the rest', () => {
    const { store, getById } = setup();
    store.loadOrder(7);
    expect(getById).toHaveBeenCalledTimes(1);
    expect(store.order(7)).toEqual(order);
    expect(store.orderStatus(7)).toBe('loaded');
  });

  it('does not fetch when the order is already loaded', () => {
    const { store, getById } = setup();
    store.loadOrder(7);
    store.loadOrder(7);
    expect(getById).toHaveBeenCalledTimes(1);
  });
});
