import { ResolveFn, Routes } from '@angular/router';
import { OrdersPageComponent } from './features/orders/orders-page.component';

/** The only place the :id param becomes a number; null when it is not a positive integer. */
const orderId: ResolveFn<number | null> = (route) => {
  const id = Number(route.paramMap.get('id'));
  return Number.isInteger(id) && id > 0 ? id : null;
};

export const routes: Routes = [
  { path: '', component: OrdersPageComponent },
  {
    path: 'orders/:id',
    resolve: { id: orderId },
    // ponytail: the only dynamic import (lazy route), an exception to AD-15 `no-dynamic-imports`.
    loadComponent: () =>
      import('./features/orders/order-detail.component').then((m) => m.OrderDetailComponent),
  },
];
