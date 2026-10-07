import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { OrderCardComponent } from './order-card.component';
import { OrdersStore } from './orders.store';

@Component({
  selector: 'app-orders-page',
  imports: [OrderCardComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <main class="mx-auto max-w-5xl p-4">
      <h1 class="mb-4 text-title-lg" i18n="@@orders.title">Órdenes</h1>
      <div aria-live="polite">
        @switch (store.listStatus()) {
          @case ('loading') {
            <p role="status" class="flex items-center gap-2 text-on-surface-muted">
              <span
                class="size-4 animate-spin rounded-full border-2 border-outline border-t-primary"
                aria-hidden="true"
              ></span>
              <span i18n="@@orders.loading">Cargando órdenes</span>
            </p>
          }
          @case ('error') {
            <div role="alert" class="flex flex-col items-start gap-2">
              <p>{{ store.listError()?.message }}</p>
              <button
                type="button"
                class="rounded-full bg-placeholder px-4 py-2 text-label-md text-on-placeholder focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus"
                (click)="store.load()"
                i18n="@@orders.retry"
              >
                Reintentar
              </button>
            </div>
          }
          @case ('loaded') {
            <div class="mx-auto grid gap-4 lg:grid-cols-2">
              @for (order of store.orders(); track order.id) {
                <app-order-card [order]="order" />
              }
            </div>
          }
        }
      </div>
    </main>
  `,
})
export class OrdersPageComponent {
  protected readonly store = inject(OrdersStore);

  constructor() {
    this.store.load();
  }
}
