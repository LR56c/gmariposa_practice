import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { Router, provideRouter, withComponentInputBinding } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { routes } from '../../../../app/app.routes';
import {
  ORDERS_URL,
  orderUrl,
} from '../../../../app/features/orders/data/orders.service';

describe('OrderDetailComponent (through the router)', () => {
  const order = {
    id: 5,
    userId: 2,
    total: 30,
    products: [{ id: 1, title: 'Mascara', quantity: 2, price: 10 }],
  };
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideRouter(routes, withComponentInputBinding()),
        provideHttpClient(),
        provideHttpClientTesting(),
      ],
    });
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify()); // no request left over, none unexpected

  async function open(url: string) {
    const harness = await RouterTestingHarness.create();
    await harness.navigateByUrl(url);
    return harness;
  }

  async function settle(harness: RouterTestingHarness): Promise<HTMLElement> {
    harness.detectChanges();
    await harness.fixture.whenStable();
    harness.detectChanges();
    return harness.routeNativeElement as HTMLElement;
  }

  it('shows the products of the order', async () => {
    const harness = await open('/orders/5');
    http.expectOne(orderUrl(5)).flush(order);
    const page = await settle(harness);

    expect(page.textContent).toContain('Mascara');
    expect(page.textContent).toContain('10.00');
    expect(page.querySelector('h3')?.textContent).toContain('Detalle de productos');
  });

  it('says so when the order has no products', async () => {
    const harness = await open('/orders/5');
    http.expectOne(orderUrl(5)).flush({ ...order, products: [] });
    const page = await settle(harness);

    expect(page.textContent).toContain('Esta orden no tiene productos');
  });

  it('shows "not found" for a 404', async () => {
    const harness = await open('/orders/5');
    http.expectOne(orderUrl(5)).flush({}, { status: 404, statusText: 'Not Found' });
    const page = await settle(harness);

    expect(page.textContent).toContain('No encontramos esa orden');
  });

  it('shows the error and "Reintentar" loads it again', async () => {
    const harness = await open('/orders/5');
    http.expectOne(orderUrl(5)).flush({}, { status: 500, statusText: 'Server Error' });
    const page = await settle(harness);
    expect(page.textContent).toContain('Algo salió mal');

    page.querySelector('button')?.click();
    http.expectOne(orderUrl(5)).flush(order);
    await settle(harness);

    expect(page.textContent).toContain('Mascara');
  });

  it('an invalid id shows "not found" without any request', async () => {
    const harness = await open('/orders/abc');
    const page = await settle(harness);

    expect(page.textContent).toContain('No encontramos esa orden');
    // afterEach(http.verify) fails if a request was made
  });

  it('an unknown URL goes back to the list', async () => {
    await open('/does/not/exist');
    http.expectOne(ORDERS_URL).flush({ carts: [] });

    expect(TestBed.inject(Router).url).toBe('/');
  });
});
