import { ResolveFn, Routes } from '@angular/router';
import { OrdersPageComponent } from './features/orders/components/orders-page.component';

/** The only place the :id param becomes a number; null when it is not a positive integer. */
export const orderId: ResolveFn<number | null> = (route) => {
  const raw = route.paramMap.get('id') ?? '';
  const id = Number(raw);
  return /^[1-9]\d*$/.test(raw) && Number.isSafeInteger(id) ? id : null;
};

export const routes: Routes = [
  { path: '', component: OrdersPageComponent },
  {
    path: 'orders/:id',
    resolve: { id: orderId },
    loadComponent: () =>
      import('./features/orders/components/order-detail.component').then(
        (m) => m.OrderDetailComponent,
      ),
  },
  // Any other URL goes back to the list.
  { path: '**', redirectTo: '' },
];
