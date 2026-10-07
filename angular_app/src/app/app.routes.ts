import { ResolveFn, Routes } from '@angular/router';
import { OrdersPageComponent } from './features/orders/components/orders-page.component';

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
    loadComponent: () =>
      import('./features/orders/components/order-detail.component').then(
        (m) => m.OrderDetailComponent,
      ),
  },
];
