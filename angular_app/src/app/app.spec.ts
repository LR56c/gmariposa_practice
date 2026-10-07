import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { Router, provideRouter } from '@angular/router';
import { App } from './app';
import { routes } from './app.routes';
import { ORDERS_URL } from './features/orders/orders.service';

describe('App', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideRouter(routes), provideHttpClient(), provideHttpClientTesting()],
    });
  });

  async function render() {
    const fixture = TestBed.createComponent(App);
    await TestBed.inject(Router).navigateByUrl('/');
    await fixture.whenStable();
    return fixture;
  }

  const text = (f: { nativeElement: unknown }) => (f.nativeElement as HTMLElement).textContent ?? '';

  it('shows the title and a loading state while the list loads', async () => {
    const fixture = await render();
    expect(text(fixture)).toContain('Órdenes');
    expect(text(fixture)).toContain('Cargando');
  });

  it('renders one card per order, sorted by id', async () => {
    const fixture = await render();
    const order = (id: number, extra = {}) => ({ id, userId: 7, total: 1234.5, products: [], ...extra });
    TestBed.inject(HttpTestingController)
      .expectOne(ORDERS_URL)
      .flush({ carts: [order(2, { discountedTotal: 999 }), order(1)] });
    await fixture.whenStable();
    const cards = (fixture.nativeElement as HTMLElement).querySelectorAll('app-order-card');
    expect(cards.length).toBe(2);
    expect(cards[0].textContent).toContain('Orden 1');
    expect(cards[0].textContent).toContain('1234.50');
    expect(cards[0].textContent).not.toContain('descuento');
    expect(cards[1].textContent).toContain('999.00');
  });

  it('shows the error message and retries', async () => {
    const fixture = await render();
    const http = TestBed.inject(HttpTestingController);
    http.expectOne(ORDERS_URL).flush('boom', { status: 500, statusText: 'Server Error' });
    await fixture.whenStable();
    expect(text(fixture)).toContain('Algo salió mal');
    (fixture.nativeElement as HTMLElement).querySelector('button')!.click();
    await fixture.whenStable();
    expect(text(fixture)).toContain('Cargando');
    http.expectOne(ORDERS_URL).flush({ carts: 'bad' });
    await fixture.whenStable();
    expect(text(fixture)).toContain('No se pudo leer la respuesta');
  });

  it('maps a connection failure to the network message', async () => {
    const fixture = await render();
    TestBed.inject(HttpTestingController).expectOne(ORDERS_URL).error(new ProgressEvent('error'));
    await fixture.whenStable();
    expect(text(fixture)).toContain('No se pudo conectar');
  });

  it('filters by minimum total without a second request, and shows the empty message', async () => {
    const fixture = await render();
    const http = TestBed.inject(HttpTestingController);
    const order = (id: number, total: number) => ({ id, userId: 7, total, products: [] });
    http.expectOne(ORDERS_URL).flush({ carts: [order(1, 50), order(2, 100)] });
    await fixture.whenStable();
    const root = fixture.nativeElement as HTMLElement;
    const input = root.querySelector<HTMLInputElement>('#min-total')!;
    const type = async (v: string) => {
      input.value = v;
      input.dispatchEvent(new Event('input'));
      await fixture.whenStable();
    };
    await type('100');
    expect(root.querySelectorAll('app-order-card').length).toBe(1);
    await type('30,5');
    expect(root.querySelectorAll('app-order-card').length).toBe(2);
    await type('101');
    expect(text(fixture)).toContain('Ninguna orden alcanza ese total');
    http.expectNone(ORDERS_URL);
  });
});
